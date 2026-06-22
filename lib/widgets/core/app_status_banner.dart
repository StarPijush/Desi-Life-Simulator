import 'package:flutter/material.dart';

import '../../core/design_system.dart';

class AppStatusBanner extends StatelessWidget {
  final String label;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const AppStatusBanner({
    super.key,
    required this.label,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppTextStyles.labelBold.copyWith(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: AppTextStyles.displayMd.copyWith(fontSize: 20),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      subtitle!,
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
