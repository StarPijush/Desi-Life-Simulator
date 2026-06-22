import 'package:flutter/material.dart';

import '../../core/design_system.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
    this.fontSize = 9,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: 2,
    ),
  });

  static const active = StatusChip(label: 'ACTIVE', color: AppColors.primary);
  static const retired = StatusChip(label: 'RETIRED', color: AppColors.textSecondary);
  static const locked = StatusChip(label: 'LOCKED', color: AppColors.outline);
  static const promoted = StatusChip(label: 'PROMOTED', color: AppColors.primary);
  static const bankrupt = StatusChip(label: 'BANKRUPT', color: AppColors.error);
  static const atWar = StatusChip(label: 'AT WAR', color: AppColors.error);
  static const married = StatusChip(label: 'MARRIED', color: Color(0xFFDB2777));
  static const divorced = StatusChip(label: 'DIVORCED', color: AppColors.textSecondary);
  static const unemployed = StatusChip(label: 'UNEMPLOYED', color: AppColors.warning);
  static const military_ = StatusChip(label: 'MILITARY', color: Color(0xFF1B5E20));
  static const completed = StatusChip(label: 'COMPLETED', color: AppColors.primary);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelBold.copyWith(
          fontSize: fontSize,
          color: textColor ?? color,
          letterSpacing: 0.05,
        ),
      ),
    );
  }
}
