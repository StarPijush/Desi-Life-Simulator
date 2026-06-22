import 'package:flutter/material.dart';

import '../../../../core/design_system.dart';
import '../../../../models/character.dart';
import '../../../../models/actor_award.dart';
import '../../../../widgets/core/app_scaffold.dart';
import '../../../../widgets/core/app_status_banner.dart';
import '../../../../widgets/game/action_tile.dart';
import '../../../../widgets/game/game_card.dart';
import '../../../../widgets/game/progress_bar.dart';
import '../../../../widgets/game/section_header.dart';
import '../../../../widgets/game/status_chip.dart';
import '../../../../widgets/game/timeline_tile.dart';
import 'models/movie_project.dart';
import 'models/tv_project.dart';
import 'models/released_project.dart';
import 'movie_project_page.dart';
import 'pages/tv_project_page.dart';
import 'pages/movie_auditions_page.dart';
import 'pages/tv_auditions_page.dart';

class ActorPage extends StatelessWidget {
  final Character character;

  const ActorPage({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    final stats = character.actorStats;
    final activeProjects = stats?.activeProjects ?? [];
    final awards = stats?.actorAwards ?? [];
    final releasedMovies = stats?.releasedMovieProjects ?? [];
    final releasedTV = stats?.releasedTVProjects ?? [];
    final allReleases = [...releasedMovies, ...releasedTV];
    allReleases.sort((a, b) => b.year.compareTo(a.year));

    final income = character.annualIncome > 0
        ? character.annualIncome.toInt()
        : (stats?.experience ?? 0) * 10000;

    final monthlyIncome = character.annualIncome > 0
        ? (character.annualIncome / 12).round()
        : 0;

    return AppScaffold(
      title: 'ACTOR',
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      children: [
        AppStatusBanner(
          label: 'CURRENT IDENTITY',
          title: character.name.toUpperCase(),
          subtitle: null,
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'AGE: ${character.age}',
                style: AppTextStyles.labelSm.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '₹${formatMoney(income)}',
                style: AppTextStyles.displayMd.copyWith(
                  color: AppColors.primary,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Fame Meter
        const SectionHeader(title: 'FAME METER'),
        GameCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProgressBar(
                value: (stats?.fame ?? 0).toDouble(),
                color: const Color(0xFF2ECC71),
                height: 28,
                trackColor: const Color(0xFFDDE2F3),
                trackBorderColor: const Color(0xFFDDE2F3),
              ),
              const SizedBox(height: 6),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _FameLabel('Unknown'),
                  _FameLabel('Local Star'),
                  _FameLabel('Rising'),
                  _FameLabel('Celebrity'),
                  _FameLabel('Superstar'),
                  _FameLabel('Legend'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Current Projects
        const SectionHeader(title: 'Current Projects'),
        if (activeProjects.isEmpty)
          GameCard(
            child: Text(
              'No active projects. Go audition!',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          GameCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: activeProjects.asMap().entries.map((entry) {
                final isLast = entry.key == activeProjects.length - 1;
                final proj = entry.value;
                final isMovie = proj['type'] == 'movie';
                final progress = (proj['progress'] as double?) ?? 0.0;
                final status = (proj['status'] as String?) ?? 'PRE-PRODUCTION';

                return Column(
                  children: [
                    TimelineTile(
                      title: proj['title'] ?? 'Unknown Project',
                      subtitle: isMovie ? 'Movie' : 'TV Show',
                      status: status,
                      state: TimelineState.active,
                      onTap: () {
                        if (isMovie) {
                          final movieObj = MovieProject(
                            id: proj['id'] ?? '',
                            title: proj['title'] ?? '',
                            genre: proj['genre'] ?? '',
                            stage: status,
                            progress: progress,
                            director: proj['director'] ?? '',
                            budget: proj['budget'] ?? 0,
                            productionHouse: proj['productionHouse'] ?? '',
                            characterName: character.name,
                            roleType: proj['roleType'] ?? '',
                            salary: proj['salary'] ?? 0,
                            cast: [
                              MovieCastMember(
                                name: character.name,
                                role: proj['roleType'] ?? '',
                              ),
                            ],
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MovieProjectPage(project: movieObj),
                            ),
                          );
                        } else {
                          final tvObj = TVProject(
                            id: proj['id'] ?? '',
                            title: proj['title'] ?? '',
                            genre: proj['genre'] ?? '',
                            network: proj['network'] ?? '',
                            showStatus: status,
                            seasonNumber: 1,
                            totalEpisodes: 10,
                            completedEpisodes: (10 * progress).floor(),
                            productionProgress: progress,
                            director: 'Unknown',
                            producer: 'Unknown',
                            productionCompany: proj['network'] ?? '',
                            roleName: 'Unknown',
                            roleType: proj['roleType'] ?? '',
                            salaryPerEpisode: proj['salaryPerEpisode'] ?? 0,
                            signingBonus: 0,
                            contractLength: 0,
                            rating: 7.0,
                            fanGrowth: 0,
                            reputationImpact: 0,
                            fameImpact: 0,
                            castMembers: [
                              TVCastMember(
                                name: character.name,
                                role: proj['roleType'] ?? '',
                              ),
                            ],
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TVProjectPage(project: tvObj),
                            ),
                          );
                        }
                      },
                    ),
                    if (progress > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.containerPadding,
                        ),
                        child: ProgressBar(
                          value: progress * 100,
                          height: 6,
                          color: AppColors.primary,
                        ),
                      ),
                    if (!isLast) const Divider(height: 1, color: AppColors.divider),
                  ],
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 8),

        // Current Status
        const SectionHeader(title: 'Current Status'),
        GameCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _StatusRow(
                label: 'Current Role',
                value: character.jobTitle == 'Unemployed' ? 'None' : character.jobTitle,
              ),
              _divider,
              _StatusRow(
                label: 'Monthly Income',
                value: '₹${formatMoney(monthlyIncome)}',
                valueColor: AppColors.primary,
              ),
              _divider,
              _StatusRow(
                label: 'Awards Won',
                value: '${awards.length}',
              ),
              _divider,
              _StatusRow(
                label: 'Movies Completed',
                value: '${stats?.completedMovieProjects.length ?? 0}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Career Actions
        const SectionHeader(title: 'Career Actions'),
        GameCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              const ActionTile(
                emoji: '🎭',
                label: 'Join Acting School',
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Expanded(
                    child: ActionTile(emoji: '🔍', label: 'Find Talent Agent'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ActionTile(
                      emoji: '📺',
                      label: 'Audition TV',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TVAuditionsPage(character: character),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ActionTile(
                emoji: '🎬',
                label: 'Audition For Movie',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MovieAuditionsPage(character: character),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Actor Profile
        const SectionHeader(title: 'Actor Profile'),
        GameCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _StatusRow(
                label: 'Fame',
                value: '${stats?.fame ?? 0}%',
                valueColor: AppColors.primary,
              ),
              _divider,
              _StatusRow(
                label: 'Prestige',
                value: '${stats?.prestige ?? 0}%',
                valueColor: AppColors.primary,
              ),
              _divider,
              _StatusRow(
                label: 'Reputation',
                value: '${stats?.reputation ?? 50}%',
              ),
              _divider,
              _StatusRow(
                label: 'Acting Skill',
                value: '${stats?.actingSkill ?? 0}%',
              ),
              _divider,
              _StatusRow(
                label: 'Stardom Tier',
                value: stats?.stardomTier ?? 'Newcomer',
                valueColor: const Color(0xFFD3A300),
              ),
              _divider,
              _StatusRow(
                label: 'Agency',
                value: stats?.agency?.name ?? 'Independent',
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Awards History
        const SectionHeader(title: 'Awards History'),
        if (awards.isEmpty)
          GameCard(
            child: Text(
              'No awards or nominations yet.',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          GameCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: awards.map((award) => _buildAwardCard(award)).toList(),
            ),
          ),
        const SizedBox(height: 8),

        // Release History
        const SectionHeader(title: 'Release History'),
        if (allReleases.isEmpty)
          GameCard(
            child: Text(
              'No released projects yet.',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          ...allReleases.map((release) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _buildReleaseCard(release),
          )),
      ],
    );
  }

  Widget _buildAwardCard(ActorAward award) {
    final isWon = award.won;
    final isLifetime = award.category == 'Lifetime';
    final badgeColor = isLifetime
        ? const Color(0xFFD3A300)
        : isWon
            ? AppColors.primary
            : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(
            isLifetime
                ? Icons.stars_rounded
                : isWon
                    ? Icons.emoji_events_outlined
                    : Icons.workspace_premium_outlined,
            size: 28,
            color: badgeColor,
          ),
          const SizedBox(width: AppSpacing.cardGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  award.awardName,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${award.projectTitle} • ${award.year}',
                  style: AppTextStyles.labelSm.copyWith(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          StatusChip(
            label: isLifetime ? 'HONORED' : (isWon ? 'WON' : 'NOMINATED'),
            color: badgeColor,
          ),
        ],
      ),
    );
  }

  Widget _buildReleaseCard(ReleasedProject release) {
    final outcomeColor = switch (release.outcome) {
      'FLOP' => const Color(0xFFBA1A1A),
      'AVERAGE' => AppColors.textSecondary,
      'HIT' => AppColors.primary,
      'SUPER HIT' || 'BLOCKBUSTER' => const Color(0xFFD3A300),
      _ => AppColors.textSecondary,
    };

    return GameCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  release.title,
                  style: AppTextStyles.bodyLg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusChip(
                label: release.outcome,
                color: outcomeColor,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                release.type == 'movie' ? Icons.movie_outlined : Icons.tv_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${release.year}',
                style: AppTextStyles.labelSm.copyWith(fontSize: 12),
              ),
              const Spacer(),
              const Icon(Icons.star_half_outlined, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                'Critics: ${release.criticScore}%',
                style: AppTextStyles.labelSm.copyWith(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.people_outline, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                'Audience: ${release.audienceScore}%',
                style: AppTextStyles.labelSm.copyWith(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const _divider = Divider(height: 1, color: AppColors.divider);
}

class _FameLabel extends StatelessWidget {
  final String text;

  const _FameLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.caption.copyWith(
        fontSize: 9,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatusRow({
    required this.label,
    required this.value,
    this.valueColor,
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
          Text(
            label.toUpperCase(),
            style: AppTextStyles.labelBold.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMd.copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
