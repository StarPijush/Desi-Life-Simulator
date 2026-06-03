// lib/screens/finance/assets_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design_system.dart';
import '../../core/engine.dart';
import '../../core/assets_data.dart';
import '../../models/character.dart';

class AssetsPage extends StatefulWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const AssetsPage({
    super.key,
    required this.character,
    required this.onGameAction,
  });

  @override
  State<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  AssetCategory _tab = AssetCategory.vehicle;

  List<AssetCategory> get _tabs => [
    AssetCategory.vehicle,
    AssetCategory.property,
    AssetCategory.jewelry,
  ];

  String _tabLabel(AssetCategory c) {
    switch (c) {
      case AssetCategory.vehicle: return 'VEHICLES';
      case AssetCategory.property: return 'PROPERTY';
      case AssetCategory.jewelry: return 'JEWELRY';
    }
  }

  bool _isOwned(GameAsset asset) =>
      widget.character.ownedAssets.contains(asset.id);

  bool _canAfford(GameAsset asset) =>
      widget.character.bankBalance >= asset.purchasePrice;

  bool _meetsRequirements(GameAsset asset) {
    if (widget.character.age < asset.minAge) return false;
    if (asset.netWorthRequired > 0 && widget.character.bankBalance < asset.netWorthRequired) return false;
    if (asset.incomeRequired > 0 && widget.character.annualIncome < asset.incomeRequired) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final items = AssetsData.getByCategory(_tab);

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
                    child: const Icon(Icons.arrow_back, color: Color(0xFF006D37), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(_tabLabel(_tab), style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w900, color: const Color(0xFF181C1F), letterSpacing: 0.5)),
                  const Spacer(),
                  Text(formatMoney(widget.character.bankBalance), style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF006D37))),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            height: 36,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE4E4E7), width: 1)),
            ),
            child: Row(
              children: _tabs.map((t) {
                final selected = t == _tab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tab = t),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? Colors.white : const Color(0xFFF4F4F5),
                        border: selected
                            ? const Border(bottom: BorderSide(color: Color(0xFF006D37), width: 2))
                            : null,
                      ),
                      child: Text(
                        _tabLabel(t),
                        style: GoogleFonts.lexend(
                          fontSize: 9, fontWeight: FontWeight.w800,
                          color: selected ? const Color(0xFF006D37) : const Color(0xFF71717A),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ), // Owned count
          if (widget.character.ownedAssets.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: const Color(0xFFF0FDF4),
              child: Text(
                '${widget.character.ownedAssets.length} asset${widget.character.ownedAssets.length == 1 ? '' : 's'} owned',
                style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF059669)),
              ),
            ),

          // Asset list
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE4E4E7), indent: 52),
              itemBuilder: (_, i) => _buildAssetRow(context, items[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetRow(BuildContext context, GameAsset asset) {
    final owned = _isOwned(asset);
    final canAfford = _canAfford(asset);
    final meetsReqs = _meetsRequirements(asset);
    final locked = !meetsReqs;

    Color rarityColor;
    switch (asset.rarity) {
      case AssetRarity.legendary: rarityColor = const Color(0xFFD97706); break;
      case AssetRarity.epic:      rarityColor = const Color(0xFF7C3AED); break;
      case AssetRarity.rare:      rarityColor = const Color(0xFF2563EB); break;
      default:                    rarityColor = const Color(0xFF6B7280); break;
    }

    return GestureDetector(
      onTap: locked ? null : () => _showAssetModal(context, asset),
      child: Opacity(
        opacity: locked ? 0.45 : 1.0,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: owned ? const Color(0xFFF0FDF4) : Colors.white,
          child: Row(
            children: [
              Text(asset.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(asset.name, style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF161C28))),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          color: rarityColor.withValues(alpha: 0.12),
                          child: Text(
                            asset.rarity.name.toUpperCase(),
                            style: GoogleFonts.lexend(fontSize: 7, fontWeight: FontWeight.w900, color: rarityColor, letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      shortMoney(asset.purchasePrice),
                      style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w700, color: canAfford && !locked ? const Color(0xFF059669) : const Color(0xFF71717A)),
                    ),
                  ],
                ),
              ),
              if (owned)
                const Icon(Icons.check_circle, color: Color(0xFF059669), size: 18)
              else if (locked)
                const Icon(Icons.lock_outline, color: Color(0xFFD4D4D8), size: 16)
              else
                const Icon(Icons.chevron_right, color: Color(0xFFD4D4D8), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  void _showAssetModal(BuildContext context, GameAsset asset) {
    final owned = _isOwned(asset);
    final canAfford = _canAfford(asset);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(),
      builder: (_) => _AssetSheet(
        asset: asset,
        owned: owned,
        canAfford: canAfford,
        character: widget.character,
        onBuy: () {
          Navigator.of(context).pop();
          widget.onGameAction(GameAction('asset.buy', {'asset': asset}));
        },
        onSell: () {
          Navigator.of(context).pop();
          widget.onGameAction(GameAction('asset.sell', {'asset': asset}));
        },
      ),
    );
  }
}

// ── Asset Bottom Sheet ───────────────────────────────────────────────────────
class _AssetSheet extends StatelessWidget {
  final GameAsset asset;
  final bool owned;
  final bool canAfford;
  final Character character;
  final VoidCallback onBuy;
  final VoidCallback onSell;

  const _AssetSheet({
    required this.asset,
    required this.owned,
    required this.canAfford,
    required this.character,
    required this.onBuy,
    required this.onSell,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(margin: const EdgeInsets.only(top: 10, bottom: 8), width: 32, height: 3, color: const Color(0xFFD4D4D8))),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                Text(asset.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(asset.name, style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF161C28))),
                      Text(asset.description, style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF71717A))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Info rows
          _row('PURCHASE PRICE', shortMoney(asset.purchasePrice)),
          _row('YEARLY UPKEEP', shortMoney(asset.yearlyMaintenance)),
          if (asset.statusBoost > 0) _row('STATUS BOOST', '+${asset.statusBoost}'),
          _row('MIN AGE', '${asset.minAge}+'),
          _row('YOUR BALANCE', formatMoney(character.bankBalance)),
          const Divider(height: 1, color: Color(0xFFE4E4E7)),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (!owned)
                  Expanded(
                    child: GestureDetector(
                      onTap: canAfford ? () { HapticFeedback.lightImpact(); onBuy(); } : null,
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        color: canAfford ? const Color(0xFF006D37) : const Color(0xFFE4E4E7),
                        child: Text('BUY', style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w900, color: canAfford ? Colors.white : const Color(0xFFA1A1AA))),
                      ),
                    ),
                  ),
                if (owned) ...[
                  Expanded(
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      color: const Color(0xFFF0FDF4),
                      child: Text('OWNED ✓', style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFF059669))),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () { HapticFeedback.lightImpact(); onSell(); },
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        color: const Color(0xFFDC2626),
                        child: Text('SELL', style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF71717A), letterSpacing: 0.5)),
          Text(value, style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF161C28))),
        ],
      ),
    );
  }
}
