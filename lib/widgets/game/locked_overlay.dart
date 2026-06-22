import 'package:flutter/material.dart';

import '../../core/design_system.dart';

class LockedOverlay extends StatelessWidget {
  final String requirement;
  final double opacity;

  const LockedOverlay({
    super.key,
    required this.requirement,
    this.opacity = 0.4,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🔒 ',
            style: TextStyle(
              fontSize: 10,
            ),
          ),
          Text(
            requirement,
            style: AppTextStyles.labelBold.copyWith(
              fontSize: 10,
              color: AppColors.warning,
              letterSpacing: 0.05,
            ),
          ),
        ],
      ),
    );
  }
}
