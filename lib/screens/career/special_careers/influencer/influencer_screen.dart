import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/engine.dart';
import '../../../../models/character.dart';
import 'influencer_studio_screen.dart';

class InfluencerCareerScreen extends StatefulWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const InfluencerCareerScreen({
    super.key,
    required this.character,
    required this.onGameAction,
  });

  @override
  State<InfluencerCareerScreen> createState() => _InfluencerCareerScreenState();
}

class _InfluencerCareerScreenState extends State<InfluencerCareerScreen> {
  late Character _character;

  @override
  void initState() {
    super.initState();
    _character = widget.character;
  }

  @override
  void didUpdateWidget(InfluencerCareerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.character != oldWidget.character) {
      _character = widget.character;
    }
  }

  void _runAction(String action, [Map<String, dynamic>? payload]) {
    final gameAction = GameAction(
      'career.perform',
      {
        'actionId': 'career.influencer.$action',
        'stayInFlow': true,
        ...?payload,
      },
    );
    widget.onGameAction(gameAction);
  }

  void _changeNiche() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
      ),
      builder: (context) {
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
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'SELECT NICHE',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF606366),
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFDDE2F3)),
              ...niches.map((niche) => ListTile(
                    title: Text(
                      niche,
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.w700,
                        color: _character.contentType == niche
                            ? const Color(0xFF006D37)
                            : const Color(0xFF161C28),
                      ),
                    ),
                    trailing: _character.contentType == niche
                        ? const Icon(Icons.check, color: Color(0xFF006D37))
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      _runAction('set_niche', {'niche': niche});
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
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3FF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          height: 56,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFDDE2F3), width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).pop();
                      },
                      child: const SizedBox(
                        width: 24,
                        height: 40,
                        child: Icon(Icons.arrow_back,
                            color: Color(0xFF10B981), size: 24),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'LIFE SIM',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF10B981),
                        letterSpacing: -0.02,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24), // Spacer
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // Top Status Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF5C5E62),
                            letterSpacing: 0.05,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${_character.followers}',
                              style: GoogleFonts.lexend(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF161C28),
                                letterSpacing: -0.02,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Followers',
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
                    // Verification Status
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (_character.isVerified)
                          Text(
                            'VERIFIED',
                            style: GoogleFonts.lexend(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2563EB),
                            ),
                          )
                        else if (_character.followers >= 100000)
                          GestureDetector(
                            onTap: () => _runAction('apply_verification'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xFF006D37), width: 1.5),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                'APPLY FOR VERIFICATION',
                                style: GoogleFonts.lexend(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF006D37),
                                  letterSpacing: 0.05,
                                ),
                              ),
                            ),
                          )
                        else
                          Text(
                            'NO',
                            style: GoogleFonts.lexend(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFBA1A1A),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Platform Selection Tabs
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFF1F3FF), width: 1),
                    ),
                  ),
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPlatformTab(Icons.photo_camera, 'Instagram'),
                      _buildPlatformTab(Icons.movie, 'YouTube'),
                      _buildPlatformTab(Icons.smart_display, 'TikTok'),
                      _buildPlatformTab(Icons.podcasts, 'Podcast'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Content Type Selector Row
                GestureDetector(
                  onTap: _changeNiche,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3FF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NICHE / CONTENT TYPE',
                              style: GoogleFonts.lexend(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF5C5E62),
                                letterSpacing: 0.05,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _character.contentType,
                              style: GoogleFonts.lexend(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF006D37),
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.expand_more, color: Color(0xFF6C7B6D)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Fame and Engagement bars
                _ProgressBar(
                  label: 'FAME',
                  percentage: _character.fame,
                  fillColor: const Color(0xFFFF9875),
                ),
                const SizedBox(height: 6),
                _ProgressBar(
                  label: 'ENGAGEMENT',
                  percentage: _character.engagement,
                  fillColor: const Color(0xFF793015),
                ),
              ],
            ),
          ),
          // Section: CONTENT CREATION
          Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'CONTENT CREATION',
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF606366),
                letterSpacing: 1.5,
              ),
            ),
          ),
          Column(
            children: [
              _FlatRow(
                emoji: '📸',
                title: 'Post Photo',
                subtitle: 'Share a new look with your audience.',
                onTap: () => _runAction('post_photo'),
              ),
              _FlatRow(
                emoji: '🎥',
                title: 'Upload Video',
                subtitle: 'Vlog your daily life and editing skills.',
                onTap: () => _runAction('upload_video'),
              ),
              _FlatRow(
                emoji: '📱',
                title: 'Create Short Video',
                subtitle: 'Quick fun clips for the algorithm.',
                onTap: () => _runAction('create_short'),
              ),
              _FlatRow(
                emoji: '🎙',
                title: 'Go Live',
                subtitle: 'Interact with fans in real-time.',
                onTap: () => _runAction('go_live'),
              ),
              _FlatRow(
                emoji: '📖',
                title: 'Share Story',
                subtitle: 'Daily updates that disappear in 24h.',
                onTap: () => _runAction('share_story'),
              ),
              const SizedBox(height: 16),
              _FlatRow(
                emoji: '🎤',
                title: 'STUDIO',
                subtitle:
                    'Manage your audience, monetization, and career risks',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => InfluencerStudioScreen(
                        character: _character,
                        onGameAction: (action) {
                          widget.onGameAction(action);
                          // Refresh status when returning or updating
                          final result =
                              GameEngine.processAction(_character, action);
                          setState(() => _character = result.character);
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildPlatformTab(IconData icon, String platformName) {
    final isActive = _character.platform == platformName;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!isActive) {
          _runAction('set_platform', {'platform': platformName});
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: isActive
              ? const Border(
                  bottom: BorderSide(color: Color(0xFF006D37), width: 2),
                )
              : null,
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive ? const Color(0xFF006D37) : const Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final String label;
  final int percentage;
  final Color fillColor;

  const _ProgressBar({
    required this.label,
    required this.percentage,
    required this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.lexend(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF5C5E62),
                letterSpacing: 0.05,
              ),
            ),
            Text(
              '$percentage%',
              style: GoogleFonts.lexend(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF5C5E62),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 5,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFE8EEFF),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage / 100.0,
            child: Container(
              color: fillColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _FlatRow extends StatefulWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FlatRow({
    required this.emoji,
    required this.title,
    required this.subtitle,
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
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _pressed ? const Color(0xFFF1F3FF) : Colors.white,
          border: const Border(
            bottom: BorderSide(color: Color(0xFFDDE2F3), width: 1),
          ),
        ),
        child: Row(
          children: [
            Text(
              widget.emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF161C28),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    widget.subtitle,
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF5C5E62),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFBBCBBB),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
