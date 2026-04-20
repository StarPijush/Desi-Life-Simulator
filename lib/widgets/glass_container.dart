// lib/widgets/glass_container.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/design_system.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? extraShadows;
  final Color? tintColor;
  final double borderOpacity;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 20,
    this.opacity = 0.72,
    this.borderRadius = 28,
    this.padding,
    this.extraShadows,
    this.tintColor,
    this.borderOpacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: extraShadows ?? AppShadows.glass,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: (tintColor ?? Colors.white).withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: borderOpacity),
                width: 1,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: opacity + 0.05),
                  Colors.white.withValues(alpha: opacity - 0.1),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
