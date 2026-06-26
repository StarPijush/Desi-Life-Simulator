import 'package:flutter/material.dart';

import '../../core/app_animations.dart';
import '../../core/design_system.dart';

class CareerPathCard extends StatefulWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const CareerPathCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<CareerPathCard> createState() => _CareerPathCardState();
}

class _CareerPathCardState extends State<CareerPathCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? kPressScale : 1.0,
        duration: AppMotion.tap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minHeight: 64),
          decoration: BoxDecoration(
            color: _pressed ? AppColors.background : AppColors.surface,
            borderRadius: BorderRadius.circular(AppBorderRadius.xl),
            border: Border.all(color: AppColors.outline.withValues(alpha: 0.85)),
            boxShadow: AppShadows.card,
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                widget.emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: AppTextStyles.labelSm,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
