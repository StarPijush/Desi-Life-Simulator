import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/engine.dart';
import '../../../core/part_time_jobs_data.dart';
import '../../../models/character.dart';
import '../../../models/part_time_job.dart';
import 'widgets/current_job_section.dart';
import 'widgets/positions_section.dart';
import 'widgets/status_section.dart';
import 'widgets/work_actions_section.dart';

class PartTimeJobsScreen extends StatefulWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const PartTimeJobsScreen({
    super.key,
    required this.character,
    required this.onGameAction,
  });

  @override
  State<PartTimeJobsScreen> createState() => _PartTimeJobsScreenState();
}

class _PartTimeJobsScreenState extends State<PartTimeJobsScreen> {
  late String _currentJobId;
  late int _experience;
  late int _responsibility;
  late int _customerSkill;
  late int _performance;
  late int _monthsWorked;

  @override
  void initState() {
    super.initState();
    _currentJobId = widget.character.currentPartTimeJob;
    _experience = widget.character.partTimeExperience;
    _responsibility = widget.character.partTimeResponsibility;
    _customerSkill = widget.character.customerSkill;
    _performance = widget.character.partTimeJobPerformance;
    _monthsWorked = widget.character.partTimeMonthsWorked;
  }

  @override
  Widget build(BuildContext context) {
    final currentJob = PartTimeJobsData.findById(_currentJobId);
    final displayCharacter = widget.character.copyWith(
      currentPartTimeJob: _currentJobId,
      partTimeExperience: _experience,
      partTimeResponsibility: _responsibility,
      customerSkill: _customerSkill,
      partTimeJobPerformance: _performance,
      partTimeMonthsWorked: _monthsWorked,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      appBar: const _PartTimeHeader(),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          const SizedBox(height: 8),
          PartTimeStatusSection(
            character: displayCharacter,
            currentJob: currentJob,
            experience: _experience,
            responsibility: _responsibility,
            customerSkill: _customerSkill,
          ),
          const SizedBox(height: 8),
          PositionsSection(
            character: displayCharacter,
            jobs: PartTimeJobsData.jobs,
            onSelectJob: _confirmJob,
          ),
          const SizedBox(height: 8),
          CurrentJobSection(
            job: currentJob,
            performance: _performance,
            monthsWorked: _monthsWorked,
          ),
          const SizedBox(height: 8),
          WorkActionsSection(
            hasJob: currentJob != null,
            onWorkShift: () => _workAction('work_shift'),
            onHelpCustomer: () => _workAction('help_customer'),
            onExtraShift: () => _workAction('extra_shift'),
            onAskForRaise: () => _workAction('ask_raise'),
            onQuitJob: _quitJob,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmJob(PartTimeJob job) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => Center(
        child: Material(
          color: Colors.white,
          elevation: 0,
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Accept Job?',
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF161C28),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  job.name,
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF5C5E62),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Accept'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (accepted != true) return;

    setState(() {
      _currentJobId = job.id;
      _performance = _performance.clamp(45, 100).toInt();
      _monthsWorked = 0;
    });
    _emit('apply', {'jobId': job.id});
  }

  void _workAction(String action) {
    final job = PartTimeJobsData.findById(_currentJobId);
    if (job == null) return;
    setState(() {
      if (action == 'work_shift') {
        _experience = (_experience + job.experienceGain).clamp(0, 100).toInt();
        _responsibility = (_responsibility + 3).clamp(0, 100).toInt();
        _performance = (_performance + 4).clamp(0, 100).toInt();
        _monthsWorked += 1;
      } else if (action == 'help_customer') {
        _customerSkill =
            (_customerSkill + job.customerSkillGain + 3).clamp(0, 100).toInt();
        _performance = (_performance + 5).clamp(0, 100).toInt();
      } else if (action == 'extra_shift') {
        _experience =
            (_experience + job.experienceGain + 2).clamp(0, 100).toInt();
        _responsibility = (_responsibility + 4).clamp(0, 100).toInt();
        _performance = (_performance + 3).clamp(0, 100).toInt();
        _monthsWorked += 1;
      } else if (action == 'ask_raise') {
        _performance = (_performance + 1).clamp(0, 100).toInt();
      }
    });
    _emit(action);
  }

  void _quitJob() {
    setState(() {
      _currentJobId = 'None';
      _performance = 50;
      _monthsWorked = 0;
    });
    _emit('quit');
  }

  void _emit(String action, [Map<String, dynamic> payload = const {}]) {
    widget.onGameAction(
      GameAction(
        'career.perform',
        {
          'actionId': 'career.part_time.$action',
          'stayInFlow': true,
          ...payload,
        },
      ),
    );
  }
}

class _PartTimeHeader extends StatelessWidget implements PreferredSizeWidget {
  const _PartTimeHeader();

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: const Color(0xFFF9F9FF),
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
                child:
                    Icon(Icons.arrow_back, color: Color(0xFF006D37), size: 24),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'PART-TIME JOBS',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF161C28),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
