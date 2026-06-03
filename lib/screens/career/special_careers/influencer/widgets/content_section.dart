import 'package:flutter/material.dart';

import '../../../../../models/character.dart';
import '../../../../../widgets/common_widgets.dart';

class InfluencerContentSection extends StatelessWidget {
  final Character character;
  final ValueChanged<String> onAction;

  const InfluencerContentSection({
    super.key,
    required this.character,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final active =
        character.careerGroup == 'Influencer' && character.annualIncome > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader.band('CONTENT'),
        AppFlatRowGroup(
          rows: [
            if (!active)
              AppFlatRow(
                icon: const Icon(Icons.play_circle,
                    color: Color(0xFF059669), size: 24),
                title: 'Start Influencer Career',
                subtitle: 'Launch your creator profile',
                onTap: () => onAction('start'),
              ),
            AppFlatRow(
              icon: const Icon(Icons.video_camera_front,
                  color: Color(0xFF059669), size: 24),
              title: 'Post Content',
              subtitle: 'Gain followers, fame, and possible viral momentum',
              locked: !active,
              onTap: () => onAction('post_content'),
            ),
            AppFlatRow(
              icon: const Icon(Icons.forum, color: Color(0xFF059669), size: 24),
              title: 'Engage Audience',
              subtitle: 'Boost engagement and reputation',
              locked: !active,
              onTap: () => onAction('engage_audience'),
            ),
            AppFlatRow(
              icon: const Icon(Icons.health_and_safety,
                  color: Color(0xFF059669), size: 24),
              title: 'Manage Reputation',
              subtitle: 'Recover public trust after criticism',
              locked: !active,
              onTap: () => onAction('manage_reputation'),
            ),
          ],
        ),
      ],
    );
  }
}
