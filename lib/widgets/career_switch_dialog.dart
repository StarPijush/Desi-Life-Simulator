// lib/widgets/career_switch_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/engine.dart';

class CareerSwitchDialog extends StatefulWidget {
  final CareerSwitchOffer offer;
  final void Function(CareerGroup? chosen) onChoice;

  const CareerSwitchDialog({super.key, required this.offer, required this.onChoice});

  static Future<void> show(
    BuildContext context, {
    required CareerSwitchOffer offer,
    required void Function(CareerGroup? chosen) onChoice,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => CareerSwitchDialog(offer: offer, onChoice: onChoice),
    );
  }

  @override
  State<CareerSwitchDialog> createState() => _CareerSwitchDialogState();
}

class _CareerSwitchDialogState extends State<CareerSwitchDialog> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  bool _chosen = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 340));
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _pick(CareerGroup? chosen) {
    if (_chosen) return;
    _chosen = true;
    HapticFeedback.heavyImpact();
    Navigator.of(context).pop();
    widget.onChoice(chosen);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.22), blurRadius: 40, offset: const Offset(0, 16))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header ──────────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
                  ),
                  child: Column(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text('CAREER CROSSROADS', style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.8), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.8)),
                    ),
                    const SizedBox(height: 10),
                    Text('Time for a Change?', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3)),
                    const SizedBox(height: 6),
                    Text('A new chapter could be yours. Switch careers\nor stay the course — it\'s your call.', textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.55), height: 1.5)),
                  ]),
                ),

                // ── Body ────────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  child: Column(children: [
                    _SwitchOption(group: widget.offer.optionA, onTap: () => _pick(widget.offer.optionA), primary: const Color(0xFF6366F1)),
                    const SizedBox(height: 10),
                    _SwitchOption(group: widget.offer.optionB, onTap: () => _pick(widget.offer.optionB), primary: const Color(0xFF0EA5E9)),
                    const SizedBox(height: 14),
                    // Stay button
                    GestureDetector(
                      onTap: () => _pick(null),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                        ),
                        child: Center(child: Text('🏳️  Stay in current career', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)))),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwitchOption extends StatefulWidget {
  final CareerGroup group;
  final VoidCallback onTap;
  final Color primary;
  const _SwitchOption({required this.group, required this.onTap, required this.primary});

  @override
  State<_SwitchOption> createState() => _SwitchOptionState();
}

class _SwitchOptionState extends State<_SwitchOption> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final topSalary = group.topStep.annualSalary;
    final salaryStr = topSalary >= 10000000
        ? '₹${(topSalary / 10000000).toStringAsFixed(1)}Cr'
        : topSalary >= 100000
            ? '₹${(topSalary / 100000).toStringAsFixed(0)}L'
            : '₹${(topSalary / 1000).toStringAsFixed(0)}K';

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.primary.withValues(alpha: 0.25), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [widget.primary.withValues(alpha: 0.7), widget.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: Text(group.emoji, style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(group.name, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: widget.primary)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: widget.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                      child: Text('${group.steps.length} levels', style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: widget.primary)),
                    ),
                  ]),
                  Text(group.description, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8))),
                  const SizedBox(height: 4),
                  Row(children: [
                    Text('Start: ', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFFCBD5E1))),
                    Text(group.steps.first.title, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
                    const Spacer(),
                    Text('Top: $salaryStr/yr', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF16A34A))),
                  ]),
                ]),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: widget.primary.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
