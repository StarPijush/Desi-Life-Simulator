// lib/core/event_data.dart
import '../models/character.dart';

class EventData {
  static double _avgBond(Character c) {
    if (c.relationships.isEmpty) return 0;
    return c.relationships.map((r) => r.bond).reduce((a, b) => a + b) /
        c.relationships.length;
  }

  // Unified Smart Event System
  static final List<Map<String, dynamic>> allSmartEvents = [
    // --- FINANCIAL (30+) ---
    {
      'title': 'Salary Hike!',
      'desc': 'Boss noticed your dedication. ₹10k monthly jump!',
      'type': 'Financial',
      'money': 120000.0,
      'happiness': 15,
      'cond': (c) => (c.annualIncome) > 0 && (c.smarts) > 60,
      'weight': 10
    },
    {
      'title': 'Freelance Gig',
      'desc': 'A friend referred you for a weekend project.',
      'type': 'Financial',
      'money': 45000.0,
      'happiness': 5,
      'cond': (c) => c.smarts > 50 && c.age > 18,
      'weight': 8
    },
    {
      'title': 'Stock Bull Run',
      'desc': 'Your portfolio hit a new all-time high!',
      'type': 'Financial',
      'money': 50000.0,
      'happiness': 10,
      'cond': (c) => c.stockPortfolio.isNotEmpty,
      'weight': 5
    },
    {
      'title': 'Crypto Mooning',
      'desc': 'Your crypto bag is finally in the green!',
      'type': 'Financial',
      'money': 80000.0,
      'happiness': 12,
      'cond': (c) => c.cryptoPortfolio.isNotEmpty,
      'weight': 4
    },
    {
      'title': 'Unexpected Tax Refund',
      'desc': 'IT department actually sent money back.',
      'type': 'Financial',
      'money': 15000.0,
      'happiness': 8,
      'cond': (c) => c.annualIncome > 300000,
      'weight': 7
    },
    {
      'title': 'Festival Bonus',
      'desc': 'Diwali bonus credited to your account!',
      'type': 'Financial',
      'money': 25000.0,
      'happiness': 10,
      'cond': (c) => c.annualIncome > 0,
      'weight': 10
    },
    {
      'title': 'Busted AC Repair',
      'desc': 'AC broke in peak summer. Heavy bill.',
      'type': 'Financial',
      'money': -12000.0,
      'happiness': -10,
      'cond': (c) => c.bankBalance > 20000,
      'weight': 6
    },
    {
      'title': 'Traffic Challan',
      'desc': 'Caught on camera speeding. E-challan arrived.',
      'type': 'Financial',
      'money': -5000.0,
      'happiness': -5,
      'cond': (c) => c.bankBalance > 10000 && c.age > 18,
      'weight': 8
    },
    {
      'title': 'Phone Scratched',
      'desc': 'Major scratch on screen. Repair is pricey.',
      'type': 'Financial',
      'money': -3500.0,
      'happiness': -8,
      'cond': (c) => c.bankBalance > 5000,
      'weight': 7
    },
    {
      'title': 'Found Old Cash',
      'desc': 'Found ₹2000 in an old jacket. Lucky!',
      'type': 'Financial',
      'money': 2000.0,
      'happiness': 5,
      'cond': (c) => true,
      'weight': 5
    },
    {
      'title': 'Scam Call Avoided',
      'desc': 'Recognized a phishing scam. Money saved!',
      'type': 'Financial',
      'happiness': 5,
      'smarts': 5,
      'cond': (c) => (c.smarts) > 60,
      'weight': 6
    },
    {
      'title': 'Bad Investment',
      'desc': 'That "sure hit" tip failed miserably.',
      'type': 'Financial',
      'money': -25000.0,
      'happiness': -15,
      'cond': (c) => c.smarts < 50 && c.bankBalance > 30000,
      'weight': 5
    },
    {
      'title': 'Credit Limit Boost',
      'desc': 'Bank increased your credit limit. Spending power!',
      'type': 'Financial',
      'happiness': 5,
      'cond': (c) => c.hasCreditCard && c.cibilScore > 750,
      'weight': 4
    },
    {
      'title': 'Wedding Expense',
      'desc': 'Best friend is getting married. Gift + Travel cost.',
      'type': 'Financial',
      'money': -15000.0,
      'social': 10,
      'cond': (c) => c.age > 22 && c.bankBalance > 20000,
      'weight': 8
    },
    {
      'title': 'Side Hustle Win',
      'desc': 'Your side hustle sold its first product!',
      'type': 'Financial',
      'money': 10000.0,
      'happiness': 15,
      'cond': (c) => c.smarts > 65,
      'weight': 5
    },
    {
      'title': 'Subscription Leak',
      'desc': 'Forgot to cancel a service. Money drained.',
      'type': 'Financial',
      'money': -4000.0,
      'happiness': -5,
      'cond': (c) => c.bankBalance > 10000,
      'weight': 7
    },
    {
      'title': 'Hospital Bill',
      'desc': 'Sudden illness required minor admission.',
      'type': 'Financial',
      'money': -20000.0,
      'health': -10,
      'cond': (c) => c.health < 60 && c.bankBalance > 30000,
      'weight': 6
    },
    {
      'title': 'Inheritance Gift',
      'desc': 'Relative sent a small token from an estate.',
      'type': 'Financial',
      'money': 50000.0,
      'happiness': 10,
      'cond': (c) => c.age > 30,
      'weight': 2
    },
    {
      'title': 'Bull Market Exit',
      'desc': 'Sold stocks at the peak. Smart move!',
      'type': 'Financial',
      'money': 100000.0,
      'happiness': 15,
      'cond': (c) => c.stockPortfolio.isNotEmpty && c.smarts > 80,
      'weight': 3
    },
    {
      'title': 'GST Penalty',
      'desc': 'Paperwork error led to a minor fine.',
      'type': 'Financial',
      'money': -8000.0,
      'happiness': -5,
      'cond': (c) => c.careerGroup == 'Business',
      'weight': 4
    },

    // --- RELATIONSHIPS (25+) ---
    {
      'title': 'Deep Conversation',
      'desc': 'Spent a long night talking to family.',
      'type': 'Relationships',
      'happiness': 10,
      'social': 10,
      'cond': (c) => _avgBond(c) > 60,
      'weight': 10
    },
    {
      'title': 'Old Friend Call',
      'desc': 'Reconnected with a childhood buddy.',
      'type': 'Relationships',
      'happiness': 12,
      'social': 8,
      'cond': (c) => c.age > 20,
      'weight': 7
    },
    {
      'title': 'Family Feud',
      'desc': 'A trivial argument turned into a major fight.',
      'type': 'Relationships',
      'happiness': -15,
      'social': -10,
      'cond': (c) => _avgBond(c) < 50,
      'weight': 6
    },
    {
      'title': 'Public Praise',
      'desc': 'Friends praised you at a gathering.',
      'type': 'Relationships',
      'social': 15,
      'happiness': 8,
      'cond': (c) => c.social > 70,
      'weight': 5
    },
    {
      'title': 'Romantic Night',
      'desc': 'Partner planned a surprise date.',
      'type': 'Relationships',
      'happiness': 20,
      'social': 10,
      'cond': (c) => c.relationships.any((r) => r.type == 'Partner'),
      'weight': 6
    },
    {
      'title': 'Betrayal',
      'desc': 'A trusted "friend" leaked your secrets.',
      'type': 'Relationships',
      'happiness': -25,
      'social': -20,
      'cond': (c) => _avgBond(c) < 60 && c.social > 40,
      'weight': 2
    },
    {
      'title': 'Gift from Home',
      'desc': 'Parents sent your favorite sweets.',
      'type': 'Relationships',
      'happiness': 10,
      'cond': (c) => _avgBond(c) > 70,
      'weight': 8
    },
    {
      'title': 'Social Ostracization',
      'desc': 'People are avoiding you due to your rudeness.',
      'type': 'Relationships',
      'social': -15,
      'happiness': -10,
      'cond': (c) => c.karma < 30,
      'weight': 4
    },
    {
      'title': 'Mentorship Request',
      'desc': 'A junior reached out for career advice.',
      'type': 'Relationships',
      'social': 10,
      'smarts': 5,
      'cond': (c) => c.smarts > 70 && c.age > 30,
      'weight': 6
    },
    {
      'title': 'Neighborhood Hero',
      'desc': 'Helped an elderly neighbor with groceries.',
      'type': 'Relationships',
      'karma': 15,
      'social': 5,
      'cond': (c) => true,
      'weight': 9
    },

    // --- EDUCATION & GROWTH (20+) ---
    {
      'title': 'Math Marathon',
      'desc': 'Solved difficult problems for 6 hours.',
      'type': 'Education',
      'smarts': 10,
      'happiness': -5,
      'cond': (c) => c.age < 22,
      'weight': 10
    },
    {
      'title': 'Course Completion',
      'desc': 'Finished a professional certification.',
      'type': 'Education',
      'smarts': 15,
      'happiness': 10,
      'cond': (c) => c.age > 22,
      'weight': 8
    },
    {
      'title': 'Language Skill',
      'desc': 'Finally able to speak a third language.',
      'type': 'Personal Growth',
      'smarts': 12,
      'social': 10,
      'cond': (c) => c.smarts > 60,
      'weight': 5
    },
    {
      'title': 'Creative Breakthrough',
      'desc': 'Inspired! You created something beautiful.',
      'type': 'Personal Growth',
      'happiness': 20,
      'smarts': 5,
      'cond': (c) => c.happiness > 70,
      'weight': 6
    },
    {
      'title': 'Productivity Streak',
      'desc': 'Everything is clicking. High efficiency!',
      'type': 'Personal Growth',
      'smarts': 8,
      'happiness': 8,
      'cond': (c) => c.happiness > 60,
      'weight': 5
    },
    {
      'title': 'Library Discovery',
      'desc': 'Found a rare book in an old library corner.',
      'type': 'Education',
      'smarts': 8,
      'cond': (c) => true,
      'weight': 7
    },
    {
      'title': 'Coding Prowess',
      'desc': 'Automated a tedious task at your setup.',
      'type': 'Personal Growth',
      'smarts': 12,
      'cond': (c) => c.careerGroup == 'Tech',
      'weight': 6
    },
    {
      'title': 'Public Speaking',
      'desc': 'Delivered a talk. Confidence boosted.',
      'type': 'Personal Growth',
      'social': 15,
      'smarts': 5,
      'cond': (c) => true,
      'weight': 5
    },

    // --- CHAOS & UNEXPECTED (15+) ---
    {
      'title': 'Sudden Storm',
      'desc': 'Heavy rain ruined your travel plans.',
      'type': 'Chaos',
      'happiness': -10,
      'cond': (c) => true,
      'weight': 8
    },
    {
      'title': 'Unfair Rejection',
      'desc': 'Despite quality work, you were ignored.',
      'type': 'Chaos',
      'happiness': -20,
      'cond': (c) => c.smarts > 80,
      'weight': 3
    },
    {
      'title': 'Random Act of Kindness',
      'desc': 'Stranger paid for your coffee. Unexpected!',
      'type': 'Chaos',
      'happiness': 15,
      'karma': 5,
      'cond': (c) => true,
      'weight': 4
    },
    {
      'title': 'System Glitch',
      'desc': 'Bank error froze your account for 2 days.',
      'type': 'Chaos',
      'happiness': -12,
      'cond': (c) => c.bankBalance > 100000,
      'weight': 2
    },
    {
      'title': 'Traffic Karma',
      'desc': 'Avoided a major jam by taking a shortcut.',
      'type': 'Chaos',
      'happiness': 10,
      'smarts': 2,
      'cond': (c) => true,
      'weight': 6
    },

    // --- RARE BIG WINS (10+) ---
    {
      'title': '💰 JACKPOT!',
      'desc': 'State lottery hit your ticket. HUGE!',
      'type': 'Rare',
      'money': 2000000.0,
      'happiness': 50,
      'cond': (c) => c.karma > 50,
      'weight': 1
    },
    {
      'title': '🚀 VIRAL FAME!',
      'desc': 'A video of you went global. Brand deals incoming!',
      'type': 'Rare',
      'money': 500000.0,
      'social': 40,
      'happiness': 40,
      'cond': (c) => c.social > 50,
      'weight': 1
    },
    {
      'title': '🏆 NATIONAL AWARD!',
      'desc': 'Recognized for your excellence in field.',
      'type': 'Rare',
      'smarts': 30,
      'social': 30,
      'happiness': 40,
      'cond': (c) => c.smarts > 85,
      'weight': 1
    },
    {
      'title': '📈 ANGEL INVESTMENT',
      'desc': 'Billionaire likes your side idea. Check signed!',
      'type': 'Rare',
      'money': 5000000.0,
      'happiness': 60,
      'cond': (c) => c.smarts > 90,
      'weight': 1
    },
    {
      'title': '🚁 HELICOPTER RIDE',
      'desc': 'Won a VIP tour of the city from a contest.',
      'type': 'Rare',
      'happiness': 35,
      'social': 15,
      'cond': (c) => true,
      'weight': 1
    },
    {
      'title': '🏡 ANCESTRAL ESTATE',
      'desc': 'Family won a decade-long legal battle for land.',
      'type': 'Rare',
      'money': 1500000.0,
      'happiness': 25,
      'cond': (c) => c.age > 40,
      'weight': 1
    },
  ];

  // Specific Auto-Decision Consequences
  static final List<Map<String, dynamic>> autoDecisionEvents = [
    {
      'title': '💔 Friendships Faded',
      'desc': 'You haven\'t called anyone in years. Bond broken.',
      'socialDelta': -30,
      'happinessDelta': -10,
      'cond': (c) => (c.age - c.lastActivityAge) > 5 && c.social > 20
    },
    {
      'title': '📉 Skills Outdated',
      'desc': 'Technology moved on while you rested. Career hit.',
      'smartsDelta': -15,
      'annualIncomeMod': 0.9,
      'cond': (c) => (c.age - c.lastActivityAge) > 6 && c.careerGroup != 'None'
    },
    {
      'title': '🤒 Health Neglect',
      'desc': 'Years of no exercise and poor sleep caught up.',
      'healthDelta': -25,
      'happinessDelta': -15,
      'cond': (c) => c.health < 40 && (c.age - c.lastActivityAge) > 4
    },
    {
      'title': '🏛️ CIBIL Crash',
      'desc': 'Ignoring your finances led to a score collapse.',
      'cibilDelta': -100,
      'cond': (c) => c.bankBalance < 0 && (c.age - c.lastActivityAge) > 3
    },
    {
      'title': '🔥 Aggressive Outburst',
      'desc': 'Your hot temper caused a scene at a local gathering. Social reputation hit.',
      'socialDelta': -20,
      'karmaDelta': -10,
      'cond': (c) => (c.personalityScores['Aggressive'] ?? 0) > 75 && (c.age % 5 == 0)
    },
    {
      'title': '😴 Procrastination Peak',
      'desc': 'Your lazy habits meant you missed a major growth window. Smarts and Momentum dropped.',
      'smartsDelta': -10,
      'happinessDelta': 5,
      'cond': (c) => (c.personalityScores['Lazy'] ?? 0) > 80 && (c.age % 4 == 0)
    },
    {
      'title': '🛡️ Disciplined Savings',
      'desc': 'Your disciplined nature automatically set aside extra savings this year.',
      'moneyDelta': 15000.0,
      'happinessDelta': 2,
      'cond': (c) => (c.personalityScores['Disciplined'] ?? 0) > 75 && c.bankBalance > 50000 && (c.age % 6 == 0)
    },
    {
      'title': '🌀 Emotional Spiral',
      'desc': 'A wave of intense emotions led to a week of overspending and social withdrawal.',
      'moneyDelta': -5000.0,
      'socialDelta': -10,
      'cond': (c) => (c.personalityScores['Emotional'] ?? 0) > 80 && (c.age % 7 == 0)
    },
    {
      'title': '🧠 Logical Investment',
      'desc': 'Your logical mind identified a small fee leak and plugged it. Efficiency up!',
      'moneyDelta': 2500.0,
      'smartsDelta': 2,
      'cond': (c) => (c.personalityScores['Logical'] ?? 0) > 75 && (c.age % 8 == 0)
    }
  ];

  static List<String> getEventsForAge(int age) {
    // Legacy support for basic random messages
    if (age < 13) return ['Started school.', 'Played gully cricket.', 'Nani made sweets.'];
    if (age < 18) return ['Board exam pressure.', 'First crush.', 'Gym motivation.'];
    return ['Office routine.', 'Commute struggle.', 'Evening chai.'];
  }
}
