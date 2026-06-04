import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/character.dart';
import '../../core/engine.dart';
import '../../widgets/common_widgets.dart';

class TutorsScreen extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const TutorsScreen({
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

  void _showTutorOptionsDialog(
      BuildContext context, String subject, Map? activeTutor) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('$subject Tutors',
              style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (activeTutor != null) ...[
                Text('Currently hired: ${activeTutor['name']}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF006D37))),
                const SizedBox(height: 8),
                Text(
                    'Cost: ₹${activeTutor['monthlyFee']}/mo\nBoost: +${activeTutor['learningBoost']}%\nStress Impact: ${activeTutor['stressImpact'] > 0 ? '+' : ''}${activeTutor['stressImpact']}'),
                const SizedBox(height: 16),
              ] else
                const Text(
                    'Hiring a tutor will automatically deduct their monthly fee from your bank balance every year (fee x 12). Only one tutor per subject allowed.'),
              const SizedBox(height: 16),
              const Text('Available Tutors:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildTutorOption(
                title: 'Friendly Tutor',
                fee: '₹7,000/mo',
                desc: 'Moderate prep boost, stress relief',
                onTap: () {
                  Navigator.of(ctx).pop();
                  onGameAction(GameAction('activity.perform',
                      {'activityId': 'tutor.hire::$subject::Friendly'}));
                },
              ),
              const SizedBox(height: 8),
              _buildTutorOption(
                title: 'Strict Tutor',
                fee: '₹12,000/mo',
                desc: 'Extreme prep boost, increases stress',
                onTap: () {
                  Navigator.of(ctx).pop();
                  onGameAction(GameAction('activity.perform',
                      {'activityId': 'tutor.hire::$subject::Strict'}));
                },
              ),
            ],
          ),
          actions: [
            if (activeTutor != null)
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  onGameAction(GameAction('activity.perform',
                      {'activityId': 'tutor.fire::$subject'}));
                },
                child: const Text('Fire Tutor',
                    style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTutorOption(
      {required String title,
      required String fee,
      required String desc,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE4E4E7)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(desc,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Text(fee,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF006D37))),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectRow(BuildContext context, String subject, String emoji) {
    final Map? activeTutor = character.activeTutors[subject];
    final bool hasTutor = activeTutor != null;

    return AppFlatRow(
      icon: Text(emoji, style: const TextStyle(fontSize: 24)),
      title: subject,
      subtitle: hasTutor ? 'Hired: ${activeTutor['name']}' : 'No active tutor',
      subtitleStyle: hasTutor
          ? GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF006D37),
            )
          : null,
      trailing: hasTutor
          ? const Icon(Icons.check_circle, color: Color(0xFF006D37), size: 20)
          : null,
      onTap: () => _showTutorOptionsDialog(context, subject, activeTutor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: _buildAppBar(context, 'TUTORS'),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSectionHeader('SCIENCE & MATH'),
          AppFlatRowGroup(
            rows: [
              _buildSubjectRow(context, 'Mathematics', '📐'),
              _buildSubjectRow(context, 'Physics', '⚛️'),
              _buildSubjectRow(context, 'Chemistry', '🧪'),
              _buildSubjectRow(context, 'Biology', '🧬'),
            ],
          ),
          _buildSectionHeader('COMMERCE & HUMANITIES'),
          AppFlatRowGroup(
            rows: [
              _buildSubjectRow(context, 'Accounts', '📊'),
              _buildSubjectRow(context, 'Economics', '📉'),
              _buildSubjectRow(context, 'English', '📚'),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
