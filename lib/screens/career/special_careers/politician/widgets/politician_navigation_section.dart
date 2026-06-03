// lib/screens/career/special_careers/politician/widgets/politician_navigation_section.dart
import 'package:flutter/material.dart';

import '../../../../../core/design_system.dart';
import '../../../../../models/character.dart';
import '../pages/career_progression_page.dart';
import '../pages/elections_page.dart';
import '../pages/legacy_page.dart';
import '../pages/networking_page.dart';
import '../pages/political_activities_page.dart';
import '../pages/public_image_page.dart';
import '../pages/scandals_page.dart';

class PoliticianNavigationSection extends StatelessWidget {
  final Character character;

  const PoliticianNavigationSection({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBg,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: [
          _buildNavRow(
            context,
            icon: Icons.account_balance,
            iconColor: AppColors.primary,
            label: 'Political Activities',
            page: PoliticalActivitiesPage(character: character),
          ),
          _buildNavRow(
            context,
            icon: Icons.campaign,
            iconColor: AppColors.primary,
            label: 'Public Image',
            page: PublicImagePage(character: character),
          ),
          _buildNavRow(
            context,
            icon: Icons.handshake,
            iconColor: AppColors.primary,
            label: 'Networking',
            page: NetworkingPage(character: character),
          ),
          _buildNavRow(
            context,
            icon: Icons.how_to_vote,
            iconColor: AppColors.primary,
            label: 'Elections',
            page: ElectionsPage(character: character),
          ),
          _buildNavRow(
            context,
            icon: Icons.trending_up,
            iconColor: AppColors.primary,
            label: 'Career Progression',
            page: CareerProgressionPage(character: character),
          ),
          _buildNavRow(
            context,
            icon: Icons.warning,
            iconColor: AppColors.danger,
            label: 'Scandals',
            page: ScandalsPage(character: character),
          ),
          _buildNavRow(
            context,
            icon: Icons.emoji_events,
            iconColor: AppColors.primary,
            label: 'Legacy',
            page: LegacyPage(character: character),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNavRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required Widget page,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          border: isLast ? null : const Border(
            bottom: BorderSide(color: AppColors.divider, width: 1.0),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.rowTitle,
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.divider, size: 24),
          ],
        ),
      ),
    );
  }
}
