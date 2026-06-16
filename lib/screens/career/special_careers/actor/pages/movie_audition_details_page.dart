import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../models/character.dart';
import '../../../../../widgets/events/event_card.dart';
import '../../../../../widgets/events/event_types.dart';
import '../models/movie_audition.dart';
import '../models/movie_project.dart';
import '../data/audition_engine.dart';
import '../widgets/movie_detail_info_row.dart';
import '../widgets/movie_requirement_tile.dart';

class MovieAuditionDetailsPage extends StatelessWidget {
  final Character character;
  final MovieAudition audition;

  const MovieAuditionDetailsPage({
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
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: const _Header(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 576), // max-w-xl
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroSection(audition: audition),
                const SizedBox(height: 12),
                _ProjectDetailsCard(audition: audition, formatMoney: _formatMoney),
                const SizedBox(height: 12),
                _ContractOfferCard(audition: audition, formatMoney: _formatMoney),
                const SizedBox(height: 12),
                _AuditionRequirementsCard(audition: audition),
                const SizedBox(height: 12),
                _CareerImpactCard(audition: audition),
                const SizedBox(height: 32),
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
      color: const Color(0xFFF9F9FF),
      child: SafeArea(
        bottom: false,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'MOVIE AUDITION',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF006D37),
                    ),
                  ),
                  Text(
                    'Casting Opportunity',
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5C5E62),
                      letterSpacing: 1.0,
                    ),
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
  final MovieAudition audition;

  const _HeroSection({required this.audition});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          audition.movieTitle,
          style: GoogleFonts.lexend(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF161C28),
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              color: const Color(0xFF006D37),
              child: Text(
                audition.genre.toUpperCase(),
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              color: const Color(0xFFDDE2F3),
              child: Text(
                audition.productionHouse.toUpperCase(),
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3D4A3E),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fiber_manual_record, color: Color(0xFF006D37), size: 18),
            const SizedBox(width: 4),
            Text(
              audition.status.toUpperCase(),
              style: GoogleFonts.lexend(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF006D37),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FlatCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;

  const _FlatCard({
    required this.child,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFBBCBBB),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: const EdgeInsets.all(16.0),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({
    required this.title,
    this.color = const Color(0xFF5C5E62),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.lexend(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _ProjectDetailsCard extends StatelessWidget {
  final MovieAudition audition;
  final String Function(int) formatMoney;

  const _ProjectDetailsCard({required this.audition, required this.formatMoney});

  @override
  Widget build(BuildContext context) {
    return _FlatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Project Details'),
          MovieDetailInfoRow(label: 'Genre', value: audition.genre),
          MovieDetailInfoRow(label: 'Budget', value: formatMoney(audition.budget)),
          MovieDetailInfoRow(label: 'Director', value: audition.director),
          MovieDetailInfoRow(label: 'Role Type', value: audition.roleType),
        ],
      ),
    );
  }
}

class _ContractOfferCard extends StatelessWidget {
  final MovieAudition audition;
  final String Function(int) formatMoney;

  const _ContractOfferCard({required this.audition, required this.formatMoney});

  @override
  Widget build(BuildContext context) {
    return _FlatCard(
      backgroundColor: const Color(0xFF2ECC71).withValues(alpha: 0.1),
      borderColor: const Color(0xFF006D37),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Contract Offer', color: Color(0xFF006D37)),
          MovieDetailInfoRow(label: 'Salary', value: formatMoney(audition.salary), valueColor: const Color(0xFF006D37)),
          MovieDetailInfoRow(label: 'Signing Bonus', value: formatMoney(audition.signingBonus)),
          MovieDetailInfoRow(label: 'Revenue Share', value: '${(audition.revenueShare * 100).toInt()}%'),
          MovieDetailInfoRow(label: 'Duration', value: '${audition.contractDuration} Days'),
        ],
      ),
    );
  }
}

class _AuditionRequirementsCard extends StatelessWidget {
  final MovieAudition audition;

  const _AuditionRequirementsCard({required this.audition});

  @override
  Widget build(BuildContext context) {
    return _FlatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Audition Requirements'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              MovieRequirementTile(label: 'Fame', value: '${audition.requiredFame}+'),
              MovieRequirementTile(label: 'Acting', value: '${audition.requiredActing}+'),
              MovieRequirementTile(label: 'Reputation', value: '${audition.requiredReputation}+'),
              MovieRequirementTile(label: 'Age', value: '${audition.requiredAge}+'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CareerImpactCard extends StatelessWidget {
  final MovieAudition audition;

  const _CareerImpactCard({required this.audition});

  @override
  Widget build(BuildContext context) {
    return _FlatCard(
      backgroundColor: const Color(0xFFDDE2F3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Career Impact'),
          MovieDetailInfoRow(label: 'Fame Gain', value: '+${audition.fameGain}%', valueColor: const Color(0xFF006D37)),
          MovieDetailInfoRow(label: 'Reputation', value: '+${audition.reputationGain}%', valueColor: const Color(0xFF006D37)),
          MovieDetailInfoRow(label: 'Award Potential', value: audition.awardPotential),
          MovieDetailInfoRow(label: 'Risk Level', value: audition.riskLevel, valueColor: const Color(0xFF98472A)),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final Character character;
  final MovieAudition audition;

  const _BottomActions({required this.character, required this.audition});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9F9FF),
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: MediaQuery.of(context).padding.bottom + 16.0,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
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
                
                final project = MovieProject(
                  id: 'movie_${DateTime.now().millisecondsSinceEpoch}',
                  title: audition.movieTitle,
                  genre: audition.genre,
                  stage: 'Pre-Production',
                  progress: 0.0,
                  director: audition.director,
                  budget: audition.budget,
                  productionHouse: audition.productionHouse,
                  characterName: 'Unknown',
                  roleType: audition.roleType,
                  salary: audition.salary,
                  cast: [MovieCastMember(name: character.name, role: audition.roleType)],
                );
                
                stats.activeProjects.add({
                  'type': 'movie',
                  'id': project.id,
                  'title': project.title,
                  'genre': project.genre,
                  'roleType': project.roleType,
                  'director': project.director,
                  'productionHouse': project.productionHouse,
                  'salary': project.salary,
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
                    EventInfoRow(label: 'Project Name', value: project.title),
                    EventInfoRow(label: 'Role', value: project.roleType),
                    EventInfoRow(label: 'Salary', value: '₹${audition.salary}'),
                    EventInfoRow(label: 'Production House', value: project.productionHouse),
                  ],
                  primaryAction: EventCardAction(label: 'Accept Role', onPressed: () {
                    Navigator.of(context).pop();
                  }),
                );
                
                // Navigate back to auditions page
                if (context.mounted) Navigator.of(context).pop();
                
              } else {
                stats.experience += 2;
                character.triggerMutation();
                character.save();
                
                final reqScore = AuditionEngine.getRequiredScore(audition.difficulty);
                final myScore = AuditionEngine.calculatePlayerScore(character);
                
                // Generate improvement hint
                String hint = 'Keep gaining Experience.';
                if (stats.actingSkill < 50) hint = 'Increase Acting Skill.';
                else if (stats.fame < 30) hint = 'Increase Fame.';
                else if (stats.reputation < 40) hint = 'Improve Reputation.';
                
                await showEventCard(
                  context: context,
                  category: EventCategory.career,
                  mode: EventCardMode.info,
                  title: 'AUDITION REJECTED',
                  description: 'Another actor was selected.\\n\\nImprovement Hint: $hint',
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
              backgroundColor: const Color(0xFF006D37),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: Text(
              'APPLY FOR AUDITION',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF006D37),
              side: const BorderSide(color: Color(0xFF006D37), width: 2),
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: Text(
              'DECLINE',
              style: GoogleFonts.lexend(
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
