import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/design_system.dart';
import '../../../../core/engine.dart';
import '../../../../models/character.dart';
import '../../../../widgets/core/app_scaffold.dart';
import '../../../../widgets/events/event_card.dart';
import '../../../../widgets/events/event_types.dart';
import '../../../../widgets/game/section_header.dart';

class InfluencerStudioScreen extends StatefulWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const InfluencerStudioScreen({
    super.key,
    required this.character,
    required this.onGameAction,
  });

  @override
  State<InfluencerStudioScreen> createState() => _InfluencerStudioScreenState();
}

class _InfluencerStudioScreenState extends State<InfluencerStudioScreen> {
  late Character _character;
  final List<Map<String, dynamic>> _offers = [];

  static const List<Map<String, dynamic>> _brands = [
    {
      'name': 'Zomato',
      'minFollowers': 5000,
      'basePay': 1500,
      'payPerFollower': 0.12,
      'fame': 1
    },
    {
      'name': 'Mamaearth',
      'minFollowers': 8000,
      'basePay': 2500,
      'payPerFollower': 0.14,
      'fame': 2
    },
    {
      'name': 'Boat Audio',
      'minFollowers': 12000,
      'basePay': 4000,
      'payPerFollower': 0.16,
      'fame': 2
    },
    {
      'name': 'Dream11',
      'minFollowers': 25000,
      'basePay': 8000,
      'payPerFollower': 0.18,
      'fame': 3
    },
    {
      'name': 'Jio Fiber',
      'minFollowers': 50000,
      'basePay': 18000,
      'payPerFollower': 0.22,
      'fame': 4
    },
    {
      'name': 'TATA Tea',
      'minFollowers': 100000,
      'basePay': 45000,
      'payPerFollower': 0.25,
      'fame': 5
    },
  ];

  @override
  void initState() {
    super.initState();
    _character = widget.character;
    _generateOffers();
  }

  @override
  void didUpdateWidget(InfluencerStudioScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.character != oldWidget.character) {
      _character = widget.character;
    }
  }

  void _generateOffers() {
    if (_character.followers < 5000) return;

    final rng = Random();
    final eligibleBrands = _brands
        .where((b) => _character.followers >= (b['minFollowers'] as int))
        .toList();
    if (eligibleBrands.isEmpty) return;

    eligibleBrands.shuffle(rng);
    final count = min(eligibleBrands.length, 2 + rng.nextInt(2));

    for (int i = 0; i < count; i++) {
      final brand = eligibleBrands[i];
      final double basePay = (brand['basePay'] as int).toDouble();
      final double payPerFollower = brand['payPerFollower'] as double;
      final double payout =
          basePay + (_character.followers * payPerFollower) + rng.nextInt(1000);
      final int fame = brand['fame'] as int;

      _offers.add({
        'company': brand['name'],
        'money': payout,
        'fame': fame,
      });
    }
  }

  void _acceptOffer(int index) {
    final offer = _offers[index];
    final gameAction = GameAction(
      'career.perform',
      {
        'actionId': 'career.influencer.sponsorship_accept',
        'stayInFlow': true,
        'company': offer['company'],
        'money': offer['money'],
        'fame': offer['fame'],
      },
    );

    setState(() {
      _offers.removeAt(index);
    });
    widget.onGameAction(gameAction);
  }

  void _rejectOffer(int index) {
    final company = _offers[index]['company'];
    setState(() {
      _offers.removeAt(index);
    });
    showEventCard(
      context: context,
      category: EventCategory.fame,
      mode: EventCardMode.info,
      title: 'Offer Declined',
      description: 'Rejected offer from $company.',
    );
  }

  void _showOfferDialog(int index) {
    final offer = _offers[index];
    showEventCard(
      context: context,
      category: EventCategory.fame,
      mode: EventCardMode.offer,
      title: 'SPONSORSHIP OFFER',
      description: '${offer['company']} wants to sponsor a campaign on your profile.',
      illustration: const EventIllustration.emoji('🤝'),
      infoRows: [
        EventInfoRow(label: 'Payout', value: '₹${GameEngine.formatMoney(offer['money'])}'),
        EventInfoRow(label: 'Fame Boost', value: '+${offer['fame']}%'),
      ],
      primaryAction: EventCardAction(
        label: 'ACCEPT',
        onPressed: () {
          Navigator.pop(context);
          _acceptOffer(index);
        },
      ),
      secondaryAction: EventCardAction(
        label: 'DECLINE',
        onPressed: () {
          Navigator.pop(context);
          _rejectOffer(index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Influencer Studio',
      showBack: true,
      children: [
        const SectionHeader(title: 'ANALYTICS'),
        Column(
          children: [
            _buildStatRow('Total Followers', '${_character.followers}'),
            _buildStatRow('Total Posts', '${_character.totalPosts}'),
            _buildStatRow('Fame', '${_character.fame}%'),
            _buildStatRow('Engagement', '${_character.engagement}%'),
            _buildStatRow('Most Successful Platform', _character.platform),
            _buildStatRow('Current Niche', _character.contentType),
          ],
        ),

        const SectionHeader(title: 'SPONSORSHIPS'),
        if (_character.followers < 5000)
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
            color: AppColors.surface,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Icon(Icons.lock, color: AppColors.error, size: 20),
                const SizedBox(width: AppSpacing.cardGap),
                Expanded(
                  child: Text(
                    'Locked: Reach 5,000 followers to unlock sponsorships.',
                    style: AppTextStyles.rowSubtitle.copyWith(color: AppColors.error),
                  ),
                ),
              ],
            ),
          )
        else if (_offers.isEmpty)
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
            color: AppColors.surface,
            alignment: Alignment.center,
            child: Text(
              'No sponsorships available right now. Post more content!',
              style: AppTextStyles.rowSubtitle,
            ),
          )
        else
          Column(
            children: _offers.asMap().entries.map((entry) {
              final index = entry.key;
              final offer = entry.value;
              return _buildSponsorshipRow(
                index: index,
                company: offer['company'],
                payout: offer['money'],
                fame: offer['fame'],
              );
            }).toList(),
          ),

        const SectionHeader(title: 'CAREER STATISTICS'),
        Column(
          children: [
            _buildStatRow('Brand Deals Completed', '${_character.brandDealsCompleted}'),
            _buildStatRow('Total Content Posts', '${_character.totalPosts}'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.outline, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.rowSubtitle.copyWith(color: AppColors.textPrimary),
          ),
          Text(
            value,
            style: AppTextStyles.rowSubtitle.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSponsorshipRow({
    required int index,
    required String company,
    required double payout,
    required int fame,
  }) {
    return GestureDetector(
      onTap: () => _showOfferDialog(index),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            bottom: BorderSide(color: AppColors.outline, width: 1),
          ),
        ),
        child: Row(
          children: [
            const Text('💰', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$company Campaign Offer',
                    style: AppTextStyles.rowTitle.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Payout: ₹${GameEngine.formatMoney(payout)} • Fame +$fame%',
                    style: AppTextStyles.rowSubtitle.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.outline, size: 20),
          ],
        ),
      ),
    );
  }
}
