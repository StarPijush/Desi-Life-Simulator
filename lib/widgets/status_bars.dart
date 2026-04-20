// lib/widgets/status_bars.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/character.dart';

class StatusBars extends StatelessWidget {
  final Character character;
  const StatusBars({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          _StatBar(label: 'Happiness', emoji: '😊', value: character.happiness, colors: const [Color(0xFF4ADE80), Color(0xFF16A34A)]),
          _StatBar(label: 'Health', emoji: '❤️', value: character.health, colors: const [Color(0xFFF87171), Color(0xFFDC2626)]),
          _StatBar(label: 'Smarts', emoji: '🧠', value: character.smarts, colors: const [Color(0xFF60A5FA), Color(0xFF2563EB)]),
          _StatBar(label: 'Social', emoji: '🤝', value: character.social, colors: const [Color(0xFFFB923C), Color(0xFFEA580C)]),
          _StatBar(label: 'Karma', emoji: '✨', value: character.karma, colors: const [Color(0xFFC084FC), Color(0xFFEAB308)]),
        ],
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  final String label;
  final String emoji;
  final int value;
  final List<Color> colors;

  const _StatBar({required this.label, required this.emoji, required this.value, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 6),
              Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
              const Spacer(),
              Text('$value%', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: colors.last)),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(height: 8, width: double.infinity, color: const Color(0xFFE5E7EB)),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: (value / 100).clamp(0.0, 1.0)),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => FractionallySizedBox(
                    widthFactor: v,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: colors, begin: Alignment.centerLeft, end: Alignment.centerRight),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
