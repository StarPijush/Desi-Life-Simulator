import 'package:flutter/material.dart';

import '../../core/design_system.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final TextStyle? style;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.style,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.containerPadding,
      vertical: AppSpacing.sm,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: AppSpacing.xs),
          ],
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: style ?? AppTextStyles.labelBold.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
                letterSpacing: 0.6,
                height: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: AppTextStyles.labelBold.copyWith(
                  fontSize: 10,
                  color: AppColors.primary,
                  letterSpacing: 0.05,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
