// lib/screens/career/special_careers/politician/pages/elections_page.dart
import 'package:flutter/material.dart';

import '../../../../../core/design_system.dart';
import '../../../../../models/character.dart';

class ElectionsPage extends StatelessWidget {
  final Character character;

  const ElectionsPage({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.cardBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'ELECTIONS',
          style: AppTextStyles.pageTitle.copyWith(color: AppColors.primary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.divider,
            height: 1.0,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Elections and campaign management will appear here.',
            style: AppTextStyles.rowTitle,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
