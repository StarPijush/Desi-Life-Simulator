// lib/widgets/age_button.dart
import 'package:flutter/material.dart';
import 'premium_fab.dart';

class AgeButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isScrolling;

  const AgeButton({super.key, required this.onTap, this.isScrolling = false});

  @override
  Widget build(BuildContext context) {
    return PremiumFAB(onTap: onTap, isScrolling: isScrolling);
  }
}
