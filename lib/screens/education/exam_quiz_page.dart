// lib/screens/education/exam_quiz_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design_system.dart';
import '../../core/engine.dart';
import '../../core/exam_data.dart';
import '../../models/character.dart';

class ExamQuizPage extends StatefulWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const ExamQuizPage({
    super.key,
    required this.character,
    required this.onGameAction,
  });

  @override
  State<ExamQuizPage> createState() => _ExamQuizPageState();
}

class _ExamQuizPageState extends State<ExamQuizPage> {
  static const int _totalQuestions = 5;
  late final List<ExamQuestion> _questions;
  int _current = 0;
  int _correct = 0;
  int? _selected;
  bool _answered = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    final pool = List<ExamQuestion>.from(ExamData.questionBank)..shuffle(rng);
    _questions = pool.take(_totalQuestions).toList();
  }

  void _select(int idx) {
    if (_answered) return;
    HapticFeedback.lightImpact();
    setState(() {
      _selected = idx;
      _answered = true;
      if (idx == _questions[_current].correctIndex) _correct++;
    });
  }

  void _next() {
    if (_current + 1 >= _totalQuestions) {
      setState(() => _done = true);
    } else {
      setState(() {
        _current++;
        _selected = null;
        _answered = false;
      });
    }
  }

  void _submitResult() {
    final multiplier = 0.7 + (_correct / _totalQuestions) * 0.8;
    widget.onGameAction(
      GameAction('career.perform', {
        'actionId': 'career.take_exam_with_multiplier::${multiplier.toStringAsFixed(2)}',
      }),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.cardGap),
                  Text(
                    _examLabel,
                    style: AppTextStyles.labelBold.copyWith(
                      fontSize: 13, fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary, letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  if (!_done)
                    Text(
                      '${_current + 1}/$_totalQuestions',
                      style: AppTextStyles.labelBold.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _done ? _buildResult() : _buildQuestion(),
    );
  }

  String get _examLabel {
    final spec = widget.character.specialization;
    if (spec == 'PCB') return 'NEET ENTRANCE EXAM';
    if (widget.character.memories.containsKey('track_commerce')) return 'CA FOUNDATION EXAM';
    if (widget.character.memories.containsKey('track_arts')) return 'CLAT ENTRANCE EXAM';
    return 'JEE ENTRANCE EXAM';
  }

  Widget _buildQuestion() {
    final q = _questions[_current];
    final progress = (_current + 1) / _totalQuestions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 3,
          color: AppColors.divider,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(color: AppColors.primary),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, 20, AppSpacing.md, AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                color: const Color(0xFFF1F5FF),
                child: Text(
                  q.category.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 9, fontWeight: FontWeight.w800,
                    color: const Color(0xFF5C5E62), letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.cardGap),
              Text(
                q.question,
                style: GoogleFonts.lexend(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary, height: 1.4,
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1, color: AppColors.divider),

        Expanded(
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: q.options.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.divider, indent: 0),
            itemBuilder: (_, idx) => _buildOption(idx, q),
          ),
        ),

        if (_answered)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.lg),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
            ),
            child: GestureDetector(
              onTap: _next,
              child: Container(
                height: 44,
                alignment: Alignment.center,
                color: AppColors.primary,
                child: Text(
                  _current + 1 >= _totalQuestions ? 'SEE RESULTS' : 'NEXT QUESTION',
                  style: GoogleFonts.lexend(
                    fontSize: 13, fontWeight: FontWeight.w900,
                    color: Colors.white, letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOption(int idx, ExamQuestion q) {
    Color bg = AppColors.surface;
    Color textColor = AppColors.textPrimary;
    Widget? trailing;

    if (_answered) {
      if (idx == q.correctIndex) {
        bg = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        trailing = const Icon(Icons.check_circle, color: Color(0xFF059669), size: 18);
      } else if (idx == _selected && idx != q.correctIndex) {
        bg = const Color(0xFFFFE4E6);
        textColor = const Color(0xFF9F1239);
        trailing = const Icon(Icons.cancel, color: Color(0xFFE11D48), size: 18);
      }
    } else if (_selected == idx) {
      bg = const Color(0xFFF0FDF4);
    }

    return GestureDetector(
      onTap: () => _select(idx),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        color: bg,
        child: Row(
          children: [
            Container(
              width: 22, height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.outline, width: 1),
                color: Colors.transparent,
              ),
              child: Text(
                String.fromCharCode(65 + idx),
                style: GoogleFonts.lexend(
                  fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.cardGap),
            Expanded(
              child: Text(
                q.options[idx],
                style: GoogleFonts.lexend(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: textColor, height: 1.3,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    final pct = (_correct / _totalQuestions * 100).toInt();
    final label = _correct >= 4
        ? 'OUTSTANDING'
        : _correct >= 3
            ? 'GOOD ATTEMPT'
            : _correct >= 2
                ? 'AVERAGE'
                : 'NEEDS IMPROVEMENT';
    final color = _correct >= 4
        ? const Color(0xFF059669)
        : _correct >= 2
            ? const Color(0xFFD97706)
            : const Color(0xFFDC2626);

    return Column(
      children: [
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              Text(label, style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w800, color: color, letterSpacing: 1.5)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '$_correct / $_totalQuestions',
                style: GoogleFonts.lexend(fontSize: 48, fontWeight: FontWeight.w900, color: color),
              ),
              Text(
                '$pct% accuracy',
                style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                height: 8, color: AppColors.divider,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _correct / _totalQuestions,
                  child: Container(color: color),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.cardGap),
          color: const Color(0xFFF4F4F5),
          child: Text(
            _correct >= 4
                ? 'Excellent quiz performance! Your AIR rank will reflect your preparation.'
                : _correct >= 2
                    ? 'Decent attempt. Your rank may qualify for NITs or private colleges.'
                    : 'Tough exam. Your rank might be in the lower bracket. Try again next year.',
            style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF5C5E62), height: 1.4),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
          child: GestureDetector(
            onTap: _submitResult,
            child: Container(
              height: 44,
              alignment: Alignment.center,
              color: AppColors.primary,
              child: Text(
                'SUBMIT & SEE RESULT',
                style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
