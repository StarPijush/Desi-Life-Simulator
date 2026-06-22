import 'package:flutter/material.dart';

import '../../core/design_system.dart';
import '../../widgets/core/app_top_bar.dart';
import '../../widgets/game/game_card.dart';
import '../../widgets/game/progress_bar.dart';
import '../../widgets/game/action_tile.dart';
import '../../widgets/game/job_card.dart';
import '../../widgets/game/section_header.dart';
import '../../widgets/game/stats_section.dart';

class CareerCenterScreen extends StatelessWidget {
  const CareerCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppTopBar(
              title: 'Career Center',
              subtitle: 'Age 17 • Student • Part-Time Worker',
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.containerPadding,
                  AppSpacing.md,
                  AppSpacing.containerPadding,
                  AppSpacing.lg,
                ),
                children: const [
                  _PlayerCareerCard(),
                  SizedBox(height: 12),
                  _WorkActionsGrid(),
                  SizedBox(height: 12),
                  _ProfessionalStats(),
                  SizedBox(height: 12),
                  _AvailableJobsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerCareerCard extends StatelessWidget {
  const _PlayerCareerCard();

  @override
  Widget build(BuildContext context) {
    return const GameCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT ROLE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.1,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Junior Store Assistant',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.01,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Big Bazaar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹80',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: -0.01,
                        ),
                      ),
                      Text(
                        '/hr',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    '1 Year Exp.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          ProgressBarRow(
            label: 'PROMOTION PROGRESS',
            value: 65,
            barHeight: 12,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ProgressBarRow(
                  label: 'SATISFACTION',
                  value: 80,
                  color: AppColors.primary,
                  barHeight: 8,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ProgressBarRow(
                  label: 'STRESS',
                  value: 30,
                  color: AppColors.warning,
                  barHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WorkActionsGrid extends StatelessWidget {
  const _WorkActionsGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Work Actions', padding: EdgeInsets.only(bottom: 8)),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
          children: const [
            ActionTile(
              emoji: '⏰',
              label: 'Work Shift',
              rewards: [ActionReward('+₹', AppColors.primary), ActionReward('+Exp', AppColors.primary)],
            ),
            ActionTile(
              emoji: '⚡',
              label: 'Extra Shift',
              rewards: [ActionReward('++₹', AppColors.primary), ActionReward('+Str', AppColors.warning)],
            ),
            ActionTile(
              emoji: '📖',
              label: 'Study Skill',
              rewards: [ActionReward('+Exp', AppColors.primary)],
            ),
            ActionTile(
              emoji: '💬',
              label: 'Ask Raise',
              rewards: [ActionReward('Risk', AppColors.error)],
            ),
            ActionTile(
              emoji: '📈',
              label: 'Promotion',
              locked: true,
            ),
            ActionTile(
              emoji: '🚪',
              label: 'Quit Job',
              rewards: [ActionReward('Resign', AppColors.error)],
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfessionalStats extends StatelessWidget {
  const _ProfessionalStats();

  @override
  Widget build(BuildContext context) {
    return const StatsSection(
      title: 'Professional Stats',
      icon: Icon(Icons.bar_chart, color: AppColors.primary, size: 18),
      stats: [
        StatItem(label: 'Customer Skills', value: 75),
        StatItem(label: 'Leadership', value: 40, color: AppColors.primary),
        StatItem(label: 'Technical', value: 55, color: AppColors.primary),
      ],
    );
  }
}

class _AvailableJobsSection extends StatelessWidget {
  const _AvailableJobsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Available Jobs',
          actionLabel: 'View All',
          onAction: _noop,
        ),
        const SizedBox(height: 8),
        const JobCard(
          emoji: '🛒',
          title: 'Store Cashier',
          company: 'Reliance Fresh • Easy',
          salary: '₹12,000/mo',
          requirement: 'Age 18+',
        ),
        const SizedBox(height: 8),
        const JobCard(
          emoji: '🚲',
          title: 'Delivery Lead',
          company: 'Swiggy • Medium',
          salary: '₹15,000/mo',
          requirement: 'Unlock at Age 18',
          locked: true,
          accentColor: AppColors.warning,
        ),
      ],
    );
  }

  static void _noop() {}
}
