import 'package:flutter/material.dart';

import '../../core/app_animations.dart';
import '../../core/design_system.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? leftAccentColor;
  final VoidCallback? onTap;
  final double leftAccentWidth;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.leftAccentColor,
    this.onTap,
    this.leftAccentWidth = 6,
  });

  const AppCard.accent({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    required this.leftAccentColor,
    this.onTap,
    this.leftAccentWidth = 6,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.85)),
        boxShadow: AppShadows.card,
      ),
      child: leftAccentColor != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppBorderRadius.xl),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: leftAccentWidth,
                    color: leftAccentColor,
                  ),
                  Expanded(child: Padding(padding: padding, child: child)),
                ],
              ),
            )

          : Padding(padding: padding, child: child),
    );

    if (onTap != null) {
      return _PressableCard(onTap: onTap!, child: card);
    }

    return card;
  }
}

class _PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableCard({required this.child, required this.onTap});

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard> {
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
        child: widget.child,
      ),
    );
  }
}
