// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/character.dart';
import '../models/life_event.dart';
import '../core/enums.dart';
import '../core/engine.dart';
import '../core/storage.dart';
import '../core/design_system.dart';
import '../widgets/premium_stats_card.dart';
import '../widgets/home_header.dart';
import '../widgets/age_button.dart';
import '../widgets/timeline_section.dart';

import 'assets_page.dart';
import 'activities_page.dart';
import 'relations_page.dart';
import 'legacy_page.dart';
import 'career_page.dart';
import 'create_character_screen.dart';

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

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late ValueNotifier<Character> _characterNotifier;
  late ValueNotifier<List<LifeEvent>> _eventsNotifier;
  Map<String, int>? _currentStatDeltas;
  final ValueNotifier<bool> _isAgingNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _showCriticalFlashNotifier = ValueNotifier(false);
  bool _isScrolling = false;

  // Buffer for the next year's pre-calculated result
  AgeUpResult? _nextYearBuffer;
  bool _isBuffering = false;

  // Strict execution lock for the Age Up simulation
  bool _isExecutingAgeUp = false;
  int _latestExecutionId = 0;

  // Rapid-tap fast-forward: if user taps again while aging, skip delays
  bool _fastForward = false;

  // Active bottom nav tab: 0=Life, 1=Career, 2=Assets, 3=Relations, 4=Activities
  int _currentTabIndex = 0;

  // Event list cap — keeps memory bounded across long sessions
  static const int _kEventCap = 100;

  @override
  void initState() {
    super.initState();
    _characterNotifier = ValueNotifier(widget.initialCharacter);
    _eventsNotifier = ValueNotifier(_loadInitialEvents());

    // Start pre-calculating the first available next year
    _bufferNextYear();
  }

  @override
  void dispose() {
    _characterNotifier.dispose();
    _eventsNotifier.dispose();
    _isAgingNotifier.dispose();
    _showCriticalFlashNotifier.dispose();
    super.dispose();
  }

  List<LifeEvent> _loadInitialEvents() {
    final List<LifeEvent> events = [];
    final savedData = StorageService.loadEvents();
    if (savedData.isNotEmpty) {
      for (var item in savedData) {
        if (item is Map<String, dynamic>) {
          events.add(LifeEvent.fromJson(item));
        }
      }
    } else {
      events.add(LifeEvent(
        title: '🌟 A new life begins!',
        description: 'Welcome to ${widget.initialCharacter.city}, ${widget.initialCharacter.name}.',
        type: LifeEventType.milestone,
        metadata: {'age': 0},
      ));
    }
    return events;
  }

  void _saveEvents() {
    final data = _eventsNotifier.value.map((e) => e.toJson()).toList();
    StorageService.saveEvents(data);
  }

  /// Background pre-calculation of the next year.
  Future<void> _bufferNextYear() async {
    if (_isBuffering || _isExecutingAgeUp || _characterNotifier.value.isDead) return;

    _isBuffering = true;
    try {
      final characterJson = _characterNotifier.value.toJson();
      final resultData = await compute(simulateAgeUp, characterJson);
      if (mounted) {
        _nextYearBuffer = AgeUpResult.fromJson(resultData);
      }
    } catch (e) {
      debugPrint("Simulation buffer error: $e");
    } finally {
      if (mounted) _isBuffering = false;
    }
  }

  Future<void> _handleAgeUp() async {
    if (_characterNotifier.value.isDead) return;
    
    // Strict Execution Lock: Prevent any new trigger while simulation is in progress
    if (_isExecutingAgeUp) {
      // Rapid tap handling: If already aging, enable fast-forward to skip animation delays
      _fastForward = true;
      return;
    }

    _isExecutingAgeUp = true;
    _isAgingNotifier.value = true;
    _fastForward = false;
    
    final int myId = ++_latestExecutionId;

    if (enableLogging) {
      debugPrint("[AGE UP] Execution Started (ID: $myId) for ${_characterNotifier.value.name}");
    }

    AgeUpResult? results;

    // 1. Try to use pre-calculated buffer
    if (_nextYearBuffer != null) {
      if (_nextYearBuffer!.sourceVersion == _characterNotifier.value.stateVersion) {
        results = _nextYearBuffer;
        if (enableLogging) debugPrint("[AGE UP] Using Valid Buffered Result (v${results!.sourceVersion})");
      } else {
        if (enableLogging) {
          debugPrint("[AGE UP] Discarding Stale Buffer (Buffer v${_nextYearBuffer!.sourceVersion} != Current v${_characterNotifier.value.stateVersion})");
        }
      }
      _nextYearBuffer = null;
    } 
    
    // 2. If no valid buffer, run simulation
    if (results == null) {
      try {
        final characterJson = _characterNotifier.value.toJson();
        final int currentVersion = _characterNotifier.value.stateVersion;
        
        final resultData = await compute(simulateAgeUp, characterJson);
        
        // Ownership Check: Did another request start while we were in the isolate?
        if (myId != _latestExecutionId) {
          if (enableLogging) debugPrint("[AGE UP] Discarding Late Isolate Result (ID $myId)");
          return;
        }

        results = AgeUpResult.fromJson(resultData);
        
        // Double-check version match after isolate returns (safety catch for delayed isolates)
        if (results.sourceVersion != currentVersion) {
          debugPrint("[AGE UP] Discarding Stale Isolate Result (v${results.sourceVersion} != current v$currentVersion)");
          _isExecutingAgeUp = false;
          _isAgingNotifier.value = false;
          _handleAgeUp(); // Retry with fresh state
          return;
        }
      } catch (e) {
        debugPrint("Age up isolate error: $e. Falling back to sync simulation.");
        
        // Ownership check before fallback
        if (myId != _latestExecutionId) return;

        try {
          results = GameEngine.ageUp(_characterNotifier.value);
        } catch (innerE) {
          debugPrint("Critical Age up failure: $innerE");
          _isExecutingAgeUp = false;
          _isAgingNotifier.value = false;
          _showErrorSnackBar("Simulation failed. Please try again.");
          return;
        }
      }
    }

    // Double check ownership before handoff
    if (myId != _latestExecutionId) return;

    // 3. Unified Result Pipeline: Hand off for UI and state updates
    await _applyAgeUpResult(results, myId);
  }

  /// The unified result pipeline: Guarantees consistent state updates, 
  /// UI notifications, and persistence regardless of simulation path.
  Future<void> _applyAgeUpResult(AgeUpResult results, int executionId) async {
    if (!mounted) {
      _isExecutingAgeUp = false;
      _isAgingNotifier.value = false;
      return;
    }

    // Ownership Check: Only the latest request is allowed to update the UI
    if (executionId != _latestExecutionId) {
      if (enableLogging) debugPrint("[AGE UP] Discarding Ownership (ID $executionId != $_latestExecutionId)");
      return;
    }

    try {
      final bool hasCritical = results.events.any((e) => e.type == LifeEventType.critical);
      final bool hasRare = results.events.any((e) => e.priority == EventPriority.rare);

      // Haptic signals
      if (hasCritical || hasRare) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.lightImpact();
      }

      // Visual flash for critical events
      if (hasCritical && !_fastForward) {
        _showCriticalFlashNotifier.value = true;
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) _showCriticalFlashNotifier.value = false;
      }

      final List<LifeEvent> displayEvents = [];
      if (results.events.isEmpty) {
        displayEvents.add(LifeEvent(
          title: 'A quiet year…',
          description: 'Nothing significant happened this year.',
          type: LifeEventType.neutral,
          metadata: {'age': results.character.age},
        ));
      } else {
        displayEvents.addAll(results.events);
      }

      // Add personality narrative feedback
      for (var feedback in results.personalityFeedback) {
        displayEvents.insert(0, LifeEvent(
          title: feedback,
          description: 'Your personality is evolving.',
          type: LifeEventType.milestone,
          metadata: {'age': results.character.age, 'isNarrative': true},
        ));
      }

      // ATOMIC STATE UPDATE
      // Replace character state and stat deltas in one cycle
      _characterNotifier.value = results.character;
      _currentStatDeltas = results.statChanges;

      if (enableLogging) {
        debugPrint("[AGE UP] State Applied. Age: ${_characterNotifier.value.age}");
      }

      // Chronological Event Injection (with optional animation delays)
      for (int i = 0; i < displayEvents.length; i++) {
        // Ownership check inside animation loops
        if (executionId != _latestExecutionId) return;

        final newEvents = [displayEvents[i], ..._eventsNotifier.value];
        _eventsNotifier.value = _sanitizeTimeline(newEvents);

        if (!_fastForward && i < displayEvents.length - 1) {
          await Future.delayed(const Duration(milliseconds: 32));
        }
      }

      // ATOMIC PERSISTENCE
      // Ensure save operation always completes after state update
      await StorageService.saveCharacter(_characterNotifier.value);
      _saveEvents();

    } catch (e) {
      debugPrint("[AGE UP] Error during result application: $e");
    } finally {
      // Re-enable Age Up and trigger next buffer
      // Only release the lock if we ARE the latest execution
      if (mounted && executionId == _latestExecutionId) {
        _isExecutingAgeUp = false;
        _isAgingNotifier.value = false;
        _bufferNextYear();
      }
    }
  }

  /// Smart timeline trimming that protects critical milestones and rare narrative chains.
  List<LifeEvent> _sanitizeTimeline(List<LifeEvent> events) {
    if (events.length <= _kEventCap) return events;

    // Protection priority: Critical > Milestone > Rare > Decision > All Else
    final List<LifeEvent> protected = events.where((e) {
      return e.type == LifeEventType.critical || 
             e.type == LifeEventType.milestone || 
             e.priority == EventPriority.critical;
    }).toList();

    final List<LifeEvent> regular = events.where((e) => !protected.contains(e)).toList();

    // Reconstruct list up to cap
    final List<LifeEvent> sanitized = [...protected];
    int remainingSpace = _kEventCap - sanitized.length;
    
    if (remainingSpace > 0) {
      sanitized.addAll(regular.take(remainingSpace));
    } else {
      // If we have TOO MANY protected events, we must keep at least most recent ones
      // but strictly enforce the hard limit of _kEventCap for performance
      return protected.take(_kEventCap).toList();
    }

    return sanitized;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleEventTap(LifeEvent event) {
    // Placeholder for decision events
  }

  void _openProfileSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ProfileSheet(
        character: _characterNotifier.value,
        onLegacyTap: () {
          Navigator.pop(context);
          _navigateTo(page: LegacyPage(character: _characterNotifier.value));
        },
        onNewLife: () async {
          await StorageService.clearAll();
          if (mounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (c, a, s) => const CreateCharacterScreen(),
                transitionDuration: AppMotion.modal,
                transitionsBuilder: (c, a, s, child) =>
                    FadeTransition(opacity: a, child: child),
              ),
            );
          }
        },
      ),
    );
  }

  void _navigateTo({required Widget page}) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a, s) => page,
        transitionDuration: AppMotion.navigation,
        transitionsBuilder: (c, a, s, child) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: AppMotion.appearCurve),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: a, curve: AppMotion.navCurve)),
            child: child,
          ),
        ),
      ),
    ).then((_) {
      // Refresh character state when returning from any secondary screen
      final saved = StorageService.loadCharacter();
      if (mounted) {
        _characterNotifier.value = saved;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: Colors.black,
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Scaffold(
              backgroundColor: AppColors.scaffoldBg,
              body: Stack(
                children: [
                  // ── Tab body (IndexedStack keeps all tabs alive) ──
                  IndexedStack(
                    index: _currentTabIndex,
                    children: [
                      _buildLifeScreen(),
                      ValueListenableBuilder<Character>(
                        valueListenable: _characterNotifier,
                        builder: (_, char, __) => CareerPage(
                          character: char,
                          isTab: true,
                          onBack: () => setState(() => _currentTabIndex = 0),
                        ),
                      ),
                      ValueListenableBuilder<Character>(
                        valueListenable: _characterNotifier,
                        builder: (_, char, __) => AssetsPage(
                          character: char,
                          isTab: true,
                          onBack: () => setState(() => _currentTabIndex = 0),
                        ),
                      ),
                      ValueListenableBuilder<Character>(
                        valueListenable: _characterNotifier,
                        builder: (_, char, __) => RelationsPage(
                          character: char,
                          isTab: true,
                          onBack: () => setState(() => _currentTabIndex = 0),
                        ),
                      ),
                      ValueListenableBuilder<Character>(
                        valueListenable: _characterNotifier,
                        builder: (_, char, __) => ActivitiesPage(
                          character: char,
                          isTab: true,
                          onBack: () => setState(() => _currentTabIndex = 0),
                        ),
                      ),
                    ],
                  ),
                  // Critical flash overlay — only on Life tab
                  if (_currentTabIndex == 0)
                    ValueListenableBuilder<bool>(
                      valueListenable: _showCriticalFlashNotifier,
                      builder: (context, show, _) => show
                          ? Positioned.fill(
                              child: IgnorePointer(
                                child: Container(
                                  color: Colors.red.withValues(alpha: 0.14),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  
                  // Persistent Docked Bottom UI (Nav Bar + FAB)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildDockedBottomUI(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// The Life (Root) Screen — fully scrollable with header, stats, module nav, timeline.
  Widget _buildLifeScreen() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final scrolling = notification is! ScrollEndNotification;
        if (scrolling != _isScrolling) {
          setState(() => _isScrolling = scrolling);
        }
        return false;
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Header
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s16, AppSpacing.s16, 0),
                child: ValueListenableBuilder<Character>(
                  valueListenable: _characterNotifier,
                  builder: (context, character, _) => HomeHeader(
                    character: character,
                    onAvatarTap: _openProfileSheet,
                  ),
                ),
              ),
            ),
          ),

          // 2. Goal Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s8, AppSpacing.s16, 0),
              child: ValueListenableBuilder<Character>(
                valueListenable: _characterNotifier,
                builder: (context, char, _) => _buildGoalBanner(char),
              ),
            ),
          ),

          // 3. Stats Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s16, AppSpacing.s16, 0),
              child: ValueListenableBuilder<Character>(
                valueListenable: _characterNotifier,
                builder: (context, char, _) => PremiumStatsCard(
                  character: char,
                  statDeltas: _currentStatDeltas,
                ),
              ),
            ),
          ),

          // 4. Timeline Header
          SliverToBoxAdapter(child: TimelineSection.buildHeader()),

          // 6. Timeline
          ValueListenableBuilder<List<LifeEvent>>(
            valueListenable: _eventsNotifier,
            builder: (context, events, _) => TimelineSection(
              events: events,
              onEventTap: _handleEventTap,
            ),
          ),

          // Bottom padding for persistent navigation bar
          const SliverToBoxAdapter(
            child: SizedBox(height: 160),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalBanner(Character char) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s8,
      ),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.track_changes_rounded,
            size: 13,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: Text(
              char.suggestedGoal,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Master Docked UI: Layers the Navigation Bar and the AgeButton FAB.
  Widget _buildDockedBottomUI() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: SafeArea(
        top: false,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Layer 1: The Navigation Bar
            _buildBottomNav(),

            // Layer 2: The Centered FAB (Docked)
            Positioned(
              // Refined for ~42% overlap (30px inside / 72px total)
              bottom: 40,
              child: ValueListenableBuilder<bool>(
                valueListenable: _isAgingNotifier,
                builder: (context, bool isAging, _) => AgeButton(
                  onTap: _handleAgeUp,
                  isScrolling: _isScrolling || isAging,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    // Indices for: Career (1), Assets (2), [Space], Relations (3), Activities (4)
    final barItems = [1, 2, -1, 3, 4];
    final icons = {
      1: Icons.school_rounded,
      2: Icons.account_balance_wallet_rounded,
      3: Icons.people_rounded,
      4: Icons.sports_esports_rounded,
    };
    final gradients = {
      1: AppColors.smartsGradient,
      2: AppColors.happyGradient,
      3: AppColors.primaryGradient,
      4: AppColors.healthGradient,
    };

    return Container(
      height: 70, 
      padding: const EdgeInsets.only(top: 8), // Tighter top space
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), // Ultra-soft shadow
            blurRadius: 16,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: barItems.map((idx) {
          if (idx == -1) {
            // Fixed Width Center Space for FAB + Spacing
            return const SizedBox(width: 90);
          }

          final bool isActive = _currentTabIndex == idx;
          final Color activeColor = gradients[idx]!.first;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (_currentTabIndex != idx) {
                  HapticFeedback.selectionClick();
                  setState(() => _currentTabIndex = idx);
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: const EdgeInsets.only(top: 4), // Refined lowered icons
                  decoration: isActive 
                    ? BoxDecoration(
                        color: activeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      )
                    : null,
                  child: Icon(
                    icons[idx],
                    size: 28,
                    color: isActive ? activeColor : AppColors.textMuted.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s12),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),

          // Profile Header Section
          const SizedBox(height: AppSpacing.s12),
          Container(
            padding: const EdgeInsets.all(AppSpacing.s24),
            child: Row(
              children: [
                // Avatar
                Hero(
                  tag: 'avatar-profile',
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.avatarRingGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          character.name[0].toUpperCase(),
                          style: AppTextStyles.h1
                              .copyWith(color: Colors.white, fontSize: 34),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(character.name,
                          style: AppTextStyles.h2.copyWith(fontSize: 24)),
                      const SizedBox(height: 2),
                      Text(
                        character.identityTitle,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '${character.lifeStage.toUpperCase()} · ${character.city}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.s24),
          Divider(color: AppColors.textMuted.withValues(alpha: 0.15), height: 1),

          // Actions
          _SheetAction(
            icon: Icons.history_edu_rounded,
            label: 'Legacy',
            subtitle: 'View your life\'s final story',
            iconColor: AppColors.primaryLight,
            onTap: onLegacyTap,
          ),
          Divider(
            color: AppColors.textMuted.withValues(alpha: 0.1),
            height: 1,
            indent: AppSpacing.s16 + 44 + AppSpacing.s16,
          ),
          _SheetAction(
            icon: Icons.emoji_events_rounded,
            label: 'Achievements',
            subtitle: '${character.achievements.length} earned',
            iconColor: const Color(0xFFF59E0B),
            onTap: () => Navigator.pop(context),
          ),
          Divider(
            color: AppColors.textMuted.withValues(alpha: 0.1),
            height: 1,
            indent: AppSpacing.s16 + 44 + AppSpacing.s16,
          ),
          _SheetAction(
            icon: Icons.refresh_rounded,
            label: 'New Life',
            subtitle: 'Start a fresh journey',
            iconColor: AppColors.alertRed,
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  title: Text('Start New Life?', style: AppTextStyles.h3),
                  content: Text(
                    'This will erase your current progress permanently.',
                    style: AppTextStyles.bodyMedium,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ),
                    TextButton(
                      onPressed: onNewLife,
                      child: Text(
                        'Yes, reset',
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.alertRed),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          SizedBox(
            height: MediaQuery.of(context).padding.bottom + AppSpacing.s16,
          ),
        ],
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const _SheetAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s16,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ),
            const SizedBox(width: AppSpacing.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.bodyBold),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.subtitle.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
