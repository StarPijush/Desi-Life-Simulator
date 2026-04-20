// lib/widgets/relation_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/character.dart';
import '../models/relationship.dart';
import '../core/engine.dart';
import '../core/storage.dart';

class RelationDialog extends StatefulWidget {
  final Character character;
  final Relationship relationship;
  final Function(String result) onInteraction;

  const RelationDialog({
    super.key,
    required this.character,
    required this.relationship,
    required this.onInteraction,
  });

  static Future<void> show(
    BuildContext context, {
    required Character character,
    required Relationship relationship,
    required Function(String result) onInteraction,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => RelationDialog(
        character: character,
        relationship: relationship,
        onInteraction: onInteraction,
      ),
    );
  }

  @override
  State<RelationDialog> createState() => _RelationDialogState();
}

class _RelationDialogState extends State<RelationDialog> {
  void _interact(String action) {
    HapticFeedback.mediumImpact();
    final result = GameEngine.interactWithRelation(widget.character, widget.relationship, action);
    StorageService.saveCharacter(widget.character);
    Navigator.of(context).pop();
    widget.onInteraction(result);
  }

  @override
  Widget build(BuildContext context) {
    final rel = widget.relationship;
    final parent = rel.type == 'Father' || rel.type == 'Mother';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 30, offset: const Offset(0, 10))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 2),
                    ),
                    child: Center(child: Text(rel.initial, style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white))),
                  ),
                  const SizedBox(height: 16),
                  Text(rel.name, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                  Text(rel.type, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                  const SizedBox(height: 16),
                  // Bond Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Relationship: ', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withValues(alpha: 0.4), fontWeight: FontWeight.w600)),
                      Text('${rel.bond}%', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 140, height: 6,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 140 * (rel.bond / 100),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399)]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Actions ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              child: Column(
                children: [
                  _ActionButton(
                    icon: Icons.groups_rounded,
                    label: 'Spend Time',
                    subtitle: 'Go out together',
                    color: const Color(0xFF6366F1),
                    onTap: () => _interact('Spend Time'),
                  ),
                  const SizedBox(height: 12),
                  _ActionButton(
                    icon: Icons.card_giftcard_rounded,
                    label: 'Give Gift',
                    subtitle: rel.type == 'Partner' ? 'Cost: ₹5,000' : 'Cost: ₹2,000',
                    color: const Color(0xFFEC4899),
                    onTap: () => _interact('Give Gift'),
                  ),
                  const SizedBox(height: 12),
                  if (rel.type == 'Partner') ...[
                    _ActionButton(
                      icon: Icons.favorite_rounded,
                      label: 'Go on Date',
                      subtitle: 'Cost: ₹3,000',
                      color: const Color(0xFFE11D48),
                      onTap: () => _interact('Go on Date'),
                    ),
                    const SizedBox(height: 12),
                    _ActionButton(
                      icon: Icons.chat_bubble_rounded,
                      label: 'Talk',
                      subtitle: 'Have a conversation',
                      color: const Color(0xFF0EA5E9),
                      onTap: () => _interact('Talk'),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _ActionButton(
                    icon: Icons.mood_bad_rounded,
                    label: 'Argue',
                    subtitle: 'Air your grievances',
                    color: const Color(0xFF94A3B8),
                    onTap: () => _interact('Argue'),
                  ),
                  if (parent) ...[
                    const SizedBox(height: 12),
                    _ActionButton(
                      icon: Icons.currency_rupee_rounded,
                      label: 'Ask for Money',
                      subtitle: 'Depends on bond',
                      color: const Color(0xFF10B981),
                      onTap: () => _interact('Ask for Money'),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Maybe later', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
                  Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
