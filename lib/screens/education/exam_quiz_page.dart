// lib/screens/education/exam_quiz_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
    // multiplier: 1 correct = 0.7, 5 correct = 1.5
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
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
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
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: Color(0xFF71717A), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _examLabel,
                    style: GoogleFonts.lexend(
                      fontSize: 13, fontWeight: FontWeight.w900,
                      color: const Color(0xFF181C1F), letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  if (!_done)
                    Text(
                      '${_current + 1}/$_totalQuestions',
                      style: GoogleFonts.lexend(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: const Color(0xFF71717A),
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
        // Progress bar
        Container(
          height: 3,
          color: const Color(0xFFE4E4E7),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(color: const Color(0xFF006D37)),
          ),
        ),

        // Category tag + question
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                color: const Color(0xFFF1F5FF),
                child: Text(
                  q.category.toUpperCase(),
                  style: GoogleFonts.lexend(
                    fontSize: 9, fontWeight: FontWeight.w800,
                    color: const Color(0xFF5C5E62), letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                q.question,
                style: GoogleFonts.lexend(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: const Color(0xFF161C28), height: 1.4,
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1, color: Color(0xFFE4E4E7)),

        // Options
        Expanded(
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: q.options.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFE4E4E7), indent: 0),
            itemBuilder: (_, idx) => _buildOption(idx, q),
          ),
        ),

        // Next / submit
        if (_answered)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE4E4E7), width: 1)),
            ),
            child: GestureDetector(
              onTap: _next,
              child: Container(
                height: 44,
                alignment: Alignment.center,
                color: const Color(0xFF006D37),
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
    Color bg = Colors.white;
    Color textColor = const Color(0xFF161C28);
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: bg,
        child: Row(
          children: [
            Container(
              width: 22, height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD4D4D8), width: 1),
                color: Colors.transparent,
              ),
              child: Text(
                String.fromCharCode(65 + idx), // A, B, C, D
                style: GoogleFonts.lexend(
                  fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF71717A),
                ),
              ),
            ),
            const SizedBox(width: 12),
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Text(label, style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w800, color: color, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Text(
                '$_correct / $_totalQuestions',
                style: GoogleFonts.lexend(fontSize: 48, fontWeight: FontWeight.w900, color: color),
              ),
              Text(
                '$pct% accuracy',
                style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF71717A)),
              ),
              const SizedBox(height: 24),
              Container(
                height: 8, color: const Color(0xFFE4E4E7),
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
        // What happens next
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
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
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          child: GestureDetector(
            onTap: _submitResult,
            child: Container(
              height: 44,
              alignment: Alignment.center,
              color: const Color(0xFF006D37),
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
