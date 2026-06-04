// lib/screens/career/special_careers/politician/widgets/politician_navigation_section.dart
import 'package:flutter/material.dart';

import '../../../../../core/design_system.dart';
import '../../../../../models/character.dart';

class PoliticianNavigationSection extends StatelessWidget {
  final Character character;
  final void Function(String actionId) onAction;

  const PoliticianNavigationSection({
    super.key,
    required this.character,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBg,
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          _buildNavRow(
            context,
            icon: Icons.account_balance,
            iconColor: AppColors.primary,
            label: 'Political Activities',
            actions: const [
              _PoliticianAction('Community Service', 'community_service'),
              _PoliticianAction('Attend Rally', 'attend_rally'),
              _PoliticianAction('Political Debate', 'political_debate'),
            ],
          ),
          _buildNavRow(
            context,
            icon: Icons.campaign,
            iconColor: AppColors.primary,
            label: 'Public Image',
            actions: const [
              _PoliticianAction('Public Speech', 'public_speech'),
              _PoliticianAction('Campaigning', 'campaigning'),
            ],
          ),
          _buildNavRow(
            context,
            icon: Icons.handshake,
            iconColor: AppColors.primary,
            label: 'Networking',
            actions: const [
              _PoliticianAction('Join Party', 'join_party'),
              _PoliticianAction('Meet Leaders', 'meet_leaders'),
              _PoliticianAction('Fund Raising', 'fund_raising'),
            ],
          ),
          _buildNavRow(
            context,
            icon: Icons.how_to_vote,
            iconColor: AppColors.primary,
            label: 'Elections',
            actions: const [
              _PoliticianAction('Campaigning', 'campaigning'),
              _PoliticianAction('Political Debate', 'political_debate'),
              _PoliticianAction('Public Speech', 'public_speech'),
            ],
          ),
          _buildNavRow(
            context,
            icon: Icons.trending_up,
            iconColor: AppColors.primary,
            label: 'Career Progression',
            actions: const [
              _PoliticianAction('Meet Leaders', 'meet_leaders'),
              _PoliticianAction('Community Service', 'community_service'),
            ],
          ),
          _buildNavRow(
            context,
            icon: Icons.warning,
            iconColor: AppColors.danger,
            label: 'Scandals',
            actions: const [
              _PoliticianAction('Public Speech', 'public_speech'),
              _PoliticianAction('Meet Leaders', 'meet_leaders'),
            ],
          ),
          _buildNavRow(
            context,
            icon: Icons.emoji_events,
            iconColor: AppColors.primary,
            label: 'Legacy',
            actions: const [
              _PoliticianAction('Community Service', 'community_service'),
              _PoliticianAction('Public Speech', 'public_speech'),
            ],
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
    required List<_PoliticianAction> actions,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          useRootNavigator: true,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: actions
                  .map(
                    (action) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(action.label),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        onAction(action.id);
                      },
                    ),
                  )
                  .toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close',
                    style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: AppColors.divider, width: 1.0),
                ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.rowTitle,
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.divider, size: 20),
          ],
        ),
      ),
    );
  }
}

class _PoliticianAction {
  final String label;
  final String id;

  const _PoliticianAction(this.label, this.id);
}
