import 'package:flutter/material.dart';

import '../../../../../../core/design_system.dart';
import '../../../../../../models/character.dart';
import '../../../../../../widgets/core/app_scaffold.dart';
import '../data/tv_audition_generator.dart';
import '../models/tv_show_audition.dart';
import '../widgets/tv_audition_tile.dart';
import 'tv_audition_details_page.dart';

class TVAuditionsPage extends StatefulWidget {
  final Character character;
  final int currentYear;

  const TVAuditionsPage({
    super.key,
    required this.character,
    this.currentYear = 2026,
  });

  @override
  State<TVAuditionsPage> createState() => _TVAuditionsPageState();
}

class _TVAuditionsPageState extends State<TVAuditionsPage> {
  late List<TVShowAudition> _auditions;

  @override
  void initState() {
    super.initState();
    final tier = widget.character.actorStats?.stardomTier ?? 'Newcomer';
    final multiplier = widget.character.actorStats?.agency?.salaryMultiplier ?? 1.0;
    _auditions = TVAuditionGenerator.generateAuditionsForYear(
      widget.currentYear, 
      count: 10,
      stardomTier: tier,
      salaryMultiplier: multiplier,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'TV AUDITIONS',
      showBack: true,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.containerPadding, top: AppSpacing.cardGap, bottom: AppSpacing.sm),
          child: Text(
            'OPEN CASTING CALLS',
            style: AppTextStyles.sectionLabel.copyWith(fontSize: 13, letterSpacing: 1.0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
          child: Container(height: 1, color: AppColors.outline.withValues(alpha: 0.5)),
        ),
        ...List.generate(_auditions.length, (index) {
          final audition = _auditions[index];
          return TVAuditionTile(
            showTitle: audition.showTitle,
            genre: audition.genre,
            roleType: audition.roleType,
            iconEmoji: audition.iconEmoji,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => TVAuditionDetailsPage(character: widget.character, audition: audition)));
            },
          );
        }),
      ],
    );
  }
}
