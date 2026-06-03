import 'package:flutter/material.dart';

import '../../../../../models/character.dart';
import '../../../../../widgets/common_widgets.dart';

class InfluencerMonetizationSection extends StatelessWidget {
  final Character character;
  final ValueChanged<String> onAction;

  const InfluencerMonetizationSection({
    super.key,
    required this.character,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final active =
        character.careerGroup == 'Influencer' && character.annualIncome > 0;
    final canBrandDeal =
        active && character.followers >= 10000 && character.engagement >= 35;
    final canSponsorship = active &&
        character.followers >= 50000 &&
        character.fame >= 25 &&
        character.reputation >= 45;
    final canVerify = active &&
        !character.isVerified &&
        character.followers >= 100000 &&
        character.fame >= 35 &&
        character.reputation >= 55;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader.band('MONETIZATION'),
        AppFlatRowGroup(
          rows: [
            AppFlatRow(
              icon: const Icon(Icons.handshake,
                  color: Color(0xFF059669), size: 24),
              title: 'Brand Deal Offer',
              subtitle: canBrandDeal
                  ? 'Offer available'
                  : 'Needs 10K followers and 35 engagement',
              locked: !canBrandDeal,
              onTap: () => onAction('brand_deal'),
            ),
            AppFlatRow(
              icon: const Icon(Icons.campaign,
                  color: Color(0xFF059669), size: 24),
              title: 'Sponsorship Offer',
              subtitle: canSponsorship
                  ? 'Premium offer available'
                  : 'Needs 50K followers, 25 fame, 45 reputation',
              locked: !canSponsorship,
              onTap: () => onAction('sponsorship'),
            ),
            AppFlatRow(
              icon: Icon(
                character.isVerified ? Icons.verified : Icons.verified_outlined,
                color: character.isVerified
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF059669),
                size: 24,
              ),
              title: character.isVerified
                  ? 'Verified Status'
                  : 'Apply Verification',
              subtitle: character.isVerified
                  ? 'Official creator profile'
                  : 'Needs 100K followers, 35 fame, 55 reputation',
              locked: character.isVerified || !canVerify,
              onTap: () => onAction('apply_verification'),
            ),
          ],
        ),
      ],
    );
  }
}
