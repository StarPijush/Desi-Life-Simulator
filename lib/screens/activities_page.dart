// lib/screens/activities_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design_system.dart';
import '../core/engine.dart';
import '../models/character.dart';

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
          const _SectionHeader(title: 'FAVORITES'),
          _ActivityRowGroup(rows: [
            _ActivityRow(
              icon: '❤️',
              title: 'Love',
              subtitle: 'Find a partner',
              locked: character.age < 16,
              onTap: () => onGameAction(const GameAction('activity.find_love')),
            ),
            _ActivityRow(
              icon: '🧘',
              title: 'Mind & Body',
              subtitle: 'Improve wellness',
              onTap: () => onGameAction(const GameAction('activity.perform', {'activityId': 'Temple Visit'})),
            ),
          ]),

          const SizedBox(height: 24),

          // ALL ACTIVITIES SECTION
          const _SectionHeader(title: 'ALL ACTIVITIES'),
          _ActivityRowGroup(rows: [
            _ActivityRow(
              icon: '💼',
              title: 'Doctor',
              subtitle: 'Get a checkup',
              cost: 250,
              onTap: () => onGameAction(const GameAction('activity.perform', {'activityId': 'Doctor Visit'})),
            ),
            _ActivityRow(
              icon: '🏋️',
              title: 'Gym',
              subtitle: 'Physical training',
              locked: character.age < 12,
              onTap: () => onGameAction(const GameAction('activity.perform', {'activityId': 'Gym Workout'})),
            ),
            _ActivityRow(
              icon: '📚',
              title: 'Library',
              subtitle: 'Read books',
              locked: character.age < 5,
              onTap: () => onGameAction(const GameAction('activity.perform', {'activityId': 'Study Hard'})),
            ),
            _ActivityRow(
              icon: '🎬',
              title: 'Movies',
              subtitle: 'Watch a film',
              cost: 500,
              onTap: () => onGameAction(const GameAction('activity.perform', {'activityId': 'Watch Movie'})),
            ),
            _ActivityRow(
              icon: '🍸',
              title: 'Nightlife',
              subtitle: 'Clubbing & events',
              locked: character.age < 18,
              onTap: () => onGameAction(const GameAction('activity.perform', {'activityId': 'Go to Party'})),
            ),
            _ActivityRow(
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
                _StatBar(label: 'HAPPINESS', value: character.happiness, color: const Color(0xFF006D37)),
                const SizedBox(height: 12),
                _StatBar(label: 'HEALTH', value: character.health, color: const Color(0xFF34D399)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Text(
        title,
        style: GoogleFonts.lexend(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFA1A1AA),
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _ActivityRowGroup extends StatelessWidget {
  final List<Widget> rows;
  const _ActivityRowGroup({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.symmetric(horizontal: BorderSide(color: Color(0xFFF4F4F5), width: 1)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              const Divider(height: 1, thickness: 1, color: Color(0xFFF4F4F5), indent: 56),
          ],
        ],
      ),
    );
  }
}

class _ActivityRow extends StatefulWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool locked;
  final int? cost;
  final VoidCallback onTap;

  const _ActivityRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.locked = false,
    this.cost,
    required this.onTap,
  });

  @override
  State<_ActivityRow> createState() => _ActivityRowState();
}

class _ActivityRowState extends State<_ActivityRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.locked ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.locked
          ? null
          : (_) {
              setState(() => _pressed = false);
              HapticFeedback.selectionClick();
              widget.onTap();
            },
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: _pressed ? const Color(0xFFF9FAFB) : Colors.white,
        child: Opacity(
          opacity: widget.locked ? 0.5 : 1.0,
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Center(child: Text(widget.icon, style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF161C28),
                        height: 1.2,
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.lexend(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF71717A),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.cost != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '-${formatMoney(widget.cost!)}',
                    style: GoogleFonts.lexend(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ),
              const Icon(Icons.chevron_right, color: Color(0xFFD4D4D8), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatBar({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.lexend(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF5C5E62),
              ),
            ),
            Text(
              '$value%',
              style: GoogleFonts.lexend(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF5C5E62),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 10,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFF4F4F5),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (value / 100).clamp(0.01, 1.0),
            child: Container(
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
