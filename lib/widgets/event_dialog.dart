// lib/widgets/event_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/event_choice.dart';
import '../core/design_system.dart';

class EventDialog extends StatefulWidget {
  final EventChoice event;
  final void Function(bool choseA, String result) onChoice;

  const EventDialog({super.key, required this.event, required this.onChoice});

  static Future<void> show(
    BuildContext context, {
    required EventChoice event,
    required void Function(bool choseA, String result) onChoice,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'EventDialog',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, a1, a2) => EventDialog(event: event, onChoice: onChoice),
      transitionBuilder: (context, a1, a2, child) {
        final curve = Curves.easeOutBack.transform(a1.value);
        return Transform.scale(
          scale: 0.85 + (curve * 0.15),
          child: Opacity(
            opacity: a1.value,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
  bool _chosen = false;

  void _choose(bool choseA) {
    if (_chosen) return;
    _chosen = true;
    HapticFeedback.heavyImpact();
    final result = choseA ? widget.event.resultA : widget.event.resultB;
    Navigator.of(context).pop();
    widget.onChoice(choseA, result);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      elevation: 0,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 50,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header with Glass effect ────────────────────────────
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(AppSpacing.s24, 32, AppSpacing.s24, 28),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'LIFE DECISION',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              letterSpacing: 3,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s16),
                        Text(
                          widget.event.title,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.h1.copyWith(
                            color: Colors.white,
                            fontSize: 24,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -20, right: -20,
                    child: Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),

              // ── Body ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.s24, AppSpacing.s24, AppSpacing.s24, AppSpacing.s32),
                child: Column(
                  children: [
                    Text(
                      widget.event.description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.s32),
                    
                    Text(
                      'MAKE YOUR CHOICE',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),

                    // Choice Buttons
                    _ChoiceButton(
                      label: widget.event.optionA,
                      effect: widget.event.effectA,
                      onTap: () => _choose(true),
                      isPrimary: true,
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    _ChoiceButton(
                      label: widget.event.optionB,
                      effect: widget.event.effectB,
                      onTap: () => _choose(false),
                      isPrimary: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceButton extends StatefulWidget {
  final String label;
  final StatEffect effect;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ChoiceButton({
    required this.label, 
    required this.effect, 
    required this.onTap,
    required this.isPrimary,
  });

  @override
  State<_ChoiceButton> createState() => _ChoiceButtonState();
}

class _ChoiceButtonState extends State<_ChoiceButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.isPrimary ? const Color(0xFF16A34A) : const Color(0xFFEA580C);
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.s20),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryColor.withValues(alpha: 0.15), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    widget.isPrimary ? Icons.check_circle_rounded : Icons.flash_on_rounded,
                    color: primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: AppTextStyles.bodyBold.copyWith(
                        color: primaryColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              if (!_isEffectEmpty(widget.effect)) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _buildEffectChips(widget.effect),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _isEffectEmpty(StatEffect e) =>
      e.happiness == 0 && e.health == 0 && e.smarts == 0 && e.social == 0 && e.karma == 0 && e.money == 0;

  List<Widget> _buildEffectChips(StatEffect e) {
    final chips = <Widget>[];
    void add(String emoji, int val) {
      if (val == 0) return;
      final isPos = val > 0;
      chips.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isPos ? const Color(0xFF16A34A).withValues(alpha: 0.1) : const Color(0xFFDC2626).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${isPos ? '+' : ''}$val $emoji',
          style: AppTextStyles.caption.copyWith(
            color: isPos ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
            fontWeight: FontWeight.w800,
            fontSize: 10,
          ),
        ),
      ));
    }

    add('😊', e.happiness);
    add('❤️', e.health);
    add('🧠', e.smarts);
    add('🤝', e.social);
    add('✨', e.karma);
    if (e.money != 0) {
      final isPos = e.money > 0;
      chips.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isPos ? const Color(0xFF16A34A).withValues(alpha: 0.1) : const Color(0xFFDC2626).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${isPos ? '+' : ''}₹${(e.money.abs() / 1000).toStringAsFixed(0)}K',
          style: AppTextStyles.caption.copyWith(
            color: isPos ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
            fontWeight: FontWeight.w800,
            fontSize: 10,
          ),
        ),
      ));
    }
    return chips;
  }
}
