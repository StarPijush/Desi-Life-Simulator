// lib/screens/assets_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/character.dart';
import '../core/assets_data.dart';
import '../core/engine.dart';
import '../core/storage.dart';

import '../core/investments_data.dart';
import '../core/design_system.dart';
import '../widgets/empty_state.dart';

class AssetsPage extends StatefulWidget {
  final Character character;
  final bool isTab;
  final VoidCallback? onBack;
  const AssetsPage({super.key, required this.character, this.isTab = false, this.onBack});

  @override
  State<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  @override
  void initState() {
    super.initState();
  }

  String _formatMoney(double amount) {
    if (amount >= 10000000) return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(2)} L';
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }

  void _openMarketplace() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MarketplaceSheet(
        character: widget.character,
        onBought: (updatedChar) {
          // The parent (HomePage) handles the notifier update if needed, 
          // but here we just trigger a rebuild of this page.
          setState(() {});
        },
      ),
    );
  }

  void _openInvestmentMarket() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _InvestmentMarketSheet(
        character: widget.character,
        onUpdate: (updatedChar) {
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final char = widget.character;
    final ownedVehicles = char.ownedAssets
        .map((id) => AssetsData.findById(id))
        .where((a) => a != null && a.category == AssetCategory.vehicle)
        .cast<GameAsset>()
        .toList();

    final ownedProperties = char.ownedAssets
        .map((id) => AssetsData.findById(id))
        .where((a) => a != null && a.category == AssetCategory.property)
        .cast<GameAsset>()
        .toList();

    final ownedJewelry = char.ownedAssets
        .map((id) => AssetsData.findById(id))
        .where((a) => a != null && a.category == AssetCategory.jewelry)
        .cast<GameAsset>()
        .toList();

    double totalAssetValue = 0;
    for (var id in char.ownedAssets) {
      final a = AssetsData.findById(id);
      if (a != null) totalAssetValue += a.purchasePrice;
    }

    double netWorth = char.bankBalance + totalAssetValue;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: Colors.black,
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Scaffold(
              backgroundColor: AppColors.scaffoldBg,
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.mainBgGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 0. Back AppBar (visible if not tab or if onBack provided)
                if (!widget.isTab || widget.onBack != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s4),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (widget.onBack != null) {
                                widget.onBack!();
                              } else {
                                Navigator.pop(context);
                              }
                            },
                            icon: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: AppShadows.soft,
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // 1. Premium Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s8, AppSpacing.s16, AppSpacing.s16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Assets', style: AppTextStyles.h1.copyWith(fontSize: 32)),
                        const SizedBox(height: 4),
                        Text('Manage your wealth and investments', style: AppTextStyles.subtitle),
                      ],
                    ),
                  ),
                ),

                // 2. Net Worth Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.s32),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.35),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TOTAL NET WORTH', 
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.5), 
                          fontSize: 10,
                          letterSpacing: 2,
                        )
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Text(_formatMoney(netWorth), 
                        style: AppTextStyles.h1.copyWith(
                          color: Colors.white, 
                          fontSize: 40,
                          letterSpacing: -1,
                        )
                      ),
                      const SizedBox(height: AppSpacing.s40),
                      Row(
                        children: [
                          _NetWorthMiniStat(
                            label: 'Liquid Cash', 
                            value: _formatMoney(char.bankBalance), 
                            icon: Icons.account_balance_wallet_rounded, 
                            color: AppColors.happyGradient.first
                          ),
                          const Spacer(),
                          _NetWorthMiniStat(
                            label: 'Total Assets', 
                            value: _formatMoney(totalAssetValue), 
                            icon: Icons.home_rounded, 
                            color: AppColors.smartsGradient.first
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

                // 3. Sections
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.s16, 32, AppSpacing.s16, 160),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Banking Section
                      _SectionHeading(title: 'BANKING', actionLabel: 'MARKETPLACE', onAction: _openMarketplace),
                      _BankingSection(
                        character: char,
                        onUpdate: (c) => setState(() {}),
                      ),

                      const SizedBox(height: 24),

                      // Investments Section
                      _InvestmentsSection(
                        character: char,
                        onUpdate: (updatedChar) => setState(() {}),
                        onOpenMarket: _openInvestmentMarket,
                      ),

                      const SizedBox(height: 24),

                      // Physical Assets Section
                      const _SectionHeading(title: 'PHYSICAL ASSETS'),
                      _AssetsCard(
                        vehicles: ownedVehicles,
                        properties: ownedProperties,
                        jewelry: ownedJewelry,
                        onOpenMarket: _openMarketplace,
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
},
);
}
}

class _NetWorthMiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _NetWorthMiniStat({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.caption.copyWith(color: Colors.white.withValues(alpha: 0.5))),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.bodyBold.copyWith(color: Colors.white, fontSize: 18)),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _SectionHeading({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, 
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary, 
              letterSpacing: 2,
              fontWeight: FontWeight.w800,
            )
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGradient.first.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primaryGradient.first.withValues(alpha: 0.2)),
                ),
                child: Text(
                  actionLabel!, 
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryGradient.last, 
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AssetsCard extends StatelessWidget {
  final List<GameAsset> vehicles;
  final List<GameAsset> properties;
  final List<GameAsset> jewelry;
  final VoidCallback onOpenMarket;

  const _AssetsCard({required this.vehicles, required this.properties, required this.jewelry, required this.onOpenMarket});

  @override
  Widget build(BuildContext context) {
    final all = [...vehicles, ...properties, ...jewelry];
    if (all.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.account_balance_wallet_outlined,
        title: 'No Assets Owned',
        subtitle: 'Visit the marketplace to buy your first property or vehicle!',
        actionLabel: 'Start Investing',
        onAction: onOpenMarket,
      );
    }

    return Container(
      decoration: AppDecoration.card.copyWith(
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: all.asMap().entries.map((entry) {
          final idx = entry.key;
          final asset = entry.value;
          return Column(
            children: [
              _AssetListItem(asset: asset),
              if (idx < all.length - 1)
                Divider(height: 1, color: AppColors.textMuted.withValues(alpha: 0.05), indent: 70),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Marketplace Sheet ───────────────────────────────────────────────────────
class _MarketplaceSheet extends StatelessWidget {
  final Character character;
  final Function(Character) onBought;

  const _MarketplaceSheet({required this.character, required this.onBought});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
        Text('Marketplace',
            style: AppTextStyles.h2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12)),
          child: Text(
            '₹${(character.bankBalance / 1000).toStringAsFixed(1)}K Available',
            style: AppTextStyles.label.copyWith(
                fontSize: 12, color: const Color(0xFF16A34A))),
        ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.s16, 0, AppSpacing.s16, 40),
              children: [
                _MarketSection(title: 'Vehicles', items: AssetsData.getByCategory(AssetCategory.vehicle), character: character, onBought: onBought),
                _MarketSection(title: 'Properties', items: AssetsData.getByCategory(AssetCategory.property).where((a) => character.age >= a.minAge).toList(), character: character, onBought: onBought),
                _MarketSection(title: 'Lifestyle & Jewelry', items: AssetsData.getByCategory(AssetCategory.jewelry), character: character, onBought: onBought),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketSection extends StatelessWidget {
  final String title;
  final List<GameAsset> items;
  final Character character;
  final Function(Character) onBought;

  const _MarketSection({required this.title, required this.items, required this.character, required this.onBought});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
              title,
              style: AppTextStyles.label.copyWith(
                  fontSize: 13, fontWeight: FontWeight.w700)),
        ),
        ...items.map((asset) => _MarketItemCard(asset: asset, character: character, onBought: onBought)),
      ],
    );
  }
}

class _MarketItemCard extends StatelessWidget {
  final GameAsset asset;
  final Character character;
  final Function(Character) onBought;

  const _MarketItemCard({required this.asset, required this.character, required this.onBought});

  String _formatMoney(double amount) {
    if (amount >= 10000000) return '₹${(amount / 10000000).toStringAsFixed(1)} Cr';
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)} L';
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(0)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final alreadyOwned = character.ownedAssets.contains(asset.id) && asset.category != AssetCategory.jewelry;
    final canAfford = character.bankBalance >= asset.purchasePrice;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 58, height: 58,
            decoration: BoxDecoration(
              color: AppColors.primaryGradient.first.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(18)
            ),
            child: Center(child: Text(asset.emoji, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset.name, style: AppTextStyles.bodyBold.copyWith(fontSize: 16)),
                const SizedBox(height: 2),
                Text(asset.description, style: AppTextStyles.subtitle.copyWith(fontSize: 11, height: 1.3)),
                const SizedBox(height: AppSpacing.s8),
                Row(
                  children: [
                    Text(_formatMoney(asset.purchasePrice), 
                      style: AppTextStyles.bodyBold.copyWith(fontSize: 14, color: AppColors.textPrimary)
                    ),
                    const SizedBox(width: 8),
                    Text('• Maint: ${_formatMoney(asset.yearlyMaintenance)}/yr', 
                      style: AppTextStyles.caption.copyWith(fontSize: 10, color: AppColors.textMuted)
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          _BuyButton(
            alreadyOwned: alreadyOwned,
            canAfford: canAfford,
            onTap: () {
              final result = GameEngine.buyAsset(character, asset);
              if (result != null && result.startsWith('✅')) {
                StorageService.saveCharacter(character);
                onBought(character);
              }
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(result ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.darkBg,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.all(AppSpacing.s16),
              ));
            },
          ),
        ],
      ),
    );
  }
}

class _BuyButton extends StatelessWidget {
  final bool alreadyOwned;
  final bool canAfford;
  final VoidCallback onTap;

  const _BuyButton({required this.alreadyOwned, required this.canAfford, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (alreadyOwned) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
        child: Text('OWNED',
            style: AppTextStyles.caption.copyWith(
                fontSize: 10, color: const Color(0xFF94A3B8))),
      );
    }

    return GestureDetector(
      onTap: canAfford ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: canAfford ? const Color(0xFF6366F1) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('BUY',
            style: AppTextStyles.label.copyWith(
                fontSize: 12,
                color: canAfford ? Colors.white : const Color(0xFFCBD5E1))),
      ),
    );
  }
}

// ── Banking Section ──────────────────────────────────────────────────────────
class _BankingSection extends StatelessWidget {
  final Character character;
  final Function(Character) onUpdate;

  const _BankingSection({required this.character, required this.onUpdate});

  String _formatMoney(double amount) {
    if (amount >= 10000000) return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(2)} L';
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }

  void _showBankSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _BankSelectionSheet(character: character, onUpdate: onUpdate),
    );
  }

  void _showLoanSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
          Text('Available Loans',
              style: AppTextStyles.h2.copyWith(fontSize: 20)),
              const SizedBox(height: 20),
              _LoanOption(
                name: 'Student Loan',
                desc: 'Age 10+, Smarts 60+. Low Interest (6%).',
                icon: Icons.school_rounded,
                available: character.age >= 10 && character.smarts >= 60,
                onTap: () => _applyForLoan(context, 'Student'),
              ),
              _LoanOption(
                name: 'Personal Loan',
                desc: 'Age 18+, Needs Salary. Interest (12%).',
                icon: Icons.person_rounded,
                available: character.age >= 18 && character.annualIncome > 0,
                onTap: () => _applyForLoan(context, 'Personal'),
              ),
              _LoanOption(
                name: 'Home Loan',
                desc: 'Age 21+, High Salary, CIBIL 700+. Interest (8%).',
                icon: Icons.home_rounded,
                available: character.age >= 21 && character.annualIncome >= 1000000 && character.cibilScore >= 700,
                onTap: () => _applyForLoan(context, 'Home'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _applyForLoan(BuildContext context, String type) {
    final controller = TextEditingController();
    Navigator.pop(context); // Close selection sheet
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Apply for $type Loan', style: AppTextStyles.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter loan amount. Monthly EMIs will be deducted.',
                style: AppTextStyles.bodyMedium.copyWith(fontSize: 12)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. 500000',
                prefixText: '₹ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              if (amount > 0) {
                String result = '';
                if (type == 'Student') {
                  result = GameEngine.takeStudentLoan(character, amount);
                } else if (type == 'Personal') {
                  result = GameEngine.takePersonalLoan(character, amount);
                } else if (type == 'Home') {
                  result = GameEngine.takeHomeLoan(character, amount);
                }
                
                StorageService.saveCharacter(character);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
                onUpdate(character);
                Navigator.pop(context);
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showSavingsDialog(BuildContext context, bool isDeposit) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
            isDeposit ? 'Deposit to Savings' : 'Withdraw from Savings',
            style: AppTextStyles.h3),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter amount',
            prefixText: '₹ ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              if (amount > 0) {
                final result = isDeposit 
                    ? GameEngine.depositToSavings(character, amount)
                    : GameEngine.withdrawFromSavings(character, amount);
                StorageService.saveCharacter(character);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
                onUpdate(character);
                Navigator.pop(context);
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showCreditRepayDialog(BuildContext context) {
    if (character.creditUsed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No credit debt to repay! ✨')));
      return;
    }
    final controller = TextEditingController(text: character.creditUsed.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Repay Credit Balance', style: AppTextStyles.h3),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter amount',
            prefixText: '₹ ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              final amount = double.tryParse(controller.text) ?? 0;
              if (amount > 0) {
                final result = GameEngine.repayCreditCard(character, amount);
                StorageService.saveCharacter(character);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
                onUpdate(character);
                Navigator.pop(context);
              }
            },
            child: const Text('Repay'),
          ),
        ],
      ),
    );
  }

  void _showLoanRepayDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Extra Loan Repayment', style: AppTextStyles.h3),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter extra amount',
            prefixText: '₹ ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              final amount = double.tryParse(controller.text) ?? 0;
              if (amount > 0) {
                final result = GameEngine.repayLoanPartially(character, amount);
                StorageService.saveCharacter(character);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
                onUpdate(character);
                Navigator.pop(context);
              }
            },
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BANKING & FINANCE',
            style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        
        // --- Bank Account Card ---
        if (character.bankName.isEmpty)
          _ActionCard(
            title: character.age < 18 ? 'No Bank Account' : 'Open Bank Account',
            subtitle: character.age < 18 
                ? 'Ask your parents to open an account for you.'
                : 'Manage your wealth, loans, and credit cards.',
            icon: Icons.account_balance_outlined,
            buttonText: character.age < 18 ? 'Ask Parents' : 'Open Account',
            onTap: () {
              if (character.age < 18) {
                final result = GameEngine.askParentsForBank(character);
                StorageService.saveCharacter(character);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
                onUpdate(character);
              } else {
                _showBankSelection(context);
              }
            },
            color: const Color(0xFF6366F1),
          )
        else
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AppDecoration.card.copyWith(
              boxShadow: AppShadows.soft,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.smartsGradient.last.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.account_balance_rounded, color: AppColors.smartsGradient.last),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(character.bankName, style: AppTextStyles.bodyBold.copyWith(fontSize: 16)),
                          Text('${character.accountType} Account', style: AppTextStyles.subtitle),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹${(character.savingsBalance / 1000).toStringAsFixed(1)}K', style: AppTextStyles.h1.copyWith(fontSize: 18, color: const Color(0xFF16A34A))),
                        Text('Savings Balance', style: AppTextStyles.caption.copyWith(fontSize: 10, color: const Color(0xFF94A3B8))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _TinyButton(
                        text: 'Deposit', 
                        icon: Icons.add, 
                        onTap: () => _showSavingsDialog(context, true),
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TinyButton(
                        text: 'Withdraw', 
                        icon: Icons.remove, 
                        onTap: () => _showSavingsDialog(context, false),
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // --- Credit Card & CIBIL ---
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.credit_card, color: Color(0xFF6366F1), size: 20),
                        if (!character.hasCreditCard)
                          GestureDetector(
                            onTap: () {
                              final res = GameEngine.applyForCreditCard(character);
                              StorageService.saveCharacter(character);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
                              onUpdate(character);
                            },
                            child: Text('APPLY', style: AppTextStyles.caption.copyWith(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF6366F1))),
                          )
                        else
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _showCreditRepayDialog(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(8)),
                              child: Text('REPAY', style: AppTextStyles.caption.copyWith(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF0284C7))),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(character.hasCreditCard ? 'Credit Status' : 'No Credit Card', style: AppTextStyles.bodyBold.copyWith(fontSize: 13)),
                    if (character.hasCreditCard) ...[
                      const SizedBox(height: 8),
                      _CreditStatRow(label: 'Used Amount', value: _formatMoney(character.creditUsed), color: character.creditUsed > 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
                      _CreditStatRow(label: 'Credit Limit', value: _formatMoney(character.creditLimit)),
                      _CreditStatRow(label: 'Minimum Due', value: _formatMoney(character.creditMinDue), isBold: true),
                    ] else
                      Text('Get one for rewards', style: AppTextStyles.subtitle.copyWith(fontSize: 11, color: const Color(0xFF94A3B8))),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.speed, color: Color(0xFFF43F5E), size: 20),
                    const SizedBox(height: 8),
                    Text('CIBIL Score', style: AppTextStyles.bodyBold.copyWith(fontSize: 13)),
                    Text('${character.cibilScore}', style: AppTextStyles.h1.copyWith(fontSize: 18, fontWeight: FontWeight.w800, color: _getCibilColor(character.cibilScore))),
                    const SizedBox(height: 4),
                    Text(character.cibilScore >= 750 ? 'Excellent' : character.cibilScore >= 650 ? 'Good' : 'Needs Work', 
                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 10, fontWeight: FontWeight.w600, color: _getCibilColor(character.cibilScore).withValues(alpha: 0.8))),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // --- Loan Status Card ---
        if (character.loanAmount > 0)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFEF3C7)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: Color(0xFFFEF3C7), shape: BoxShape.circle),
                      child: const Icon(Icons.monetization_on, color: Color(0xFFD97706), size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${character.loanType} Loan Active', style: AppTextStyles.bodyBold.copyWith(fontSize: 15, color: const Color(0xFF92400E))),
                          Text('Rate: ${character.loanType == 'Student' ? '6%' : character.loanType == 'Home' ? '8%' : '12%'} p.a.', style: AppTextStyles.subtitle.copyWith(fontSize: 11, color: const Color(0xFFB45309), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹${(character.loanAmount / 1000).toStringAsFixed(1)}K', style: AppTextStyles.h1.copyWith(fontSize: 18, color: const Color(0xFFB45309))),
                        Text('Outstanding', style: AppTextStyles.caption.copyWith(fontSize: 9, color: const Color(0xFFB45309), fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFFEF3C7)),
                const SizedBox(height: 16),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Loan Amount', style: AppTextStyles.caption.copyWith(fontSize: 10, color: const Color(0xFFB45309), fontWeight: FontWeight.w600)),
                        Text('₹${_formatMoney(character.loanAmount)}', style: AppTextStyles.label.copyWith(fontSize: 11, color: const Color(0xFF92400E), fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text('Estimated EMI', style: AppTextStyles.caption.copyWith(fontSize: 10, color: const Color(0xFFB45309), fontWeight: FontWeight.w600)),
                        Text('15% of annual income', style: AppTextStyles.label.copyWith(fontSize: 11, color: const Color(0xFF92400E), fontWeight: FontWeight.w700)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _showLoanRepayDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text('Repay Loan', style: AppTextStyles.label.copyWith(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          )
        else
          _ActionCard(
            title: 'Need a Loan?',
            subtitle: 'Check available loan options for you.',
            icon: Icons.payments_outlined,
            buttonText: 'View Options',
            onTap: () => _showLoanSelection(context),
            color: const Color(0xFF10B981),
          ),
      ],
    );
  }

  Color _getCibilColor(int score) {
    if (score >= 750) return const Color(0xFF16A34A);
    if (score >= 650) return const Color(0xFFF59E0B);
    return const Color(0xFFDC2626);
  }
}

class _BankSelectionSheet extends StatelessWidget {
  final Character character;
  final Function(Character) onUpdate;

  const _BankSelectionSheet({required this.character, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Select Your Bank', style: AppTextStyles.h2.copyWith(fontSize: 20)),
          const SizedBox(height: 20),
          _BankOption(
            name: 'SBI', 
            desc: 'Safe, 4% Interest', 
            icon: Icons.account_balance,
            onTap: () => _openAccount(context, 'SBI', 'Savings'),
          ),
          _BankOption(
            name: 'HDFC', 
            desc: 'Balanced, 4% Interest', 
            icon: Icons.account_balance_wallet,
            onTap: () => _openAccount(context, 'HDFC', 'Savings'),
          ),
          _BankOption(
            name: 'ICICI Premium', 
            desc: 'High Benefits, 7% Interest', 
            icon: Icons.stars,
            onTap: () => _openAccount(context, 'ICICI', 'Premium'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _openAccount(BuildContext context, String bank, String type) {
    final result = GameEngine.openBankAccount(character, bank, type);
    StorageService.saveCharacter(character);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    onUpdate(character);
    Navigator.pop(context);
  }
}

class _LoanOption extends StatelessWidget {
  final String name;
  final String desc;
  final IconData icon;
  final bool available;
  final VoidCallback onTap;

  const _LoanOption({required this.name, required this.desc, required this.icon, required this.available, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: available ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: available ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: available ? const Color(0xFFF1F5F9) : Colors.transparent),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: available ? const Color(0xFFDCFCE7) : const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: available ? const Color(0xFF16A34A) : const Color(0xFF94A3B8), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.bodyBold.copyWith(color: available ? const Color(0xFF1E293B) : const Color(0xFF94A3B8))),
                  Text(desc, style: AppTextStyles.subtitle.copyWith(fontSize: 11, color: const Color(0xFF94A3B8))),
                ],
              ),
            ),
            if (!available)
              const Icon(Icons.lock_outline, size: 16, color: Color(0xFFCBD5E1))
            else
              const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}

class _BankOption extends StatelessWidget {
  final String name;
  final String desc;
  final IconData icon;
  final VoidCallback onTap;

  const _BankOption({required this.name, required this.desc, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6366F1)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyBold),
                Text(desc, style: AppTextStyles.subtitle.copyWith(fontSize: 12, color: const Color(0xFF94A3B8))),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String buttonText;
  final VoidCallback onTap;
  final Color color;

  const _ActionCard({required this.title, required this.subtitle, required this.icon, required this.buttonText, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(title, style: AppTextStyles.bodyBold.copyWith(fontSize: 14)),
                 Text(subtitle, style: AppTextStyles.subtitle.copyWith(fontSize: 11, color: const Color(0xFF94A3B8))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(buttonText, style: AppTextStyles.label.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _TinyButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _TinyButton({required this.text, required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(text, style: AppTextStyles.label.copyWith(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}

class _AssetListItem extends StatelessWidget {
  final GameAsset asset;
  const _AssetListItem({required this.asset});

  String _formatMoney(double amount) {
    if (amount >= 10000000) return '₹${(amount / 10000000).toStringAsFixed(1)} Cr';
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)} L';
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(0)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return _AssetItemRaw(
      icon: Icons.circle, // Placeholder for icon
      customIcon: Text(asset.emoji, style: const TextStyle(fontSize: 22)),
      iconBg: const Color(0xFFF8FAFC),
      iconColor: Colors.transparent,
      title: asset.name,
      subtitle: asset.category.name.toUpperCase(),
      trailing: _formatMoney(asset.purchasePrice),
    );
  }
}

class _AssetItemRaw extends StatelessWidget {
  final IconData icon;
  final Widget? customIcon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String trailing;

  const _AssetItemRaw({required this.icon, this.customIcon, required this.iconBg, required this.iconColor, required this.title, required this.subtitle, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: customIcon ?? Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyBold.copyWith(fontSize: 14, color: const Color(0xFF1E293B))),
                Text(subtitle, style: AppTextStyles.subtitle.copyWith(fontSize: 12, color: const Color(0xFF94A3B8))),
              ],
            ),
          ),
          Text(trailing, style: AppTextStyles.bodyBold.copyWith(fontSize: 14, color: const Color(0xFF16A34A))),
        ],
      ),
    );
  }
}

class _CreditStatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool isBold;

  const _CreditStatRow({required this.label, required this.value, this.color, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.subtitle.copyWith(fontSize: 10, color: const Color(0xFF94A3B8), fontWeight: FontWeight.normal)),
          Text(value, style: AppTextStyles.bodyBold.copyWith(fontSize: 11, fontWeight: isBold ? FontWeight.w700 : FontWeight.w600, color: color ?? const Color(0xFF1E293B))),
        ],
      ),
    );
  }
}

// ── Investment Widgets ──────────────────────────────────────────────────

class _InvestmentsSection extends StatelessWidget {
  final Character character;
  final Function(Character) onUpdate;
  final VoidCallback onOpenMarket;

  const _InvestmentsSection({required this.character, required this.onUpdate, required this.onOpenMarket});

  String _formatMoney(double amount) {
    if (amount >= 10000000) return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(2)} L';
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final allHoldings = [...character.stockPortfolio, ...character.cryptoPortfolio, ...character.bondPortfolio];
    double totalInvested = 0;
    double totalCurrent = 0;
    for (var item in allHoldings) {
      totalInvested += (item['buyPrice'] as num).toDouble() * (item['quantity'] as num).toDouble();
      totalCurrent += (item['currentPrice'] as num).toDouble() * (item['quantity'] as num).toDouble();
    }
    double totalPL = totalCurrent - totalInvested;
    bool isProfit = totalPL >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("INVESTMENTS", style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, letterSpacing: 1.4, fontWeight: FontWeight.w800)),
            GestureDetector(
              onTap: () { HapticFeedback.lightImpact(); onOpenMarket(); },
              child: Text("MARKET 📈", style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.darkBg,
            borderRadius: BorderRadius.circular(32),
            boxShadow: AppShadows.premium,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("PORTFOLIO VALUE", style: AppTextStyles.caption.copyWith(color: Colors.white.withValues(alpha: 0.5))),
                      const SizedBox(height: 4),
                      Text(_formatMoney(totalCurrent), style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 24)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isProfit ? AppColors.highlightGreen.withValues(alpha: 0.2) : AppColors.alertRed.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${isProfit ? "+" : ""}${(totalInvested > 0 ? (totalPL / totalInvested * 100) : 0).toStringAsFixed(1)}%", 
                      style: AppTextStyles.bodyBold.copyWith(color: isProfit ? AppColors.highlightGreen : AppColors.alertRed, fontSize: 13),
                    ),
                  ),
                ],
              ),
              if (allHoldings.isEmpty) ...[
                const SizedBox(height: 24),
                Text("Start investing to grow your wealth.", style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.4))),
                const SizedBox(height: 16),
                _TinyButtonInv(text: "Explore Market", icon: Icons.trending_up, onTap: onOpenMarket, color: AppColors.smartsGradient.last),
              ] else ...[
                const SizedBox(height: 24),
                ...character.stockPortfolio.asMap().entries.map((e) => _PortfolioAssetCard(item: e.value, type: "Stock", onSell: () => _handleSell(context, "Stock", e.key))),
                ...character.cryptoPortfolio.asMap().entries.map((e) => _PortfolioAssetCard(item: e.value, type: "Crypto", onSell: () => _handleSell(context, "Crypto", e.key))),
                ...character.bondPortfolio.asMap().entries.map((e) => _PortfolioAssetCard(item: e.value, type: "Bond", onSell: () => _handleSell(context, "Bond", e.key))),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _handleSell(BuildContext context, String type, int index) {
    final result = GameEngine.sellInvestment(character, type, index);
    StorageService.saveCharacter(character);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    onUpdate(character);
  }
}

class _PortfolioAssetCard extends StatelessWidget {
  final Map<dynamic, dynamic> item;
  final String type;
  final VoidCallback onSell;

  const _PortfolioAssetCard({required this.item, required this.type, required this.onSell});

  @override
  Widget build(BuildContext context) {
    double buyPrice = (item["buyPrice"] as num).toDouble();
    double currPrice = (item["currentPrice"] as num).toDouble();
    double quantity = (item["quantity"] as num).toDouble();
    double pl = (currPrice - buyPrice) * quantity;
    bool isProfit = pl >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item["name"], style: AppTextStyles.bodyBold.copyWith(fontSize: 14, color: Colors.white)),
                Text("$quantity units • Avg: ₹${buyPrice.toStringAsFixed(0)}", style: AppTextStyles.caption.copyWith(color: Colors.white.withAlpha(100))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("₹${(currPrice * quantity).toStringAsFixed(0)}", style: AppTextStyles.bodyBold.copyWith(fontSize: 14, color: Colors.white)),
              Text("${isProfit ? "+" : ""}₹${pl.abs().toStringAsFixed(0)}", style: AppTextStyles.bodyBold.copyWith(fontSize: 10, fontWeight: FontWeight.w600, color: isProfit ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
            ],
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () { HapticFeedback.mediumImpact(); onSell(); },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFF43F5E).withValues(alpha: 0.2), shape: BoxShape.circle),
              child: const Icon(Icons.sell_outlined, color: Color(0xFFF43F5E), size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvestmentMarketSheet extends StatefulWidget {
  final Character character;
  final Function(Character) onUpdate;

  const _InvestmentMarketSheet({required this.character, required this.onUpdate});

  @override
  State<_InvestmentMarketSheet> createState() => _InvestmentMarketSheetState();
}

class _InvestmentMarketSheetState extends State<_InvestmentMarketSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Investment Market", style: AppTextStyles.h2),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined, size: 14, color: Color(0xFF16A34A)),
                      const SizedBox(width: 6),
                      Text("₹${(widget.character.bankBalance / 1000).toStringAsFixed(1)}K Cash Available", 
                        style: AppTextStyles.label.copyWith(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF16A34A))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.s16, 0, AppSpacing.s16, 40),
              children: [
                const _MarketHeading(title: "Stocks (Moderate Risk)", icon: Icons.trending_up, color: Colors.blue),
                ...InvestmentsData.stocks.map((s) => _MarketAssetCard(asset: s, character: widget.character, onUpdate: () => setState(() {}), onFinalUpdate: widget.onUpdate)),
                const SizedBox(height: 24),
                const _MarketHeading(title: "Crypto (High Risk)", icon: Icons.currency_bitcoin, color: Colors.orange),
                ...InvestmentsData.crypto.map((c) => _MarketAssetCard(asset: c, character: widget.character, onUpdate: () => setState(() {}), onFinalUpdate: widget.onUpdate)),
                const SizedBox(height: 24),
                const _MarketHeading(title: "Bonds (Safe Returns)", icon: Icons.security, color: Colors.green),
                ...InvestmentsData.bonds.map((b) => _MarketAssetCard(asset: b, character: widget.character, onUpdate: () => setState(() {}), onFinalUpdate: widget.onUpdate)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketHeading extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _MarketHeading({required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(title, style: AppTextStyles.label.copyWith(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8), letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

class _MarketAssetCard extends StatelessWidget {
  final MarketAsset asset;
  final Character character;
  final VoidCallback onUpdate;
  final Function(Character) onFinalUpdate;

  const _MarketAssetCard({required this.asset, required this.character, required this.onUpdate, required this.onFinalUpdate});

  @override
  Widget build(BuildContext context) {
    final price = (character.marketPrices[asset.name] as num?)?.toDouble() ?? asset.initialPrice;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(asset.emoji, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset.name, style: AppTextStyles.bodyBold.copyWith(fontSize: 15, color: const Color(0xFF1E293B))),
                Text(asset.description, style: AppTextStyles.bodyMedium.copyWith(fontSize: 10, color: const Color(0xFF94A3B8), height: 1.3)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("₹${price.toStringAsFixed(0)}", style: AppTextStyles.bodyBold.copyWith(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
              ElevatedButton(
                onPressed: () => _showBuyDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  minimumSize: const Size(60, 30),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text("BUY", style: AppTextStyles.label.copyWith(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBuyDialog(BuildContext context) {
    final controller = TextEditingController(text: "1");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Buy ${asset.name}", style: AppTextStyles.h2.copyWith(fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Current Price: ₹${(character.marketPrices[asset.name] as num).toStringAsFixed(0)}", style: AppTextStyles.bodyMedium.copyWith(fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final qty = double.tryParse(controller.text) ?? 0;
              if (qty > 0) {
                final res = GameEngine.buyInvestment(character, asset, qty);
                StorageService.saveCharacter(character);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
                onFinalUpdate(character);
                onUpdate();
                Navigator.pop(context);
              }
            },
            child: const Text("Confirm Buy"),
          ),
        ],
      ),
    );
  }
}

class _TinyButtonInv extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _TinyButtonInv({required this.text, required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticFeedback.mediumImpact(); onTap(); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(text, style: AppTextStyles.label.copyWith(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}

