import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/character.dart';
import '../../core/engine.dart';
import '../../widgets/common_widgets.dart';

class ScholarshipsScreen extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const ScholarshipsScreen({
    super.key,
    required this.character,
    required this.onGameAction,
  });

  PreferredSizeWidget _buildAppBar(BuildContext context, String title) {
    return EducationAppBar(title: title);
  }

  Widget _buildSectionHeader(String title) {
    return AppSectionHeader.education(title);
  }

  void _showScholarshipDialog(BuildContext context, String id, String title, bool isClaimed) {
    if (isClaimed) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(title, style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
          content: const Text('You have already claimed this scholarship. The funds were deposited into your bank account.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK', style: TextStyle(color: Color(0xFF006D37))),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(title, style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
          content: const Text('Would you like to apply for this scholarship? We will evaluate your eligibility based on your performance and stats.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                onGameAction(GameAction('activity.perform',
                    {'activityId': 'scholarship.apply::$id'}));
              },
              child: const Text('Apply',
                  style: TextStyle(color: Color(0xFF006D37), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScholarshipRow(
      BuildContext context, String id, String title, String subtitle, String emoji, double reward) {
    final bool isClaimed = character.claimedScholarships.contains(id);
    final String formattedReward = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
      locale: 'en_IN',
    ).format(reward);

    return AppFlatRow(
      height: 64,
      icon: Text(emoji, style: const TextStyle(fontSize: 24)),
      title: title,
      subtitle: subtitle,
      trailing: isClaimed
          ? const Icon(Icons.check_circle, color: Color(0xFF006D37), size: 20)
          : Text(
              formattedReward,
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF006D37),
              ),
            ),
      onTap: () => _showScholarshipDialog(context, id, title, isClaimed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: _buildAppBar(context, 'SCHOLARSHIPS'),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSectionHeader('Need-Based Aid'),
          AppFlatRowGroup(
            rows: [
              _buildScholarshipRow(
                context,
                'low_income',
                'Financial Support Grant',
                'Requires Low parent wealth',
                '🪙',
                10000,
              ),
            ],
          ),
          
          _buildSectionHeader('High School Merit'),
          AppFlatRowGroup(
            rows: [
              _buildScholarshipRow(
                context,
                '10th_merit',
                '10th Board Merit',
                'Requires 75%+ in 10th Boards',
                '📝',
                10000,
              ),
              _buildScholarshipRow(
                context,
                '12th_excellence',
                '12th Excellence Award',
                'Requires Smarts 80%+, Prep 80%+',
                '🎓',
                25000,
              ),
            ],
          ),

          _buildSectionHeader('Talent & Extracurricular'),
          AppFlatRowGroup(
            rows: [
              _buildScholarshipRow(
                context,
                'sports_talent',
                'Sports Council Grant',
                'Elite in Cricket/Football/Basketball',
                '🏅',
                15000,
              ),
              _buildScholarshipRow(
                context,
                'arts_talent',
                'Creative Arts Talent',
                'Elite in Acting/Singing/Dance',
                '🎭',
                15000,
              ),
              _buildScholarshipRow(
                context,
                'coding_talent',
                'Hackathon Winner Grant',
                'Good in Coding Club + Smarts 75%+',
                '💻',
                15000,
              ),
              _buildScholarshipRow(
                context,
                'debate_excellence',
                'Debate Excellence Award',
                'Good in Debate Club + Smarts 70%+',
                '🏆',
                12000,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}


