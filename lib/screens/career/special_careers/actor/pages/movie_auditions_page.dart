import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../models/character.dart';
import '../models/movie_audition.dart';
import '../data/audition_generator.dart';
import '../widgets/movie_audition_tile.dart';
import 'movie_audition_details_page.dart';

class MovieAuditionsPage extends StatefulWidget {
  final Character character;
  final int currentYear;

  const MovieAuditionsPage({
    super.key,
    required this.character,
    this.currentYear = 2026, // Default for UI testing
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
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const _AuditionsHeader(),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            decoration: const BoxDecoration(
              color: Color(0xFFF9F9FF),
              border: Border(bottom: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
            ),
            child: Text(
              'OPEN CASTING CALLS',
              style: GoogleFonts.lexend(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3D4A3E),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _auditions.length,
              itemBuilder: (context, index) {
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
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditionsHeader extends StatelessWidget implements PreferredSizeWidget {
  const _AuditionsHeader();

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
                  child: Icon(Icons.arrow_back, color: Color(0xFF006D37), size: 28),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'AUDITIONS',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
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
}
