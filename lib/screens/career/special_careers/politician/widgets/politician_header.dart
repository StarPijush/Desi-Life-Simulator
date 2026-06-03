// lib/screens/career/special_careers/politician/widgets/politician_header.dart
import 'package:flutter/material.dart';

import '../../../../../core/design_system.dart';
import '../../../../../core/engine.dart';
import '../../../../../models/character.dart';

class PoliticianHeader extends StatelessWidget {
  final Character character;

  const PoliticianHeader({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      margin: const EdgeInsets.only(bottom: 4.0),
      color: AppColors.scaffoldBg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              character.name,
              style: AppTextStyles.pageTitle.copyWith(color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                GameEngine.formatMoney(character.bankBalance),
                style: AppTextStyles.pageTitle.copyWith(
                  color: AppColors.primary,
                  fontSize: 18,
                ),
              ),
              Text(
                'Age: ${character.age}',
                style: AppTextStyles.sectionLabel.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
