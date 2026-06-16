import 'package:flutter/material.dart';

import '../../core/engine.dart';
import '../../models/character.dart';
import '../../widgets/events/event_card.dart';
import '../../widgets/events/event_types.dart';
import 'military/military_screen.dart';

class MilitaryPage extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const MilitaryPage({
    super.key,
    required this.character,
    required this.onGameAction,
  });

  void _handleEnlistmentOrTraining(BuildContext context) {
    if (character.careerGroup == 'Military') {
      _emit('career.military.training');
      return;
    }

    final eduLevels = [
      'None',
      'Primary',
      'Secondary',
      'Higher Secondary',
      'Undergraduate',
      'Graduate',
      'Postgraduate'
    ];
    final charEduIdx = eduLevels.indexOf(character.educationLevel);
    final reqEduIdx = eduLevels.indexOf('Secondary');

    bool isMet = character.age >= 18 && charEduIdx >= reqEduIdx && character.smarts >= 45;

    if (!isMet) {
      showEventCard(
        context: context,
        category: EventCategory.military,
        mode: EventCardMode.requirement,
        title: 'Requirements',
        description: 'You do not meet the strict requirements to join the military.',
        illustration: const EventIllustration.emoji('🔒'),
        requirements: [
          EventRequirement(emojiIcon: '🎂', label: 'Age (Current: ${character.age} | Required: 18+)', isMet: character.age >= 18),
          EventRequirement(emojiIcon: '📚', label: 'Education (Current: ${character.educationLevel} | Required: Secondary)', isMet: charEduIdx >= reqEduIdx),
          EventRequirement(emojiIcon: '🧠', label: 'Smarts (Current: ${character.smarts} | Required: 45)', isMet: character.smarts >= 45),
        ],
        primaryAction: EventCardAction(
          label: 'Okay',
          onPressed: () => Navigator.of(context).pop(),
        ),
      );
    } else {
      showEventCard(
        context: context,
        category: EventCategory.military,
        mode: EventCardMode.offer,
        title: 'MILITARY ENLISTMENT',
        description: 'Are you ready to swear your allegiance and enlist as a Recruit?',
        illustration: const EventIllustration.emoji('🎖️'),
        infoRows: [
          const EventInfoRow(label: 'Rank', value: 'Recruit'),
          const EventInfoRow(label: 'Salary', value: '₹32,000'),
          const EventInfoRow(label: 'Hours', value: 'Full Time'),
          const EventInfoRow(label: 'Risk', value: 'Medium'),
          const EventInfoRow(label: 'Reward', value: 'Military Career'),
        ],
        primaryAction: EventCardAction(
          label: 'Enlist',
          onPressed: () {
            Navigator.of(context).pop();
            _emit('career.military.enlist');
          },
        ),
        secondaryAction: EventCardAction(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MilitaryScreen(
      character: character,
      onTrainPhysically: () => _handleEnlistmentOrTraining(context),
      onWeaponsPractice: () => _emit('career.military.physical_drill'),
      onLeadershipTraining: () => _emit('career.military.leadership_course'),
      onPromotionExam: () => _emit('career.military.border_deployment'),
      onSpecialForcesSelection: () => _emit('career.military.special_mission'),
    );
  }

  void _emit(String actionId) {
    onGameAction(GameAction('career.perform', {'actionId': actionId}));
  }
}
