import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/engine.dart';
import '../../../../models/character.dart';

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

  void _generateOffers() {
    if (_character.followers < 5000) return;

    final rng = Random();
    final eligibleBrands = _brands
        .where((b) => _character.followers >= (b['minFollowers'] as int))
        .toList();
    if (eligibleBrands.isEmpty) return;

    // Shuffle and pick 2-3 brands
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

    final result = GameEngine.processAction(_character, gameAction);
    setState(() {
      _character = result.character;
      _offers.removeAt(index);
    });
    widget.onGameAction(gameAction);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Accepted sponsorship from ${offer['company']}! Earned ₹${GameEngine.formatMoney(offer['money'])}',
            style: GoogleFonts.lexend(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF006D37),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _rejectOffer(int index) {
    final company = _offers[index]['company'];
    setState(() {
      _offers.removeAt(index);
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Rejected offer from $company.',
            style: GoogleFonts.lexend(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF5C5E62),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _showOfferDialog(int index) {
    final offer = _offers[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        backgroundColor: Colors.white,
        title: Text(
          'SPONSORSHIP OFFER',
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF161C28),
            letterSpacing: 0.5,
          ),
        ),
        content: Text(
          '${offer['company']} is offering you ₹${GameEngine.formatMoney(offer['money'])} to post a sponsored campaign on your profile. This will boost your fame by +${offer['fame']}%. Do you accept?',
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF5C5E62),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectOffer(index);
            },
            child: Text(
              'DECLINE',
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.bold,
                color: const Color(0xFFBA1A1A),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _acceptOffer(index);
            },
            child: Text(
              'ACCEPT',
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF006D37),
              ),
            ),
          ),
        ],
      ),
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
                  'INFLUENCER STUDIO',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF10B981),
                    letterSpacing: -0.02,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // Section: ANALYTICS
          Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'ANALYTICS',
              style: GoogleFonts.lexend(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF606366),
                letterSpacing: 1.5,
              ),
            ),
          ),
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

          // Section: SPONSORSHIPS
          Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'SPONSORSHIPS',
              style: GoogleFonts.lexend(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF606366),
                letterSpacing: 1.5,
              ),
            ),
          ),
          if (_character.followers < 5000)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.white,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const Icon(Icons.lock, color: Color(0xFFBA1A1A), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Locked: Reach 5,000 followers to unlock sponsorships.',
                      style: GoogleFonts.lexend(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFBA1A1A),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (_offers.isEmpty)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.white,
              alignment: Alignment.center,
              child: Text(
                'No sponsorships available right now. Post more content!',
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5C5E62),
                ),
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

          // Section: CAREER STATISTICS
          Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'CAREER STATISTICS',
              style: GoogleFonts.lexend(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF606366),
                letterSpacing: 1.5,
              ),
            ),
          ),
          Column(
            children: [
              _buildStatRow(
                  'Brand Deals Completed', '${_character.brandDealsCompleted}'),
              _buildStatRow('Total Content Posts', '${_character.totalPosts}'),
            ],
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFDDE2F3), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF161C28),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF006D37),
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFDDE2F3), width: 1),
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
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF161C28),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Payout: ₹${GameEngine.formatMoney(payout)} • Fame +$fame%',
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF006D37),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFBBCBBB), size: 20),
          ],
        ),
      ),
    );
  }
}
