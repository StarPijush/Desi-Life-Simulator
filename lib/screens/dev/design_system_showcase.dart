import 'package:flutter/material.dart';

import '../../core/design_system.dart';
import '../../widgets/core/app_scaffold.dart';
import '../../widgets/core/app_card.dart';
import '../../widgets/core/app_top_bar.dart';
import '../../widgets/core/app_status_banner.dart';
import '../../widgets/game/game_card.dart';
import '../../widgets/game/progress_bar.dart';
import '../../widgets/game/action_tile.dart';
import '../../widgets/game/job_card.dart';
import '../../widgets/game/section_header.dart';
import '../../widgets/game/stats_section.dart';
import '../../widgets/game/locked_overlay.dart';
import '../../widgets/game/timeline_tile.dart';
import '../../widgets/game/status_chip.dart';

class DesignSystemShowcase extends StatelessWidget {
  const DesignSystemShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Design System',
      subtitle: 'DESILIFE UI Toolkit',
      children: [
        _ColorSection(),
        _TypographySection(),
        _AppBarSection(),
        _StatusBannerSection(),
        _CardSection(),
        _GameCardSection(),
        _ProgressBarSection(),
        _ActionTileSection(),
        _JobCardSection(),
        _SectionHeaderSection(),
        _StatsSectionSection(),
        _LockedOverlaySection(),
        _TimelineTileSection(),
        _StatusChipSection(),
      ],
    );
  }
}

class _ColorSection extends StatelessWidget {
  const _ColorSection();

  @override
  Widget build(BuildContext context) {
    return _showcase('Colors', [
      _swatch('Background', AppColors.background),
      _swatch('Surface', AppColors.surface),
      _swatch('Primary', AppColors.primary),
      _swatch('Warning', AppColors.warning),
      _swatch('Error', AppColors.error),
      _swatch('Text Primary', AppColors.textPrimary),
      _swatch('Text Secondary', AppColors.textSecondary),
      _swatch('Outline', AppColors.outline),
    ]);
  }

  Widget _swatch(String label, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: AppColors.outline),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyles.bodyMd),
          const Spacer(),
          Text(color.toARGB32().toRadixString(16).toUpperCase(),
              style: AppTextStyles.labelSm.copyWith(fontFamily: 'monospace')),
        ],
      ),
    );
  }
}

class _TypographySection extends StatelessWidget {
  const _TypographySection();

  @override
  Widget build(BuildContext context) {
    return _showcase('Typography', [
      Text('Display Lg (32/40)', style: AppTextStyles.displayLg.copyWith(fontSize: 20)),
      Text('Display Md (24/32)', style: AppTextStyles.displayMd.copyWith(fontSize: 18)),
      Text('Headline Sm (20/28)', style: AppTextStyles.headlineSm.copyWith(fontSize: 16)),
      const SizedBox(height: 8),
      Text('Body Lg (16/24) — Inter Regular', style: AppTextStyles.bodyLg),
      Text('Body Md (14/20) — Inter Regular', style: AppTextStyles.bodyMd),
      const SizedBox(height: 8),
      Text('LABEL BOLD (12/16) — Inter Bold +0.05em', style: AppTextStyles.labelBold),
      Text('Label Sm (11/14) — Inter Medium', style: AppTextStyles.labelSm),
    ]);
  }
}

class _AppBarSection extends StatelessWidget {
  const _AppBarSection();

  @override
  Widget build(BuildContext context) {
    return _showcase('App Top Bar', [
      const AppTopBar(title: 'Career Center', subtitle: 'Age 17 • Student'),
      const AppTopBar(title: 'Military', showBack: true),
    ]);
  }
}

class _StatusBannerSection extends StatelessWidget {
  const _StatusBannerSection();

  @override
  Widget build(BuildContext context) {
    return _showcase('Status Banner', [
      const AppStatusBanner(
        label: 'ACTIVE DUTY',
        title: 'Pvt. Rahul Sharma',
        subtitle: 'RECRUIT',
        trailing: Column(
          children: [
            Text('₹12,000', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('MONTHLY PAY', style: TextStyle(fontSize: 9)),
          ],
        ),
      ),
    ]);
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection();

  @override
  Widget build(BuildContext context) {
    return _showcase('AppCard', [
      const AppCard(padding: EdgeInsets.all(16), child: Text('Basic Card')),
      const SizedBox(height: 8),
      AppCard(
        leftAccentColor: AppColors.primary,
        padding: const EdgeInsets.all(16),
        child: const Text('Accent Card (Primary)'),
      ),
      const SizedBox(height: 8),
      AppCard(
        leftAccentColor: AppColors.error,
        padding: const EdgeInsets.all(16),
        child: const Text('Accent Card (Error)'),
      ),
    ]);
  }
}

class _GameCardSection extends StatelessWidget {
  const _GameCardSection();

  @override
  Widget build(BuildContext context) {
    return _showcase('GameCard', [
      const GameCard(child: Text('Basic GameCard')),
      const SizedBox(height: 8),
      const GameCard.accent(
        leftAccentColor: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Junior Store Assistant',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Big Bazaar'),
          ],
        ),
      ),
    ]);
  }
}

class _ProgressBarSection extends StatelessWidget {
  const _ProgressBarSection();

  @override
  Widget build(BuildContext context) {
    return _showcase('Progress Bars', [
      const ProgressBar(value: 65),
      const SizedBox(height: 8),
      const ProgressBar(value: 80, color: AppColors.warning),
      const SizedBox(height: 8),
      const ProgressBar(value: 30, color: AppColors.error),
      const SizedBox(height: 8),
      const ProgressBar.sm(value: 75),
      const SizedBox(height: 16),
      const ProgressBarRow(label: 'Promotion Progress', value: 65),
      const SizedBox(height: 8),
      const ProgressBarRow(label: 'Satisfaction', value: 80, color: AppColors.warning),
      const SizedBox(height: 8),
      const ProgressBarRow(label: 'Stress', value: 30, color: AppColors.error),
    ]);
  }
}

class _ActionTileSection extends StatelessWidget {
  const _ActionTileSection();

  @override
  Widget build(BuildContext context) {
    return _showcase('Action Tiles', [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          SizedBox(
            width: 100,
            child: const ActionTile(
              emoji: '⏰',
              label: 'Work Shift',
              rewards: [ActionReward('+₹', AppColors.primary), ActionReward('+Exp', AppColors.primary)],
            ),
          ),
          SizedBox(
            width: 100,
            child: const ActionTile(
              emoji: '⚡',
              label: 'Extra Shift',
              rewards: [ActionReward('+₹', AppColors.primary), ActionReward('+Str', AppColors.warning)],
            ),
          ),
          SizedBox(
            width: 100,
            child: const ActionTile(
              emoji: '📖',
              label: 'Study Skill',
              rewards: [ActionReward('+Exp', AppColors.primary)],
            ),
          ),
          SizedBox(
            width: 100,
            child: const ActionTile(
              emoji: '💬',
              label: 'Ask Raise',
              rewards: [ActionReward('Risk', AppColors.error)],
            ),
          ),
          SizedBox(
            width: 100,
            child: const ActionTile(
              emoji: '📈',
              label: 'Promotion',
              locked: true,
            ),
          ),
          SizedBox(
            width: 100,
            child: const ActionTile(
              emoji: '🚪',
              label: 'Quit Job',
              rewards: [ActionReward('Resign', AppColors.error)],
            ),
          ),
        ],
      ),
    ]);
  }
}

class _JobCardSection extends StatelessWidget {
  const _JobCardSection();

  @override
  Widget build(BuildContext context) {
    return _showcase('Job Cards', [
      const JobCard(
        emoji: '🛒',
        title: 'Store Cashier',
        company: 'Reliance Fresh',
        salary: '₹12,000/mo',
        requirement: 'Age 18+',
      ),
      const SizedBox(height: 8),
      const JobCard(
        emoji: '🚲',
        title: 'Delivery Lead',
        company: 'Swiggy',
        salary: '₹15,000/mo',
        requirement: 'Unlock at Age 18',
        locked: true,
        accentColor: AppColors.warning,
      ),
    ]);
  }
}

class _SectionHeaderSection extends StatelessWidget {
  const _SectionHeaderSection();

  @override
  Widget build(BuildContext context) {
    return _showcase('Section Headers', [
      const SectionHeader(title: 'Available Jobs'),
      const SectionHeader(
        title: 'Professional Stats',
        icon: Icon(Icons.bar_chart, color: AppColors.primary, size: 18),
      ),
      const SectionHeader(
        title: 'Promotion',
        actionLabel: 'View All',
        onAction: _noop,
      ),
    ]);
  }

  static void _noop() {}
}

class _StatsSectionSection extends StatelessWidget {
  const _StatsSectionSection();

  @override
  Widget build(BuildContext context) {
    return _showcase('Stats Section', [
      const StatsSection(
        title: 'Professional Stats',
        icon: Icon(Icons.bar_chart, color: AppColors.primary, size: 18),
        stats: [
          StatItem(label: 'Customer Skills', value: 75),
          StatItem(label: 'Leadership', value: 40, color: Color(0xFF1E9E54)),
          StatItem(label: 'Technical', value: 55),
        ],
      ),
    ]);
  }
}

class _LockedOverlaySection extends StatelessWidget {
  const _LockedOverlaySection();

  @override
  Widget build(BuildContext context) {
    return _showcase('Locked Overlay', [
      const LockedOverlay(requirement: 'Unlock at Age 18'),
      const SizedBox(height: 4),
      const LockedOverlay(requirement: 'Requires University Degree'),
      const SizedBox(height: 4),
      const LockedOverlay(requirement: 'Requires Rank Captain'),
    ]);
  }
}

class _TimelineTileSection extends StatelessWidget {
  const _TimelineTileSection();

  @override
  Widget build(BuildContext context) {
    return _showcase('Timeline Tiles', [
      const TimelineTile(
        title: 'Recruit',
        subtitle: 'Basic Training Complete',
        state: TimelineState.completed,
        status: 'Completed',
      ),
      const TimelineTile(
        title: 'Cadet',
        subtitle: 'Active Service',
        state: TimelineState.completed,
        status: 'Completed',
      ),
      const TimelineTile(
        title: 'Lieutenant',
        subtitle: 'Current Rank',
        state: TimelineState.active,
        status: 'Active',
        activeColor: AppColors.primary,
      ),
      const TimelineTile(
        title: 'Captain',
        subtitle: 'Need 3 more years',
        state: TimelineState.locked,
        status: 'Locked',
      ),
    ]);
  }
}

class _StatusChipSection extends StatelessWidget {
  const _StatusChipSection();

  @override
  Widget build(BuildContext context) {
    return _showcase('Status Chips', [
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: const [
          StatusChip.active,
          StatusChip.retired,
          StatusChip.locked,
          StatusChip.promoted,
          StatusChip.bankrupt,
          StatusChip.atWar,
          StatusChip.married,
          StatusChip.divorced,
          StatusChip.unemployed,
          StatusChip.military_,
          StatusChip.completed,
        ],
      ),
    ]);
  }
}

Widget _showcase(String title, List<Widget> children) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.containerPadding,
      AppSpacing.md,
      AppSpacing.containerPadding,
      AppSpacing.md,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTextStyles.labelBold.copyWith(
            fontSize: 12,
            color: AppColors.primary,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.sm),
        ...children,
      ],
    ),
  );
}
