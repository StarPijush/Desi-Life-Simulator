// lib/screens/career/jobs_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/career_data.dart';
import '../../core/design_system.dart';
import '../../core/engine.dart';
import '../../models/character.dart';
import '../../widgets/common_widgets.dart';

class JobsListScreen extends StatelessWidget {
  final String title;
  final Character character;
  final void Function(GameAction) onGameAction;
  final CareerTier tier;

  const JobsListScreen({
    super.key,
    required this.title,
    required this.character,
    required this.onGameAction,
    required this.tier,
  });

  @override
  Widget build(BuildContext context) {
    if (title.toUpperCase() == 'JOBS') {
      return _buildFullTimeJobs(context);
    }
    if (title.toUpperCase() == 'PART-TIME JOBS') {
      return _buildPartTimeJobs(context);
    }

    final groups = CareerSystem.allGroups.where((g) => g.tier == tier).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: _buildAppBar(context, title),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildIdentityHeader(character),
          _buildSectionHeader('OPENINGS'),
          AppFlatRowGroup(
            rows: groups.map((group) {
              final firstStep = group.steps.first;
              return AppFlatRow(
                icon: Text(group.emoji.isNotEmpty ? group.emoji : '💼',
                    style: const TextStyle(fontSize: 24)),
                title: group.name,
                subtitle:
                    '${firstStep.title} • ₹${GameEngine.formatMoney(firstStep.annualSalary)}/yr',
                onTap: () => showDialog(
                  context: context,
                  useRootNavigator: true,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    title: Text('Apply for ${firstStep.title}?'),
                    content: Text(
                        'Salary: ₹${GameEngine.formatMoney(firstStep.annualSalary.toDouble())}/year\nStress: Low\nHours: 40 hours/week'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          onGameAction(GameAction('career.perform', {
                            'actionId': 'career.apply_group::${group.name}'
                          }));
                        },
                        child: const Text('Apply',
                            style: TextStyle(
                                color: Color(0xFF006D37),
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPartTimeJobs(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar:
          _buildAppBar(context, 'PART-TIME JOBS', trailing: const SizedBox()),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFF1F3FF),
            child: Text(
              'AVAILABLE POSITIONS',
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5C5E62),
                letterSpacing: 1.5,
              ),
            ),
          ),
          ...CareerData.allJobs.where((j) => j.tier == CareerTier.partTime).map(
              (job) => _buildPartTimeRow(
                  context,
                  job.emoji,
                  job.title,
                  '₹${GameEngine.formatMoney(job.startingSalary)}/yr • Age ${job.eduReq == "None" ? 14 : 16}+',
                  14)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3FF),
                border: Border.all(color: const Color(0xFFBBCBBB)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildPartTimeMetricBar('HAPPINESS', character.happiness,
                      const Color(0xFF006D37)),
                  const SizedBox(height: 12),
                  _buildPartTimeMetricBar(
                      'STRESS', character.stressLevel, const Color(0xFFBA1A1A)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartTimeRow(BuildContext context, String emoji, String title,
      String subtitle, int minAge) {
    return GestureDetector(
      onTap: () {
        if (character.age >= minAge) {
          onGameAction(const GameAction(
              'career.perform', {'actionId': 'career.apply_group::Part-Time'}));
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('You must be $minAge to apply.')));
        }
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          border:
              Border(bottom: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF161C28),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.lexend(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF5C5E62),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF6C7B6D), size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPartTimeMetricBar(String label, int value, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.lexend(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5C5E62),
                letterSpacing: 1.0,
              ),
            ),
            Text(
              '$value%',
              style: GoogleFonts.lexend(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 5,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFDDE2F3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (value / 100).clamp(0.01, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFullTimeJobs(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: _buildAppBar(
        context,
        'FULL-TIME JOBS',
        trailing: GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EEFF),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'REFRESH',
              style: GoogleFonts.lexend(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF10B981),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 16),

          _buildSectionHeader('COMPETITIVE EXAMS'),
          AppFlatRowGroup(
            rows: [
              AppFlatRow(
                icon: const Text('🏛️', style: TextStyle(fontSize: 24)),
                title: 'UPSC/Civil Services',
                subtitle: character.memories.containsKey('passed_UPSC')
                    ? 'Cleared'
                    : 'Requires Preparation',
                onTap: () => onGameAction(const GameAction(
                    'career.perform', {'actionId': 'career.exam::UPSC'})),
              ),
              AppFlatRow(
                icon: const Text('🏦', style: TextStyle(fontSize: 24)),
                title: 'Bank PO Exam',
                subtitle: character.memories.containsKey('passed_BankPO')
                    ? 'Cleared'
                    : 'Requires Preparation',
                onTap: () => onGameAction(const GameAction(
                    'career.perform', {'actionId': 'career.exam::BankPO'})),
              ),
            ],
          ),

          ...Industry.values.map((industry) {
            final industryJobs = CareerData.allJobs
                .where((j) =>
                    j.industry == industry &&
                    j.tier != CareerTier.partTime &&
                    j.tier != CareerTier.freelance)
                .toList();
            if (industryJobs.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildSectionHeader(industry.name.toUpperCase()),
                AppFlatRowGroup(
                  rows: industryJobs.map((job) {
                    bool locked = false;
                    String lockSubtitle =
                        '₹${GameEngine.formatMoney(job.startingSalary)}/year';

                    if (job.smartsReq > character.smarts) {
                      locked = true;
                    }
                    final eduLevels = [
                      'None',
                      'Primary',
                      'Secondary',
                      'Higher Secondary',
                      'Undergraduate',
                      'Graduate',
                      'Postgraduate'
                    ];
                    final charEduIdx =
                        eduLevels.indexOf(character.educationLevel);
                    final reqEduIdx = eduLevels.indexOf(job.eduReq);
                    if (reqEduIdx > charEduIdx) locked = true;

                    if (locked && job.lockReason != null) {
                      lockSubtitle = '🔒 ${job.lockReason}';
                    } else if (locked) {
                      lockSubtitle = '🔒 Requires more experience';
                    }

                    if (job.examReq != null &&
                        !character.memories
                            .containsKey('passed_${job.examReq}')) {
                      locked = true;
                      lockSubtitle =
                          '🔒 ${job.lockReason ?? "Requires ${job.examReq} clearance"}';
                    }

                    if (job.specializationReq != null) {
                      final spec = job.specializationReq!;
                      final hasSpec = character.specialization == spec ||
                          character.degree
                              .toLowerCase()
                              .contains(spec.toLowerCase()) ||
                          character.memories
                              .containsKey('track_${spec.toLowerCase()}') ||
                          character.memories.containsKey('cleared_$spec');
                      if (!hasSpec) {
                        locked = true;
                        lockSubtitle =
                            '🔒 ${job.lockReason ?? "Requires $spec specialization"}';
                      }
                    }

                    return AppFlatRow(
                      icon:
                          Text(job.emoji, style: const TextStyle(fontSize: 24)),
                      title: job.title,
                      subtitle: lockSubtitle,
                      locked: locked,
                      subtitleStyle: locked
                          ? GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFDC2626))
                          : null,
                      onTap: locked
                          ? () {}
                          : () => showDialog(
                                context: context,
                                useRootNavigator: true,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  title: Text('Apply for ${job.title}?'),
                                  content: Text(
                                      'Salary: ₹${GameEngine.formatMoney(job.startingSalary)}/year\nStress: ${job.stressLevel > 70 ? 'Extreme' : job.stressLevel > 40 ? 'High' : 'Low'}\nHours: 40 hours/week'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text('Cancel',
                                          style: TextStyle(color: Colors.grey)),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                        onGameAction(GameAction(
                                            'career.perform', {
                                          'actionId':
                                              'career.apply::${job.title}'
                                        }));
                                      },
                                      child: const Text('Apply',
                                          style: TextStyle(
                                              color: Color(0xFF006D37),
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                    );
                  }).toList(),
                ),
              ],
            );
          }),

          // Metric Bars (Simulation aesthetic)
          Container(
            margin: const EdgeInsets.only(top: 32),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildMetricBarDetailed(
                    'Happiness', character.happiness, const Color(0xFF2ECC71)),
                const SizedBox(height: 16),
                _buildMetricBarDetailed(
                    'Health', character.health, const Color(0xFF006D37)),
                const SizedBox(height: 16),
                _buildMetricBarDetailed(
                    'Stress', character.stressLevel, const Color(0xFFFF9875)),
              ],
            ),
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildMetricBarDetailed(String label, int value, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.lexend(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5C5E62),
              ),
            ),
            Text(
              '$value%',
              style: GoogleFonts.lexend(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF161C28),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 5,
          width: double.infinity,
          decoration: const BoxDecoration(
              color: Color(0xFFDEDFE3)), // secondary-container
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (value / 100).clamp(0.01, 1.0),
            child: Container(color: color),
          ),
        ),
      ],
    );
  }
}

PreferredSizeWidget _buildAppBar(BuildContext context, String title,
    {Widget? trailing}) {
  return FlatBackAppBar(title: title, trailing: trailing);
}

Widget _buildIdentityHeader(Character character) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: Color(0xFFE4E4E7), width: 1)),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT STATUS',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF71717A),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  character.name,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF181C1F),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatMoney(character.bankBalance),
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF059669),
                  ),
                ),
                Text(
                  'Age: ${character.age}',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF71717A),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        _buildMetricBar('Smarts', character.smarts),
        const SizedBox(height: 4),
        _buildMetricBar('Looks', character.looks),
      ],
    ),
  );
}

Widget _buildMetricBar(String label, int value,
    {Color color = const Color(0xFF10B981)}) {
  return Row(
    children: [
      SizedBox(
        width: 64,
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF71717A),
          ),
        ),
      ),
      Expanded(
        child: Container(
          height: 5,
          decoration: const BoxDecoration(color: Color(0xFFF4F4F5)),
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

Widget _buildSectionHeader(String title) {
  return AppSectionHeader(
    title: title,
    style: GoogleFonts.lexend(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF71717A),
      letterSpacing: 2.0,
    ),
  );
}
