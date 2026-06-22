import 'package:flutter/material.dart';

import '../../core/design_system.dart';

class AppTopBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final Widget? trailing;
  final VoidCallback? onBack;

  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = true,
    this.trailing,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
      height: 64,
      child: Row(
        children: [
          if (showBack)
            GestureDetector(
              onTap: onBack ?? () => Navigator.of(context).pop(),
              child: const Padding(
                padding: EdgeInsets.only(right: AppSpacing.sm),
                child: Icon(Icons.arrow_back, color: AppColors.primary, size: 24),
              ),
            ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.displayMd,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTextStyles.labelSm,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
