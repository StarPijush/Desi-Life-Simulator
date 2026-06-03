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
      onTrainPhysically: () => _emit('career.military.train_physically'),
      onWeaponsPractice: () => _emit('career.military.weapons_practice'),
      onLeadershipTraining: () => _emit('career.military.leadership_training'),
      onPromotionExam: () => _emit('career.military.promotion_exam'),
      onSpecialForcesSelection: () => _emit('career.military.special_forces'),
    );
  }

  void _emit(String actionId) {
    onGameAction(GameAction('career.perform', {'actionId': actionId}));
  }
}
