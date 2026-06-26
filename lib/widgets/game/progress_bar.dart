import 'package:flutter/material.dart';

import '../../core/design_system.dart';

class ProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;
  final Color? trackColor;
  final Color? trackBorderColor;

  const ProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.primary,
    this.height = 8,
    this.trackColor,
    this.trackBorderColor,
  });

  const ProgressBar.sm({
    super.key,
    required this.value,
    this.color = AppColors.primary,
    this.height = 8,
    this.trackColor,
    this.trackBorderColor,
  });

  const ProgressBar.xs({
    super.key,
    required this.value,
    this.color = AppColors.primary,
    this.height = 6,
    this.trackColor,
    this.trackBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0, 100);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: trackColor ?? AppColors.slate200,
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
        border: Border.all(
          color: trackBorderColor ?? Colors.transparent,
          width: 1,
        ),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: clamped / 100,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppBorderRadius.full),
          ),
        ),
      ),
    );
  }
}

class ProgressBarRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final double barHeight;
  final bool showPercent;
  final TextStyle? labelStyle;
  final TextStyle? percentStyle;
  final Widget? trailing;

  const ProgressBarRow({
    super.key,
    required this.label,
    required this.value,
    this.color = AppColors.primary,
    this.barHeight = 10,
    this.showPercent = true,
    this.labelStyle,
    this.percentStyle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: labelStyle ??
                      AppTextStyles.labelBold.copyWith(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.08,
                      ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  trailing!,
                ],
              ],
            ),
            if (showPercent)
              Text(
                '${value.round()}%',
                style: percentStyle ??
                    AppTextStyles.labelSm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        ProgressBar(value: value, color: color, height: barHeight),
      ],
    );
  }
}
