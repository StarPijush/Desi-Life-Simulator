// lib/screens/career/special_careers/politician/widgets/politician_stat_bars.dart
import 'package:flutter/material.dart';

import '../../../../../core/design_system.dart';
import '../../../../../models/character.dart';

class PoliticianStatBars extends StatelessWidget {
  final Character character;

  const PoliticianStatBars({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBg,
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          // Position Row
          _buildInfoRow('Current Position', character.currentPosition,
              isBold: true),
          // Party Row
          _buildInfoRow('Party', character.partyName, isMuted: true),

          // Popularity Bar
          _buildProgressBar(
            label: 'Popularity',
            value: character.popularity,
            color: AppColors.info,
            textColor: AppColors.primary,
          ),

          // Public Trust Bar
          _buildProgressBar(
            label: 'Public Trust',
            value: character.publicTrust,
            color: const Color(0xFFFF9875), // tertiary-container
            textColor: const Color(0xFFFF9875),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isBold = false, bool isMuted = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.rowTitle,
          ),
          Text(
            value,
            style: AppTextStyles.rowTitle.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isMuted ? AppColors.textMuted : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar({
    required String label,
    required int value,
    required Color color,
    required Color textColor,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.divider, width: 1.0),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyles.rowTitle,
              ),
              Text(
                '$value%',
                style: AppTextStyles.rowTitle.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 5,
            width: double.infinity,
            color: AppColors.dividerLight,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (value / 100.0)
                  .clamp(0.005, 1.0), // 0.5% min width for visibility like HTML
              child: Container(
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
