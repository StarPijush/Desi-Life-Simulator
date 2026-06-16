import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/movie_project.dart';
import 'widgets/movie_info_row.dart';
import 'widgets/movie_cast_tile.dart';
import 'widgets/movie_action_tile.dart';

// Formatter function to match engine's formatMoney temporarily since we can't import Engine easily in pure UI mock
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

class MovieProjectPage extends StatelessWidget {
  final MovieProject project;

  const MovieProjectPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: const _MovieHeader(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 96.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 672), // max-w-2xl
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MovieOverviewSection(project: project),
                const SizedBox(height: 32),
                _MovieProductionSection(project: project),
                const SizedBox(height: 32),
                _MovieRoleSection(project: project),
                const SizedBox(height: 32),
                _MovieCastSection(project: project),
                const SizedBox(height: 32),
                _MovieActionsSection(project: project),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MovieHeader extends StatelessWidget implements PreferredSizeWidget {
  const _MovieHeader();

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
              Text(
                'MOVIE PROJECT',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF006D37),
                  letterSpacing: -0.5,
                ),
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

class _MovieOverviewSection extends StatelessWidget {
  final MovieProject project;

  const _MovieOverviewSection({required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('PROJECT OVERVIEW'),
        Text(
          project.title,
          style: GoogleFonts.lexend(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF161C28),
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${project.genre} • ${project.stage}',
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF5C5E62),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 12,
          width: double.infinity,
          color: const Color(0xFFDEDFE3),
          child: Row(
            children: [
              Expanded(
                flex: (project.progress * 100).toInt(),
                child: Container(color: const Color(0xFF2ECC71)),
              ),
              Expanded(
                flex: ((1 - project.progress) * 100).toInt(),
                child: const SizedBox(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MovieProductionSection extends StatelessWidget {
  final MovieProject project;

  const _MovieProductionSection({required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('PRODUCTION DETAILS'),
        MovieInfoRow(label: 'Director', value: project.director),
        MovieInfoRow(label: 'Budget', value: '₹${_formatMoney(project.budget)}'),
        MovieInfoRow(label: 'Production House', value: project.productionHouse, valueAlign: TextAlign.right),
      ],
    );
  }
}

class _MovieRoleSection extends StatelessWidget {
  final MovieProject project;

  const _MovieRoleSection({required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('YOUR ROLE'),
        MovieInfoRow(label: 'Character', value: project.characterName),
        MovieInfoRow(label: 'Position', value: project.roleType),
        MovieInfoRow(label: 'Salary', value: '₹${_formatMoney(project.salary)}'),
      ],
    );
  }
}

class _MovieCastSection extends StatelessWidget {
  final MovieProject project;

  const _MovieCastSection({required this.project});

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
            children: project.cast.map((member) => MovieCastTile(
              member: member,
              onTap: () {}, // Future integration
            )).toList(),
          ),
        ),
      ],
    );
  }
}

class _MovieActionsSection extends StatelessWidget {
  final MovieProject project;

  const _MovieActionsSection({required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('CAREER ACTIONS'),
        Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
          ),
          child: Column(
            children: [
              MovieActionTile(
                icon: Icons.theater_comedy,
                label: 'Rehearse Scene',
                onTap: () {},
              ),
              MovieActionTile(
                icon: Icons.campaign,
                label: 'Promote Movie',
                onTap: () {},
              ),
              MovieActionTile(
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
