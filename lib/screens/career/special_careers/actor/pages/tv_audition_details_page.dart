import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/design_system.dart';
import '../../../../../models/character.dart';
import '../../../../../widgets/events/event_card.dart';
import '../../../../../widgets/events/event_types.dart';
import '../../../../../widgets/game/game_card.dart';
import '../../../../../widgets/game/section_header.dart';
import '../data/audition_engine.dart';
import '../models/tv_show_audition.dart';
import '../models/tv_project.dart';
import '../widgets/movie_detail_info_row.dart';
import '../widgets/movie_requirement_tile.dart';

class TVAuditionDetailsPage extends StatelessWidget {
  final Character character;
  final TVShowAudition audition;

  const TVAuditionDetailsPage({
    super.key,
    required this.character,
    required this.audition,
  });

  String _formatMoney(int amount) {
    final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return format.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iconBg,
      appBar: const _Header(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding, vertical: AppSpacing.cardGap),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 576),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroSection(audition: audition),
                const SizedBox(height: AppSpacing.cardGap),
                _ProjectDetailsCard(audition: audition),
                const SizedBox(height: AppSpacing.cardGap),
                _ContractOfferCard(audition: audition, formatMoney: _formatMoney),
                const SizedBox(height: AppSpacing.cardGap),
                _AuditionRequirementsCard(audition: audition),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _BottomActions(character: character, audition: audition),
    );
  }
}

class _Header extends StatelessWidget implements PreferredSizeWidget {
  const _Header();

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.iconBg,
      child: SafeArea(
        bottom: false,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.outline, width: 1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding, vertical: AppSpacing.sm),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(AppBorderRadius.full),
                child: const Padding(
                  padding: EdgeInsets.all(AppSpacing.xs),
                  child: Icon(Icons.arrow_back, color: AppColors.primary, size: 24),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'TV AUDITION',
                    style: AppTextStyles.labelBold.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Casting Opportunity',
                    style: AppTextStyles.sectionLabel.copyWith(letterSpacing: 1.0),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final TVShowAudition audition;

  const _HeroSection({required this.audition});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          audition.showTitle,
          style: AppTextStyles.displayMd.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.cardGap, vertical: AppSpacing.xs),
              color: AppColors.primary,
              child: Text(
                audition.genre.toUpperCase(),
                style: AppTextStyles.labelBold.copyWith(fontSize: 13, color: AppColors.surface),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.cardGap, vertical: AppSpacing.xs),
              color: AppColors.dividerLight,
              child: Text(
                audition.network.toUpperCase(),
                style: AppTextStyles.labelBold.copyWith(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProjectDetailsCard extends StatelessWidget {
  final TVShowAudition audition;

  const _ProjectDetailsCard({required this.audition});

  @override
  Widget build(BuildContext context) {
    return GameCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Project Details'),
          MovieDetailInfoRow(label: 'Network', value: audition.network),
          MovieDetailInfoRow(label: 'Season', value: '${audition.seasonNumber}'),
          MovieDetailInfoRow(label: 'Episodes', value: '${audition.episodes}'),
          MovieDetailInfoRow(label: 'Role Type', value: audition.roleType),
        ],
      ),
    );
  }
}

class _ContractOfferCard extends StatelessWidget {
  final TVShowAudition audition;
  final String Function(int) formatMoney;

  const _ContractOfferCard({required this.audition, required this.formatMoney});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Contract Offer', style: AppTextStyles.labelBold.copyWith(
            fontSize: 13,
            color: AppColors.primary,
            letterSpacing: 1.0,
          )),
          MovieDetailInfoRow(label: 'Per Episode', value: formatMoney(audition.salaryPerEpisode), valueColor: AppColors.primary),
          MovieDetailInfoRow(label: 'Total Potential', value: formatMoney(audition.salaryPerEpisode * audition.episodes), valueColor: AppColors.primary),
        ],
      ),
    );
  }
}

class _AuditionRequirementsCard extends StatelessWidget {
  final TVShowAudition audition;

  const _AuditionRequirementsCard({required this.audition});

  @override
  Widget build(BuildContext context) {
    return GameCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Audition Requirements'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.cardGap,
            crossAxisSpacing: AppSpacing.cardGap,
            childAspectRatio: 2.5,
            children: [
              MovieRequirementTile(label: 'Fame', value: '${audition.requiredFame}+'),
              MovieRequirementTile(label: 'Acting', value: '${audition.requiredActing}+'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final Character character;
  final TVShowAudition audition;

  const _BottomActions({required this.character, required this.audition});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.iconBg,
      padding: EdgeInsets.only(
        left: AppSpacing.containerPadding,
        right: AppSpacing.containerPadding,
        top: AppSpacing.containerPadding,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.containerPadding,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.outline, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () async {
              final success = AuditionEngine.processAudition(character, audition.difficulty);
              final stats = character.actorStats!;
              
              if (success) {
                stats.experience += 10;
                stats.fame += 2;
                
                final project = TVProject(
                  id: 'tv_${DateTime.now().millisecondsSinceEpoch}',
                  title: audition.showTitle,
                  genre: audition.genre,
                  network: audition.network,
                  showStatus: 'IN PRODUCTION',
                  seasonNumber: audition.seasonNumber,
                  totalEpisodes: audition.episodes,
                  completedEpisodes: 0,
                  productionProgress: 0.0,
                  director: 'Unknown',
                  producer: 'Unknown',
                  productionCompany: audition.network,
                  roleName: 'Unknown Role',
                  roleType: audition.roleType,
                  salaryPerEpisode: audition.salaryPerEpisode,
                  signingBonus: 0,
                  contractLength: audition.episodes * 5,
                  rating: 7.0,
                  fanGrowth: 5,
                  reputationImpact: 5,
                  fameImpact: 5,
                  castMembers: [TVCastMember(name: character.name, role: audition.roleType)],
                );
                
                stats.activeProjects.add({
                  'type': 'tv',
                  'id': project.id,
                  'title': project.title,
                  'genre': project.genre,
                  'roleType': project.roleType,
                  'network': project.network,
                  'salaryPerEpisode': project.salaryPerEpisode,
                  'status': 'PRE-PRODUCTION',
                  'progress': 0.0,
                  'recentEvents': [],
                });
                
                character.triggerMutation();
                character.save();
                
                await showEventCard(
                  context: context,
                  category: EventCategory.career,
                  mode: EventCardMode.info,
                  title: 'CASTING SUCCESS',
                  description: 'You have been selected for the role.',
                  infoRows: [
                    EventInfoRow(label: 'TV Show', value: project.title),
                    EventInfoRow(label: 'Role', value: project.roleType),
                    EventInfoRow(label: 'Per Episode', value: '₹${audition.salaryPerEpisode}'),
                    EventInfoRow(label: 'Network', value: project.network),
                  ],
                  primaryAction: EventCardAction(label: 'Accept Role', onPressed: () {
                    Navigator.of(context).pop();
                  }),
                );
                
                if (context.mounted) Navigator.of(context).pop();
                
              } else {
                stats.experience += 2;
                character.triggerMutation();
                character.save();
                
                final reqScore = AuditionEngine.getRequiredScore(audition.difficulty);
                final myScore = AuditionEngine.calculatePlayerScore(character);
                
                String hint = 'Keep gaining Experience.';
                if (stats.actingSkill < 50) hint = 'Increase Acting Skill.';
                else if (stats.fame < 30) hint = 'Increase Fame.';
                else if (stats.reputation < 40) hint = 'Improve Reputation.';
                
                await showEventCard(
                  context: context,
                  category: EventCategory.career,
                  mode: EventCardMode.info,
                  title: 'AUDITION REJECTED',
                  description: 'Another actor was selected.\n\nImprovement Hint: $hint',
                  infoRows: [
                    EventInfoRow(label: 'Required Score', value: '$reqScore'),
                    EventInfoRow(label: 'Your Score', value: '$myScore'),
                  ],
                  primaryAction: EventCardAction(label: 'Okay', onPressed: () {
                    Navigator.of(context).pop();
                  }),
                );
                
                if (context.mounted) Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: Text(
              'APPLY FOR AUDITION',
              style: AppTextStyles.labelBold.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 2),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.cardGap),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: Text(
              'DECLINE',
              style: AppTextStyles.labelBold.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
