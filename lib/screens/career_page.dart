// lib/screens/career_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/character.dart';
import '../core/engine.dart';
import '../core/design_system.dart';
import '../core/career_data.dart';
import '../core/institute_data.dart';

typedef LifeAction = ActionResult Function(Character character);

class CareerPage extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;
  final void Function(LifeAction) onLifeAction;

  const CareerPage({
    super.key,
    required this.character,
    required this.onGameAction,
    required this.onLifeAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: _buildAppBar(context, 'CAREER'),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildIdentityHeader(character),
          
          _buildSectionHeader('OCCUPATION'),
          _FlatRowGroup(
            rows: [
              _FlatRow(
                icon: Text(character.annualIncome > 0 ? '💼' : '🏫', style: const TextStyle(fontSize: 24)),
                title: character.annualIncome > 0 ? character.jobTitle : 'Student',
                subtitle: character.annualIncome > 0 ? character.careerGroup : 'Studying at School',
                onTap: () {},
              ),
              if (character.annualIncome > 0 || character.age >= 5)
                _FlatRow(
                  icon: const Icon(Icons.auto_stories, color: Color(0xFF059669), size: 24),
                  title: 'Study Harder',
                  onTap: () => onGameAction(const GameAction('career.perform', {'actionId': 'career.study_hard'})),
                ),
            ],
          ),

          _buildSectionHeader('OPTIONS'),
          _FlatRowGroup(
            rows: [
              _FlatRow(
                icon: const Icon(Icons.work, color: Color(0xFF059669), size: 24),
                title: 'Jobs',
                onTap: () => _push(context, _JobsListScreen(
                  title: 'JOBS',
                  character: character,
                  onGameAction: onGameAction,
                  tier: CareerTier.fullTime,
                )),
              ),
              _FlatRow(
                icon: const Icon(Icons.schedule, color: Color(0xFF059669), size: 24),
                title: 'Part-Time Jobs',
                onTap: () => _push(context, _JobsListScreen(
                  title: 'PART-TIME JOBS',
                  character: character,
                  onGameAction: onGameAction,
                  tier: CareerTier.partTime,
                )),
              ),
              _FlatRow(
                icon: const Icon(Icons.computer, color: Color(0xFF059669), size: 24),
                title: 'Freelance',
                onTap: () => _push(context, _JobsListScreen(
                  title: 'FREELANCE',
                  character: character,
                  onGameAction: onGameAction,
                  tier: CareerTier.freelance,
                )),
              ),
              _FlatRow(
                icon: const Icon(Icons.star, color: Color(0xFF059669), size: 24),
                title: 'Special Careers',
                onTap: () => _push(context, _SpecialListScreen(
                  character: character,
                  onGameAction: onGameAction,
                )),
              ),
              _FlatRow(
                icon: const Icon(Icons.school, color: Color(0xFF059669), size: 24),
                title: 'Education',
                onTap: () => _push(context, _EducationListScreen(
                  character: character,
                  onGameAction: onGameAction,
                )),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

// ─── Sub Screens (Using same flat style) ─────────────────────────────────────

class _JobsListScreen extends StatelessWidget {
  final String title;
  final Character character;
  final void Function(GameAction) onGameAction;
  final CareerTier tier;

  const _JobsListScreen({
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
          _FlatRowGroup(
            rows: groups.map((group) {
              final firstStep = group.steps.first;
              return _FlatRow(
                icon: Text(group.emoji.isNotEmpty ? group.emoji : '💼', style: const TextStyle(fontSize: 24)),
                title: group.name,
                subtitle: '${firstStep.title} • ₹${GameEngine.formatMoney(firstStep.annualSalary)}/yr',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => _JobDetailScreen(
                    character: character,
                    onGameAction: onGameAction,
                    jobTitle: firstStep.title,
                    emoji: group.emoji.isNotEmpty ? group.emoji : '💼',
                    salary: firstStep.annualSalary.toDouble(),
                    stressLevel: 'Low',
                    workHours: 40,
                    promotionChance: 'Moderate',
                    actionId: 'career.apply_group::${group.name}',
                  ),
                )),
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
      appBar: _buildAppBar(context, 'PART-TIME JOBS', trailing: const SizedBox()),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFF1F3FF),
            child: Text(
              'AVAILABLE POSITIONS',
              style: GoogleFonts.lexend(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5C5E62),
                letterSpacing: 1.5,
              ),
            ),
          ),
          
          _buildPartTimeRow(context, '🍔', 'Fast Food Worker', '\$15/hr • Age 14+', 14),
          _buildPartTimeRow(context, '📦', 'Delivery Boy', '\$12/hr • Age 16+', 16),
          _buildPartTimeRow(context, '🛒', 'Shop Assistant', '\$14/hr • Age 15+', 15),
          _buildPartTimeRow(context, '☕', 'Cafe Worker', '\$16/hr • Age 16+', 16),
          _buildPartTimeRow(context, '🐕', 'Dog Walker', '\$10/hr • Age 12+', 12),
          _buildPartTimeRow(context, '📰', 'Paper Route', '\$8/hr • Age 10+', 10),

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
                  _buildPartTimeMetricBar('HAPPINESS', character.happiness, const Color(0xFF006D37)),
                  const SizedBox(height: 12),
                  _buildPartTimeMetricBar('STRESS', character.stressLevel, const Color(0xFFBA1A1A)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartTimeRow(BuildContext context, String emoji, String title, String subtitle, int minAge) {
    return GestureDetector(
      onTap: () {
        if (character.age >= minAge) {
          onGameAction(const GameAction('career.perform', {'actionId': 'career.apply_group::Part-Time'}));
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You must be $minAge to apply.')));
        }
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          border: Border(bottom: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF161C28),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
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
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5C5E62),
                letterSpacing: 1.0,
              ),
            ),
            Text(
              '$value%',
              style: GoogleFonts.lexend(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
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
    final medGroup = CareerSystem.allGroups.firstWhere((g) => g.name == 'Medical');
    final medLocked = !CareerSystem.canEnter(medGroup, character);

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
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back, color: Color(0xFF10B981), size: 24),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'JOBS',
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF181C1F),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF005228),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'LVL ${character.age}',
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2ECC71),
                      ),
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

          _buildSectionHeader('ENTRY LEVEL'),
          _FlatRowGroup(
            rows: [
              _FlatRow(
                icon: const Text('🧑‍💼', style: TextStyle(fontSize: 24)),
                title: 'Office Assistant',
                subtitle: '\$30,000/year',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => _JobDetailScreen(
                    character: character,
                    onGameAction: onGameAction,
                    jobTitle: 'Office Assistant',
                    emoji: '🧑‍💼',
                    salary: 30000,
                    stressLevel: 'Low',
                    workHours: 40,
                    promotionChance: 'Moderate',
                    actionId: 'career.apply_group::Business',
                  ),
                )),
              ),
              _FlatRow(
                icon: const Text('📦', style: TextStyle(fontSize: 24)),
                title: 'Delivery Driver',
                subtitle: '\$25,000/year',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => _JobDetailScreen(
                    character: character,
                    onGameAction: onGameAction,
                    jobTitle: 'Delivery Driver',
                    emoji: '📦',
                    salary: 25000,
                    stressLevel: 'Low',
                    workHours: 40,
                    promotionChance: 'High',
                    actionId: 'career.apply_group::Business',
                  ),
                )),
              ),
            ],
          ),

          const SizedBox(height: 8),
          _buildSectionHeader('CORPORATE'),
          _FlatRowGroup(
            rows: [
              _FlatRow(
                icon: const Text('💼', style: TextStyle(fontSize: 24)),
                title: 'Junior Analyst',
                subtitle: '\$55,000/year',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => _JobDetailScreen(
                    character: character,
                    onGameAction: onGameAction,
                    jobTitle: 'Junior Analyst',
                    emoji: '💼',
                    salary: 55000,
                    stressLevel: 'High',
                    workHours: 50,
                    promotionChance: 'High',
                    actionId: 'career.apply_group::Corporate',
                  ),
                )),
              ),
              _FlatRow(
                icon: const Text('👔', style: TextStyle(fontSize: 24)),
                title: 'HR Assistant',
                subtitle: '\$48,000/year',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => _JobDetailScreen(
                    character: character,
                    onGameAction: onGameAction,
                    jobTitle: 'HR Assistant',
                    emoji: '👔',
                    salary: 48000,
                    stressLevel: 'Low',
                    workHours: 40,
                    promotionChance: 'Moderate',
                    actionId: 'career.apply_group::Government',
                  ),
                )),
              ),
            ],
          ),

          const SizedBox(height: 8),
          _buildSectionHeader('TECH'),
          _FlatRowGroup(
            rows: [
              _FlatRow(
                icon: const Text('💻', style: TextStyle(fontSize: 24)),
                title: 'Junior Developer',
                subtitle: '\$65,000/year',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => _JobDetailScreen(
                    character: character,
                    onGameAction: onGameAction,
                    jobTitle: 'Junior Developer',
                    emoji: '💻',
                    salary: 65000,
                    stressLevel: 'Low',
                    workHours: 40,
                    promotionChance: 'Moderate',
                    actionId: 'career.apply_group::Tech',
                  ),
                )),
              ),
              _FlatRow(
                icon: const Text('🖥️', style: TextStyle(fontSize: 24)),
                title: 'IT Support',
                subtitle: '\$50,000/year',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => _JobDetailScreen(
                    character: character,
                    onGameAction: onGameAction,
                    jobTitle: 'IT Support',
                    emoji: '🖥️',
                    salary: 50000,
                    stressLevel: 'Moderate',
                    workHours: 40,
                    promotionChance: 'Moderate',
                    actionId: 'career.apply_group::Tech',
                  ),
                )),
              ),
            ],
          ),

          const SizedBox(height: 8),
          _buildSectionHeader('HEALTHCARE'),
          _FlatRowGroup(
            rows: [
              _FlatRow(
                icon: const Text('🏥', style: TextStyle(fontSize: 24)),
                title: 'Nursing Assistant',
                subtitle: '\$40,000/year',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => _JobDetailScreen(
                    character: character,
                    onGameAction: onGameAction,
                    jobTitle: 'Nursing Assistant',
                    emoji: '🏥',
                    salary: 40000,
                    stressLevel: 'High',
                    workHours: 50,
                    promotionChance: 'High',
                    actionId: 'career.apply_group::Medical',
                  ),
                )),
              ),
              _FlatRow(
                icon: const Text('🩺', style: TextStyle(fontSize: 24)),
                title: 'Surgeon (Locked)',
                subtitle: 'Requires Medical School',
                locked: medLocked,
                titleStyle: medLocked ? GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF5C5E62)) : null,
                subtitleStyle: medLocked ? GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFFBA1A1A)) : null,
                onTap: medLocked ? () {} : () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => _JobDetailScreen(
                    character: character,
                    onGameAction: onGameAction,
                    jobTitle: 'Surgeon',
                    emoji: '🩺',
                    salary: 200000,
                    stressLevel: 'Extreme',
                    workHours: 70,
                    promotionChance: 'Moderate',
                    actionId: 'career.apply_group::Medical',
                  ),
                )),
              ),
            ],
          ),

          // Metric Bars (Simulation aesthetic)
          Container(
            margin: const EdgeInsets.only(top: 32),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildMetricBarDetailed('Happiness', character.happiness, const Color(0xFF2ECC71)),
                const SizedBox(height: 16),
                _buildMetricBarDetailed('Health', character.health, const Color(0xFF006D37)),
                const SizedBox(height: 16),
                _buildMetricBarDetailed('Stress', character.stressLevel, const Color(0xFFFF9875)),
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
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5C5E62),
              ),
            ),
            Text(
              '$value%',
              style: GoogleFonts.lexend(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF161C28),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 12,
          width: double.infinity,
          decoration: const BoxDecoration(color: Color(0xFFDEDFE3)), // secondary-container
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

class _JobDetailScreen extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;
  final String jobTitle;
  final String emoji;
  final double salary;
  final String stressLevel;
  final int workHours;
  final String promotionChance;
  final String actionId;

  const _JobDetailScreen({
    required this.character,
    required this.onGameAction,
    required this.jobTitle,
    required this.emoji,
    required this.salary,
    required this.stressLevel,
    required this.workHours,
    required this.promotionChance,
    required this.actionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: _buildAppBar(context, 'JOB DETAIL', trailing: const SizedBox()),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSectionHeader('JOB INFO'),
          _FlatRowGroup(
            rows: [
              _FlatRow(
                icon: Text(emoji, style: const TextStyle(fontSize: 24)),
                title: jobTitle,
                subtitle: 'Position',
                titleStyle: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF161C28)),
                subtitleStyle: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF5C5E62)),
                onTap: () {},
              ),
              _FlatRow(
                icon: const Text('💰', style: TextStyle(fontSize: 24)),
                title: '\$${GameEngine.formatMoney(salary)}/year',
                subtitle: 'Salary',
                titleStyle: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF161C28)),
                subtitleStyle: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF5C5E62)),
                onTap: () {},
              ),
              _FlatRow(
                icon: const Text('😰', style: TextStyle(fontSize: 24)),
                title: stressLevel,
                subtitle: 'Stress Level',
                titleStyle: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF161C28)),
                subtitleStyle: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF5C5E62)),
                onTap: () {},
              ),
              _FlatRow(
                icon: const Text('⏰', style: TextStyle(fontSize: 24)),
                title: '$workHours hours/week',
                subtitle: 'Work Hours',
                titleStyle: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF161C28)),
                subtitleStyle: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF5C5E62)),
                onTap: () {},
              ),
              _FlatRow(
                icon: const Text('🚀', style: TextStyle(fontSize: 24)),
                title: promotionChance,
                subtitle: 'Promotion Chance',
                titleStyle: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF161C28)),
                subtitleStyle: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF5C5E62)),
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 16),
          _buildSectionHeader('ACTIONS'),
          _FlatRowGroup(
            rows: [
              _FlatRow(
                icon: const Text('✅', style: TextStyle(fontSize: 20)),
                title: 'Apply for Job',
                subtitle: 'Submit your application',
                titleStyle: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF006D37)),
                subtitleStyle: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF5C5E62)),
                onTap: () {
                  onGameAction(GameAction('career.perform', {'actionId': actionId}));
                  Navigator.of(context).pop();
                },
              ),
              _FlatRow(
                icon: const Text('🔍', style: TextStyle(fontSize: 20)),
                title: 'Research Company',
                subtitle: 'Learn more about the role',
                titleStyle: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF161C28)),
                subtitleStyle: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF5C5E62)),
                onTap: () {},
              ),
              _FlatRow(
                icon: const Text('🔙', style: TextStyle(fontSize: 20)),
                title: 'Back to Listings',
                subtitle: 'Return to the jobs page',
                titleStyle: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF161C28)),
                subtitleStyle: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF5C5E62)),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          // Metric Bars Footer Area
          Container(
            margin: const EdgeInsets.only(top: 32, bottom: 32),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildJobMetricBarDetailed('Performance', 80, const Color(0xFF2ECC71)),
                const SizedBox(height: 16),
                _buildJobMetricBarDetailed('Stress', 15, const Color(0xFFFF9875)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobMetricBarDetailed(String label, int value, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.lexend(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF5C5E62),
              ),
            ),
            Text(
              '$value%',
              style: GoogleFonts.lexend(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF5C5E62),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          width: double.infinity,
          decoration: const BoxDecoration(color: Color(0xFFDDE2F3)), // surface-container-highest
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

class _SpecialFlatRow extends StatefulWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool locked;
  final VoidCallback onTap;

  const _SpecialFlatRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.locked = false,
    required this.onTap,
  });

  @override
  State<_SpecialFlatRow> createState() => _SpecialFlatRowState();
}

class _SpecialFlatRowState extends State<_SpecialFlatRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.locked ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.locked ? null : (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _pressed ? const Color(0xFFE8EEFF) : Colors.transparent,
          border: const Border(bottom: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
        ),
        child: Opacity(
          opacity: widget.locked ? 0.6 : 1.0,
          child: Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: Text(widget.icon, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF5C5E62),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF5C5E62).withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (widget.locked)
                const Icon(Icons.lock, color: Color(0xFF6C7B6D), size: 24)
              else
                const Icon(Icons.chevron_right, color: Color(0xFF6C7B6D), size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecialListScreen extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const _SpecialListScreen({
    required this.character,
    required this.onGameAction,
  });

  bool _isLocked(String careerName) {
    try {
      final career = CareerSystem.specialCareers.firstWhere((c) => c.name == careerName);
      return !CareerSystem.canEnterSpecial(career, character);
    } catch (_) {
      return true; // Lock if not found
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: _buildAppBar(context, 'SPECIAL CAREERS', trailing: const SizedBox()),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSectionHeader('FAME'),
          _SpecialFlatRow(
            icon: '🎬',
            title: 'Actor',
            subtitle: 'Fame: 0% • Education: None',
            locked: _isLocked('Actor'),
            onTap: () => onGameAction(const GameAction('career.perform', {'actionId': 'career.special.apply::Actor'})),
          ),
          _SpecialFlatRow(
            icon: '🎤',
            title: 'Singer',
            subtitle: 'Fame: 0% • Skill: High',
            locked: _isLocked('Musician'),
            onTap: () => onGameAction(const GameAction('career.perform', {'actionId': 'career.special.apply::Musician'})),
          ),

          const SizedBox(height: 8),
          _buildSectionHeader('SPORTS'),
          _SpecialFlatRow(
            icon: '🏏',
            title: 'Cricketer',
            subtitle: 'Reputation: 0% • Skill: Max',
            locked: _isLocked('Athlete'),
            onTap: () => onGameAction(const GameAction('career.perform', {'actionId': 'career.special.apply::Athlete'})),
          ),
          _SpecialFlatRow(
            icon: '⚽',
            title: 'Footballer',
            subtitle: 'Reputation: 0% • Skill: Max',
            locked: _isLocked('Athlete'),
            onTap: () => onGameAction(const GameAction('career.perform', {'actionId': 'career.special.apply::Athlete'})),
          ),

          const SizedBox(height: 8),
          _buildSectionHeader('ENTERTAINMENT'),
          _SpecialFlatRow(
            icon: '📺',
            title: 'Influencer',
            subtitle: 'Fame: 0% • Followers: 0',
            locked: _isLocked('Influencer'),
            onTap: () => onGameAction(const GameAction('career.perform', {'actionId': 'career.special.apply::Influencer'})),
          ),

          const SizedBox(height: 8),
          _buildSectionHeader('GOVERNMENT'),
          _SpecialFlatRow(
            icon: '🏛️',
            title: 'Politician',
            subtitle: 'Reputation: 0% • Education: University',
            locked: _isLocked('Politician'),
            onTap: () => onGameAction(const GameAction('career.perform', {'actionId': 'career.special.apply::Politician'})),
          ),
          
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _EducationListScreen extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const _EducationListScreen({
    required this.character,
    required this.onGameAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: _buildAppBar(context, 'EDUCATION', trailing: const SizedBox()),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // Status Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFE8EEFF),
              border: Border(bottom: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'High School',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF161C28),
                      ),
                    ),
                    Text(
                      'GPA: 3.8',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF006D37),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CURRENT GRADE: 10',
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5C5E62),
                      ),
                    ),
                    SizedBox(
                      width: 96,
                      height: 8,
                      child: Container(
                        decoration: const BoxDecoration(color: Color(0xFFE1E2E6)),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.85,
                          child: Container(color: const Color(0xFF2ECC71)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          _buildSectionHeader('CURRENT EDUCATION'),
          _FlatRowGroup(
            rows: [
              _FlatRow(
                icon: const Text('🏫', style: TextStyle(fontSize: 24)),
                title: 'Public High School',
                subtitle: 'Grade 10',
                onTap: () {},
              ),
              _FlatRow(
                icon: const Text('📈', style: TextStyle(fontSize: 24)),
                title: 'GPA / Performance',
                subtitle: 'Excellent',
                subtitleStyle: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF006D37),
                ),
                onTap: () {},
              ),
              _FlatRow(
                icon: const Text('📚', style: TextStyle(fontSize: 24)),
                title: 'Study Harder',
                subtitle: 'Improve your grades',
                onTap: () => onGameAction(const GameAction('career.perform', {'actionId': 'career.study_hard'})),
              ),
            ],
          ),

          _buildSectionHeader('OPTIONS'),
          _FlatRowGroup(
            rows: [
              _FlatRow(icon: const Text('🎭', style: TextStyle(fontSize: 24)), title: 'School Activities', onTap: () {}),
              _FlatRow(icon: const Text('📝', style: TextStyle(fontSize: 24)), title: 'Exams', onTap: () {}),
              _FlatRow(icon: const Text('💰', style: TextStyle(fontSize: 24)), title: 'Scholarships', onTap: () {}),
              _FlatRow(icon: const Text('🏛️', style: TextStyle(fontSize: 24)), title: 'Libraries', onTap: () {}),
              _FlatRow(icon: const Text('👨‍🏫', style: TextStyle(fontSize: 24)), title: 'Tutors', onTap: () {}),
            ],
          ),

          _buildSectionHeader('UNIVERSITIES'),
          _FlatRowGroup(
            rows: [
              _FlatRow(
                icon: const Text('🎓', style: TextStyle(fontSize: 24)),
                title: 'Universities',
                subtitle: 'Apply for higher education',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => _UniversityScreen(character: character, onGameAction: onGameAction)
                )),
              ),
              _FlatRow(
                icon: const Text('🏢', style: TextStyle(fontSize: 24)),
                title: 'Post-Graduate',
                subtitle: 'Complete University first',
                locked: true,
                titleStyle: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF5C5E62)),
                subtitleStyle: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic, color: const Color(0xFF5C5E62)),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _UniversityScreen extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const _UniversityScreen({
    required this.character,
    required this.onGameAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: _buildAppBar(
        context, 
        'UNIVERSITY', 
        trailing: const Icon(Icons.school, color: Color(0xFF5C5E62), size: 24),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // Identity Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F3FF),
              border: Border(bottom: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT STATUS',
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5C5E62),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'High School Graduate',
                      style: GoogleFonts.lexend(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF161C28),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      GameEngine.formatMoney(character.bankBalance),
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF006D37),
                      ),
                    ),
                    Text(
                      'Savings',
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5C5E62),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          _buildSectionHeader('COLLEGES'),
          _FlatRowGroup(
            rows: InstituteData.topInstitutes.map((inst) {
              return _FlatRow(
                icon: const Text('🎓', style: TextStyle(fontSize: 24)),
                title: inst.name,
                subtitle: 'Fees: ₹${GameEngine.formatMoney(inst.feesPerYear)} • Prestige: ${inst.tier}',
                onTap: () => onGameAction(GameAction('career.perform', {'actionId': 'education.enroll::${inst.name}'})),
              );
            }).toList(),
          ),

          _buildSectionHeader('APPLICATION'),
          _FlatRowGroup(
            rows: [
              _FlatRow(
                icon: const Text('📝', style: TextStyle(fontSize: 24)),
                title: 'Apply for Admission',
                subtitle: 'Choose your major',
                onTap: () {},
              ),
              _FlatRow(
                icon: const Text('💰', style: TextStyle(fontSize: 24)),
                title: 'Financial Aid',
                subtitle: 'Apply for a student loan',
                onTap: () {},
              ),
            ],
          ),

          // Metric Bars
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
            ),
            child: Column(
              children: [
                _buildMetricBar('INTELLIGENCE', character.smarts, color: const Color(0xFF006D37)),
                const SizedBox(height: 16),
                _buildMetricBar('AMBITION', 95, color: const Color(0xFF98472A)),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}


// ─── Reusable UI Components ──────────────────────────────────────────────────

PreferredSizeWidget _buildAppBar(BuildContext context, String title, {Widget? trailing}) {
  return PreferredSize(
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
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.arrow_back, color: Color(0xFF10B981), size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                title.toUpperCase(),
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF181C1F),
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              trailing ?? const Icon(Icons.more_vert, color: Color(0xFF71717A), size: 24),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildIdentityHeader(Character character) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
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
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF059669),
                  ),
                ),
                Text(
                  'Age: ${character.age}',
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF71717A),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildMetricBar('Smarts', character.smarts),
        const SizedBox(height: 8),
        _buildMetricBar('Looks', character.looks),
      ],
    ),
  );
}

Widget _buildMetricBar(String label, int value, {Color color = const Color(0xFF10B981)}) {
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
          height: 8,
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
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Text(
      title,
      style: GoogleFonts.lexend(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF71717A),
        letterSpacing: 2.0,
      ),
    ),
  );
}

class _FlatRowGroup extends StatelessWidget {
  final List<Widget> rows;
  const _FlatRowGroup({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.symmetric(horizontal: BorderSide(color: Color(0xFFE4E4E7), width: 1)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              const Divider(height: 1, thickness: 1, color: Color(0xFFF4F4F5), indent: 0),
          ],
        ],
      ),
    );
  }
}

class _FlatRow extends StatefulWidget {
  final Widget icon;
  final String title;
  final String? subtitle;
  final bool locked;

  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final VoidCallback onTap;

  const _FlatRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.locked = false,

    this.titleStyle,
    this.subtitleStyle,
    required this.onTap,
  });

  @override
  State<_FlatRow> createState() => _FlatRowState();
}

class _FlatRowState extends State<_FlatRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.locked ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.locked ? null : (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: _pressed ? const Color(0xFFFAFAFA) : (widget.locked ? const Color(0xFFF1F3FF).withValues(alpha: 0.6) : Colors.white),
        child: Opacity(
          opacity: widget.locked ? 0.6 : 1.0,
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: widget.icon,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: widget.titleStyle ?? GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF181C1F),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.subtitle != null)
                      Text(
                        widget.subtitle!,
                        style: widget.subtitleStyle ?? GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF71717A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Icon(widget.locked ? Icons.lock : Icons.chevron_right, color: const Color(0xFFD4D4D8), size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
