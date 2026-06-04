// lib/screens/career/freelance_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/engine.dart';
import '../../models/character.dart';

class _FreelanceClient {
  final String emoji;
  final String name;
  final String work;
  final String category;
  final int payout;
  final int stress;
  final int skillXP;
  final int requiredSkill;
  final Color tint;

  const _FreelanceClient({
    required this.emoji,
    required this.name,
    required this.work,
    required this.category,
    required this.payout,
    required this.stress,
    required this.skillXP,
    required this.requiredSkill,
    required this.tint,
  });

  String get stressLabel {
    if (stress >= 16) return 'High';
    if (stress >= 9) return 'Medium';
    return 'Low';
  }

  double get stressFactor => (stress / 20).clamp(0.05, 1.0);
}

const List<_FreelanceClient> _freelanceClients = [
  _FreelanceClient(
    emoji: '\u{1F3E2}',
    name: 'Tech Corp',
    work: 'Tech Corp freelance work',
    category: 'Web Developer',
    payout: 500,
    stress: 4,
    skillXP: 5,
    requiredSkill: 0,
    tint: Color(0xFFDBEAFE),
  ),
  _FreelanceClient(
    emoji: '\u{1F6CD}\u{FE0F}',
    name: 'Indie Startup',
    work: 'Indie Startup freelance work',
    category: 'Web Developer',
    payout: 300,
    stress: 10,
    skillXP: 6,
    requiredSkill: 0,
    tint: Color(0xFFFFEDD5),
  ),
  _FreelanceClient(
    emoji: '\u{1F393}',
    name: 'University Dept',
    work: 'University Dept freelance work',
    category: 'Technical Writer',
    payout: 450,
    stress: 17,
    skillXP: 7,
    requiredSkill: 0,
    tint: Color(0xFFF3E8FF),
  ),
];

PreferredSizeWidget _buildHtmlFreelanceAppBar(
    BuildContext context, String title) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(56),
    child: Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF9F9FF),
        border: Border(bottom: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
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
                child: const SizedBox(
                  width: 28,
                  height: 56,
                  child: Icon(Icons.arrow_back,
                      color: Color(0xFF006D37), size: 28),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title.toUpperCase(),
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF161C28),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class FreelanceClientsScreen extends StatefulWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const FreelanceClientsScreen({
    super.key,
    required this.character,
    required this.onGameAction,
  });

  @override
  State<FreelanceClientsScreen> createState() => _FreelanceClientsScreenState();
}

class _FreelanceClientsScreenState extends State<FreelanceClientsScreen> {
  late int _skill;
  late int _stress;
  late double _balance;
  String? _flashText;

  @override
  void initState() {
    super.initState();
    _skill = widget.character.freelanceEffort;
    _stress = widget.character.stressLevel;
    _balance = widget.character.bankBalance;
  }

  String get _skillTier {
    if (_skill > 75) return 'Elite';
    if (_skill > 50) return 'Advanced';
    if (_skill > 25) return 'Skilled';
    return 'Beginner';
  }

  void _performGig(_FreelanceClient client) {
    if (_skill < client.requiredSkill) {
      HapticFeedback.selectionClick();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Needs ${_requiredTier(client.requiredSkill)} freelance skill.'),
          duration: const Duration(milliseconds: 900),
        ),
      );
      return;
    }

    HapticFeedback.selectionClick();
    setState(() {
      _balance += client.payout.toDouble();
      _stress = (_stress + client.stress).clamp(0, 100);
      _skill = (_skill + client.skillXP).clamp(0, 100);
      _flashText =
          '+${GameEngine.formatMoney(client.payout.toDouble())}  Skill +${client.skillXP}  Stress +${client.stress}';
    });

    widget.onGameAction(GameAction('career.perform', {
      'actionId': 'career.perform_freelance_gig',
      'stayInFlow': true,
      'clientName': client.name,
      'workDescription': client.work,
      'category': client.category,
      'payout': client.payout,
      'stress': client.stress,
      'skillXP': client.skillXP,
    }));
  }

  String _requiredTier(int skill) {
    if (skill >= 76) return 'Elite';
    if (skill >= 51) return 'Advanced';
    if (skill >= 26) return 'Skilled';
    return 'Beginner';
  }

  @override
  Widget build(BuildContext context) {
    const available = _freelanceClients;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F7),
      appBar: _buildHtmlFreelanceAppBar(context, 'SELECT CLIENT'),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 56),
        children: [
          Visibility(
            visible: false,
            child: Container(
              color: const Color(0xFFF9F9FF),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${GameEngine.formatMoney(_balance)}  •  $_skillTier $_skill%',
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3D4A3E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 140),
                    child: Text(
                      _flashText ?? 'STRESS $_stress%',
                      key: ValueKey(_flashText ?? _stress),
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF006D37),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F3FF),
              border: Border(
                top: BorderSide(color: Color(0xFFBBCBBB), width: 1),
                bottom: BorderSide(color: Color(0xFFBBCBBB), width: 1),
              ),
            ),
            child: Text(
              'AVAILABLE CLIENTS',
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3D4A3E),
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            color: const Color(0xFFF9F9FF),
            child: Column(
              children: [
                for (final client in available)
                  _FreelanceClientRow(
                    client: client,
                    locked: _skill < client.requiredSkill,
                    onTap: () => _performGig(client),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FreelanceClientRow extends StatefulWidget {
  final _FreelanceClient client;
  final bool locked;
  final VoidCallback onTap;

  const _FreelanceClientRow({
    required this.client,
    required this.locked,
    required this.onTap,
  });

  @override
  State<_FreelanceClientRow> createState() => _FreelanceClientRowState();
}

class _FreelanceClientRowState extends State<_FreelanceClientRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final stressColor = widget.client.stress >= 16
        ? const Color(0xFFBA1A1A)
        : widget.client.stress >= 9
            ? const Color(0xFF98472A)
            : const Color(0xFF006D37);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _pressed
              ? const Color(0xFF2ECC71).withValues(alpha: 0.14)
              : const Color(0xFFF9F9FF),
          border: const Border(
            bottom: BorderSide(color: Color(0xFFDDE2F3), width: 1),
          ),
        ),
        child: Opacity(
          opacity: widget.locked ? 0.54 : 1,
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 10),
                alignment: Alignment.center,
                color: widget.client.tint,
                child: Text(widget.client.emoji,
                    style: const TextStyle(fontSize: 24)),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.client.name,
                            style: GoogleFonts.lexend(
                              fontSize: 13,
                              height: 1.1,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF161C28),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          GameEngine.formatMoney(
                              widget.client.payout.toDouble()),
                          style: GoogleFonts.lexend(
                            fontSize: 10,
                            height: 1,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF006D37),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.client.work,
                      style: GoogleFonts.lexend(
                        fontSize: 10,
                        height: 1.1,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF3D4A3E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'STRESS:',
                          style: GoogleFonts.lexend(
                            fontSize: 9,
                            height: 1,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3D4A3E),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 96,
                          height: 5,
                          child: Stack(
                            children: [
                              Container(color: const Color(0xFFDEDFE3)),
                              FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: widget.client.stressFactor,
                                child: Container(color: stressColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.client.stressLabel.toUpperCase(),
                          style: GoogleFonts.lexend(
                            fontSize: 9,
                            height: 1,
                            fontWeight: FontWeight.w600,
                            color: stressColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                widget.locked ? Icons.lock : Icons.chevron_right,
                color: const Color(0xFFBBCBBB),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
