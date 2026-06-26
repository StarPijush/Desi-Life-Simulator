import 'package:flutter/material.dart';

import '../../core/app_animations.dart';
import '../../core/design_system.dart';

class JobCard extends StatefulWidget {
  final String emoji;
  final String title;
  final String company;
  final String salary;
  final String? requirement;
  final bool locked;
  final Color accentColor;
  final VoidCallback? onTap;

  const JobCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.company,
    required this.salary,
    this.requirement,
    this.locked = false,
    this.accentColor = AppColors.primary,
    this.onTap,
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveOnTap = widget.locked ? null : widget.onTap;

    return GestureDetector(
      onTapDown: effectiveOnTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp: effectiveOnTap != null
          ? (_) {
              setState(() => _pressed = false);
              effectiveOnTap();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? kPressScale : 1.0,
        duration: AppMotion.tap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppBorderRadius.xl),
            border: Border.all(color: AppColors.outline.withValues(alpha: 0.85)),
            boxShadow: AppShadows.card,
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: widget.locked
                        ? AppColors.outline
                        : widget.accentColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppBorderRadius.xl - 1),
                      bottomLeft: Radius.circular(AppBorderRadius.xl - 1),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Opacity(
                      opacity: widget.locked ? 0.4 : 1.0,
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                              border: Border.all(color: AppColors.outline),
                            ),
                            child: Center(
                              child: widget.locked
                                  ? ColorFiltered(
                                      colorFilter: const ColorFilter.matrix(<double>[
                                        0.21, 0.72, 0.07, 0, 0,
                                        0.21, 0.72, 0.07, 0, 0,
                                        0.21, 0.72, 0.07, 0, 0,
                                        0, 0, 0, 1, 0,
                                      ]),
                                      child: Text(widget.emoji, style: const TextStyle(fontSize: 24)),
                                    )
                                  : Text(widget.emoji, style: const TextStyle(fontSize: 24)),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.title,
                                  style: AppTextStyles.bodyLg.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.company,
                                  style: AppTextStyles.labelSm.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (widget.locked && widget.requirement != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Text('🔒 ', style: TextStyle(fontSize: 10)),
                                      Text(
                                        widget.requirement!,
                                        style: AppTextStyles.labelSm.copyWith(
                                          color: AppColors.warning,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.salary,
                                style: AppTextStyles.labelBold.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                ),
                              ),
                              if (widget.requirement != null && !widget.locked)
                                Text(
                                  widget.requirement!,
                                  style: AppTextStyles.labelSm.copyWith(
                                    fontSize: 10,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
