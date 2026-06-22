import 'package:flutter/material.dart';

import '../../../../../../core/design_system.dart';
import '../../../../../../models/character.dart';
import '../../../../../../widgets/core/app_scaffold.dart';
import '../data/audition_generator.dart';
import '../models/movie_audition.dart';
import '../widgets/movie_audition_tile.dart';
import 'movie_audition_details_page.dart';

class MovieAuditionsPage extends StatefulWidget {
  final Character character;
  final int currentYear;

  const MovieAuditionsPage({
    super.key,
    required this.character,
    this.currentYear = 2026,
  });

  @override
  State<MovieAuditionsPage> createState() => _MovieAuditionsPageState();
}

class _MovieAuditionsPageState extends State<MovieAuditionsPage> {
  late List<MovieAudition> _auditions;

  @override
  void initState() {
    super.initState();
    final tier = widget.character.actorStats?.stardomTier ?? 'Newcomer';
    final multiplier = widget.character.actorStats?.agency?.salaryMultiplier ?? 1.0;
    _auditions = AuditionGenerator.generateAuditionsForYear(
      widget.currentYear, 
      count: 10,
      stardomTier: tier,
      salaryMultiplier: multiplier,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'MOVIE AUDITIONS',
      showBack: true,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding, vertical: AppSpacing.xs),
          decoration: const BoxDecoration(
            color: AppColors.iconBg,
            border: Border(bottom: BorderSide(color: AppColors.outline, width: 1)),
          ),
          child: Text(
            'OPEN CASTING CALLS',
            style: AppTextStyles.labelBold.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...List.generate(_auditions.length, (index) {
          final audition = _auditions[index];
          return MovieAuditionTile(
            title: audition.movieTitle,
            genre: audition.genre,
            roleType: audition.roleType,
            iconEmoji: audition.iconEmoji,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => MovieAuditionDetailsPage(character: widget.character, audition: audition)));
            },
          );
        }),
      ],
    );
  }
}
