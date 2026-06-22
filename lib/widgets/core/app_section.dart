import 'package:flutter/material.dart';

import '../../core/design_system.dart';

class AppSection extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  const AppSection({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(0),
    this.backgroundColor,
  });

  const AppSection.card({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: backgroundColor ?? Colors.transparent,
      padding: padding,
      child: child,
    );
  }
}
