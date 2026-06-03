import 'package:desilife/core/engine.dart';
import 'package:desilife/models/character.dart';
import 'package:desilife/screens/career/part_time_jobs/part_time_jobs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Part-Time Jobs opens and renders locked/unlocked rows',
      (tester) async {
    final actions = <GameAction>[];
    final character = Character.defaultCharacter().copyWith(
      age: 16,
      educationLevel: 'Secondary',
      partTimeExperience: 12,
      partTimeResponsibility: 45,
      customerSkill: 30,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PartTimeJobsScreen(
          character: character,
          onGameAction: actions.add,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('PART-TIME JOBS'), findsOneWidget);
    expect(find.text('Grocery Store Helper'), findsOneWidget);
    expect(find.text('Barista Apprentice'), findsOneWidget);
    expect(find.text('Warehouse Sorter'), findsOneWidget);
    expect(find.textContaining('Requires Age 18+'), findsOneWidget);
    expect(find.text('IT Lab Monitor'), findsOneWidget);
    expect(find.textContaining('Requires Responsibility 60+'), findsOneWidget);

    await tester.tap(find.text('Grocery Store Helper'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Accept Job?'), findsOneWidget);
    expect(find.text('Accept'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });
}
