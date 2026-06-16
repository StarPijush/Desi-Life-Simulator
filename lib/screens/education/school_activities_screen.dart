import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/character.dart';
import '../../core/engine.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/events/event_card.dart';
import '../../widgets/events/event_types.dart';

class SchoolActivitiesScreen extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const SchoolActivitiesScreen({
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

  String _getPerformanceString(int performance) {
    if (performance >= 5) return 'Elite';
    if (performance >= 4) return 'Excellent';
    if (performance >= 3) return 'Good';
    if (performance >= 2) return 'Average';
    return 'Beginner';
  }

  void _showActivityDialog(BuildContext context, String id, bool isJoined) {
    showEventCard(
      context: context,
      category: EventCategory.education,
      mode: EventCardMode.actions,
      title: id,
      description: isJoined
          ? 'You are currently a member of the $id. You can practice harder to improve your performance or leave the activity.'
          : 'Would you like to try out for the $id? Make sure you meet the requirements.',
      illustration: const EventIllustration.emoji('🏫'),
      actions: isJoined
          ? [
              EventCardAction(
                label: 'Practice Harder',
                onPressed: () {
                  Navigator.of(context).pop();
                  onGameAction(GameAction('activity.perform',
                      {'activityId': 'school_activity.practice::$id'}));
                },
              ),
              EventCardAction(
                label: 'Leave Activity',
                onPressed: () {
                  Navigator.of(context).pop();
                  onGameAction(GameAction('activity.perform',
                      {'activityId': 'school_activity.leave::$id'}));
                },
              ),
              EventCardAction(
                label: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ]
          : [
              EventCardAction(
                label: 'Join',
                onPressed: () {
                  Navigator.of(context).pop();
                  onGameAction(GameAction('activity.perform',
                      {'activityId': 'school_activity.join::$id'}));
                },
              ),
              EventCardAction(
                label: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
    );
  }

  Widget _buildActivityRow(BuildContext context, String id, String emoji) {
    final bool isJoined = character.joinedActivities.contains(id);
    final int performance = character.activityPerformance[id] ?? 0;

    return AppFlatRow(
      icon: Text(emoji, style: const TextStyle(fontSize: 24)),
      title: id,
      subtitle: isJoined
          ? 'Performance: ${_getPerformanceString(performance)}'
          : null,
      subtitleStyle: isJoined
          ? GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF006D37),
            )
          : null,
      trailing: isJoined
          ? const Icon(Icons.check_circle, color: Color(0xFF006D37), size: 20)
          : null,
      onTap: () => _showActivityDialog(context, id, isJoined),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: _buildAppBar(context, 'SCHOOL ACTIVITIES'),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSectionHeader('SPORTS'),
          AppFlatRowGroup(
            rows: [
              _buildActivityRow(context, 'Cricket', '🏏'),
              _buildActivityRow(context, 'Football', '⚽'),
              _buildActivityRow(context, 'Basketball', '🏀'),
            ],
          ),
          _buildSectionHeader('ARTS & CULTURE'),
          AppFlatRowGroup(
            rows: [
              _buildActivityRow(context, 'Acting Club', '🎭'),
              _buildActivityRow(context, 'Singing Club', '🎤'),
              _buildActivityRow(context, 'Dance Club', '💃'),
              _buildActivityRow(context, 'Art Club', '🎨'),
            ],
          ),
          _buildSectionHeader('ACADEMICS & CLUBS'),
          AppFlatRowGroup(
            rows: [
              _buildActivityRow(context, 'Debate Club', '🗣️'),
              _buildActivityRow(context, 'Coding Club', '💻'),
              _buildActivityRow(context, 'Science Club', '🔬'),
            ],
          ),
          _buildSectionHeader('VOLUNTEERING'),
          AppFlatRowGroup(
            rows: [
              _buildActivityRow(context, 'NCC Cadet', '🪖'),
              _buildActivityRow(context, 'Teaching Volunteer', '👨‍🏫'),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
