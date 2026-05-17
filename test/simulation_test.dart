import 'package:flutter_test/flutter_test.dart';
import 'package:desilife/models/character.dart';
import 'package:desilife/core/engine.dart';
import 'package:desilife/models/loan_model.dart';

void main() {
  group('Simulation Integrity Tests', () {
    test('Character CopyWith maintains deep state integrity', () {
      final char = Character(name: 'Test User', age: 20, city: 'Delhi', gender: 'Male')
        ..bankBalance = 1000
        ..unlockedActivityIds = ['A', 'B']
        ..hiddenModifiers = {'X': 1.0};

      final copy = char.copyWith();

      expect(copy.name, equals(char.name));
      expect(copy.age, equals(char.age));

      // Verify deep copy of lists
      copy.unlockedActivityIds.add('C');
      expect(char.unlockedActivityIds.length, equals(2));
      expect(copy.unlockedActivityIds.length, equals(3));

      // Verify deep copy of maps
      copy.hiddenModifiers['X'] = 2.0;
      expect(char.hiddenModifiers['X'], equals(1.0));
    });

    test('AgeUp cycle correctly updates age and syncs unlocks', () {
      final char = Character(name: 'Sim User', age: 16, city: 'Mumbai', gender: 'Female')
        ..unlockedActivityIds = [];

      final result = GameEngine.ageUp(char);

      expect(result.character.age, equals(17));
      expect(result.events, isNotEmpty);
      // Verify hard-sync worked
      expect(
        result.character.unlockedActivityIds.contains('Go to Party'),
        isTrue,
      );
    });

    test('Financial Pressure System triggers stress on high EMI load', () {
      final char = Character(name: 'Debt User', age: 30, city: 'Bangalore', gender: 'Male')
        ..annualIncome = 100000
        ..stressLevel = 20
        ..bankName = 'HDFC'
        ..loans = [];

      // Add a huge loan that creates high EMI
      // GameEngine calculates EMI as ~15% of balance.
      // We need EMI > 50,000 (50% of 100,000).
      // So balance * 0.15 > 50,000 => balance > 333,333.

      char.loans.add(LoanModel(
        type: 'Personal',
        startAge: 30,
        durationYears: 12,
        amount: 400000,
        remainingAmount: 400000,
        interestRate: 0.1,
      ));

      final result = GameEngine.ageUp(char);

      // Stress should increase by 15 (base) + potentially others
      expect(result.character.stressLevel, greaterThan(20));
      expect(
        result.character.tensionSignals.any(
          (s) => s.contains('FINANCIAL PRESSURE'),
        ),
        isTrue,
      );
    });

    test('Job actions update performance and clamp it safely', () {
      final char = Character(name: 'Worker User', age: 24, city: 'Pune', gender: 'Female')
        ..careerGroup = 'Tech'
        ..jobTitle = 'Junior Developer'
        ..annualIncome = 360000
        ..jobPerformance = 90;

      final hard = GameEngine.performCareerAction(char, 'career.job.work_hard');
      expect(hard.character.jobPerformance, equals(100));

      final slack = GameEngine.performCareerAction(
        hard.character,
        'career.job.slack_off',
      );
      expect(slack.character.jobPerformance, equals(90));

      final breakResult = GameEngine.performCareerAction(
        slack.character,
        'career.job.take_break',
      );
      expect(breakResult.character.jobPerformance, equals(85));
    });

    test('AgeUp promotes a high-performing worker after enough experience', () {
      final char = Character(
        name: 'Promotion User',
        age: 24,
        city: 'Hyderabad',
        educationLevel: 'Graduate',
        smarts: 90,
        gender: 'Male',
      );
      final tech = CareerSystem.findGroup('Tech')!;
      CareerSystem.assignCareer(char, tech);
      char
        ..yearsInRole = 1
        ..yearsInJob = 0
        ..jobPerformance = 100
        ..hiddenModifiers['promotionChance'] = 10;

      final result = GameEngine.ageUp(char);

      expect(result.character.jobLevel, equals(1));
      expect(result.character.jobTitle, equals('Junior Developer'));
      expect(
        result.events.any((event) => event.description.contains('Promoted')),
        isTrue,
      );
    });

    test('Business actions create scalable business stats', () {
      final char = Character(
        name: 'Founder User',
        age: 25,
        city: 'Bengaluru',
        bankBalance: 800000,
        smarts: 70,
        gender: 'Male',
      );

      final started = GameEngine.performCareerAction(
        char,
        'career.business.start',
      );

      expect(started.success, isTrue);
      expect(started.character.hiddenModifiers['business_active'], equals(1));
      expect(started.character.hiddenModifiers['business_revenue'], greaterThan(0));
      expect(started.character.bankBalance, equals(300000));

      final invested = GameEngine.performCareerAction(
        started.character,
        'career.business.invest',
      );

      expect(invested.success, isTrue);
      expect(
        invested.character.hiddenModifiers['business_growth'],
        greaterThan(started.character.hiddenModifiers['business_growth']!),
      );
    });

    test('Special career requirements unlock high-risk paths', () {
      final char = Character(
        name: 'Fame User',
        age: 19,
        city: 'Mumbai',
        smarts: 40,
        social: 80,
        gender: 'Female',
      );

      final actor = GameEngine.performCareerAction(
        char,
        'career.special.apply::Actor',
      );

      expect(actor.success, isTrue);
      expect(actor.character.careerGroup, equals('Actor'));
      expect(actor.character.jobTitle, equals('Struggling Actor'));

      final action = GameEngine.performCareerAction(
        actor.character,
        'career.special.perform::Actor',
      );

      expect(action.events, isNotEmpty);
      expect(action.character.jobPerformance, inInclusiveRange(0, 100));
    });
  });
}
