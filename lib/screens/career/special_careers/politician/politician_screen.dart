import 'package:flutter/material.dart';

import '../../../../core/design_system.dart';
import '../../../../core/engine.dart';
import '../../../../models/character.dart';
import '../../../../widgets/core/app_scaffold.dart';
import '../../../../widgets/core/app_status_banner.dart';
import '../../../../widgets/game/game_card.dart';
import '../../../../widgets/game/progress_bar.dart';
import '../../../../widgets/game/section_header.dart';

class PoliticianScreen extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const PoliticianScreen({
    super.key,
    required this.character,
    required this.onGameAction,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'POLITICIAN',
      bottomWidget: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => _emit('campaigning'),
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
              style: AppTextStyles.displayMd.copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
      children: [
        AppStatusBanner(
          label: 'POLITICIAN',
          title: character.name,
          subtitle: character.currentPosition.isNotEmpty
              ? character.currentPosition
              : null,
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatMoney(character.bankBalance),
                style: AppTextStyles.displayMd.copyWith(
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
              Text(
                'Age: ${character.age}',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const SectionHeader(title: 'CURRENT STATUS'),
        GameCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _InfoRow(
                label: 'Current Position',
                value: character.currentPosition,
                bold: true,
              ),
              _divider,
              _InfoRow(
                label: 'Party',
                value: character.partyName,
                muted: true,
              ),
              _divider,
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.containerPadding,
                  vertical: AppSpacing.sm,
                ),
                child: ProgressBarRow(
                  label: 'Popularity',
                  value: character.popularity.toDouble(),
                  color: AppColors.info,
                ),
              ),
              _divider,
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.containerPadding,
                  vertical: AppSpacing.sm,
                ),
                child: ProgressBarRow(
                  label: 'Public Trust',
                  value: character.publicTrust.toDouble(),
                  color: const Color(0xFFFF9875),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const SectionHeader(title: 'MANAGEMENT'),
        GameCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: _navSections.map((section) => _NavRow(
              emoji: section.emoji,
              label: section.label,
              iconColor: section.color,
              actions: section.actions,
              onAction: _emit,
              isLast: section == _navSections.last,
            )).toList(),
          ),
        ),
      ],
    );
  }

  void _emit(String actionId) {
    onGameAction(GameAction(
      'career.perform',
      {'actionId': 'career.politician.$actionId'},
    ));
  }

  static const _divider = Divider(height: 1, color: AppColors.divider);
}

class _NavSectionData {
  final String label;
  final String emoji;
  final Color color;
  final List<_PoliticianAction> actions;

  const _NavSectionData(this.label, this.emoji, this.color, this.actions);
}

class _PoliticianAction {
  final String label;
  final String id;

  const _PoliticianAction(this.label, this.id);
}

const _navSections = [
  _NavSectionData('Political Activities', '🏛️', AppColors.primary, [
    _PoliticianAction('Community Service', 'community_service'),
    _PoliticianAction('Attend Rally', 'attend_rally'),
    _PoliticianAction('Political Debate', 'political_debate'),
  ]),
  _NavSectionData('Public Image', '📢', AppColors.primary, [
    _PoliticianAction('Public Speech', 'public_speech'),
    _PoliticianAction('Campaigning', 'campaigning'),
  ]),
  _NavSectionData('Networking', '🤝', AppColors.primary, [
    _PoliticianAction('Join Party', 'join_party'),
    _PoliticianAction('Meet Leaders', 'meet_leaders'),
    _PoliticianAction('Fund Raising', 'fund_raising'),
  ]),
  _NavSectionData('Elections', '🗳️', AppColors.primary, [
    _PoliticianAction('Campaigning', 'campaigning'),
    _PoliticianAction('Political Debate', 'political_debate'),
    _PoliticianAction('Public Speech', 'public_speech'),
  ]),
  _NavSectionData('Career Progression', '📈', AppColors.primary, [
    _PoliticianAction('Meet Leaders', 'meet_leaders'),
    _PoliticianAction('Community Service', 'community_service'),
  ]),
  _NavSectionData('Scandals', '⚠️', AppColors.danger, [
    _PoliticianAction('Public Speech', 'public_speech'),
    _PoliticianAction('Meet Leaders', 'meet_leaders'),
  ]),
  _NavSectionData('Legacy', '🏆', AppColors.primary, [
    _PoliticianAction('Community Service', 'community_service'),
    _PoliticianAction('Public Speech', 'public_speech'),
  ]),
];

class _NavRow extends StatelessWidget {
  final String emoji;
  final String label;
  final Color iconColor;
  final List<_PoliticianAction> actions;
  final void Function(String) onAction;
  final bool isLast;

  const _NavRow({
    required this.emoji,
    required this.label,
    required this.iconColor,
    required this.actions,
    required this.onAction,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.containerPadding,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: AppColors.divider, width: 1),
                ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.outline, size: 20),
          ],
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.displayMd.copyWith(fontSize: 18),
                ),
                const SizedBox(height: AppSpacing.md),
                ...actions.map(
                  (action) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      action.label,
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      onAction(action.id);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final bool muted;

  const _InfoRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerPadding,
        vertical: 7,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.labelBold),
          Text(
            value,
            style: AppTextStyles.labelBold.copyWith(
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              color: muted ? AppColors.textSecondary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
