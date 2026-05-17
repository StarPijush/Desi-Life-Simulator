// lib/screens/people_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design_system.dart';
import '../core/engine.dart';
import '../models/character.dart';
import '../models/relationship.dart';

class PeoplePage extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const PeoplePage({super.key, required this.character, required this.onGameAction});

  @override
  Widget build(BuildContext context) {
    final family = character.relationships.where((r) => ['Father', 'Mother', 'Sibling'].contains(r.type)).toList();
    final friends = character.relationships.where((r) => r.type == 'Friend').toList();
    final partners = character.relationships.where((r) => r.type == 'Partner').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE4E4E7), width: 1)),
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
                  Text(
                    'PEOPLE',
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF181C1F),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.search, color: Color(0xFF71717A), size: 24),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // Status Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F3FF),
              border: Border(bottom: BorderSide(color: Color(0xFFE4E4E7), width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT IDENTITY',
                      style: GoogleFonts.lexend(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5C5E62),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      character.name,
                      style: GoogleFonts.lexend(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF161C28),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Age: ${character.age}',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF006D37),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatMoney(character.bankBalance),
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF5C5E62),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // FAMILY SECTION
          if (family.isNotEmpty) ...[
            const SizedBox(height: 8),
            const _SectionHeader(title: 'FAMILY'),
            _FlatRowGroup(
              rows: family.map((r) => _RelationRow(relationship: r, onGameAction: onGameAction)).toList(),
            ),
          ],

          // RELATIONSHIPS SECTION
          const SizedBox(height: 8),
          const _SectionHeader(title: 'RELATIONSHIPS'),
          _FlatRowGroup(
            rows: [
              if (character.age >= 16)
                _ActionRow(
                  iconBgColor: const Color(0xFFFFDAD6),
                  icon: const Text('❤️', style: TextStyle(fontSize: 20)),
                  title: 'Find a Partner',
                  trailing: const Icon(Icons.add, color: Color(0xFFD4D4D8), size: 24),
                  onTap: () => onGameAction(const GameAction('activity.find_love')),
                ),
              ...partners.map((r) => _RelationRow(relationship: r, onGameAction: onGameAction)),
              if (friends.isNotEmpty)
                _ActionRow(
                  iconBgColor: const Color(0xFFE8EEFF),
                  icon: const Text('👥', style: TextStyle(fontSize: 20)),
                  title: 'View Friends',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: const BoxDecoration(color: Color(0xFF006D37)),
                        child: Text(
                          '${friends.length}',
                          style: GoogleFonts.lexend(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: Color(0xFFD4D4D8), size: 24),
                    ],
                  ),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => _FriendsListScreen(friends: friends, onGameAction: onGameAction),
                  )),
                ),
            ],
          ),

          // CORE VITALS
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CORE VITALS',
                  style: GoogleFonts.lexend(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5C5E62),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                _VitalBar(label: 'Happiness', value: character.happiness, color: const Color(0xFF10B981)),
                const SizedBox(height: 16),
                _VitalBar(label: 'Health', value: character.health, color: const Color(0xFF10B981)),
                const SizedBox(height: 16),
                _VitalBar(label: 'Karma', value: character.karma, color: const Color(0xFF006D37)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendsListScreen extends StatelessWidget {
  final List<Relationship> friends;
  final void Function(GameAction) onGameAction;

  const _FriendsListScreen({required this.friends, required this.onGameAction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE4E4E7), width: 1)),
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
                  Text(
                    'FRIENDS',
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF181C1F),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 16),
          _FlatRowGroup(
            rows: friends.map((r) => _RelationRow(relationship: r, onGameAction: onGameAction)).toList(),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF1F3FF),
        border: Border(bottom: BorderSide(color: Color(0xFFF4F4F5), width: 1)),
      ),
      child: Text(
        title,
        style: GoogleFonts.lexend(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF5C5E62),
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _FlatRowGroup extends StatelessWidget {
  final List<Widget> rows;
  const _FlatRowGroup({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6), indent: 0),
          ],
        ],
      ),
    );
  }
}

class _RelationRow extends StatefulWidget {
  final Relationship relationship;
  final void Function(GameAction) onGameAction;

  const _RelationRow({required this.relationship, required this.onGameAction});

  @override
  State<_RelationRow> createState() => _RelationRowState();
}

class _RelationRowState extends State<_RelationRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isMother = widget.relationship.type.toLowerCase() == 'mother';
    final isFather = widget.relationship.type.toLowerCase() == 'father';
    
    Color iconBgColor = const Color(0xFFF4F4F5);
    String icon = '👤';
    
    if (isMother) {
      iconBgColor = const Color(0xFFFFDBD0);
      icon = '👩';
    } else if (isFather) {
      iconBgColor = const Color(0xFFE2E8F9);
      icon = '👨';
    } else if (widget.relationship.type.toLowerCase() == 'partner') {
      iconBgColor = const Color(0xFFFFDAD6);
      icon = '❤️';
    } else if (widget.relationship.type.toLowerCase() == 'friend') {
      iconBgColor = const Color(0xFFE8EEFF);
      icon = '👤';
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onGameAction(GameAction('relation.interact', {
          'relationshipId': widget.relationship.id,
          'interactionType': widget.relationship.type == 'Partner' ? 'Go on Date' : 'Spend Time',
        }));
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: _pressed ? const Color(0xFFFAFAFA) : Colors.white,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              color: iconBgColor,
              alignment: Alignment.center,
              child: Text(icon, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.relationship.name,
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF161C28),
                    ),
                  ),
                  Text(
                    widget.relationship.type.toUpperCase(),
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5C5E62),
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 100,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 6,
                      color: const Color(0xFFE4E4E7),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (widget.relationship.bond / 100).clamp(0.01, 1.0),
                        child: Container(color: const Color(0xFF006D37)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Color(0xFFD4D4D8), size: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatefulWidget {
  final Color iconBgColor;
  final Widget icon;
  final String title;
  final Widget trailing;
  final VoidCallback onTap;

  const _ActionRow({
    required this.iconBgColor,
    required this.icon,
    required this.title,
    required this.trailing,
    required this.onTap,
  });

  @override
  State<_ActionRow> createState() => _ActionRowState();
}

class _ActionRowState extends State<_ActionRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: _pressed ? const Color(0xFFFAFAFA) : Colors.white,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              color: widget.iconBgColor,
              alignment: Alignment.center,
              child: widget.icon,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.title,
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF161C28),
                ),
              ),
            ),
            widget.trailing,
          ],
        ),
      ),
    );
  }
}

class _VitalBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _VitalBar({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.lexend(
               fontSize: 10,
               fontWeight: FontWeight.w700,
               color: const Color(0xFF5C5E62),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 12,
            color: const Color(0xFFE4E4E7),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (value / 100).clamp(0.01, 1.0),
              child: Container(color: color),
            ),
          ),
        ),
      ],
    );
  }
}
