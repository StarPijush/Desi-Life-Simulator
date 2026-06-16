import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/tv_project.dart';
import '../widgets/tv_info_row.dart';
import '../widgets/tv_cast_tile.dart';
import '../widgets/tv_project_action_tile.dart';

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

class TVProjectPage extends StatelessWidget {
  final TVProject project;

  const TVProjectPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: const _Header(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 96.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 672),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroSection(project: project),
                const SizedBox(height: 32),
                _ProductionProgressSection(project: project),
                const SizedBox(height: 32),
                _ProjectDetailsSection(project: project),
                const SizedBox(height: 32),
                _ContractDetailsSection(project: project),
                const SizedBox(height: 32),
                _CastSection(project: project),
                const SizedBox(height: 32),
                _NetworkSection(project: project),
                const SizedBox(height: 32),
                _CareerImpactSection(project: project),
                const SizedBox(height: 32),
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
      color: const Color(0xFFF9F9FF),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.arrow_back, color: Color(0xFF006D37), size: 24),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'TV PROJECT',
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF006D37),
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Current Production',
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5C5E62),
                      letterSpacing: 1.0,
                    ),
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.lexend(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF5C5E62),
          letterSpacing: 1.5,
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              color: const Color(0xFF006D37),
              child: Text(
                project.genre.toUpperCase(),
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              color: const Color(0xFFDEDFE3),
              child: Text(
                project.network.toUpperCase(),
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF606366),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          project.title.toUpperCase(),
          style: GoogleFonts.lexend(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF161C28),
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.radio_button_checked, color: Color(0xFF006D37), size: 14),
            const SizedBox(width: 6),
            Text(
              project.showStatus.toUpperCase(),
              style: GoogleFonts.lexend(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF006D37),
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
        const _SectionTitle('PRODUCTION PROGRESS'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Episodes Completed:',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF5C5E62),
              ),
            ),
            Text(
              '${project.completedEpisodes} / ${project.totalEpisodes}',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF161C28),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 12,
          width: double.infinity,
          color: const Color(0xFFDEDFE3),
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
        const SizedBox(height: 4),
        Text(
          '${(project.productionProgress * 100).toInt()}%',
          style: GoogleFonts.lexend(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF006D37),
          ),
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
        const _SectionTitle('PROJECT DETAILS'),
        TVInfoRow(label: 'Network', value: project.network),
        TVInfoRow(label: 'Season', value: project.seasonNumber.toString()),
        TVInfoRow(label: 'Episodes', value: project.totalEpisodes.toString()),
        TVInfoRow(label: 'Role', value: project.roleName),
        TVInfoRow(label: 'Role Type', value: project.roleType),
        TVInfoRow(label: 'Production Co.', value: project.productionCompany),
        TVInfoRow(label: 'Director', value: project.director),
        TVInfoRow(label: 'Producer', value: project.producer),
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
        border: Border.all(color: const Color(0xFF006D37), width: 1),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              'CONTRACT DETAILS',
              style: GoogleFonts.lexend(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF006D37),
                letterSpacing: 1.5,
              ),
            ),
          ),
          TVInfoRow(label: 'Salary Per Ep.', value: '₹${_formatMoney(project.salaryPerEpisode)}', valueColor: const Color(0xFF006D37)),
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
        const _SectionTitle('CAST'),
        Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
          ),
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
        const _SectionTitle('NETWORK'),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3FF),
            border: Border.all(color: const Color(0xFFDEDFE3), width: 1),
          ),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.network,
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF161C28),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Top-rated entertainment channel known for high-budget science fiction dramas.', // Hardcoded as per prompt
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF5C5E62),
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
        const _SectionTitle('CAREER IMPACT'),
        TVInfoRow(label: 'Fame Gain', value: '+${project.fameImpact}%', valueColor: const Color(0xFF006D37)),
        TVInfoRow(label: 'Reputation Gain', value: '+${project.reputationImpact}%', valueColor: const Color(0xFF006D37)),
        TVInfoRow(label: 'Fan Growth', value: '+${project.fanGrowth}%', valueColor: const Color(0xFF006D37)),
        const TVInfoRow(label: 'Award Potential', value: 'High'),
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
        const _SectionTitle('PROJECT ACTIONS'),
        Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
          ),
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
      color: const Color(0xFFF9F9FF),
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: MediaQuery.of(context).padding.bottom + 16.0,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006D37),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: Text(
              'CONTINUE PRODUCTION',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF006D37),
              side: const BorderSide(color: Color(0xFF006D37), width: 2),
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: Text(
              'PROJECT STATUS',
              style: GoogleFonts.lexend(
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
