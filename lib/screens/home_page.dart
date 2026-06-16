import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

import '../core/design_system.dart';
import '../core/engine.dart';
import '../core/enums.dart';
import '../core/storage.dart';
import '../models/character.dart';
import '../models/life_event.dart';
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

    // Process events in chronological order
    for (final event in events) {
      if (!mounted || executionId != _latestExecutionId) return;

      // --- ELASTIC PACING CALCULATION ---
      int delayMs = 60; // Default routine speed
      if (event.priority == EventPriority.important) delayMs = 150;
      if (event.type == LifeEventType.milestone) delayMs = 300;
      if (event.priority == EventPriority.critical ||
          event.priority == EventPriority.rare) delayMs = 500;

      if (event.choice != null) {
        // --- DRAMATIC REVEAL ---
        HapticFeedback.mediumImpact();
        _showCriticalFlashNotifier.value = true;
        await Future.delayed(const Duration(milliseconds: 200));
        _showCriticalFlashNotifier.value = false;
        await Future.delayed(
            const Duration(milliseconds: 300)); // Suspense pause

        final choiceResult = await _showDecisionPopup(event.choice!);

        if (choiceResult != null) {
          currentEvents.insert(0, choiceResult);
          _eventsNotifier.value = _sanitizeTimeline(currentEvents);
          _scrollToLatest();
          HapticFeedback.lightImpact();

          // --- SUCCESSIVE CHOICE BUFFER ---
          // Increase emotional processing gap (800ms) to allow timeline to settle
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
      // --- FINAL DEATH FLOW ---
      await Future.delayed(const Duration(milliseconds: 1000)); // Final pause
      _showCriticalFlashNotifier.value = true;
      await Future.delayed(const Duration(milliseconds: 500)); // Fade out start

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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(mainEvent.title, style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
            content: Text(mainEvent.description, style: GoogleFonts.lexend()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continue', style: TextStyle(color: Color(0xFF006D37), fontWeight: FontWeight.bold)),
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

          // Apply effects to character
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

          // Handle GameAction payload (e.g. Unexpected Career Offers)
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

          // Create result event
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
          backgroundColor: AppColors.scaffoldBg,
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: ValueListenableBuilder<Character>(
                      valueListenable: _characterNotifier,
                      builder: (_, character, __) {
                        return ValueListenableBuilder<List<LifeEvent>>(
                          valueListenable: _eventsNotifier,
                          builder: (_, events, __) {
                            return ListView(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.zero,
                              children: [
                                SafeArea(
                                  bottom: false,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: _openProfileSheet,
                                    child: IdentityHeader(
                                      name: character.name,
                                      occupation: character.jobTitle,
                                      balance: character.bankBalance,
                                    ),
                                  ),
                                ),
                                _TimelineList(
                                  events: events,
                                  character: character,
                                ),
                                const SizedBox(
                                    height: 200), // Space for bottom controls
                              ],
                            );
                          },
                        );
                      },
                    ),
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
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ValueListenableBuilder<Character>(
                  valueListenable: _characterNotifier,
                  builder: (_, character, __) {
                    return _BottomLifeControls(
                      character: character,
                      onLife: _scrollToLatest,
                      onActivities: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => ActivitiesPage(
                                  character: character,
                                  onGameAction: _runGameAction))),
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
                      onAge: _handleAgeUp,
                      isAgingListenable: _isAgingNotifier,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LifeStats extends StatelessWidget {
  final Character character;

  const _LifeStats({required this.character});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Column(
        children: [
          StatBar(
              emoji: '😊',
              label: 'Happiness',
              value: character.happiness,
              color: AppColors.happiness),
          StatBar(
              emoji: '❤️',
              label: 'Health',
              value: character.health,
              color: AppColors.health),
          StatBar(
              emoji: '🧠',
              label: 'Smarts',
              value: character.smarts,
              color: AppColors.smarts),
          StatBar(
              emoji: '✨',
              label: 'Looks',
              value: character.looks,
              color: AppColors.looks,
              isLast: true),
        ],
      ),
    );
  }
}

class _TimelineList extends StatelessWidget {
  final List<LifeEvent> events;
  final Character character;

  const _TimelineList({required this.events, required this.character});

  @override
  Widget build(BuildContext context) {
    // Ensure we always have events to show
    final displayEvents = events.isEmpty
        ? [
            LifeEvent(
              title: 'Born',
              description: '${character.name} was born in ${character.city}.',
              type: LifeEventType.milestone,
              metadata: {'age': 0},
            )
          ]
        : events;

    // Group events by age
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

    // Sort ages descending to match chronological reversed order (newest first)
    sortedAges.sort((a, b) => b.compareTo(a));

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final age in sortedAges) ...[
            _AgeGroupHeader(age: age),
            for (final event in groupedEvents[age]!) _TimelineRow(event: event),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _AgeGroupHeader extends StatelessWidget {
  final int age;
  const _AgeGroupHeader({required this.age});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        'Age $age',
        style: AppTextStyles.rowTitle.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final LifeEvent event;

  const _TimelineRow({required this.event});

  static Color _dotColor(LifeEvent e) {
    switch (e.type) {
      case LifeEventType.positive:
        return AppColors.success; // Green
      case LifeEventType.negative:
      case LifeEventType.critical:
        return AppColors.danger; // Red
      case LifeEventType.milestone:
      case LifeEventType.rare:
        return AppColors.smarts; // Blue (Special)
      default:
        return AppColors.textMuted; // Grey (Normal)
    }
  }

  @override
  Widget build(BuildContext context) {
    final desc = cleanText(event.description);
    final title = cleanText(event.title);
    final bool isImportant = event.priority == EventPriority.important ||
        event.priority == EventPriority.critical ||
        event.priority == EventPriority.rare ||
        event.type == LifeEventType.milestone;

    return Padding(
      padding:
          EdgeInsets.fromLTRB(28, isImportant ? 6 : 2, 16, isImportant ? 6 : 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: isImportant ? 7 : 5),
            width: isImportant ? 6 : 4,
            height: isImportant ? 6 : 4,
            decoration: BoxDecoration(
              color: _dotColor(event),
              shape: BoxShape.circle,
              boxShadow: isImportant
                  ? [
                      BoxShadow(
                        color: _dotColor(event).withValues(alpha: 0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              desc.isNotEmpty ? desc : title,
              style: AppTextStyles.rowSubtitle.copyWith(
                fontSize: isImportant ? 11.5 : 10,
                color:
                    isImportant ? AppColors.textPrimary : AppColors.textPrimary,
                height: 1.3,
                fontWeight: isImportant ? FontWeight.w800 : FontWeight.w500,
                letterSpacing: isImportant ? 0.1 : 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomLifeControls extends StatelessWidget {
  final Character character;
  final VoidCallback onLife;
  final VoidCallback onActivities;
  final VoidCallback onCareer;
  final VoidCallback onFinance;
  final VoidCallback onPeople;
  final VoidCallback onAge;
  final ValueListenable<bool> isAgingListenable;

  const _BottomLifeControls({
    required this.character,
    required this.onLife,
    required this.onActivities,
    required this.onCareer,
    required this.onFinance,
    required this.onPeople,
    required this.onAge,
    required this.isAgingListenable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border:
            Border(top: BorderSide(color: AppColors.dividerLight, width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LifeStats(character: character),
          // Age Up button
          ValueListenableBuilder<bool>(
            valueListenable: isAgingListenable,
            builder: (_, isAging, __) =>
                _AgeUpButton(isAging: isAging, onTap: onAge),
          ),
          // Nav bar
          SafeArea(
            top: false,
            child: Container(
              height: 50,
              color: Colors.white,
              child: Row(
                children: [
                  _NavTab(
                      icon: Icons.work_outline_rounded,
                      label: 'Career',
                      onTap: onCareer),
                  _NavTab(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Finance',
                      onTap: onFinance),
                  _NavTab(
                      icon: Icons.touch_app_outlined,
                      label: 'Activities',
                      onTap: onActivities),
                  _NavTab(
                      icon: Icons.people_outline_rounded,
                      label: 'People',
                      onTap: onPeople),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgeUpButton extends StatefulWidget {
  final bool isAging;
  final VoidCallback onTap;
  const _AgeUpButton({required this.isAging, required this.onTap});

  @override
  State<_AgeUpButton> createState() => _AgeUpButtonState();
}

class _AgeUpButtonState extends State<_AgeUpButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        setState(() => _pressed = true);
        HapticFeedback.lightImpact();
      },
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: AppMotion.tap,
        child: Container(
          height: 36,
          margin: const EdgeInsets.fromLTRB(12, 2, 12, 4),
          decoration: BoxDecoration(
            color: AppColors.success,
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: widget.isAging
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.0, color: Colors.white),
                )
              : Text(
                  'AGE +',
                  style: AppTextStyles.rowTitle.copyWith(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavTab({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 2),
              Text(
                label.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  fontSize: 9,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
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
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.dividerLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(character.name, style: AppTextStyles.pageTitle),
          Text('Born in ${character.city}', style: AppTextStyles.pageSubtitle),
          const SizedBox(height: 24),
          RowGroup(
            rows: [
              GameRow(
                icon: Icons.history_edu_rounded,
                title: 'Journal',
                subtitle: 'View your life summary',
                onTap: onLegacyTap,
              ),
              GameRow(
                icon: Icons.restart_alt_rounded,
                title: 'New Life',
                subtitle: 'Start over from scratch',
                onTap: onNewLife,
              ),
            ],
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              choice.title,
              textAlign: TextAlign.center,
              style: AppTextStyles.pageTitle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              choice.description,
              textAlign: TextAlign.center,
              style: AppTextStyles.rowSubtitle.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 24),
            _DecisionButton(
              label: choice.optionA,
              onTap: () => onChosen(true),
            ),
            const SizedBox(height: 8),
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
          backgroundColor: const Color(0xFFF2F2F7),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: AppTextStyles.rowTitle.copyWith(
            color: AppColors.info,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
