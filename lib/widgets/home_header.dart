// lib/widgets/home_header.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/design_system.dart';
import '../models/character.dart';
import '../core/engine.dart';
import 'premium_card.dart';

class HomeHeader extends StatelessWidget {
  final Character character;
  final VoidCallback? onAvatarTap;

  const HomeHeader({super.key, required this.character, this.onAvatarTap});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. LEFT: Avatar
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onAvatarTap?.call();
            },
            child: Hero(
              tag: 'avatar-profile',
              child: _buildAvatar(),
            ),
          ),

          // 2. CENTER: Name + Identity
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  character.name,
                  style: AppTextStyles.h3.copyWith(fontSize: 16),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  character.identityTitle.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // 3. RIGHT: Money
          _buildBalance(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.avatarRingGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          character.name[0].toUpperCase(),
          style: AppTextStyles.h2.copyWith(color: Colors.white, fontSize: 22),
        ),
      ),
    );
  }

  Widget _buildBalance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '₹${GameEngine.formatMoney(character.bankBalance)}',
          style: AppTextStyles.financial.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 2),
        Text(
          character.netWorthLabel,
          style: AppTextStyles.caption.copyWith(
            fontSize: 10,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
