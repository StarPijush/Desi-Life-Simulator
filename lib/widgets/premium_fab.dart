// lib/widgets/premium_fab.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/design_system.dart';

class PremiumFAB extends StatefulWidget {
  final VoidCallback onTap;
  final bool isScrolling;
  const PremiumFAB({super.key, required this.onTap, this.isScrolling = false});

  @override
  State<PremiumFAB> createState() => _PremiumFABState();
}

class _PremiumFABState extends State<PremiumFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void didUpdateWidget(PremiumFAB oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScrolling != oldWidget.isScrolling) {
      if (widget.isScrolling) {
        _controller.stop();
      } else {
        _controller.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    // Haptic layer 1: tap down = light
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
    // Haptic layer 3: confirm action = heavy
    HapticFeedback.heavyImpact();
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final scale = _isPressed ? 0.93 : _pulseAnimation.value;
          return AnimatedScale(
            scale: scale,
            duration: _isPressed
                ? AppMotion.tap
                : const Duration(milliseconds: 400),
            curve: _isPressed ? AppMotion.tapCurve : Curves.elasticOut,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: AppColors.ctaGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  // Radial Glow (Elite)
                  BoxShadow(
                    color: AppColors.ctaColor.withValues(
                      alpha: 0.15 * (1 - (_pulseAnimation.value - 1) * 8).clamp(0, 1),
                    ),
                    blurRadius: 44 * _pulseAnimation.value,
                    spreadRadius: 10,
                  ),
                  // Primary Shadow (Deep separation)
                  BoxShadow(
                    color: AppColors.ctaColor.withValues(
                      alpha: 0.48 * (2.1 - _pulseAnimation.value),
                    ),
                    blurRadius: 32 * _pulseAnimation.value,
                    spreadRadius: 3 * (_pulseAnimation.value - 1),
                    offset: const Offset(0, 12),
                  ),
                  // Sharp Accent Shadow
                  BoxShadow(
                    color: AppColors.ctaColor.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          );
        },
      ),
    );
  }
}
