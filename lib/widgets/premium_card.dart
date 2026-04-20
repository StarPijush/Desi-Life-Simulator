// lib/widgets/premium_card.dart
import 'package:flutter/material.dart';
import '../core/design_system.dart';

/// Reusable premium card with consistent radius, shadow, and border.
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? borderRadius;
  final bool elevated;
  final VoidCallback? onTap;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius,
    this.elevated = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: color ?? AppColors.cardBg,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.xl),
        boxShadow: elevated ? AppShadows.card : null,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: child,
    );

    if (onTap != null) {
      return _TappableWrapper(onTap: onTap!, child: card);
    }
    return card;
  }
}

/// Adds a scale press animation to any child widget.
class _TappableWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _TappableWrapper({required this.child, required this.onTap});

  @override
  State<_TappableWrapper> createState() => _TappableWrapperState();
}

class _TappableWrapperState extends State<_TappableWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.tap,
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.985).animate(
      CurvedAnimation(parent: _controller, curve: AppMotion.tapCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          final shadow = BoxShadow.lerpList(
            AppShadows.card,
            [
              BoxShadow(
                color: const Color(0xFF64748B).withValues(alpha: 0.12),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 12),
              ),
            ],
            _controller.value,
          );
          
          return Transform.scale(
            scale: _scale.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: shadow,
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
