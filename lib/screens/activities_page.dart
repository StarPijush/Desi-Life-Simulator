// lib/screens/activities_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design_system.dart';
import '../core/engine.dart';
import '../models/character.dart';
import '../widgets/common_widgets.dart';

class ActivitiesPage extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const ActivitiesPage({
    super.key,
    required this.character,
    required this.onGameAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).pop();
                    },
                    child: const Icon(Icons.arrow_back, color: Color(0xFF10B981), size: 24),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACTIVITIES',
                        style: GoogleFonts.lexend(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF181C1F),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'THINGS TO DO',
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF71717A),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.search, color: Color(0xFF94A3B8), size: 22),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // Identity Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F3FF),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT STATUS',
                      style: GoogleFonts.lexend(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF5C5E62),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${character.name}, ${character.age}',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF161C28),
                      ),
                    ),
                  ],
                ),
                Text(
                  formatMoney(character.bankBalance),
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF006D37),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // FAVORITES SECTION
          const AppSectionHeader.activity('FAVORITES'),
          AppFlatRowGroup(borderColor: const Color(0xFFF4F4F5), dividerIndent: 56, rows: [
            ActivityListRow(
              icon: '❤️',
              title: 'Love',
              subtitle: 'Find a partner',
              locked: character.age < 16,
              onTap: () => onGameAction(const GameAction('activity.find_love')),
            ),
            ActivityListRow(
              icon: '🧘',
              title: 'Mind & Body',
              subtitle: 'Improve wellness',
              onTap: () => onGameAction(const GameAction('activity.perform', {'activityId': 'Temple Visit'})),
            ),
          ]),

          const SizedBox(height: 24),

          // ALL ACTIVITIES SECTION
          const AppSectionHeader.activity('ALL ACTIVITIES'),
          AppFlatRowGroup(borderColor: const Color(0xFFF4F4F5), dividerIndent: 56, rows: [
            ActivityListRow(
              icon: '💼',
              title: 'Doctor',
              subtitle: 'Get a checkup',
              cost: 250,
              onTap: () => onGameAction(const GameAction('activity.perform', {'activityId': 'Doctor Visit'})),
            ),
            ActivityListRow(
              icon: '🏋️',
              title: 'Gym',
              subtitle: 'Physical training',
              locked: character.age < 12,
              onTap: () => onGameAction(const GameAction('activity.perform', {'activityId': 'Gym Workout'})),
            ),
            ActivityListRow(
              icon: '📚',
              title: 'Library',
              subtitle: 'Read books',
              locked: character.age < 5,
              onTap: () => onGameAction(const GameAction('activity.perform', {'activityId': 'Study Hard'})),
            ),
            ActivityListRow(
              icon: '🎬',
              title: 'Movies',
              subtitle: 'Watch a film',
              cost: 500,
              onTap: () => onGameAction(const GameAction('activity.perform', {'activityId': 'Watch Movie'})),
            ),
            ActivityListRow(
              icon: '🍸',
              title: 'Nightlife',
              subtitle: 'Clubbing & events',
              locked: character.age < 18,
              onTap: () => onGameAction(const GameAction('activity.perform', {'activityId': 'Go to Party'})),
            ),
            ActivityListRow(
              icon: '🛍️',
              title: 'Shopping',
              subtitle: 'Buy items',
              onTap: () => onGameAction(const GameAction('activity.perform', {'activityId': 'Shopping'})),
            ),
          ]),

          // Stats Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 40),
            child: Column(
              children: [
                LinearStatBar(showPercent: true, label: 'HAPPINESS', value: character.happiness, color: const Color(0xFF006D37)),
                const SizedBox(height: 12),
                LinearStatBar(showPercent: true, label: 'HEALTH', value: character.health, color: const Color(0xFF34D399)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


