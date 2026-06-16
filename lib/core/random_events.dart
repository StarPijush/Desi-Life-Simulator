import 'dart:math';
import '../models/character.dart';
import '../models/life_event.dart' show LifeEvent;
import 'enums.dart' show LifeEventType;

class RandomEventSystem {
  static final _rng = Random();

  static void generateAgeUpEvents(Character c, List<LifeEvent> events) {
    // Only generate 1 major random event per year to avoid spam
    if (_rng.nextDouble() > 0.4) return;

    // Pick a category to test based on character state
    final List<String> possibleCategories = ['health', 'fame', 'relationship'];
    if (c.careerGroup == 'Military') possibleCategories.add('military');
    if (c.careerGroup == 'Politician') possibleCategories.add('politics');
    if (c.careerGroup != 'None' && c.careerGroup != 'Military' && c.careerGroup != 'Politician') possibleCategories.add('career');

    final category = possibleCategories[_rng.nextInt(possibleCategories.length)];

    switch (category) {
      case 'military':
        _generateMilitaryEvent(c, events);
        break;
      case 'politics':
        _generatePoliticsEvent(c, events);
        break;
      case 'career':
        _generateCareerEvent(c, events);
        break;
      case 'relationship':
        _generateRelationshipEvent(c, events);
        break;
      case 'fame':
        _generateFameEvent(c, events);
        break;
      case 'health':
        _generateHealthEvent(c, events);
        break;
    }
  }

  static void _generateMilitaryEvent(Character c, List<LifeEvent> events) {
    final pool = [
      () {
        events.add(LifeEvent(
          title: 'Border Deployment',
          description: 'You were deployed to a tense border region for a 3-month rotation.',
          type: LifeEventType.neutral,
          metadata: {'age': c.age},
        ));
      },
      () {
        c.happiness = (c.happiness + 10).clamp(0, 100);
        c.popularity = (c.popularity + 5).clamp(0, 100);
        events.add(LifeEvent(
          title: 'Medal Ceremony',
          description: 'You were awarded a commendation for exceptional service during a training exercise.',
          type: LifeEventType.positive,
          metadata: {'age': c.age},
        ));
      },
      () {
        c.health = (c.health - 15).clamp(0, 100);
        events.add(LifeEvent(
          title: 'Injury During Training',
          description: 'You sprained your ankle severely during an obstacle course run.',
          type: LifeEventType.negative,
          metadata: {'age': c.age},
        ));
      },
      () {
        c.karma = (c.karma + 10).clamp(0, 100);
        c.happiness = (c.happiness + 15).clamp(0, 100);
        events.add(LifeEvent(
          title: 'Heroic Rescue',
          description: 'You saved a fellow soldier from drowning during a flood relief operation.',
          type: LifeEventType.milestone,
          metadata: {'age': c.age},
        ));
      },
      () {
        c.happiness = (c.happiness - 10).clamp(0, 100);
        events.add(LifeEvent(
          title: 'Transfer Order',
          description: 'You received sudden orders to transfer to a remote, harsh weather base.',
          type: LifeEventType.negative,
          metadata: {'age': c.age},
        ));
      },
    ];
    pool[_rng.nextInt(pool.length)]();
  }

  static void _generatePoliticsEvent(Character c, List<LifeEvent> events) {
    final pool = [
      () {
        c.bankBalance += 50000;
        events.add(LifeEvent(
          title: 'Campaign Donation',
          description: 'A wealthy local businessman made a large anonymous donation to your fund.',
          type: LifeEventType.positive,
          metadata: {'age': c.age},
        ));
      },
      () {
        c.publicTrust = (c.publicTrust - 15).clamp(0, 100);
        c.happiness = (c.happiness - 20).clamp(0, 100);
        events.add(LifeEvent(
          title: 'Media Attack',
          description: 'A rival news channel ran a hit-piece accusing you of neglecting your constituency.',
          type: LifeEventType.critical,
          metadata: {'age': c.age},
        ));
      },
      () {
        c.popularity = (c.popularity + 10).clamp(0, 100);
        events.add(LifeEvent(
          title: 'Debate Victory',
          description: 'You completely outsmarted your opposition in a televised town hall debate.',
          type: LifeEventType.positive,
          metadata: {'age': c.age},
        ));
      },
      () {
        c.publicTrust = (c.publicTrust - 20).clamp(0, 100);
        events.add(LifeEvent(
          title: 'Corruption Allegation',
          description: 'The opposition accused your office of misallocating road repair funds.',
          type: LifeEventType.negative,
          metadata: {'age': c.age},
        ));
      },
    ];
    pool[_rng.nextInt(pool.length)]();
  }

  static void _generateCareerEvent(Character c, List<LifeEvent> events) {
    final pool = [
      () {
        c.bankBalance += (c.annualIncome * 0.1).toInt();
        c.happiness = (c.happiness + 15).clamp(0, 100);
        events.add(LifeEvent(
          title: 'Surprise Bonus',
          description: 'Your boss handed you a performance bonus for your hard work this year.',
          type: LifeEventType.positive,
          metadata: {'age': c.age},
        ));
      },
      () {
        c.happiness = (c.happiness - 15).clamp(0, 100);
        c.stressLevel = (c.stressLevel + 20).clamp(0, 100);
        events.add(LifeEvent(
          title: 'Toxic Boss',
          description: 'A new manager joined your team and has been making your daily life miserable.',
          type: LifeEventType.negative,
          metadata: {'age': c.age},
        ));
      },
      () {
        c.jobPerformance = (c.jobPerformance + 20).clamp(0, 100);
        events.add(LifeEvent(
          title: 'Big Project Success',
          description: 'A massive project you led was completed ahead of schedule.',
          type: LifeEventType.positive,
          metadata: {'age': c.age},
        ));
      },
      () {
        c.jobPerformance = (c.jobPerformance - 15).clamp(0, 100);
        events.add(LifeEvent(
          title: 'Missed Deadline',
          description: 'You severely botched a deadline and the client was furious.',
          type: LifeEventType.negative,
          metadata: {'age': c.age},
        ));
      },
    ];
    pool[_rng.nextInt(pool.length)]();
  }

  static void _generateRelationshipEvent(Character c, List<LifeEvent> events) {
    if (c.age < 18) return;
    final pool = [
      () {
        c.happiness = (c.happiness + 20).clamp(0, 100);
        events.add(LifeEvent(
          title: 'Romantic Spark',
          description: 'You met someone incredible at a coffee shop and had a 4-hour conversation.',
          type: LifeEventType.positive,
          metadata: {'age': c.age},
        ));
      },
      () {
        c.happiness = (c.happiness - 20).clamp(0, 100);
        events.add(LifeEvent(
          title: 'Bad Breakup',
          description: 'Things ended horribly with someone you were seeing.',
          type: LifeEventType.negative,
          metadata: {'age': c.age},
        ));
      },
      () {
        c.happiness = (c.happiness - 10).clamp(0, 100);
        events.add(LifeEvent(
          title: 'Family Conflict',
          description: 'You had a screaming match with your parents over life choices.',
          type: LifeEventType.negative,
          metadata: {'age': c.age},
        ));
      },
      () {
        c.happiness = (c.happiness + 15).clamp(0, 100);
        events.add(LifeEvent(
          title: 'Family Reunion',
          description: 'You attended a massive family wedding and had a surprisingly great time.',
          type: LifeEventType.positive,
          metadata: {'age': c.age},
        ));
      },
    ];
    pool[_rng.nextInt(pool.length)]();
  }

  static void _generateFameEvent(Character c, List<LifeEvent> events) {
    if (c.fame < 10 && c.followers < 1000) return;
    final pool = [
      () {
        c.followers += 5000;
        c.fame = (c.fame + 5).clamp(0, 100);
        events.add(LifeEvent(
          title: 'Viral Video',
          description: 'One of your recent posts caught the algorithm and went massively viral.',
          type: LifeEventType.positive,
          metadata: {'age': c.age},
        ));
      },
      () {
        c.followers = (c.followers * 0.9).toInt();
        c.fame = (c.fame - 5).clamp(0, 100);
        c.happiness = (c.happiness - 15).clamp(0, 100);
        events.add(LifeEvent(
          title: 'Public Scandal',
          description: 'An old tweet of yours was dug up and "cancelled" you for a week.',
          type: LifeEventType.negative,
          metadata: {'age': c.age},
        ));
      },
      () {
        c.bankBalance += 10000;
        events.add(LifeEvent(
          title: 'Surprise Brand Deal',
          description: 'A popular energy drink company paid you for a quick shoutout.',
          type: LifeEventType.positive,
          metadata: {'age': c.age},
        ));
      },
      () {
        c.happiness = (c.happiness + 20).clamp(0, 100);
        c.fame = (c.fame + 10).clamp(0, 100);
        events.add(LifeEvent(
          title: 'Award Nomination',
          description: 'You were nominated for a prestigious internet personality award.',
          type: LifeEventType.milestone,
          metadata: {'age': c.age},
        ));
      },
    ];
    pool[_rng.nextInt(pool.length)]();
  }

  static void _generateHealthEvent(Character c, List<LifeEvent> events) {
    final pool = [
      () {
        c.health = (c.health - 20).clamp(0, 100);
        c.happiness = (c.happiness - 10).clamp(0, 100);
        events.add(LifeEvent(
          title: 'Minor Illness',
          description: 'You caught a brutal flu that knocked you out for a week.',
          type: LifeEventType.negative,
          metadata: {'age': c.age},
        ));
      },
      () {
        c.health = (c.health - 30).clamp(0, 100);
        c.happiness = (c.happiness - 20).clamp(0, 100);
        c.bankBalance -= 5000;
        events.add(LifeEvent(
          title: 'Hospital Visit',
          description: 'You had a severe appendicitis scare and needed emergency surgery.',
          type: LifeEventType.critical,
          metadata: {'age': c.age},
        ));
      },
      () {
        c.health = (c.health + 15).clamp(0, 100);
        c.happiness = (c.happiness + 10).clamp(0, 100);
        events.add(LifeEvent(
          title: 'Fitness Milestone',
          description: 'You finally hit a new personal record at the gym!',
          type: LifeEventType.positive,
          metadata: {'age': c.age},
        ));
      },
      () {
        c.health = (c.health - 15).clamp(0, 100);
        events.add(LifeEvent(
          title: 'Food Poisoning',
          description: 'That street food you ate last night was a terrible mistake.',
          type: LifeEventType.negative,
          metadata: {'age': c.age},
        ));
      },
    ];
    pool[_rng.nextInt(pool.length)]();
  }
}
