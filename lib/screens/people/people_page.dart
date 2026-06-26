import 'package:flutter/material.dart';

import '../../core/design_system.dart';
import '../../core/engine.dart';
import '../../models/character.dart';
import '../../models/relationship.dart';
import '../../widgets/core/app_scaffold.dart';
import '../../widgets/game/game_card.dart';
import '../../widgets/game/section_header.dart';

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

    final socialReputation = character.reputation * 8 + character.fame * 2;
    final familySize = family.length;
    final avgRelationships = character.relationships.isEmpty
        ? 0.0
        : character.relationships.fold<double>(
                0.0, (s, r) => s + r.bond.toDouble()) /
            character.relationships.length;

    return AppScaffold(
      title: 'People',
      subtitle: 'Family, relationships and social life',
      padding: const EdgeInsets.only(left: 16, right: 16),
      children: [
        const SizedBox(height: 24),
        _buildSummaryCard(socialReputation, familySize, avgRelationships),
        const SizedBox(height: 16),
        _buildFamilyOverviewCard(),
        const SizedBox(height: 24),
        if (family.isNotEmpty) ...[
          const SectionHeader(
            title: 'FAMILY',
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 12),
          ),
          ...family.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildPersonCard(
                  relationship: r,
                  barColor: r.type == 'Sibling'
                      ? AppColors.tertiary
                      : AppColors.primary,
                ),
              )),
          const SizedBox(height: 8),
        ],
        if (friends.isNotEmpty) ...[
          const SectionHeader(
            title: 'FRIENDS',
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 12),
          ),
          ...friends.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildPersonCard(
                  relationship: r,
                  barColor: AppColors.primary,
                ),
              )),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSummaryCard(
      int socialReputation, int familySize, double avgRelationships) {
    return GameCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: AppTextStyles.headlineSm.copyWith(
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildBadge('Age ${character.age}'),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'SOCIAL REPUTATION',
                    style: AppTextStyles.labelBold.copyWith(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.08,
                    ),
                  ),
                  Text(
                    '$socialReputation',
                    style: AppTextStyles.displayMd.copyWith(
                      color: AppColors.primary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Family Size: ${familySize.toString().padLeft(2, '0')}',
                    style: AppTextStyles.labelSm.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.divider),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _statColumn(
                    'Happiness',
                    '${character.happiness}%',
                    AppColors.primary,
                  ),
                ),
                Container(width: 1, height: 32, color: AppColors.divider),
                Expanded(
                  child: _statColumn(
                    'Karma',
                    '${character.karma >= 0 ? '+' : ''}${character.karma}',
                    AppColors.tertiary,
                  ),
                ),
                Container(width: 1, height: 32, color: AppColors.divider),
                Expanded(
                  child: _statColumn(
                    'Relationships',
                    '${avgRelationships.round()}%',
                    AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _statColumn(String label, String value, Color? valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.labelBold.copyWith(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFamilyOverviewCard() {
    return GameCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onTap: () {},
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Family Overview',
                  style: AppTextStyles.headlineSm,
                ),
                Text(
                  'Closest people in your life',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.primary,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonCard({
    required Relationship relationship,
    required Color barColor,
  }) {
    return GameCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onTap: () => onGameAction(GameAction('relation.interact', {
        'relationshipId': relationship.id,
        'interactionType':
            relationship.type == 'Partner' ? 'Go on Date' : 'Spend Time',
      })),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _emojiForType(relationship.type),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      relationship.name,
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${relationship.type} \u2022 Age ${relationship.age}',
                      style: AppTextStyles.labelSm,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: relationship.bond.clamp(0, 100) / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _emojiForType(String type) {
    switch (type.toLowerCase()) {
      case 'father':
        return '\u{1F468}';
      case 'mother':
        return '\u{1F469}';
      case 'sibling':
        return '\u{1F466}';
      case 'friend':
        return '\u{1F64B}';
      case 'partner':
        return '\u2764\uFE0F';
      default:
        return '\u{1F464}';
    }
  }
}
