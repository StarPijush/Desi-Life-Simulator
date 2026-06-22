import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/design_system.dart';
import '../../../models/character.dart';
import '../../../widgets/game/game_card.dart';
import '../../../widgets/game/action_tile.dart';
import '../../../widgets/game/timeline_tile.dart';
import '../../../widgets/game/status_chip.dart';
import '../../../widgets/game/stats_section.dart';
import 'widgets/military_header.dart';

class MilitaryScreen extends StatelessWidget {
  final Character character;
  final VoidCallback onTrainPhysically;
  final VoidCallback onWeaponsPractice;
  final VoidCallback onLeadershipTraining;
  final VoidCallback onPromotionExam;
  final VoidCallback onSpecialForcesSelection;
  final VoidCallback? onBack;
  final VoidCallback? onMore;

  const MilitaryScreen({
    super.key,
    required this.character,
    required this.onTrainPhysically,
    required this.onWeaponsPractice,
    required this.onLeadershipTraining,
    required this.onPromotionExam,
    required this.onSpecialForcesSelection,
    this.onBack,
    this.onMore,
  });

  static const List<String> _rankNames = [
    'Recruit',
    'Cadet',
    'Lieutenant',
    'Captain',
    'Major',
    'Colonel',
    'Brigadier',
    'General',
  ];

  @override
  Widget build(BuildContext context) {
    final activeRankIndex = _activeRankIndex;
    final currentRank = _rankNames[activeRankIndex];
    final promotionScore = _promotionScore;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            MilitaryHeader(onBack: onBack, onMore: onMore),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.containerPadding,
                  AppSpacing.md,
                  AppSpacing.containerPadding,
                  AppSpacing.lg,
                ),
                children: [
                  _ActiveDutyCard(
                    name: character.name,
                    rank: currentRank,
                    monthlyPay: character.annualIncome / 12,
                    yearsServed: _yearsServed,
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                  _ServiceRecordCard(
                    fitness: character.health,
                    discipline: character.discipline,
                    leadership: _leadership,
                    deployments: _deployments,
                    medals: _medals,
                    promotionScore: promotionScore,
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                  _ActionsCard(
                    promotionScore: promotionScore,
                    isEnlisted: character.careerGroup == 'Military',
                    onTrainPhysically: onTrainPhysically,
                    onWeaponsPractice: onWeaponsPractice,
                    onLeadershipTraining: onLeadershipTraining,
                    onPromotionExam: onPromotionExam,
                    onSpecialForcesSelection: onSpecialForcesSelection,
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                  _RankProgressionCard(
                    ranks: _rankProgress(activeRankIndex),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int get _activeRankIndex {
    final careerIndex = max(character.careerStep, character.jobLevel);
    return careerIndex.clamp(0, _rankNames.length - 1).toInt();
  }

  int get _yearsServed {
    return max(character.yearsInJob, character.yearsInRole)
        .clamp(0, 99)
        .toInt();
  }

  int get _leadership {
    final combined =
        ((character.reputation * 0.6) + (character.ambition * 0.4)).round();
    return combined.clamp(0, 100).toInt();
  }

  int get _promotionScore {
    final score = ((character.jobPerformance * 0.45) +
            (character.discipline * 0.25) +
            (character.health * 0.15) +
            (_leadership * 0.15))
        .round();
    return score.clamp(0, 100).toInt();
  }

  int get _deployments {
    final historyCount = character.eventHistory.keys
        .where((key) => key.toLowerCase().contains('deployment'))
        .length;
    final memoryCount = character.memories.keys
        .where((key) => key.toLowerCase().contains('deployment'))
        .length;
    final achievementCount = character.achievements
        .where(
            (achievement) => achievement.toLowerCase().contains('deployment'))
        .length;
    return max(historyCount, max(memoryCount, achievementCount));
  }

  int get _medals {
    final achievementCount = character.achievements
        .where((achievement) => achievement.toLowerCase().contains('medal'))
        .length;
    final memoryCount = character.memories.keys
        .where((key) => key.toLowerCase().contains('medal'))
        .length;
    return max(achievementCount, memoryCount);
  }

  List<_RankEntry> _rankProgress(int activeRankIndex) {
    return [
      for (int i = 0; i < _rankNames.length; i++)
        _RankEntry(
          rank: _rankNames[i],
          state: i < activeRankIndex
              ? TimelineState.completed
              : i == activeRankIndex
                  ? TimelineState.active
                  : TimelineState.locked,
          status: i < activeRankIndex
              ? 'Completed'
              : i == activeRankIndex
                  ? 'Active'
                  : i == activeRankIndex + 1
                      ? 'Next'
                      : null,
        ),
    ];
  }
}

class _RankEntry {
  final String rank;
  final TimelineState state;
  final String? status;
  const _RankEntry({
    required this.rank,
    required this.state,
    this.status,
  });
}

class _ActiveDutyCard extends StatelessWidget {
  final String name;
  final String rank;
  final double monthlyPay;
  final int yearsServed;

  const _ActiveDutyCard({
    required this.name,
    required this.rank,
    required this.monthlyPay,
    required this.yearsServed,
  });

  @override
  Widget build(BuildContext context) {
    return GameCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ACTIVE DUTY',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.displayMd.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      rank.toUpperCase(),
                      style: AppTextStyles.labelBold.copyWith(
                        fontSize: 10,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const StatusChip(label: 'MILITARY', color: Color(0xFF1B5E20)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatMoney(monthlyPay),
                style: AppTextStyles.displayMd.copyWith(fontSize: 16),
              ),
              const Text(
                'MONTHLY PAY',
                style: TextStyle(fontSize: 8, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                '$yearsServed ${yearsServed == 1 ? 'YEAR' : 'YEARS'} SERVED',
                style: const TextStyle(fontSize: 8, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceRecordCard extends StatelessWidget {
  final int fitness;
  final int discipline;
  final int leadership;
  final int deployments;
  final int medals;
  final int promotionScore;

  const _ServiceRecordCard({
    required this.fitness,
    required this.discipline,
    required this.leadership,
    required this.deployments,
    required this.medals,
    required this.promotionScore,
  });

  @override
  Widget build(BuildContext context) {
    return StatsSection(
      title: 'Service Record',
      stats: [
        StatItem(label: 'Fitness', value: fitness.toDouble(), color: AppColors.primary),
        StatItem(label: 'Discipline', value: discipline.toDouble()),
        StatItem(label: 'Leadership', value: leadership.toDouble(), color: AppColors.primary),
        StatItem(
          label: 'Promotion Score',
          value: promotionScore.toDouble(),
          barHeight: 12,
          color: promotionScore >= 70
              ? AppColors.primary
              : promotionScore >= 40
                  ? AppColors.warning
                  : AppColors.error,
        ),
      ],
    );
  }
}

class _ActionsCard extends StatelessWidget {
  final bool isEnlisted;
  final int promotionScore;
  final VoidCallback onTrainPhysically;
  final VoidCallback onWeaponsPractice;
  final VoidCallback onLeadershipTraining;
  final VoidCallback onPromotionExam;
  final VoidCallback onSpecialForcesSelection;

  const _ActionsCard({
    required this.isEnlisted,
    required this.promotionScore,
    required this.onTrainPhysically,
    required this.onWeaponsPractice,
    required this.onLeadershipTraining,
    required this.onPromotionExam,
    required this.onSpecialForcesSelection,
  });

  @override
  Widget build(BuildContext context) {
    return GameCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACTIONS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.3,
            children: [
              ActionTile(
                emoji: '💪',
                label: 'Train Physically',
                rewards: const [ActionReward('+Fit', AppColors.primary)],
                onTap: onTrainPhysically,
              ),
              ActionTile(
                emoji: '🎯',
                label: 'Weapons Practice',
                rewards: const [ActionReward('+Disc', AppColors.primary)],
                onTap: onWeaponsPractice,
              ),
              ActionTile(
                emoji: '📋',
                label: 'Leadership Training',
                rewards: const [ActionReward('+Lead', AppColors.primary)],
                onTap: onLeadershipTraining,
              ),
              ActionTile(
                emoji: '📝',
                label: 'Promotion Exam',
                locked: promotionScore < 40,
                rewards: const [ActionReward('+Rank', AppColors.primary)],
                onTap: promotionScore >= 40 ? onPromotionExam : null,
              ),
              ActionTile(
                emoji: '⭐',
                label: 'Special Forces',
                locked: promotionScore < 70,
                rewards: const [ActionReward('Elite', AppColors.warning)],
                onTap: promotionScore >= 70 ? onSpecialForcesSelection : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RankProgressionCard extends StatelessWidget {
  final List<_RankEntry> ranks;

  const _RankProgressionCard({required this.ranks});

  @override
  Widget build(BuildContext context) {
    return GameCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RANK PROGRESSION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 8),
          ...ranks.map((r) => TimelineTile(
                title: r.rank,
                state: r.state,
                status: r.status,
                activeColor: AppColors.primary,
              )),
        ],
      ),
    );
  }
}
