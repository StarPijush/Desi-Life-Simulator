import 'package:flutter/material.dart';

import '../../core/app_animations.dart';
import '../../core/design_system.dart';
import 'package:flutter/services.dart';

class ActionTileData {
  final String emoji;
  final String label;
  final List<ActionReward> rewards;
  final bool locked;
  final VoidCallback? onTap;

  const ActionTileData({
    required this.emoji,
    required this.label,
    this.rewards = const [],
    this.locked = false,
    this.onTap,
  });
}

class ActionReward {
  final String text;
  final Color color;

  const ActionReward(this.text, this.color);

  static const money = ActionReward('+₹', AppColors.primary);
  static const exp = ActionReward('+Exp', AppColors.primary);
  static const stress = ActionReward('+Str', AppColors.warning);
  static const risk = ActionReward('Risk', AppColors.error);
}

class ActionTile extends StatefulWidget {
  final String emoji;
  final String label;
  final List<ActionReward> rewards;
  final bool locked;
  final VoidCallback? onTap;

  const ActionTile({
    super.key,
    required this.emoji,
    required this.label,
    this.rewards = const [],
    this.locked = false,
    this.onTap,
  });

  ActionTile.data({
    super.key,
    required ActionTileData data,
  }) : emoji = data.emoji,
       label = data.label,
       rewards = data.rewards,
       locked = data.locked,
       onTap = data.onTap;

  @override
  State<ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<ActionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveOnTap = widget.locked ? null : widget.onTap;

    return GestureDetector(
      onTapDown: effectiveOnTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp: effectiveOnTap != null
          ? (_) {
              setState(() => _pressed = false);
              HapticFeedback.lightImpact();
              effectiveOnTap();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? kPressScale : 1.0,
        duration: AppMotion.tap,
        child: Opacity(
          opacity: widget.locked ? 0.4 : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppBorderRadius.xl),
              border: Border.all(
                color: widget.locked ? AppColors.outline.withValues(alpha: 0.5) : AppColors.outline,
              ),
              boxShadow: AppShadows.card,
            ),
            padding: const EdgeInsets.all(AppSpacing.sm + 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.locked)
                  ColorFiltered(
                    colorFilter: const ColorFilter.matrix(<double>[
                      0.21, 0.72, 0.07, 0, 0,
                      0.21, 0.72, 0.07, 0, 0,
                      0.21, 0.72, 0.07, 0, 0,
                      0, 0, 0, 1, 0,
                    ]),
                    child: Text(widget.emoji, style: const TextStyle(fontSize: 24)),
                  )
                else
                  Text(widget.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.label,
                  style: AppTextStyles.labelBold.copyWith(
                    fontSize: 10,
                    color: widget.locked ? AppColors.textSecondary : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.rewards.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: 2,
                    runSpacing: 2,
                    children: widget.rewards.map((r) => Text(
                      r.text,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: r.color,
                      ),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
