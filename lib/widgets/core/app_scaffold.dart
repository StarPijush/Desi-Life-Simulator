import 'package:flutter/material.dart';

import '../../core/design_system.dart';
import 'app_top_bar.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool showBack;
  final Widget? bottomWidget;
  final Widget? topWidget;
  final EdgeInsetsGeometry padding;
  final Widget? trailing;

  const AppScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.showBack = true,
    this.bottomWidget,
    this.topWidget,
    this.padding = EdgeInsets.zero,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(
              title: title,
              subtitle: subtitle,
              showBack: showBack,
              trailing: trailing,
            ),
            if (topWidget != null) topWidget!,
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: padding,
                children: [
                  ...children,
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
            if (bottomWidget != null) bottomWidget!,
          ],
        ),
      ),
    );
  }
}
