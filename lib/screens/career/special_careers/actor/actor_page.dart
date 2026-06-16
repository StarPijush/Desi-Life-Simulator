import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../models/character.dart';
import '../../../../../models/actor_award.dart';
import 'models/movie_project.dart';
import 'models/tv_project.dart';
import 'movie_project_page.dart';
import 'pages/tv_project_page.dart';
import 'pages/movie_auditions_page.dart';
import 'pages/tv_auditions_page.dart';

class ActorPage extends StatelessWidget {
  final Character character;

  const ActorPage({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const ActorHeader(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ActorIdentityBar(character: character),
              const SizedBox(height: 24),
              FameMeter(percentage: character.actorStats!.fame / 100),
              const SizedBox(height: 24),
              CurrentProjectsSection(character: character),
              const SizedBox(height: 24),
              CurrentStatusSection(character: character),
              const SizedBox(height: 32),
              CareerActionsSection(character: character),
              const SizedBox(height: 32),
              ActorProfileSection(character: character),
              const SizedBox(height: 24),
              AchievementsSection(character: character),
              const SizedBox(height: 96), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Header & Identity
// ============================================================================

class ActorHeader extends StatelessWidget implements PreferredSizeWidget {
  const ActorHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFFFF),
      child: SafeArea(
        bottom: false,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
          ),
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0, top: 8.0),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.arrow_back, color: Color(0xFF006D37), size: 24),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'ACTOR',
                style: GoogleFonts.lexend(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF006D37),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56); // Matches FlatBackAppBar
}

class ActorIdentityBar extends StatelessWidget {
  final Character character;
  
  const ActorIdentityBar({super.key, required this.character});

  // Formatter for income
  String _formatMoney(int amount) {
    final str = amount.toString();
    if (str.length <= 3) return str;
    
    String result = str.substring(str.length - 3);
    String remaining = str.substring(0, str.length - 3);
    
    while (remaining.isNotEmpty) {
      if (remaining.length > 2) {
        result = '${remaining.substring(remaining.length - 2)},$result';
        remaining = remaining.substring(0, remaining.length - 2);
      } else {
        result = '$remaining,$result';
        remaining = '';
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final income = (character.annualIncome > 0) ? character.annualIncome.toInt() : (character.actorStats?.experience ?? 0) * 10000;
    
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF161C28), width: 2)),
      ),
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CURRENT IDENTITY',
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5C5E62),
                ),
              ),
              Text(
                character.name.toUpperCase(),
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF161C28),
                  height: 1.2,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'AGE: ${character.age}',
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5C5E62),
                ),
              ),
              Text(
                '₹${_formatMoney(income)}',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF006D37),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Core Components
// ============================================================================

class ActorSectionHeader extends StatelessWidget {
  final String title;

  const ActorSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Color(0xFF006D37), width: 4)),
      ),
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.lexend(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF161C28),
        ),
      ),
    );
  }
}

class ActorInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const ActorInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF161C28),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.lexend(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF5C5E62),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: const ActorDottedLine(),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class ActorDottedLine extends StatelessWidget {
  const ActorDottedLine({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 2.0;
        const dashSpace = 4.0;
        final dashCount = (constraints.constrainWidth() / (dashWidth + dashSpace)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: 1.5,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFBBCBBB)),
              ),
            );
          }),
        );
      },
    );
  }
}

// ============================================================================
// Fame Meter
// ============================================================================

class FameMeter extends StatelessWidget {
  final double percentage; // 0.0 to 1.0

  const FameMeter({super.key, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FAME METER',
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF5C5E62),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 32,
          width: double.infinity,
          color: const Color(0xFFDDE2F3),
          child: Row(
            children: [
              Expanded(
                flex: (percentage * 100).toInt(),
                child: Container(
                  color: const Color(0xFF2ECC71),
                ),
              ),
              Expanded(
                flex: ((1 - percentage) * 100).toInt(),
                child: const SizedBox(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _FameStageLabel('Unknown'),
            _FameStageLabel('Local Star'),
            _FameStageLabel('Rising Actor'),
            _FameStageLabel('Celebrity'),
            _FameStageLabel('Superstar'),
            _FameStageLabel('Legend'),
          ],
        ),
      ],
    );
  }
}

class _FameStageLabel extends StatelessWidget {
  final String text;

  const _FameStageLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.lexend(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF5C5E62),
        letterSpacing: -0.5,
      ),
    );
  }
}

// ============================================================================
// Sections
// ============================================================================

class CurrentProjectsSection extends StatelessWidget {
  final Character character;

  const CurrentProjectsSection({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    final activeProjects = character.actorStats?.activeProjects ?? [];

    if (activeProjects.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ActorSectionHeader(title: 'Current Projects'),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'No active projects. Go audition!',
              style: GoogleFonts.lexend(
                color: const Color(0xFF5C5E62),
                fontSize: 14,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ActorSectionHeader(title: 'Current Projects'),
        ...activeProjects.map((proj) {
          final isMovie = proj['type'] == 'movie';
          final progress = (proj['progress'] as double?) ?? 0.0;
          final status = (proj['status'] as String?) ?? 'PRE-PRODUCTION';

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ActorProjectTile(
              title: proj['title'] ?? 'Unknown Project',
              subtitle: status,
              icon: isMovie ? Icons.movie_creation : Icons.live_tv,
              progress: progress,
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
                    cast: [MovieCastMember(name: character.name, role: proj['roleType'] ?? '')],
                  );
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MovieProjectPage(project: movieObj)));
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
                    castMembers: [TVCastMember(name: character.name, role: proj['roleType'] ?? '')],
                  );
                  Navigator.push(context, MaterialPageRoute(builder: (_) => TVProjectPage(project: tvObj)));
                }
              },
            ),
          );
        }),
      ],
    );
  }
}

class ActorProjectTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final double progress;
  final VoidCallback onTap;

  const ActorProjectTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF1F3FF),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFBBCBBB), width: 1),
          ),
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.lexend(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF161C28),
                              ),
                            ),
                            Text(
                              subtitle,
                              style: GoogleFonts.lexend(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF5C5E62),
                              ),
                            ),
                          ],
                        ),
                        Icon(icon, color: const Color(0xFF006D37), size: 24),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 6,
                      width: double.infinity,
                      color: const Color(0xFFFFFFFF),
                      child: Row(
                        children: [
                          Expanded(
                            flex: (progress * 100).toInt(),
                            child: Container(color: const Color(0xFF006D37)),
                          ),
                          Expanded(
                            flex: ((1 - progress) * 100).toInt(),
                            child: const SizedBox(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.chevron_right, color: Color(0xFFBBCBBB), size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class CurrentStatusSection extends StatelessWidget {
  final Character character;

  const CurrentStatusSection({super.key, required this.character});

  // Formatter for income
  String _formatMoney(int amount) {
    final str = amount.toString();
    if (str.length <= 3) return str;
    
    String result = str.substring(str.length - 3);
    String remaining = str.substring(0, str.length - 3);
    
    while (remaining.isNotEmpty) {
      if (remaining.length > 2) {
        result = '${remaining.substring(remaining.length - 2)},$result';
        remaining = remaining.substring(0, remaining.length - 2);
      } else {
        result = '$remaining,$result';
        remaining = '';
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final monthlyIncome = (character.annualIncome > 0) ? (character.annualIncome / 12).round() : 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ActorSectionHeader(title: 'Current Status'),
        ActorInfoRow(label: 'Current Role', value: character.jobTitle == 'Unemployed' ? 'None' : character.jobTitle),
        ActorInfoRow(label: 'Monthly Income', value: '₹${_formatMoney(monthlyIncome)}', valueColor: const Color(0xFF006D37)),
        ActorInfoRow(label: 'Awards Won', value: '${character.actorStats?.actorAwards.length ?? 0}'),
        ActorInfoRow(label: 'Movies Completed', value: '${character.actorStats?.completedMovieProjects.length ?? 0}'),
      ],
    );
  }
}

class CareerActionsSection extends StatelessWidget {
  final Character character;

  const CareerActionsSection({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ActorSectionHeader(title: 'Career Actions'),
        Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFFBBCBBB), width: 1),
              bottom: BorderSide(color: Color(0xFFBBCBBB), width: 1),
            ),
          ),
          child: Column(
            children: [
              const ActorActionTile(icon: Icons.school, label: 'Join Acting School'),
              const ActorActionTile(icon: Icons.person_search, label: 'Find Talent Agent'),
              ActorActionTile(
                icon: Icons.tv,
                label: 'Audition For TV Show',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => TVAuditionsPage(character: character)));
                },
              ),
              ActorActionTile(
                icon: Icons.movie, 
                label: 'Audition For Movie', 
                showBottomBorder: false,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MovieAuditionsPage(character: character)));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ActorActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool showBottomBorder;
  final VoidCallback? onTap;

  const ActorActionTile({
    super.key,
    required this.icon,
    required this.label,
    this.showBottomBorder = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {}, // Future integration
        child: Container(
          decoration: BoxDecoration(
            border: showBottomBorder
                ? const Border(bottom: BorderSide(color: Color(0xFFBBCBBB), width: 1))
                : null,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF5C5E62), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF161C28),
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFBBCBBB), size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class ActorProfileSection extends StatelessWidget {
  final Character character;

  const ActorProfileSection({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ActorSectionHeader(title: 'Actor Profile'),
        ActorInfoRow(label: 'Fame', value: '${character.actorStats?.fame ?? 0}%', valueColor: const Color(0xFF006D37)),
        ActorInfoRow(label: 'Prestige', value: '${character.actorStats?.prestige ?? 0}%', valueColor: const Color(0xFF006D37)),
        ActorInfoRow(label: 'Reputation', value: '${character.actorStats?.reputation ?? 50}%'),
        ActorInfoRow(label: 'Acting Skill', value: '${character.actorStats?.actingSkill ?? 0}%'),
        ActorInfoRow(label: 'Stardom Tier', value: character.actorStats?.stardomTier ?? 'Newcomer', valueColor: const Color(0xFFD3A300)),
        ActorInfoRow(label: 'Agency', value: character.actorStats?.agency?.name ?? 'Independent'),
      ],
    );
  }
}

class AchievementsSection extends StatelessWidget {
  final Character character;

  const AchievementsSection({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    final awards = character.actorStats?.actorAwards ?? [];
    final releasedMovies = character.actorStats?.releasedMovieProjects ?? [];
    final releasedTV = character.actorStats?.releasedTVProjects ?? [];
    
    // Combine and sort by year descending
    final allReleases = [...releasedMovies, ...releasedTV];
    allReleases.sort((a, b) => b.year.compareTo(a.year));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ActorSectionHeader(title: 'Awards History'),
        if (awards.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 16.0),
            child: Text(
              'No awards or nominations yet.',
              style: TextStyle(color: Color(0xFF5C5E62)),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              children: awards.map((award) => _buildAwardCard(award)).toList(),
            ),
          ),
          
        const ActorSectionHeader(title: 'Release History'),
        if (allReleases.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'No released projects yet.',
              style: TextStyle(color: Color(0xFF5C5E62)),
            ),
          )
        else
          Column(
            children: allReleases.map((release) => _buildReleaseCard(release)).toList(),
          ),
      ],
    );
  }

  Widget _buildAwardCard(ActorAward award) {
    final isWon = award.won;
    final isLifetime = award.category == 'Lifetime';
    final badgeColor = isLifetime
        ? const Color(0xFFD3A300) // Gold for lifetime
        : isWon
            ? const Color(0xFF006D37) // Green for won
            : const Color(0xFF5C5E62); // Grey for nominated
    final badgeText = isLifetime ? 'HONORED' : (isWon ? 'WON' : 'NOMINATED');
    final iconData = isLifetime
        ? Icons.stars_rounded
        : isWon
            ? Icons.emoji_events_outlined
            : Icons.workspace_premium_outlined;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E2E6)),
      ),
      child: Row(
        children: [
          Icon(iconData, size: 28, color: badgeColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  award.awardName,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF161C28),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${award.projectTitle} • ${award.year}',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    color: const Color(0xFF5C5E62),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badgeText,
              style: GoogleFonts.lexend(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReleaseCard(dynamic release) {
    Color outcomeColor;
    switch (release.outcome) {
      case 'FLOP':
        outcomeColor = const Color(0xFFBA1A1A); // Red
        break;
      case 'AVERAGE':
        outcomeColor = const Color(0xFF5C5E62); // Grey
        break;
      case 'HIT':
        outcomeColor = const Color(0xFF006D37); // Green
        break;
      case 'SUPER HIT':
      case 'BLOCKBUSTER':
        outcomeColor = const Color(0xFFD3A300); // Gold
        break;
      default:
        outcomeColor = const Color(0xFF5C5E62);
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E2E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  release.title,
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF161C28),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: outcomeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  release.outcome,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: outcomeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(release.type == 'movie' ? Icons.movie_outlined : Icons.tv_outlined, size: 14, color: const Color(0xFF5C5E62)),
              const SizedBox(width: 4),
              Text(
                '${release.year}',
                style: GoogleFonts.lexend(fontSize: 12, color: const Color(0xFF5C5E62)),
              ),
              const Spacer(),
              const Icon(Icons.star_half_outlined, size: 14, color: Color(0xFF006D37)),
              const SizedBox(width: 4),
              Text(
                'Critics: ${release.criticScore}%',
                style: GoogleFonts.lexend(fontSize: 12, color: const Color(0xFF161C28), fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.people_outline, size: 14, color: Color(0xFF006D37)),
              const SizedBox(width: 4),
              Text(
                'Audience: ${release.audienceScore}%',
                style: GoogleFonts.lexend(fontSize: 12, color: const Color(0xFF161C28), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
