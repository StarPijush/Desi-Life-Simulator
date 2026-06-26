import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

import '../core/design_system.dart';
import '../core/engine.dart';
import '../core/enums.dart';
import '../core/storage.dart';
import '../models/character.dart';
import '../models/life_event.dart';
import '../widgets/game/game_card.dart';

import 'create_character_screen.dart';
import 'legacy_page.dart';
import 'career_page.dart';
import 'activities_page.dart';
import 'finance/finance_page.dart';
import 'people/people_page.dart';
import '../models/event_choice.dart';
import '../widgets/events/event_card.dart';
import '../widgets/events/event_types.dart';

typedef LifeAction = ActionResult Function(Character character);

class HomePage extends StatefulWidget {
  final Character initialCharacter;
  final bool isNewLife;

  const HomePage({
    super.key,
    required this.initialCharacter,
    this.isNewLife = false,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ValueNotifier<Character> _characterNotifier;
  late ValueNotifier<List<LifeEvent>> _eventsNotifier;
  final ValueNotifier<bool> _isAgingNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _showCriticalFlashNotifier = ValueNotifier(false);
  final ScrollController _scrollController = ScrollController();

  bool _isExecutingAgeUp = false;
  bool _fastForward = false;
  int _latestExecutionId = 0;

  static const int _eventCap = 120;

  @override
  void initState() {
    super.initState();
    _characterNotifier = ValueNotifier(widget.initialCharacter);
    _eventsNotifier = ValueNotifier(_loadInitialEvents());
  }

  @override
  void dispose() {
    _characterNotifier.dispose();
    _eventsNotifier.dispose();
    _isAgingNotifier.dispose();
    _showCriticalFlashNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<LifeEvent> _loadInitialEvents() {
    final saved = StorageService.loadEvents();
    final events = <LifeEvent>[];

    for (final item in saved) {
      if (item is Map<String, dynamic>) {
        events.add(LifeEvent.fromJson(item));
      }
    }

    if (events.isEmpty) {
      events.add(
        LifeEvent(
          title: 'A new life begins',
          description:
              '${widget.initialCharacter.name} was born in ${widget.initialCharacter.city}.',
          type: LifeEventType.milestone,
          metadata: {'age': widget.initialCharacter.age},
        ),
      );
    }

    return _sanitizeTimeline(events);
  }

  void _saveEvents() {
    StorageService.saveEvents(
      _eventsNotifier.value.map((event) => event.toJson()).toList(),
    );
  }

  Future<void> _handleAgeUp() async {
    if (_characterNotifier.value.isDead) return;

    if (_isExecutingAgeUp) {
      _fastForward = true;
      return;
    }

    _isExecutingAgeUp = true;
    _isAgingNotifier.value = true;
    _fastForward = false;
    final executionId = ++_latestExecutionId;

    try {
      final result = GameEngine.ageUp(_characterNotifier.value.copyWith());
      if (executionId != _latestExecutionId) return;
      await _applyAgeUpResult(result, executionId);
    } catch (error) {
      debugPrint('[AGE UP] $error');
    } finally {
      if (mounted && executionId == _latestExecutionId) {
        _isExecutingAgeUp = false;
        _isAgingNotifier.value = false;
      }
    }
  }

  Future<void> _applyAgeUpResult(AgeUpResult result, int executionId) async {
    final currentVersion = _characterNotifier.value.stateVersion;
    final updatedCharacter = result.character.copyWith(
      stateVersion: result.character.stateVersion <= currentVersion
          ? currentVersion + 1
          : result.character.stateVersion,
    );

    final events = _normalizeAgeUpEvents(result);
    final currentEvents = List<LifeEvent>.from(_eventsNotifier.value);

    for (final event in events) {
      if (!mounted || executionId != _latestExecutionId) return;

      int delayMs = 60;
      if (event.priority == EventPriority.important) delayMs = 150;
      if (event.type == LifeEventType.milestone) delayMs = 300;
      if (event.priority == EventPriority.critical ||
          event.priority == EventPriority.rare) delayMs = 500;

      if (event.choice != null) {
        HapticFeedback.mediumImpact();
        _showCriticalFlashNotifier.value = true;
        await Future.delayed(const Duration(milliseconds: 200));
        _showCriticalFlashNotifier.value = false;
        await Future.delayed(const Duration(milliseconds: 300));

        final choiceResult = await _showDecisionPopup(event.choice!);

        if (choiceResult != null) {
          currentEvents.insert(0, choiceResult);
          _eventsNotifier.value = _sanitizeTimeline(currentEvents);
          _scrollToLatest();
          HapticFeedback.lightImpact();
          await Future.delayed(const Duration(milliseconds: 800));
        }
      } else {
        currentEvents.insert(0, event);
        _eventsNotifier.value = _sanitizeTimeline(currentEvents);
        _scrollToLatest();

        if (event.type == LifeEventType.negative ||
            event.priority == EventPriority.critical) {
          HapticFeedback.mediumImpact();
        } else {
          HapticFeedback.lightImpact();
        }

        if (event.priority == EventPriority.critical ||
            event.type == LifeEventType.critical ||
            event.priority == EventPriority.rare) {
          _showCriticalFlashNotifier.value = true;
          await Future.delayed(const Duration(milliseconds: 100));
          _showCriticalFlashNotifier.value = false;
        }
      }

      if (!_fastForward) {
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }

    _characterNotifier.value = updatedCharacter;
    await StorageService.saveCharacter(updatedCharacter);
    _saveEvents();

    if (updatedCharacter.isDead && mounted) {
      await Future.delayed(const Duration(milliseconds: 1000));
      _showCriticalFlashNotifier.value = true;
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                FadeTransition(
              opacity: animation,
              child: LegacyPage(character: updatedCharacter),
            ),
            transitionDuration: const Duration(milliseconds: 1200),
          ),
        );
      }
    }
  }

  List<LifeEvent> _normalizeAgeUpEvents(AgeUpResult result) {
    final events = List<LifeEvent>.from(result.events);

    for (final feedback in result.personalityFeedback.reversed) {
      events.insert(
        0,
        LifeEvent(
          title: feedback,
          description: 'Your personality shifted this year.',
          type: LifeEventType.milestone,
          metadata: {'age': result.character.age},
        ),
      );
    }

    if (events.isEmpty) {
      events.add(
        LifeEvent(
          title: 'Age ${result.character.age}',
          description: 'A quiet year passed in ${result.character.city}.',
          type: LifeEventType.neutral,
          metadata: {'age': result.character.age},
        ),
      );
    }

    return events;
  }

  void _runGameAction(GameAction action) {
    _applyActionResult(
      GameEngine.processAction(_characterNotifier.value, action),
      showResultPopup: action.payload['hidePopup'] != true,
    );
  }

  void _runLifeAction(LifeAction action) {
    _applyActionResult(action(_characterNotifier.value));
  }

  void _applyActionResult(ActionResult result, {bool showResultPopup = true}) {
    final currentVersion = _characterNotifier.value.stateVersion;
    final updatedCharacter = result.character.copyWith(
      stateVersion: result.character.stateVersion <= currentVersion
          ? currentVersion + 1
          : result.character.stateVersion,
    );

    final actionEvents = result.events.isEmpty
        ? [
            LifeEvent(
              title: result.success ? 'Action complete' : 'Action failed',
              description: result.message,
              type: result.success
                  ? LifeEventType.neutral
                  : LifeEventType.negative,
              metadata: {'age': updatedCharacter.age},
            ),
          ]
        : result.events;

    final rawActionEvents = actionEvents;

    _characterNotifier.value = updatedCharacter;
    _eventsNotifier.value = _sanitizeTimeline([
      ...actionEvents,
      ..._eventsNotifier.value,
    ]);

    HapticFeedback.lightImpact();
    _scrollToLatest();
    StorageService.saveCharacter(updatedCharacter);
    _saveEvents();

    if (showResultPopup && mounted && rawActionEvents.isNotEmpty) {
      final mainEvent = rawActionEvents.cast<LifeEvent?>().firstWhere(
        (e) => e is ActionEvent,
        orElse: () => rawActionEvents.first,
      );
      final popupAllowed = mainEvent?.metadata['popupAllowed'] != false;

      if (mainEvent is ActionEvent && popupAllowed) {
        showEventCard(
          context: context,
          category: mainEvent.category,
          mode: mainEvent.mode,
          title: mainEvent.title,
          description: mainEvent.description,
          infoRows: mainEvent.infoRows,
          requirements: mainEvent.requirements,
          illustration: mainEvent.emojiIllustration != null 
              ? EventIllustration.emoji(mainEvent.emojiIllustration!)
              : null,
        );
      } else if (mainEvent != null && popupAllowed) {
        showDialog(
          context: context,
          useRootNavigator: true,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppBorderRadius.xl)),
            title: Text(mainEvent.title, style: AppTextStyles.labelBold.copyWith(fontSize: 16)),
            content: Text(mainEvent.description, style: AppTextStyles.bodyMd),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Continue', style: AppTextStyles.labelBold.copyWith(color: AppColors.primary)),
              ),
            ],
          ),
        );
      }
    }
  }

  void _scrollToLatest() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
    );
  }

  Future<LifeEvent?> _showDecisionPopup(EventChoice choice) async {
    if (!mounted) return null;
    return showDialog<LifeEvent>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (context) => _DecisionModal(
        choice: choice,
        onChosen: (isOptionA) {
          final double roll = Random().nextDouble();
          final bool isSuccess = isOptionA
              ? roll < choice.successChanceA
              : roll < choice.successChanceB;

          final effect = isOptionA
              ? (isSuccess
                  ? choice.effectA
                  : (choice.effectAFail ?? choice.effectA))
              : (isSuccess
                  ? choice.effectB
                  : (choice.effectBFail ?? choice.effectB));

          final result = isOptionA
              ? (isSuccess
                  ? choice.resultA
                  : (choice.resultAFail ?? choice.resultA))
              : (isSuccess
                  ? choice.resultB
                  : (choice.resultBFail ?? choice.resultB));

          final memoryFlag = isOptionA
              ? (isSuccess ? choice.memoryFlagA : choice.memoryFlagAFail)
              : (isSuccess ? choice.memoryFlagB : choice.memoryFlagBFail);

          final traitShifts =
              isOptionA ? choice.traitShiftsA : choice.traitShiftsB;

          final current = _characterNotifier.value;
          final updated = current.copyWith(
            happiness:
                (current.happiness + effect.happiness).clamp(0, 100).toInt(),
            health: (current.health + effect.health).clamp(0, 100).toInt(),
            smarts: (current.smarts + effect.smarts).clamp(0, 100).toInt(),
            social: (current.social + effect.social).clamp(0, 100).toInt(),
            karma: (current.karma + effect.karma).clamp(0, 100).toInt(),
            stressLevel: (current.stressLevel + (isSuccess ? 0 : 15))
                .clamp(0, 100)
                .toInt(),
            bankBalance: current.bankBalance + effect.money,
          );

          if (memoryFlag != null) {
            updated.memories[memoryFlag] = true;
          }

          if (traitShifts != null) {
            traitShifts.forEach((trait, delta) {
              updated.shiftPersonality(trait, delta);
            });
          }

          updated.triggerMutation();
          _characterNotifier.value = updated;
          StorageService.saveCharacter(updated);

          final actionToRun = isOptionA ? choice.gameActionA : choice.gameActionB;
          if (actionToRun != null && isSuccess) {
            final actionResult = GameEngine.processAction(
                _characterNotifier.value,
                GameAction('career.perform', {'actionId': actionToRun})
            );
            if (actionResult.success) {
               _characterNotifier.value = actionResult.character;
               StorageService.saveCharacter(_characterNotifier.value);
            }
          }

          String statHint = '';
          if (effect.happiness != 0)
            statHint +=
                ' Happiness ${effect.happiness > 0 ? '+' : ''}${effect.happiness}';
          if (effect.money != 0)
            statHint +=
                ' Money ${effect.money > 0 ? '+' : ''}${effect.money.toInt()}';
          if (!isSuccess) statHint += ' (FAIL)';

          Navigator.of(context).pop(LifeEvent(
            title: isOptionA ? choice.optionA : choice.optionB,
            description: result + (statHint.isNotEmpty ? ' ($statHint)' : ''),
            type: isSuccess ? LifeEventType.positive : LifeEventType.negative,
            metadata: {
              'age': current.age,
              'outcome': isSuccess ? 'success' : 'failure',
            },
          ));
        },
      ),
    );
  }

  List<LifeEvent> _sanitizeTimeline(List<LifeEvent> events) {
    if (events.isEmpty) return _loadInitialEvents();
    return List<LifeEvent>.from(events.take(_eventCap));
  }

  void _openProfileSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProfileSheet(
        character: _characterNotifier.value,
        onLegacyTap: () {
          Navigator.pop(context);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LegacyPage(character: _characterNotifier.value),
            ),
          );
        },
        onNewLife: () async {
          final navigator = Navigator.of(context);
          try {
            await StorageService.clearAll();
          } catch (e) {
            print("⚠️ Error during new life storage clear: $e");
          }
          if (mounted) {
            navigator.pushReplacement(
              MaterialPageRoute(builder: (_) => const CreateCharacterScreen()),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Scaffold(
          backgroundColor: AppColors.slate50,
          body: Stack(
            children: [
              Column(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _openProfileSheet,
                    child: SafeArea(
                      bottom: false,
                      child: ValueListenableBuilder<Character>(
                        valueListenable: _characterNotifier,
                        builder: (_, character, __) =>
                            _HtmlHeader(character: character),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ValueListenableBuilder<Character>(
                      valueListenable: _characterNotifier,
                      builder: (_, character, __) {
                        return ValueListenableBuilder<List<LifeEvent>>(
                          valueListenable: _eventsNotifier,
                          builder: (_, events, __) {
                            return _HtmlTimeline(
                              events: events,
                              character: character,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  ValueListenableBuilder<Character>(
                    valueListenable: _characterNotifier,
                    builder: (_, character, __) =>
                        _HtmlStats(character: character),
                  ),
                  ValueListenableBuilder<Character>(
                    valueListenable: _characterNotifier,
                    builder: (_, character, __) {
                      return _HtmlBottomNav(
                        onCareer: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => CareerPage(
                                    character: character,
                                    onGameAction: _runGameAction,
                                    onLifeAction: _runLifeAction))),
                        onFinance: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => FinancePage(
                                    character: character,
                                    onGameAction: _runGameAction))),
                        onPeople: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => PeoplePage(
                                    character: character,
                                    onGameAction: _runGameAction))),
                        onActivities: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => ActivitiesPage(
                                    character: character,
                                    onGameAction: _runGameAction))),
                        onAge: _handleAgeUp,
                        isAgingListenable: _isAgingNotifier,
                      );
                    },
                  ),
                ],
              ),
              Positioned.fill(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _showCriticalFlashNotifier,
                  builder: (_, show, __) => AnimatedOpacity(
                    opacity: show ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 100),
                    child: IgnorePointer(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HtmlHeader extends StatelessWidget {
  final Character character;
  const _HtmlHeader({required this.character});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.slate200, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  character.name,
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Age ${character.age} \u2022 Student',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.slate500,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.sky50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Current Milestone: High School',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.sky700,
                      letterSpacing: 0.5,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatMoney(character.bankBalance),
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green600,
                  height: 1.2,
                ),
              ),
              Text(
                'Bank Balance',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate400,
                  letterSpacing: 0.5,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HtmlTimeline extends StatelessWidget {
  final List<LifeEvent> events;
  final Character character;

  const _HtmlTimeline({required this.events, required this.character});

  @override
  Widget build(BuildContext context) {
    final displayEvents = events.isEmpty
        ? [
            LifeEvent(
              title: 'Born',
              description:
                  '${character.name} was born in ${character.city}.',
              type: LifeEventType.milestone,
              metadata: {'age': 0},
            )
          ]
        : events.reversed.toList();

    final Map<int, List<LifeEvent>> groupedEvents = {};
    final List<int> sortedAges = [];

    for (final event in displayEvents) {
      final age = event.metadata['age'] ?? 0;
      if (!groupedEvents.containsKey(age)) {
        groupedEvents[age] = [];
        sortedAges.add(age);
      }
      groupedEvents[age]!.add(event);
    }

    sortedAges.sort((a, b) => b.compareTo(a));

    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        children: [
          for (final age in sortedAges) ...[
            Text(
              'Age: $age years',
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.darkNavy,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            for (final event in groupedEvents[age]!) ...[
              Text(
                event.description.isNotEmpty
                    ? event.description
                    : event.title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.journalText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _HtmlStats extends StatelessWidget {
  final Character character;
  const _HtmlStats({required this.character});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.slate50,
        border: Border(
          top: BorderSide(color: AppColors.slate200, width: 1),
        ),
      ),
      child: Column(
        children: [
          _StatRow(
              label: 'Happiness',
              value: character.happiness.toDouble(),
              color: AppColors.green500),
          const SizedBox(height: 8),
          _StatRow(
              label: 'Health',
              value: character.health.toDouble(),
              color: AppColors.emerald500),
          const SizedBox(height: 8),
          _StatRow(
              label: 'Smarts',
              value: character.smarts.toDouble(),
              color: AppColors.amber500),
          const SizedBox(height: 8),
          _StatRow(
              label: 'Looks',
              value: character.looks.toDouble(),
              color: AppColors.slate400),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.sky900,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.slate200,
              borderRadius: BorderRadius.circular(99),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (value.clamp(0, 100)) / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 32,
          child: Text(
            '${value.round()}%',
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.sky900,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _HtmlBottomNav extends StatelessWidget {
  final VoidCallback onCareer;
  final VoidCallback onFinance;
  final VoidCallback onPeople;
  final VoidCallback onActivities;
  final VoidCallback onAge;
  final ValueListenable<bool> isAgingListenable;

  const _HtmlBottomNav({
    required this.onCareer,
    required this.onFinance,
    required this.onPeople,
    required this.onActivities,
    required this.onAge,
    required this.isAgingListenable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.green500,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _NavItem(
                          icon: Icons.work_outline,
                          label: 'Career',
                          onTap: onCareer)),
                    Expanded(
                      child: _NavItem(
                          icon: Icons.payments_outlined,
                          label: 'Finance',
                          onTap: onFinance)),
                    const SizedBox(width: 84),
                    Expanded(
                      child: _NavItem(
                          icon: Icons.favorite_outline,
                          label: 'People',
                          onTap: onPeople)),
                    Expanded(
                      child: _NavItem(
                          icon: Icons.grid_view_outlined,
                          label: 'Activities',
                          onTap: onActivities)),
                  ],
                ),
              ),
              Positioned(
                top: -42,
                left: 0,
                right: 0,
                child: Center(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: isAgingListenable,
                    builder: (_, isAging, __) =>
                        _AgeButton(isAging: isAging, onTap: onAge),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgeButton extends StatefulWidget {
  final bool isAging;
  final VoidCallback onTap;
  const _AgeButton({required this.isAging, required this.onTap});

  @override
  State<_AgeButton> createState() => _AgeButtonState();
}

class _AgeButtonState extends State<_AgeButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: AppColors.green500,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: AppShadows.ageButton,
          ),
          child: widget.isAging
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add,
                      size: 36,
                      color: Colors.white,
                    ),
                    Text(
                      'AGE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: Colors.white),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSheet extends StatelessWidget {
  final Character character;
  final VoidCallback onLegacyTap;
  final VoidCallback onNewLife;

  const _ProfileSheet({
    required this.character,
    required this.onLegacyTap,
    required this.onNewLife,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppBorderRadius.md)),
      ),
      padding: const EdgeInsets.fromLTRB(AppSpacing.containerPadding, 20, AppSpacing.containerPadding, AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.dividerLight,
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(character.name, style: AppTextStyles.displayLg),
          Text('Born in ${character.city}', style: AppTextStyles.pageSubtitle),
          const SizedBox(height: AppSpacing.lg),
          GameCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                InkWell(
                  onTap: onLegacyTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.containerPadding,
                      vertical: AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.history_edu_rounded, color: AppColors.primary, size: 24),
                        const SizedBox(width: AppSpacing.cardGap),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Journal', style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w700)),
                              Text('View your life summary', style: AppTextStyles.labelSm),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.outline),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1, color: AppColors.divider, indent: AppSpacing.containerPadding + 24 + AppSpacing.cardGap),
                InkWell(
                  onTap: onNewLife,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.containerPadding,
                      vertical: AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.restart_alt_rounded, color: AppColors.error, size: 24),
                        const SizedBox(width: AppSpacing.cardGap),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('New Life', style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w700)),
                              Text('Start over from scratch', style: AppTextStyles.labelSm),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.outline),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DecisionModal extends StatelessWidget {
  final EventChoice choice;
  final Function(bool) onChosen;

  const _DecisionModal({required this.choice, required this.onChosen});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppBorderRadius.xl)),
      elevation: 0,
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              choice.title,
              textAlign: TextAlign.center,
              style: AppTextStyles.displayMd.copyWith(fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.cardGap),
            Text(
              choice.description,
              textAlign: TextAlign.center,
              style: AppTextStyles.rowSubtitle.copyWith(fontSize: 12),
            ),
            const SizedBox(height: AppSpacing.lg),
            _DecisionButton(
              label: choice.optionA,
              onTap: () => onChosen(true),
            ),
            const SizedBox(height: AppSpacing.sm),
            _DecisionButton(
              label: choice.optionB,
              onTap: () => onChosen(false),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecisionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DecisionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        style: TextButton.styleFrom(
          backgroundColor: AppColors.iconBg,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.cardGap),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppBorderRadius.sm)),
        ),
        child: Text(
          label,
          style: AppTextStyles.rowTitle.copyWith(
            color: AppColors.primary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
