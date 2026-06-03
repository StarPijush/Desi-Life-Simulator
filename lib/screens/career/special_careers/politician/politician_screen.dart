// lib/screens/career/special_careers/politician/politician_screen.dart
import 'package:flutter/material.dart';

import '../../../../core/design_system.dart';
import '../../../../models/character.dart';
import 'widgets/politician_header.dart';
import 'widgets/politician_navigation_section.dart';
import 'widgets/politician_stat_bars.dart';

class PoliticianScreen extends StatelessWidget {
  final Character character;

  const PoliticianScreen({super.key, required this.character});

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
          'POLITICIAN',
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
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          PoliticianHeader(character: character),
          
          _buildSectionHeader('Current Status'),
          PoliticianStatBars(character: character),
          
          _buildSectionHeader('Management'),
          PoliticianNavigationSection(character: character),
          
          // Quick Action Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 48.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement start political campaign logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'START POLITICAL CAMPAIGN',
                  style: AppTextStyles.pageTitle.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.sectionLabel,
      ),
    );
  }
}
