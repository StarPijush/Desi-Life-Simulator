import 'package:flutter/material.dart';

import '../../core/design_system.dart';

class GameCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? leftAccentColor;
  final VoidCallback? onTap;

  const GameCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.leftAccentColor,
    this.onTap,
  });

  const GameCard.accent({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    required this.leftAccentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        border: Border.all(color: AppColors.outline),
        boxShadow: AppShadows.card,
      ),
      child: leftAccentColor != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppBorderRadius.xl),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 6, color: leftAccentColor),
                  Expanded(child: Padding(padding: padding, child: child)),
                ],
              ),
            )
          : Padding(padding: padding, child: child),
    );

    if (onTap != null) {
      return _Pressable(onTap: onTap!, child: card);
    }

    return card;
  }
}

class _Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _Pressable({required this.onTap, required this.child});

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
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
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: widget.child,
      ),
    );
  }
}
