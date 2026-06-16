import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../models/character.dart';
import '../models/tv_show_audition.dart';
import '../data/tv_audition_generator.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: const _TVAuditionsHeader(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section heading
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 8.0),
            child: Text(
              'OPEN CASTING CALLS',
              style: GoogleFonts.lexend(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3D4A3E),
                letterSpacing: 1.0,
              ),
            ),
          ),
          // Subtle divider below heading
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Opacity(
              opacity: 0.5,
              child: Container(height: 1, color: const Color(0xFFDDE2F3)),
            ),
          ),
          // Audition list
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _auditions.length,
              itemBuilder: (context, index) {
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
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TVAuditionsHeader extends StatelessWidget implements PreferredSizeWidget {
  const _TVAuditionsHeader();

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9F9FF),
      child: SafeArea(
        bottom: false,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFDEDFE3), width: 1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.arrow_back, color: Color(0xFF006D37), size: 24),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'TV AUDITIONS',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF161C28),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
