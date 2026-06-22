import 'package:flutter/material.dart';

import '../../core/design_system.dart';
import 'section_header.dart';
import 'progress_bar.dart';

class StatsSection extends StatelessWidget {
  final String title;
  final Widget? icon;
  final List<StatItem> stats;
  final EdgeInsetsGeometry padding;

  const StatsSection({
    super.key,
    required this.title,
    this.icon,
    required this.stats,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        border: Border.all(color: AppColors.outline),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              0,
            ),
            child: SectionHeader(
              title: title,
              icon: icon,
              padding: EdgeInsets.zero,
            ),
          ),
          Padding(
            padding: padding,
            child: Column(
              children: [
                for (int i = 0; i < stats.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.md + 4),
                  stats[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final double barHeight;

  const StatItem({
    super.key,
    required this.label,
    required this.value,
    this.color = AppColors.primary,
    this.barHeight = 10,
  });

  @override
  Widget build(BuildContext context) {
    return ProgressBarRow(
      label: label,
      value: value,
      color: color,
      barHeight: barHeight,
    );
  }
}
