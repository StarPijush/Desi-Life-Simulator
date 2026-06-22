import 'package:flutter/material.dart';

import '../../core/design_system.dart';

enum TimelineState { completed, active, locked }

class TimelineTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? status;
  final TimelineState state;
  final Color? activeColor;
  final VoidCallback? onTap;

  const TimelineTile({
    super.key,
    required this.title,
    this.subtitle,
    this.status,
    this.state = TimelineState.locked,
    this.activeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = switch (state) {
      TimelineState.completed => activeColor ?? AppColors.primary,
      TimelineState.active => activeColor ?? AppColors.primary,
      TimelineState.locked => AppColors.outline,
    };

    final dotSize = switch (state) {
      TimelineState.completed => 8.0,
      TimelineState.active => 10.0,
      TimelineState.locked => 6.0,
    };

    final titleColor = switch (state) {
      TimelineState.completed => AppColors.textPrimary,
      TimelineState.active => activeColor ?? AppColors.primary,
      TimelineState.locked => AppColors.textSecondary,
    };

    final titleWeight = switch (state) {
      TimelineState.completed => FontWeight.w600,
      TimelineState.active => FontWeight.w700,
      TimelineState.locked => FontWeight.w500,
    };

    final showDotGlow = state == TimelineState.active;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              boxShadow: showDotGlow
                  ? [
                      BoxShadow(
                        color: dotColor.withValues(alpha: 0.3),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: titleWeight,
                    color: titleColor,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTextStyles.labelSm.copyWith(fontSize: 10),
                  ),
              ],
            ),
          ),
          if (status != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppBorderRadius.sm),
              ),
              child: Text(
                status!,
                style: AppTextStyles.labelSm.copyWith(
                  fontSize: 9,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
