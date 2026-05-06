// lib/screens/legacy_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/character.dart';
import '../core/storage.dart';
import '../core/engine.dart';
import 'create_character_screen.dart';
import '../core/design_system.dart';

class LegacyPage extends StatelessWidget {
  final Character character;
  const LegacyPage({super.key, required this.character});

  (String, String, String) _karmaVerdict(int karma) {
    if (karma >= 80) return ('😇', 'Saintly Soul', 'Your legacy of kindness will illuminate the world forever.');
    if (karma >= 60) return ('🙏', 'Noble Heart', 'A life lived with integrity and deep respect for all.');
    if (karma >= 40) return ('⚖️', 'Balanced Life', 'A human story of trials, errors, and quiet victories.');
    if (karma >= 20) return ('😈', 'Reckless Path', 'Your choices left a mark, but perhaps also many regrets.');
    return ('💀', 'Dark Legacy', 'A difficult journey has ended.');
  }

  @override
  Widget build(BuildContext context) {
    final (emoji, title, subtitle) = _karmaVerdict(character.karma);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 32),
          children: [
            // Header
            const Center(child: Text('🪦', style: TextStyle(fontSize: 64))),
            const SizedBox(height: 12),
            Center(
              child: Text('REST IN PEACE',
                  style: AppTextStyles.sectionLabel.copyWith(letterSpacing: 3)),
            ),
            const SizedBox(height: 24),

            // Profile
            const _SectionLabel(title: 'PROFILE'),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _InfoRow(label: 'Name', value: character.name),
                  const Divider(height: 1, thickness: 0.5, color: AppColors.dividerLight, indent: 14),
                  _InfoRow(label: 'Age', value: '${character.age} years'),
                  const Divider(height: 1, thickness: 0.5, color: AppColors.dividerLight, indent: 14),
                  _InfoRow(label: 'City', value: character.city),
                  const Divider(height: 1, thickness: 0.5, color: AppColors.dividerLight, indent: 14),
                  _InfoRow(label: 'Career', value: character.jobTitle),
                ],
              ),
            ),

            // Finances
            const _SectionLabel(title: 'FINANCES'),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _InfoRow(label: 'Net Worth', value: formatMoney(character.bankBalance + character.savingsBalance)),
                  const Divider(height: 1, thickness: 0.5, color: AppColors.dividerLight, indent: 14),
                  _InfoRow(label: 'Total Earned', value: formatMoney(character.totalEarned)),
                ],
              ),
            ),

            // Stats
            const _SectionLabel(title: 'FINAL STATS'),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _InfoRow(label: 'Happiness', value: '${character.happiness}%'),
                  const Divider(height: 1, thickness: 0.5, color: AppColors.dividerLight, indent: 14),
                  _InfoRow(label: 'Health', value: '${character.health}%'),
                  const Divider(height: 1, thickness: 0.5, color: AppColors.dividerLight, indent: 14),
                  _InfoRow(label: 'Smarts', value: '${character.smarts}%'),
                  const Divider(height: 1, thickness: 0.5, color: AppColors.dividerLight, indent: 14),
                  _InfoRow(label: 'Karma', value: '${character.karma}%'),
                ],
              ),
            ),

            // Karma verdict
            const _SectionLabel(title: 'KARMA VERDICT'),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
              child: Column(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Text(title, style: AppTextStyles.rowTitle.copyWith(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.rowSubtitle),
                ],
              ),
            ),

            // Achievements
            if (character.achievements.isNotEmpty) ...[
              const _SectionLabel(title: 'ACHIEVEMENTS'),
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    for (int i = 0; i < character.achievements.length; i++) ...[
                      Builder(builder: (_) {
                        final ach = Achievements.find(character.achievements[i]);
                        return _InfoRow(
                          label: ach?.emoji ?? '🏆',
                          value: ach?.title ?? character.achievements[i],
                        );
                      }),
                      if (i < character.achievements.length - 1)
                        const Divider(height: 1, thickness: 0.5, color: AppColors.dividerLight, indent: 14),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // New Life button
            GestureDetector(
              onTap: () async {
                HapticFeedback.heavyImpact();
                await StorageService.clearAll();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const CreateCharacterScreen()),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                height: 50,
                color: AppColors.info,
                alignment: Alignment.center,
                child: Text(
                  'BEGIN A NEW JOURNEY',
                  style: AppTextStyles.rowTitle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 6),
      child: Text(title, style: AppTextStyles.sectionLabel),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.rowSubtitle),
          const Spacer(),
          Text(value, style: AppTextStyles.rowTitle.copyWith(fontSize: 15)),
        ],
      ),
    );
  }
}
