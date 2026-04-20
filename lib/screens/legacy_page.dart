// lib/screens/legacy_page.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/character.dart';
import '../core/storage.dart';
import '../core/engine.dart';
import 'create_character_screen.dart';
import '../core/design_system.dart';
import '../widgets/glass_container.dart';

class LegacyPage extends StatefulWidget {
  final Character character;
  const LegacyPage({super.key, required this.character});

  @override
  State<LegacyPage> createState() => _LegacyPageState();
}

class _LegacyPageState extends State<LegacyPage>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _fadeAnim =
        CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.88, end: 1.0).animate(
        CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic));

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final character = widget.character;
    final karmaBonus = ((character.karma - 50) / 5).round().clamp(0, 30);
    final (emoji, title, subtitle, accentColor) = _karmaVerdict(character.karma);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: Colors.black, // Dark pillarbox backgrounds for wide screens
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Scaffold(
              backgroundColor: const Color(0xFF060C18),
              body: Stack(
                children: [
                  // Particle / ambient glow background
                  _ParticleBackground(
                    controller: _particleController,
                    accentColor: accentColor,
                  ),

                  // Multi-layered background glows
                  Positioned(
                    top: -120,
                    left: -80,
                    child: Container(
                      width: 360,
                      height: 360,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [accentColor.withValues(alpha: 0.22), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -80,
                    right: -60,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primaryGradient.first.withValues(alpha: 0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.s24, 80, AppSpacing.s24, 100),
                              child: Column(
                                children: [
                                  // Back button
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.15),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.arrow_back_ios_new_rounded,
                                          size: 18,
                                          color: Colors.white.withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.s32),

                                  _buildTrophySection(accentColor),
                                  const SizedBox(height: AppSpacing.s32),

                                  _buildProfileCard(character, karmaBonus, accentColor),
                                  const SizedBox(height: AppSpacing.s24),

                                  _buildKarmaCard(emoji, title, subtitle, accentColor, character),
                                  const SizedBox(height: AppSpacing.s24),

                                  if (character.achievements.isNotEmpty) ...[
                                    _buildAchievementsSection(character, accentColor),
                                    const SizedBox(height: AppSpacing.s32),
                                  ],

                                  _buildRestartButton(context, character, karmaBonus, accentColor),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  (String, String, String, Color) _karmaVerdict(int karma) {
    if (karma >= 80) return ('😇', 'Saintly Soul', 'Your legacy of kindness will illuminate the world forever.', const Color(0xFFA855F7));
    if (karma >= 60) return ('🙏', 'Noble Heart', 'A life lived with integrity and deep respect for all.', const Color(0xFF3B82F6));
    if (karma >= 40) return ('⚖️', 'Balanced Life', 'A human story of trials, errors, and quiet victories.', const Color(0xFF10B981));
    if (karma >= 20) return ('😈', 'Reckless Path', 'Your choices left a mark, but perhaps also many regrets.', const Color(0xFFF97316));
    return ('💀', 'Dark Legacy', 'A difficult journey has ended. May the next be filled with light.', const Color(0xFFEF4444));
  }

  Widget _buildTrophySection(Color accent) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            final pulse = math.sin(_particleController.value * math.pi * 2) * 0.04 + 1.0;
            return Transform.scale(
              scale: pulse,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [accent.withValues(alpha: 0.45), accent.withValues(alpha: 0)],
                  ),
                  border: Border.all(color: accent.withValues(alpha: 0.35), width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: accent.withValues(alpha: 0.3),
                        blurRadius: 50,
                        spreadRadius: 10),
                    BoxShadow(
                        color: accent.withValues(alpha: 0.15),
                        blurRadius: 20,
                        spreadRadius: 5),
                  ],
                ),
                child: const Center(
                  child: Text('🪦', style: TextStyle(fontSize: 58)),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.s20),
        Text(
          'REST IN PEACE',
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withValues(alpha: 0.35),
            letterSpacing: 5,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(Character c, int bonus, Color accent) {
    return GlassContainer(
      opacity: 0.06,
      blur: 24,
      tintColor: Colors.white,
      borderOpacity: 0.12,
      padding: const EdgeInsets.all(AppSpacing.s32),
      child: Column(
        children: [
          Text(
            c.name,
            style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 30),
          ),
          const SizedBox(height: 6),
          Text(
            '${c.city} • ${c.lifeStage}',
            style: AppTextStyles.subtitle.copyWith(
                color: Colors.white.withValues(alpha: 0.45)),
          ),
          const SizedBox(height: AppSpacing.s32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _LegacyStatItem('NET WORTH',
                  '₹${GameEngine.formatMoney(c.bankBalance + c.savingsBalance)}', accent),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              _LegacyStatItem(
                  'BANK', '₹${GameEngine.formatMoney(c.bankBalance)}', accent),
            ],
          ),
          if (bonus > 0) ...[
            const SizedBox(height: AppSpacing.s24),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.karmaGradient.first.withValues(alpha: 0.15),
                    AppColors.karmaGradient.last.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.karmaGradient.first.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('✨', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: AppSpacing.s8),
                  Text(
                    'Karma Bonus: +$bonus to stats in next life',
                    style: AppTextStyles.bodyBold.copyWith(
                        color: AppColors.karmaGradient.first, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKarmaCard(
      String emoji, String title, String subtitle, Color accent, Character c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withValues(alpha: 0.1), accent.withValues(alpha: 0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: accent.withValues(alpha: 0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.2),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: AppSpacing.s16),
          Text(
            title,
            style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 24),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.55),
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(Character c, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.s16),
          child: Text(
            'ACHIEVEMENTS',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.3),
              letterSpacing: 2,
            ),
          ),
        ),
        Wrap(
          spacing: AppSpacing.s12,
          runSpacing: AppSpacing.s12,
          children: c.achievements.map((id) {
            final ach = Achievements.find(id);
            if (ach == null) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent.withValues(alpha: 0.12),
                    accent.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(ach.emoji, style: const TextStyle(fontSize: 26)),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    ach.title,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRestartButton(
      BuildContext context, Character c, int bonus, Color accent) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.heavyImpact();
        await StorageService.clearAll();
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, a, s) => const CreateCharacterScreen(),
              transitionDuration: const Duration(milliseconds: 500),
              transitionsBuilder: (_, a, s, child) => FadeTransition(
                opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
                child: child,
              ),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF7043), Color(0xFFF97316), Color(0xFFEA580C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF97316).withValues(alpha: 0.5),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: const Color(0xFFF97316).withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.refresh_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: AppSpacing.s12),
              Text(
                'BEGIN A NEW JOURNEY',
                style: AppTextStyles.bodyBold.copyWith(
                  color: Colors.white,
                  letterSpacing: 1.2,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Particle background painter
class _ParticleBackground extends StatelessWidget {
  final AnimationController controller;
  final Color accentColor;

  const _ParticleBackground(
      {required this.controller, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _ParticlePainter(
            progress: controller.value,
            accentColor: accentColor,
          ),
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color accentColor;
  static const int _particleCount = 25;

  _ParticlePainter({required this.progress, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _particleCount; i++) {
      final seedX = random.nextDouble();
      final seedY = random.nextDouble();
      final speed = 0.08 + random.nextDouble() * 0.15;
      final size2 = 1.0 + random.nextDouble() * 3.0;
      final phase = random.nextDouble();

      final x = seedX * size.width;
      final cycleY = ((seedY + progress * speed + phase) % 1.0);
      final y = size.height - cycleY * size.height;

      final opacity =
          (math.sin(cycleY * math.pi)).clamp(0.0, 1.0) * 0.55;

      paint.color =
          (i % 3 == 0 ? accentColor : Colors.white).withValues(alpha: opacity);

      canvas.drawCircle(Offset(x, y), size2, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

class _LegacyStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  const _LegacyStatItem(this.label, this.value, this.accent);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.bodyBold.copyWith(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption
              .copyWith(color: Colors.white.withValues(alpha: 0.3)),
        ),
      ],
    );
  }
}
