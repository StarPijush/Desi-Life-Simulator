import 'package:flutter/material.dart';

import '../../../../../core/design_system.dart';
import '../../../../../widgets/game/game_card.dart';
import '../../../../../widgets/game/section_header.dart';
import '../models/tv_project.dart';
import '../widgets/tv_info_row.dart';
import '../widgets/tv_cast_tile.dart';
import '../widgets/tv_project_action_tile.dart';

class TVProjectPage extends StatelessWidget {
  final TVProject project;

  const TVProjectPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iconBg,
      appBar: const _Header(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md, left: AppSpacing.containerPadding, right: AppSpacing.containerPadding, bottom: 96),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 672),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroSection(project: project),
                const SizedBox(height: AppSpacing.xl),
                _ProductionProgressSection(project: project),
                const SizedBox(height: AppSpacing.xl),
                _ProjectDetailsSection(project: project),
                const SizedBox(height: AppSpacing.xl),
                _ContractDetailsSection(project: project),
                const SizedBox(height: AppSpacing.xl),
                _CastSection(project: project),
                const SizedBox(height: AppSpacing.xl),
                _NetworkSection(project: project),
                const SizedBox(height: AppSpacing.xl),
                _CareerImpactSection(project: project),
                const SizedBox(height: AppSpacing.xl),
                _ProjectActionsSection(project: project),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const _BottomActionArea(),
    );
  }
}

class _Header extends StatelessWidget implements PreferredSizeWidget {
  const _Header();

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.iconBg,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.outline, width: 1)),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(AppBorderRadius.full),
                child: const Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: Icon(Icons.arrow_back, color: AppColors.primary, size: 24),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'TV PROJECT',
                    style: AppTextStyles.labelBold.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Current Production',
                    style: AppTextStyles.sectionLabel.copyWith(letterSpacing: 1.0),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final TVProject project;

  const _HeroSection({required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
              color: AppColors.primary,
              child: Text(
                project.genre.toUpperCase(),
                style: AppTextStyles.labelBold.copyWith(fontSize: 13, color: AppColors.surface),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
              color: AppColors.divider,
              child: Text(
                project.network.toUpperCase(),
                style: AppTextStyles.labelBold.copyWith(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          project.title.toUpperCase(),
          style: AppTextStyles.displayMd.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            const Icon(Icons.radio_button_checked, color: AppColors.primary, size: 14),
            const SizedBox(width: 6),
            Text(
              project.showStatus.toUpperCase(),
              style: AppTextStyles.labelBold.copyWith(
                fontSize: 13,
                color: AppColors.primary,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProductionProgressSection extends StatelessWidget {
  final TVProject project;

  const _ProductionProgressSection({required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'PRODUCTION PROGRESS'),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Episodes Completed:',
              style: AppTextStyles.bodyLg.copyWith(color: AppColors.textSecondary),
            ),
            Text(
              '${project.completedEpisodes} / ${project.totalEpisodes}',
              style: AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.cardGap),
        Container(
          height: 12,
          width: double.infinity,
          color: AppColors.divider,
          child: Row(
            children: [
              Expanded(
                flex: (project.productionProgress * 100).toInt(),
                child: Container(color: const Color(0xFF2ECC71)),
              ),
              Expanded(
                flex: ((1 - project.productionProgress) * 100).toInt(),
                child: const SizedBox(),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${(project.productionProgress * 100).toInt()}%',
          style: AppTextStyles.labelBold.copyWith(fontSize: 13, color: AppColors.primary),
        ),
      ],
    );
  }
}

class _ProjectDetailsSection extends StatelessWidget {
  final TVProject project;

  const _ProjectDetailsSection({required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'PROJECT DETAILS'),
        GameCard(
          child: Column(
            children: [
              TVInfoRow(label: 'Network', value: project.network),
              TVInfoRow(label: 'Season', value: project.seasonNumber.toString()),
              TVInfoRow(label: 'Episodes', value: project.totalEpisodes.toString()),
              TVInfoRow(label: 'Role', value: project.roleName),
              TVInfoRow(label: 'Role Type', value: project.roleType),
              TVInfoRow(label: 'Production Co.', value: project.productionCompany),
              TVInfoRow(label: 'Director', value: project.director),
              TVInfoRow(label: 'Producer', value: project.producer),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContractDetailsSection extends StatelessWidget {
  final TVProject project;

  const _ContractDetailsSection({required this.project});

  @override
  Widget build(BuildContext context) {
    final totalPotentialEarnings = (project.salaryPerEpisode * project.totalEpisodes) + project.signingBonus;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
            child: Text(
              'CONTRACT DETAILS',
              style: AppTextStyles.labelBold.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 1.5,
              ),
            ),
          ),
          TVInfoRow(label: 'Salary Per Ep.', value: '₹${_formatMoney(project.salaryPerEpisode)}', valueColor: AppColors.primary),
          TVInfoRow(label: 'Signing Bonus', value: '₹${_formatMoney(project.signingBonus)}'),
          TVInfoRow(label: 'Total Potential', value: '₹${_formatMoney(totalPotentialEarnings)}'),
          TVInfoRow(label: 'Length', value: '${project.contractLength} Days'),
        ],
      ),
    );
  }
}

class _CastSection extends StatelessWidget {
  final TVProject project;

  const _CastSection({required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'CAST'),
        GameCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: project.castMembers.map((member) => TVCastTile(
              member: member,
              onTap: () {},
            )).toList(),
          ),
        ),
      ],
    );
  }
}

class _NetworkSection extends StatelessWidget {
  final TVProject project;

  const _NetworkSection({required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'NETWORK'),
        Container(
          decoration: BoxDecoration(
            color: AppColors.scaffoldBg,
            border: Border.all(color: AppColors.divider, width: 1),
          ),
          padding: const EdgeInsets.all(AppSpacing.cardGap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.network,
                style: AppTextStyles.headlineSm,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Top-rated entertainment channel known for high-budget science fiction dramas.',
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CareerImpactSection extends StatelessWidget {
  final TVProject project;

  const _CareerImpactSection({required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'CAREER IMPACT'),
        GameCard(
          child: Column(
            children: [
              TVInfoRow(label: 'Fame Gain', value: '+${project.fameImpact}%', valueColor: AppColors.primary),
              TVInfoRow(label: 'Reputation Gain', value: '+${project.reputationImpact}%', valueColor: AppColors.primary),
              TVInfoRow(label: 'Fan Growth', value: '+${project.fanGrowth}%', valueColor: AppColors.primary),
              const TVInfoRow(label: 'Award Potential', value: 'High'),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProjectActionsSection extends StatelessWidget {
  final TVProject project;

  const _ProjectActionsSection({required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'PROJECT ACTIONS'),
        GameCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              TVProjectActionTile(
                icon: Icons.description,
                label: 'View Script',
                onTap: () {},
              ),
              TVProjectActionTile(
                icon: Icons.groups,
                label: 'View Cast',
                onTap: () {},
              ),
              TVProjectActionTile(
                icon: Icons.calendar_month,
                label: 'View Production Schedule',
                onTap: () {},
              ),
              TVProjectActionTile(
                icon: Icons.chat,
                label: 'Talk To Director',
                onTap: () {},
              ),
              TVProjectActionTile(
                icon: Icons.logout,
                label: 'Leave Project',
                isDestructive: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BottomActionArea extends StatelessWidget {
  const _BottomActionArea();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.iconBg,
      padding: EdgeInsets.only(
        left: AppSpacing.containerPadding,
        right: AppSpacing.containerPadding,
        top: AppSpacing.containerPadding,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.containerPadding,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.outline, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: Text(
              'CONTINUE PRODUCTION',
              style: AppTextStyles.labelBold.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 2),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.cardGap),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: Text(
              'PROJECT STATUS',
              style: AppTextStyles.labelBold.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatMoney(int amount) {
  final str = amount.toString();
  if (str.length <= 3) return str;
  
  String result = str.substring(str.length - 3);
  String remaining = str.substring(0, str.length - 3);
  
  while (remaining.isNotEmpty) {
    if (remaining.length > 2) {
      result = '${remaining.substring(remaining.length - 2)},$result';
      remaining = remaining.substring(0, remaining.length - 2);
    } else {
      result = '$remaining,$result';
      remaining = '';
    }
  }
  return result;
}
