import 'package:flutter/material.dart';

import '../../core/engine.dart';
import '../../models/character.dart';
import 'military/military_screen.dart';

class MilitaryPage extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const MilitaryPage({
    super.key,
    required this.character,
    required this.onGameAction,
  });

  @override
  Widget build(BuildContext context) {
    return MilitaryScreen(
      character: character,
      onTrainPhysically: () => _emit(character.careerGroup == 'Military'
          ? 'career.military.training'
          : 'career.military.enlist'),
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
