import 'events/data/military_events.dart';
import 'events/data/career_events.dart';
import 'events/data/education_events.dart';
import 'events/data/scholarship_events.dart';
import 'events/data/politics_events.dart';
import 'events/data/influencer_events.dart';
import 'events/data/freelance_events.dart';
import 'events/data/relationship_events.dart';
import 'events/data/family_events.dart';
import 'events/data/health_events.dart';
import 'events/data/business_events.dart';
import 'events/data/crime_events.dart';
import 'events/data/sports_events.dart';
import 'events/data/misc_events.dart';
import 'events/data/premium_phase2_events.dart';
import '../models/smart_event.dart';

// lib/core/event_data.dart

class EventData {
  // Removed unused _avgBond

  // Unified Smart Event System
  static final List<SmartEvent> allSmartEvents = [
    ...militaryEvents,
    ...careerEvents,
    ...educationEvents,
    ...scholarshipEvents,
    ...politicsEvents,
    ...influencerEvents,
    ...freelanceEvents,
    ...relationshipEvents,
    ...familyEvents,
    ...healthEvents,
    ...businessEvents,
    ...crimeEvents,
    ...sportsEvents,
    ...premiumPhase2Events,
    ...miscEvents,
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
    },
    {
      'title': 'Startup Dream',
      'desc': 'You have an idea for a revolutionary app. Your friend wants to co-found.',
      'type': 'Career',
      'cond': (c) => c.age >= 22 && c.age <= 35 && c.smarts > 70,
      'weight': 10,
      'choice': {
        'title': 'Start a Business?',
        'desc': 'It will require ₹5,00,000 and your full focus.',
        'optionA': 'Go For It',
        'optionB': 'Stay Employed',
        'effectA': {'money': -500000.0, 'happiness': -10, 'stressLevel': 30, 'smarts': 10},
        'effectB': {'happiness': 5, 'jobPerformance': 10},
        'resultA': 'You are now an entrepreneur! The first few months are brutal but exciting.',
        'resultB': 'You chose stability. You are progressing in your career, but you wonder "what if?".',
        'memoryFlagA': 'startup_founder',
      }
    },
    {
      'title': 'Office Politics',
      'desc': 'A colleague is spreading rumors about you to the manager.',
      'type': 'Career',
      'cond': (c) => c.annualIncome > 0 && c.age > 24,
      'weight': 12,
      'choice': {
        'title': 'The Rumor Mill',
        'desc': 'How do you handle the sabotage?',
        'optionA': 'Confront Them',
        'optionB': 'Work Harder',
        'effectA': {'social': -10, 'karma': -5, 'stressLevel': 15, 'reputation': 10},
        'effectB': {'jobPerformance': 15, 'stressLevel': 20, 'happiness': -10},
        'resultA': 'You had a heated argument. The office is tense, but the rumors stopped.',
        'resultB': 'You ignored the noise. Your manager noticed your focus, but you feel isolated.',
        'memoryFlagA': 'office_fighter',
      }
    },
    {
      'title': 'The Mid-Life Crisis',
      'desc': 'You feel like life is passing you by. You want a major change.',
      'type': 'Drama',
      'cond': (c) => c.age >= 40 && c.age <= 50 && c.happiness < 50,
      'weight': 15,
      'choice': {
        'title': 'Reinvent Yourself?',
        'desc': 'You could quit everything and travel, or just buy a sports car.',
        'optionA': 'Buy a Luxury Car',
        'optionB': 'Seek Therapy',
        'effectA': {'money': -2500000.0, 'happiness': 30, 'looks': 10},
        'effectB': {'happiness': 15, 'smarts': 10, 'money': -50000.0},
        'resultA': 'You look cool in your new ride! Your bank balance is low, but your spirits are high.',
        'resultB': 'You are working through your issues. You feel more grounded and peaceful.',
        'memoryFlagA': 'midlife_car_buyer',
      }
    },
    {
      'title': 'Inheritance Conflict',
      'desc': 'A distant relative passed away, leaving a property. Your cousins are fighting for it.',
      'type': 'Family',
      'cond': (c) => c.age >= 45,
      'weight': 10,
      'choice': {
        'title': 'The Property War',
        'desc': 'Do you join the legal battle?',
        'optionA': 'Fight for Share',
        'optionB': 'Let it Go',
        'effectA': {'money': -100000.0, 'karma': -20, 'social': -30, 'stressLevel': 25},
        'effectB': {'karma': 20, 'happiness': 10, 'social': 10},
        'resultA': 'You are locked in a court case. Family dinners are a thing of the past.',
        'resultB': 'You chose peace over property. Your relatives respect your dignity.',
        'memoryFlagA': 'property_warrior',
      }
    },
    {
      'title': 'The Borrowed Charger',
      'desc': 'Your sibling took your fast-charger and "lost" it.',
      'type': 'Drama',
      'cond': (c) => c.age >= 10 && c.age <= 22,
      'weight': 10,
      'choice': {
        'title': 'Sibling War?',
        'desc': 'They claim it was already broken.',
        'optionA': 'Forgive Them',
        'optionB': 'Demand a New One',
        'effectA': {'karma': 10, 'happiness': -5},
        'resultA': 'You are a saint. They will probably lose your earphones next week.',
        'effectB': {'social': -10, 'stressLevel': 10},
        'resultB': 'A week-long cold war has started. Dinner time is extremely awkward.',
      }
    },
    {
      'title': 'The Gym Motivation',
      'desc': 'A friend called you "chubby" in a funny way.',
      'type': 'Drama',
      'cond': (c) => c.age > 18 && c.looks < 50,
      'weight': 8,
      'choice': {
        'title': 'Handle the Roast',
        'desc': 'Everyone laughed.',
        'optionA': 'Laugh it off',
        'optionB': 'Start a strict diet',
        'effectA': {'social': 10, 'happiness': 5},
        'resultA': 'You are a good sport. Your confidence is noted.',
        'effectB': {'looks': 10, 'happiness': -15, 'stressLevel': 20},
        'resultB': 'You are starving and miserable, but you look slightly sharper.',
      }
    },
    {
      'title': 'Children Marriage Pressure',
      'desc': 'Your child is of age, and society is asking "when?".',
      'type': 'Family',
      'cond': (c) => c.age >= 50 && c.age <= 60,
      'weight': 15,
      'choice': {
        'title': 'The Big Fat Wedding',
        'desc': 'Should you spend your life savings on a grand celebration?',
        'optionA': 'Spend Lavishly',
        'optionB': 'Keep it Simple',
        'effectA': {'money': -5000000.0, 'social': 40, 'happiness': 20},
        'effectB': {'money': -500000.0, 'social': -20, 'happiness': 5},
        'resultA': 'The whole city talked about the wedding! You are broke, but famous.',
        'resultB': 'A quiet ceremony. Some relatives are annoyed, but your retirement is safe.',
        'memoryFlagA': 'lavish_spender',
      }
    },
    {
      'title': 'The Comparison',
      'desc': 'A visiting relative just won\'t stop talking about Sharma ji ka beta\'s new promotion.',
      'type': 'Family',
      'cond': (c) => c.age >= 20 && c.age <= 40,
      'weight': 8,
      'choice': {
        'title': 'The Comparison',
        'desc': '"He is already a VP, and you are still in middle management..."',
        'optionA': 'Nod and Smile',
        'optionB': 'Defend Yourself',
        'effectA': {'happiness': -15, 'karma': 5, 'social': 5},
        'effectB': {'happiness': -5, 'karma': -10, 'social': -10, 'stressLevel': 10},
        'resultA': 'You swallowed your pride. Your parents are happy with your "maturity", but you feel bitter.',
        'resultB': 'You told them to worry about their own kids. The dinner ended abruptly.',
        'memoryFlagB': 'sharma_ji_rivalry',
      }
    },
    {
      'title': 'Parental Support',
      'desc': 'Your parents are growing old and having trouble living alone. They want to move in with you.',
      'type': 'Family',
      'cond': (c) => c.age >= 40 && c.age <= 55,
      'weight': 10,
      'choice': {
        'title': 'Elder Care',
        'desc': 'This will affect your privacy and finances, but it is your duty.',
        'optionA': 'Bring them Home',
        'optionB': 'Hire a Nurse',
        'effectA': {'happiness': 20, 'karma': 40, 'money': -300000.0, 'social': 15, 'stressLevel': 15},
        'effectB': {'happiness': -10, 'karma': -20, 'money': -150000.0, 'social': -10},
        'resultA': 'The house is noisy but full of love. Your parents are well-cared for.',
        'resultB': 'You are paying for their care, but you feel the distance. They sound lonely on the phone.',
        'memoryFlagA': 'dutiful_child',
      }
    },
    {
      'title': 'Risky Crypto Tip',
      'desc': 'A "finance guru" on WhatsApp is promising 10x returns on a new coin.',
      'type': 'Financial',
      'cond': (c) => c.bankBalance > 50000 && c.age > 18,
      'weight': 7,
      'choice': {
        'title': 'To the Moon?',
        'desc': 'It sounds like a scam, but what if it isn\'t?',
        'optionA': 'Invest ₹50k',
        'optionB': 'Report & Ignore',
        'effectA': {'money': -50000.0, 'karma': -5, 'smarts': -10},
        'effectB': {'smarts': 10, 'happiness': 5},
        'resultA': 'The coin went to zero in 24 hours. You got "rugged".',
        'resultB': 'You saved your money. A few days later, you saw news of the scam bust.',
        'memoryFlagA': 'crypto_victim',
      },
    },
    {
      'title': 'The Public Slip',
      'desc': 'You slipped on a banana peel in the middle of a busy mall. Everyone saw it.',
      'type': 'Drama',
      'cond': (c) => c.age > 10,
      'weight': 5,
      'choice': {
        'title': 'Social Disaster',
        'desc': 'How do you handle the embarrassment?',
        'optionA': 'Laugh it Off',
        'optionB': 'Run Away',
        'effectA': {'social': 5, 'happiness': -5, 'karma': 10},
        'effectB': {'social': -20, 'happiness': -15},
        'resultA': 'You made a joke out of it. People laughed with you, not at you.',
        'resultB': 'You bolted for the exit. You are now "the banana guy" in your local WhatsApp group.',
        'memoryFlagB': 'banana_peel_victim',
      }
    },
    {
      'title': 'Job Burnout',
      'desc': 'The 70-hour weeks are killing you. You haven\'t seen the sun in days.',
      'type': 'Career',
      'cond': (c) => c.annualIncome > 0 && c.stressLevel > 70,
      'weight': 15,
      'choice': {
        'title': 'Hitting the Wall',
        'desc': 'Your health is failing. What do you do?',
        'optionA': 'Take a Sabbatical',
        'optionB': 'Push Through',
        'effectA': {'happiness': 20, 'health': 15, 'money': -100000.0, 'jobPerformance': -20},
        'effectB': {'health': -20, 'happiness': -30, 'jobPerformance': 10, 'stressLevel': 20},
        'resultA': 'You took a break. You feel alive again, but your career momentum has stalled.',
        'resultB': 'You kept working. You are a star performer, but you feel like a ghost.',
        'memoryFlagA': 'took_sabbatical',
      }
    },
    {
      'title': 'Viral Video',
      'desc': 'A video of you doing something silly went viral on the internet!',
      'type': 'Drama',
      'cond': (c) => c.age > 15,
      'weight': 6,
      'choice': {
        'title': 'Internet Fame',
        'desc': 'Do you embrace the fame or try to delete it?',
        'optionA': 'Become an Influencer',
        'optionB': 'Ignore the Noise',
        'effectA': {'fame': 30, 'money': 50000.0, 'social': 20, 'smarts': -10},
        'effectB': {'fame': -5, 'happiness': 5},
        'resultA': 'You are now a minor celebrity! You get free samples but no privacy.',
        'resultB': 'The internet moved on in three days. Your dignity remains intact.',
        'memoryFlagA': 'viral_influencer',
      }
    },
    // --- LATE LIFE REFLECTIONS (60+) ---
    {
      'title': 'The Empty Nest',
      'desc': 'The house feels quiet. Your children are busy with their own lives now.',
      'type': 'Family',
      'cond': (c) => c.age > 60 && c.memories.containsKey('married'),
      'weight': 15,
      'choice': {
        'title': 'Lonely Halls',
        'desc': 'How do you process the silence?',
        'optionA': 'Call Them Daily',
        'optionB': 'Find a Hobby',
        'effectA': {'happiness': 5, 'social': 10, 'stressLevel': 10},
        'effectB': {'happiness': 15, 'smarts': 5, 'social': -5},
        'resultA': 'They sound busy, but they appreciate the call. You feel a bit needy.',
        'resultB': 'You started gardening. The soil doesn\'t talk back, but it is peaceful.',
        'memoryFlagB': 'gardening_elder',
      }
    },
    {
      'title': 'The Will & Legacy',
      'desc': 'You are thinking about your estate and how you will be remembered.',
      'type': 'Family',
      'cond': (c) => c.age > 70 && c.bankBalance > 1000000,
      'weight': 12,
      'choice': {
        'title': 'Final Wishes',
        'desc': 'Do you divide it equally or favor the one who cared for you?',
        'optionA': 'Divide Equally',
        'optionB': 'Reward the Caretaker',
        'effectA': {'karma': 20, 'social': 10},
        'effectB': {'karma': -10, 'social': -30, 'happiness': 10},
        'resultA': 'Fairness above all. Your family is at peace, even if the sums are smaller.',
        'resultB': 'You left more to the one who stayed. The others are furious.',
        'memoryFlagA': 'fair_patriarch',
      }
    },
    {
      'title': 'Old Rivalry Reconciliation',
      'desc': 'An old rival from your school days reached out. They are ill and want to talk.',
      'type': 'Drama',
      'cond': (c) => c.age > 65 && c.memories.containsKey('school_fighter'),
      'weight': 10,
      'choice': {
        'title': 'Forgiveness?',
        'desc': 'The grudges of youth seem so small now.',
        'optionA': 'Visit Them',
        'optionB': 'Let the Past Stay Past',
        'effectA': {'karma': 50, 'happiness': 20, 'social': 10},
        'effectB': {'happiness': -5, 'karma': -10},
        'resultA': 'You shared a cup of tea and a long laugh. The weight of the grudge is gone.',
        'resultB': 'You didn\'t go. Some things can\'t be mended, or so you tell yourself.',
        'memoryFlagA': 'forgiving_soul',
      }
    },
    // --- TEMPTATION & ECHO EVENTS ---
    {
      'title': 'Insider Tip',
      'desc': 'A cousin working at a major firm hints that their stock is about to double.',
      'type': 'Financial',
      'cond': (c) => c.bankBalance > 200000 && c.age > 25,
      'weight': 5,
      'choice': {
        'title': 'Insider Trading?',
        'desc': 'This is highly illegal, but the money is guaranteed... or is it?',
        'optionA': 'Invest Everything',
        'optionB': 'Report to SEBI',
        'successChanceA': 0.8,
        'hiddenRiskA': true,
        'isTemptation': true,
        'effectA': {'money': 1000000.0, 'karma': -60, 'reputation': -20},
        'resultA': 'The stock skyrocketed! You made a fortune, but you check every unknown call with fear.',
        'effectAFail': {'money': -200000.0, 'karma': -80, 'reputation': -90, 'happiness': -50},
        'resultAFail': 'It was a sting operation! Your accounts are frozen and you\'re facing jail time.',
        'effectB': {'karma': 40, 'reputation': 30, 'happiness': 10},
        'resultB': 'You did the right thing. The cousin was arrested, and you were praised for your integrity.',
        'memoryFlagA': 'insider_trader',
        'memoryFlagB': 'whistleblower',
      }
    },
    // --- LIFESTYLE & NARRATIVE POLISH ---
    // FAMILY FOCUSED
    {
      'title': 'The Sunday Feast',
      'desc': 'You cooked a massive meal for the whole family. Their smiles are your greatest reward.',
      'type': 'Neutral',
      'cond': (c) => c.age > 30,
      'weight': 3,
      'effect': {'happiness': 15}
    },
    {
      'title': 'Sibling Reunion',
      'desc': 'You spent the afternoon reminiscing with your sibling. The old grudges feel like another life.',
      'type': 'Neutral',
      'cond': (c) => c.age > 40,
      'weight': 3,
      'effect': {'happiness': 10, 'social': 5}
    },
    // HOPEFUL / SPIRITUAL
    {
      'title': 'Morning Prayers',
      'desc': 'The early morning sunlight in the puja room felt like a blessing. You feel peaceful.',
      'type': 'Neutral',
      'cond': (c) => c.karma > 70 && c.age > 50,
      'weight': 3,
      'effect': {'happiness': 10, 'stressLevel': -10}
    },
    {
      'title': 'Nature Walk',
      'desc': 'The park was beautiful today. You feel connected to something larger than yourself.',
      'type': 'Neutral',
      'cond': (c) => c.happiness > 70,
      'weight': 3,
      'effect': {'happiness': 5, 'health': 2}
    },
    // REGRETFUL / LATE LIFE
    {
      'title': 'Empty Nest',
      'desc': 'The house is so quiet now that the kids have moved out. You miss the noise.',
      'type': 'Neutral',
      'cond': (c) => c.age > 55,
      'weight': 4,
      'effect': {'happiness': -10}
    },
    {
      'title': 'Legacy Doubt',
      'desc': 'You wondered today if you made any real difference in the world. The answer was unclear.',
      'type': 'Neutral',
      'cond': (c) => c.age > 65 && c.happiness < 40,
      'weight': 3,
      'effect': {'happiness': -15}
    },
    // MIDDLE CLASS EMI STRESS
    {
      'title': 'EMI Date',
      'desc': 'The home loan EMI was deducted today. Your bank balance looks lonely.',
      'type': 'Financial',
      'tier': 'Middle',
      'cond': (c) => c.lifestyleTier == 'Middle' && c.age > 30,
      'weight': 5,
      'effect': {'money': -45000.0, 'stressLevel': 15}
    },
    // UPPER CLASS IMAGE PRESSURE
    {
      'title': 'Public Reputation',
      'desc': 'Your name appeared in a local business magazine. The pressure to stay successful is immense.',
      'type': 'Financial',
      'tier': 'Upper',
      'cond': (c) => c.lifestyleTier == 'Upper' && c.fame > 50,
      'weight': 4,
      'effect': {'stressLevel': 20, 'fame': 5}
    },

    // ─── 30+ PREMIUM ATMOSPHERIC REFLECTIONS (NOSTALGIA, EMPTY SUCCESS, PEACE, SPIRITUAL, FAMILY, LONELINESS, FADING AMBITION) ───
    
    // NOSTALGIA
    {
      'title': 'Paper Boats',
      'desc': 'You spent an hour making paper boats during the monsoon rains, watching them sail down the flooded alley. A wave of childhood simplicity washed over you.',
      'type': 'Neutral',
      'cond': (c) => c.age >= 5 && c.age <= 25,
      'weight': 4,
      'effect': {'happiness': 15, 'stressLevel': -10}
    },
    {
      'title': 'Gully Cricket Memories',
      'desc': 'The familiar sound of children arguing over a "one-bounce-out" rule in the street brought a nostalgic smile to your face. You miss those carefree afternoons.',
      'type': 'Neutral',
      'cond': (c) => c.age >= 20 && c.age <= 60,
      'weight': 4,
      'effect': {'happiness': 10, 'stressLevel': -5}
    },
    {
      'title': 'Cassette Tape Memories',
      'desc': 'You found an old, dusty audio cassette of 90s Bollywood hits in the attic. Humming along to the crackling music, you felt a sweet pang of nostalgia.',
      'type': 'Neutral',
      'cond': (c) => c.age >= 30 && c.age <= 70,
      'weight': 3,
      'effect': {'happiness': 12, 'stressLevel': -8}
    },
    {
      'title': 'Old School Photo',
      'desc': 'Looking at a faded class photograph, you realized you could only remember half of the names. Time is a silent river, carrying away everything in its flow.',
      'type': 'Neutral',
      'cond': (c) => c.age >= 35,
      'weight': 3,
      'effect': {'happiness': 5, 'stressLevel': 5}
    },
    {
      'title': "Nani's Kitchen Aroma",
      'desc': 'The aroma of roasted cardamom and ghee from a neighbor\'s kitchen instantly transported you back to your grandmother\'s house during childhood summer vacations.',
      'type': 'Neutral',
      'cond': (c) => c.age >= 15,
      'weight': 4,
      'effect': {'happiness': 15, 'stressLevel': -10}
    },

    // SUCCESS EMPTINESS
    {
      'title': 'The High-Rise View',
      'desc': 'Looking down from the glass office window at the bustling city below, your accomplishments felt immense, yet curiously hollow. You wondered who you are outside of work.',
      'type': 'Neutral',
      'tier': 'Upper',
      'cond': (c) => c.lifestyleTier == 'Upper' && c.age >= 25,
      'weight': 4,
      'effect': {'happiness': -5, 'stressLevel': 10}
    },
    {
      'title': 'Late-Night Takeout',
      'desc': 'Sitting in an empty, silent conference room at 10 PM eating cold takeout, you wondered if this corporate race is truly what you wanted.',
      'type': 'Neutral',
      'tier': 'Middle',
      'cond': (c) => c.lifestyleTier == 'Middle' && c.age >= 24,
      'weight': 4,
      'effect': {'happiness': -10, 'stressLevel': 12}
    },
    {
      'title': 'Unopened Luxury',
      'desc': 'Multiple expensive online delivery boxes sat unopened at your door. You realized buying things has completely stopped bringing you any real excitement.',
      'type': 'Neutral',
      'tier': 'Upper',
      'cond': (c) => c.lifestyleTier == 'Upper' && c.age >= 30,
      'weight': 3,
      'effect': {'happiness': -10, 'stressLevel': 5}
    },
    {
      'title': 'The Silent Suite',
      'desc': 'Your luxury hotel room was absolutely perfect, but the complete silence made you miss the noisy, chaotic family dinners of your childhood.',
      'type': 'Neutral',
      'tier': 'Upper',
      'cond': (c) => c.lifestyleTier == 'Upper' && c.age >= 30,
      'weight': 3,
      'effect': {'happiness': -8, 'stressLevel': 5}
    },
    {
      'title': 'Chasing the Horizon',
      'desc': 'You hit another financial milestone today, but instead of celebrating, you immediately started planning the next target. The horizon keeps shifting, endlessly.',
      'type': 'Neutral',
      'tier': 'Upper',
      'cond': (c) => c.lifestyleTier == 'Upper' && c.age >= 28,
      'weight': 3,
      'effect': {'stressLevel': 15, 'happiness': -5}
    },

    // PEACE & SPIRITUAL CALM
    {
      'title': 'Evening Sitar Raga',
      'desc': 'Listening to a classical sitar recital in the evening, the loud, chaotic noise of the city seemed to completely dissolve. You feel deeply centered.',
      'type': 'Neutral',
      'cond': (c) => c.age >= 20,
      'weight': 4,
      'effect': {'happiness': 15, 'stressLevel': -15}
    },
    {
      'title': 'Puja Lamp Glow',
      'desc': 'Watching the tiny, steady flame of the ghee diya in the quiet morning puja room, you felt an anchor of deep inner peace that no daily stress can touch.',
      'type': 'Neutral',
      'cond': (c) => c.age >= 22,
      'weight': 4,
      'effect': {'happiness': 12, 'stressLevel': -12}
    },
    {
      'title': 'Temple Bell Echo',
      'desc': 'The deep, resonant sound of the evening temple bell seemed to clear your mind of all weekly worries, leaving a peaceful silence in its wake.',
      'type': 'Neutral',
      'cond': (c) => c.age >= 18,
      'weight': 4,
      'effect': {'happiness': 10, 'stressLevel': -10}
    },
    {
      'title': 'Monsoon Tea Reflection',
      'desc': 'Sitting on the balcony with a warm cup of ginger tea as the monsoon rain washed the dusty trees clean, you felt entirely content with the present moment.',
      'type': 'Neutral',
      'cond': (c) => c.age >= 12,
      'weight': 5,
      'effect': {'happiness': 15, 'stressLevel': -12}
    },
    {
      'title': 'Quiet Balcony Garden',
      'desc': 'You spent the morning tending to the small potted plants on your balcony, feeling a simple, grounding connection to the earth and growth.',
      'type': 'Neutral',
      'cond': (c) => c.age >= 25,
      'weight': 4,
      'effect': {'happiness': 10, 'stressLevel': -8}
    },

    // FAMILY WARMTH
    {
      'title': 'Midnight Tea Talks',
      'desc': 'Staying up late with your family over hot cups of cardamom chai, sharing secrets and laughing at old jokes. These are the moments that truly matter.',
      'type': 'Neutral',
      'cond': (c) => c.age >= 16,
      'weight': 5,
      'effect': {'happiness': 20, 'social': 10}
    },
    {
      'title': 'Quiet Maternal Touch',
      'desc': 'Your mother placed a warm hand on your shoulder without saying a single word. In that quiet gesture, you felt completely safe and understood.',
      'type': 'Neutral',
      'cond': (c) => c.age >= 10 && c.age <= 40,
      'weight': 4,
      'effect': {'happiness': 15, 'stressLevel': -10}
    },
    {
      'title': "Child's Pure Laughter",
      'desc': 'The simple sound of a child laughing and playing in the living room made all the stress of your career and bills vanish instantly.',
      'type': 'Neutral',
      'cond': (c) => c.age >= 22,
      'weight': 4,
      'effect': {'happiness': 18, 'stressLevel': -12}
    },
    {
      'title': 'Warm Winter Shawl',
      'desc': 'Your partner wrapped a warm wool shawl around you on a chilly winter evening. The silent affection in the gesture was warmer than the fabric.',
      'type': 'Neutral',
      'cond': (c) => c.age >= 22,
      'weight': 4,
      'effect': {'happiness': 15, 'stressLevel': -8}
    },
    {
      'title': 'Three Generations',
      'desc': 'Watching your parents tell ancient mythological stories to the younger children, you realized the beautiful, unbroken continuity of family life.',
      'type': 'Neutral',
      'cond': (c) => c.age >= 35,
      'weight': 4,
      'effect': {'happiness': 15, 'social': 5}
    },

    // LONELINESS & EXISTENTIAL THOUGHTS
    {
      'title': 'Crowded Metro',
      'desc': 'Surrounded by hundreds of silent commuters in the packed metro train during rush hour, you felt a profound, heavy sense of isolation.',
      'type': 'Neutral',
      'cond': (c) => c.age >= 18,
      'weight': 4,
      'effect': {'happiness': -8, 'stressLevel': 5}
    },
    {
      'title': 'Terrace Stargazing',
      'desc': 'Standing on the concrete terrace under the vast, uncaring night sky, your daily struggles and fears felt beautifully, comfortingly small.',
      'type': 'Neutral',
      'cond': (c) => c.age >= 14,
      'weight': 4,
      'effect': {'happiness': 5, 'stressLevel': -10}
    },
    {
      'title': 'Unanswered Midnight Calls',
      'desc': 'You scrolled through your phone contact list at midnight, realizing there wasn\'t a single person you felt comfortable calling to share your heavy thoughts.',
      'type': 'Neutral',
      'cond': (c) => c.age >= 20,
      'weight': 4,
      'effect': {'happiness': -12}
    },
    {
      'title': 'Rain on the Glass',
      'desc': 'Watching raindrops slide down the windowpane, you pondered the fleeting nature of friendships and how easily people drift apart over time.',
      'type': 'Neutral',
      'cond': (c) => c.age >= 16,
      'weight': 4,
      'effect': {'happiness': -8}
    },
    {
      'title': 'The Empty Chair',
      'desc': 'Seeing the empty chair of a loved one who passed away, you realized that the most difficult part of aging is the silent spaces left behind in our lives.',
      'type': 'Neutral',
      'cond': (c) => c.age >= 40,
      'weight': 4,
      'effect': {'happiness': -15}
    },

    // FADING AMBITION & AGE ACCEPTANCE
    {
      'title': 'Dusty College Dreams',
      'desc': 'You looked at your old college guitar and sketchbook in the cupboard, realizing you haven\'t touched them in years. The fiery dreams of youth have quietly retired.',
      'type': 'Neutral',
      'cond': (c) => c.age >= 30,
      'weight': 3,
      'effect': {'happiness': -5, 'stressLevel': -5}
    },
    {
      'title': 'Letting Ambition Go',
      'desc': 'You decided not to apply for a highly competitive promotion, choosing instead to protect your evenings and peace of mind. Ambition is giving way to peace.',
      'type': 'Neutral',
      'cond': (c) => c.age >= 40,
      'weight': 4,
      'effect': {'happiness': 10, 'stressLevel': -15}
    },
    {
      'title': 'The Cooling Fire',
      'desc': 'The intense competitive fire that once drove you to work 80 hours a week seems to have gently cooled into a mature desire for simple comfort and quiet.',
      'type': 'Neutral',
      'cond': (c) => c.age >= 45,
      'weight': 4,
      'effect': {'happiness': 8, 'stressLevel': -12}
    },
    {
      'title': 'Mirror Reflection',
      'desc': 'You looked in the mirror and smiled at a new streak of grey hair, fully accepting that you don\'t need to conquer the world to have a meaningful life.',
      'type': 'Neutral',
      'cond': (c) => c.age >= 50,
      'weight': 4,
      'effect': {'happiness': 12, 'stressLevel': -10}
    },
    {
      'title': 'Passing the Torch',
      'desc': 'Watching younger colleagues speak with fiery ambition during meetings, you felt a peaceful, mature satisfaction in stepping back and letting them lead.',
      'type': 'Neutral',
      'cond': (c) => c.age >= 55,
      'weight': 4,
      'effect': {'happiness': 10, 'stressLevel': -8}
    },
    
    // HIGH-STATUS LIFE ATMOSPHERE
    {
      'title': 'Elite Charity Gala',
      'desc': 'You attended a high-society charity auction. Every eye was on you, and a local reporter requested an exclusive interview.',
      'type': 'Neutral',
      'tier': 'Upper',
      'cond': (c) => c.lifestyleTier == 'Upper' && c.fame > 70,
      'weight': 6,
      'effect': {'reputation': 10, 'stressLevel': 10, 'fame': 5}
    },
    {
      'title': 'Paparazzi Disturbance',
      'desc': 'Photographers followed you as you exited a fine-dining restaurant. The price of fame is the loss of quiet moments.',
      'type': 'Neutral',
      'tier': 'Upper',
      'cond': (c) => c.lifestyleTier == 'Upper' && c.fame > 80,
      'weight': 6,
      'effect': {'stressLevel': 15, 'happiness': -5}
    },
    {
      'title': 'VIP Networking Invitation',
      'desc': 'You received a gold-embossed invitation to an exclusive weekend retreat with prominent politicians and industry leaders.',
      'type': 'Neutral',
      'tier': 'Upper',
      'cond': (c) => c.lifestyleTier == 'Upper' && c.bankBalance > 10000000,
      'weight': 5,
      'effect': {'social': 15, 'reputation': 8}
    },
  ];

  static List<String> getEventsForAge(int age) {
    // Legacy support for basic random messages
    if (age < 13) return ['Started school.', 'Played gully cricket.', 'Nani made sweets.'];
    if (age < 18) return ['Board exam pressure.', 'First crush.', 'Gym motivation.'];
    return ['Office routine.', 'Commute struggle.', 'Evening chai.'];
  }
}
