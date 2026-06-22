import 'package:flutter/material.dart';

import '../../../../core/design_system.dart';
import '../../../../core/engine.dart';
import '../../../../models/character.dart';
import '../../../../widgets/core/app_scaffold.dart';
import '../../../../widgets/core/app_status_banner.dart';
import '../../../../widgets/game/action_tile.dart';
import '../../../../widgets/game/game_card.dart';
import '../../../../widgets/game/progress_bar.dart';
import '../../../../widgets/game/section_header.dart';
import 'influencer_studio_screen.dart';

class InfluencerCareerScreen extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const InfluencerCareerScreen({
    super.key,
    required this.character,
    required this.onGameAction,
  });

  void _runAction(BuildContext context, String action,
      [Map<String, dynamic>? payload]) {
    final gameAction = GameAction(
      'career.perform',
      {
        'actionId': 'career.influencer.$action',
        'stayInFlow': true,
        ...?payload,
      },
    );
    onGameAction(gameAction);
  }

  void _changeNiche(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
      ),
      builder: (ctx) {
        final niches = [
          'Gaming',
          'Lifestyle',
          'Comedy',
          'Education',
          'Fitness',
          'Technology',
          'Fashion',
          'Travel'
        ];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'SELECT NICHE',
                  style: AppTextStyles.labelBold.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF606366),
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),
              ...niches.map((niche) => ListTile(
                    title: Text(
                      niche,
                      style: AppTextStyles.labelBold.copyWith(
                        color: character.contentType == niche
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    trailing: character.contentType == niche
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      _runAction(context, 'set_niche', {'niche': niche});
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'INFLUENCER',
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      children: [
        // Top Status Section
        Container(
          color: AppColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppStatusBanner(
                label: 'CURRENT STATUS',
                title: '${character.followers}',
                subtitle: 'Followers',
                trailing: character.isVerified
                    ? Text(
                        'VERIFIED',
                        style: AppTextStyles.labelBold.copyWith(
                          fontSize: 13,
                          color: const Color(0xFF2563EB),
                        ),
                      )
                    : character.followers >= 100000
                        ? GestureDetector(
                            onTap: () => _runAction(context, 'apply_verification'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppColors.primary, width: 1.5),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                'APPLY FOR VERIFICATION',
                                style: AppTextStyles.labelBold.copyWith(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                  letterSpacing: 0.05,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            'NO',
                            style: AppTextStyles.labelBold.copyWith(
                              fontSize: 13,
                              color: const Color(0xFFBA1A1A),
                            ),
                          ),
              ),

              // Platform Selection Tabs
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.containerPadding,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPlatformTab(context, Icons.photo_camera, 'Instagram'),
                    _buildPlatformTab(context, Icons.movie, 'YouTube'),
                    _buildPlatformTab(context, Icons.smart_display, 'TikTok'),
                    _buildPlatformTab(context, Icons.podcasts, 'Podcast'),
                  ],
                ),
              ),

              // Niche Selector
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.containerPadding,
                  vertical: AppSpacing.xs,
                ),
                child: GestureDetector(
                  onTap: () => _changeNiche(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NICHE / CONTENT TYPE',
                              style: AppTextStyles.labelBold.copyWith(
                                fontSize: 9,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.05,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              character.contentType,
                              style: AppTextStyles.labelBold.copyWith(
                                fontSize: 13,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.expand_more, color: Color(0xFF6C7B6D)),
                      ],
                    ),
                  ),
                ),
              ),

              // Fame and Engagement bars
              const SizedBox(height: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.containerPadding,
                ),
                child: ProgressBarRow(
                  label: 'FAME',
                  value: character.fame.toDouble(),
                  color: const Color(0xFFFF9875),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.containerPadding,
                ),
                child: ProgressBarRow(
                  label: 'ENGAGEMENT',
                  value: character.engagement.toDouble(),
                  color: const Color(0xFF793015),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Content Creation
        const SectionHeader(title: 'CONTENT CREATION'),
        GameCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              ActionTile(
                emoji: '📸',
                label: 'Post Photo',
                rewards: const [],
                onTap: () => _runAction(context, 'post_photo'),
              ),
              const SizedBox(height: AppSpacing.sm),
              ActionTile(
                emoji: '🎥',
                label: 'Upload Video',
                rewards: const [],
                onTap: () => _runAction(context, 'upload_video'),
              ),
              const SizedBox(height: AppSpacing.sm),
              ActionTile(
                emoji: '📱',
                label: 'Create Short Video',
                rewards: const [],
                onTap: () => _runAction(context, 'create_short'),
              ),
              const SizedBox(height: AppSpacing.sm),
              ActionTile(
                emoji: '🎙',
                label: 'Go Live',
                rewards: const [],
                onTap: () => _runAction(context, 'go_live'),
              ),
              const SizedBox(height: AppSpacing.sm),
              ActionTile(
                emoji: '📖',
                label: 'Share Story',
                rewards: const [],
                onTap: () => _runAction(context, 'share_story'),
              ),
              const SizedBox(height: AppSpacing.md),
              ActionTile(
                emoji: '🎤',
                label: 'STUDIO',
                rewards: const [],
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => InfluencerStudioScreen(
                        character: character,
                        onGameAction: onGameAction,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildPlatformTab(BuildContext context, IconData icon, String platform) {
    final isActive = character.platform == platform;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!isActive) {
          _runAction(context, 'set_platform', {'platform': platform});
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: isActive
              ? const Border(
                  bottom: BorderSide(color: AppColors.primary, width: 2),
                )
              : null,
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
