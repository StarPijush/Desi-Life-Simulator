import 'package:flutter/material.dart';

import '../../core/design_system.dart';
import '../../core/engine.dart';
import '../../models/character.dart';
import '../../models/relationship.dart';
import '../../widgets/core/app_scaffold.dart';
import '../../widgets/core/app_status_banner.dart';
import '../../widgets/game/action_tile.dart';
import '../../widgets/game/game_card.dart';
import '../../widgets/game/progress_bar.dart';
import '../../widgets/game/section_header.dart';
import '../../widgets/game/stats_section.dart';

class PeoplePage extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const PeoplePage({
    super.key,
    required this.character,
    required this.onGameAction,
  });

  @override
  Widget build(BuildContext context) {
    final family = character.relationships
        .where((r) => ['Father', 'Mother', 'Sibling'].contains(r.type))
        .toList();
    final friends = character.relationships
        .where((r) => r.type == 'Friend')
        .toList();
    final partners = character.relationships
        .where((r) => r.type == 'Partner')
        .toList();

    return AppScaffold(
      title: 'People',
      children: [
        AppStatusBanner(
          label: 'CURRENT IDENTITY',
          title: character.name,
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Age: ${character.age}',
                style: AppTextStyles.displayMd.copyWith(
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
              Text(
                formatMoney(character.bankBalance),
                style: AppTextStyles.labelSm.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (family.isNotEmpty) ...[
          const SectionHeader(
            title: 'FAMILY',
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.containerPadding,
              vertical: AppSpacing.sm,
            ),
          ),
          GameCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: family.map((r) => _PersonTile(
                relationship: r,
                onGameAction: onGameAction,
              )).toList(),
            ),
          ),
          const SizedBox(height: 8),
        ],
        const SectionHeader(
          title: 'RELATIONSHIPS',
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.containerPadding,
            vertical: AppSpacing.sm,
          ),
        ),
        _buildRelationshipsContent(partners, friends),
        const SizedBox(height: 16),
        StatsSection(
          title: 'CORE VITALS',
          stats: [
            StatItem(
              label: 'Happiness',
              value: character.happiness.toDouble(),
              color: AppColors.primary,
            ),
            StatItem(
              label: 'Health',
              value: character.health.toDouble(),
              color: AppColors.primary,
            ),
            StatItem(
              label: 'Karma',
              value: character.karma.toDouble(),
              color: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRelationshipsContent(
    List<Relationship> partners,
    List<Relationship> friends,
  ) {
    final tiles = <Widget>[];

    if (character.age >= 16) {
      tiles.add(ActionTile(
        emoji: '❤️',
        label: 'Find a Partner',
        onTap: () => onGameAction(const GameAction('activity.find_love')),
      ));
    }

    for (final p in partners) {
      tiles.add(_PersonTile(
        relationship: p,
        onGameAction: onGameAction,
      ));
    }

    if (friends.isNotEmpty) {
      tiles.add(ActionTile(
        emoji: '👥',
        label: 'View Friends',
        onTap: () {},
      ));
    }

    return GameCard(
      padding: EdgeInsets.zero,
      child: Column(children: tiles),
    );
  }
}

class _PersonTile extends StatelessWidget {
  final Relationship relationship;
  final void Function(GameAction) onGameAction;

  const _PersonTile({
    required this.relationship,
    required this.onGameAction,
  });

  String get _emoji {
    switch (relationship.type.toLowerCase()) {
      case 'mother':
        return '👩';
      case 'father':
        return '👨';
      case 'partner':
        return '❤️';
      default:
        return '👤';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onGameAction(GameAction('relation.interact', {
        'relationshipId': relationship.id,
        'interactionType':
            relationship.type == 'Partner' ? 'Go on Date' : 'Spend Time',
      })),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.containerPadding,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              color: AppColors.iconBg,
              alignment: Alignment.center,
              child: Text(_emoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: AppSpacing.sm + 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    relationship.name,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    relationship.type.toUpperCase(),
                    style: AppTextStyles.labelSm.copyWith(fontSize: 10),
                  ),
                  const SizedBox(height: 4),
                  ProgressBar(
                    value: relationship.bond.toDouble(),
                    height: 6,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(Icons.chevron_right, color: AppColors.outline, size: 22),
          ],
        ),
      ),
    );
  }
}
