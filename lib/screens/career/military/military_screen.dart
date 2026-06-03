import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/design_system.dart';
import '../../../models/character.dart';
import 'widgets/military_actions_section.dart';
import 'widgets/military_header.dart';
import 'widgets/rank_progression_section.dart';
import 'widgets/service_record_section.dart';

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
    'Sepoy',
    'Naik',
    'Havildar',
    'Lieutenant',
    'Captain',
    'Major',
    'Colonel',
  ];

  @override
  Widget build(BuildContext context) {
    final activeRankIndex = _activeRankIndex;
    final currentRank = _rankNames[activeRankIndex];
    final promotionScore = _promotionScore;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      appBar: MilitaryHeader(onBack: onBack, onMore: onMore),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          _ActiveDutySection(
            name: character.name,
            rank: currentRank,
            monthlyPay: character.annualIncome / 12,
            yearsServed: _yearsServed,
          ),
          const SizedBox(height: 8),
          ServiceRecordSection(
            fitness: character.health,
            discipline: character.discipline,
            leadership: _leadership,
            deployments: _deployments,
            medals: _medals,
            promotionScore: promotionScore,
          ),
          const SizedBox(height: 16),
          MilitaryActionsSection(
            promotionScore: promotionScore,
            onTrainPhysically: onTrainPhysically,
            onWeaponsPractice: onWeaponsPractice,
            onLeadershipTraining: onLeadershipTraining,
            onPromotionExam: onPromotionExam,
            onSpecialForcesSelection: onSpecialForcesSelection,
          ),
          const SizedBox(height: 16),
          RankProgressionSection(
            ranks: _rankProgress(activeRankIndex),
          ),
        ],
      ),
    );
  }

  int get _activeRankIndex {
    final careerIndex = max(character.careerStep, character.jobLevel);
    return careerIndex.clamp(0, _rankNames.length - 1).toInt();
  }

  int get _yearsServed {
    return max(character.yearsInJob, character.yearsInRole).clamp(0, 99).toInt();
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
        .where((achievement) => achievement.toLowerCase().contains('deployment'))
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

  List<MilitaryRankProgress> _rankProgress(int activeRankIndex) {
    return [
      for (int i = 0; i < _rankNames.length; i++)
        MilitaryRankProgress(
          rank: _rankNames[i],
          state: i < activeRankIndex
              ? MilitaryRankState.completed
              : i == activeRankIndex
                  ? MilitaryRankState.active
                  : MilitaryRankState.locked,
          status: i < activeRankIndex
              ? 'Completed'
              : i == activeRankIndex
                  ? 'Active Rank'
                  : i == activeRankIndex + 1
                      ? 'Need ${i + 1} years'
                      : null,
        ),
    ];
  }
}

class _ActiveDutySection extends StatelessWidget {
  final String name;
  final String rank;
  final double monthlyPay;
  final int yearsServed;

  const _ActiveDutySection({
    required this.name,
    required this.rank,
    required this.monthlyPay,
    required this.yearsServed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      foregroundDecoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE4E4E7), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACTIVE DUTY',
                  style: _labelStyle.copyWith(letterSpacing: 2.0),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lexend(
                    fontSize: 24,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF18181B),
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  rank.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatMoney(monthlyPay),
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF18181B),
                ),
              ),
              Text('MONTHLY PAY', style: _labelStyle),
              const SizedBox(height: 4),
              Text(
                '$yearsServed ${yearsServed == 1 ? 'YEAR' : 'YEARS'} SERVED',
                style: _labelStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  TextStyle get _labelStyle {
    return GoogleFonts.lexend(
      fontSize: 13,
      height: 1.0,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF71717A),
    );
  }
}
