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
    // --- UNEXPECTED CAREER OFFERS (ADDENDUM 5) ---
    {
      'title': 'Political Mentorship',
      'desc': 'A veteran political leader noticed your influence in the community. They are offering you a chance to join their party and start a political career.',
      'type': 'Career',
      'cond': (c) => c.age >= 25 && c.careerGroup != 'Politician' && c.social > 70 && c.karma > 60,
      'weight': 5,
      'choice': {
        'title': 'Political Offer',
        'desc': 'This will replace your current career.',
        'optionA': 'Join Politics',
        'optionB': 'Decline Politely',
        'gameActionA': 'career.special.apply::Politician',
        'effectA': {'reputation': 10},
        'effectB': {'happiness': 5},
        'resultA': 'You stepped into the turbulent world of politics!',
        'resultB': 'You decided to stay out of the mud.',
      }
    },
    {
      'title': 'Military Recommendation',
      'desc': 'A retired army officer was impressed by your discipline during a community crisis. He is willing to recommend you for military officer training.',
      'type': 'Career',
      'cond': (c) => c.age >= 18 && c.age <= 25 && c.careerGroup != 'Military' && c.health > 70,
      'weight': 5,
      'choice': {
        'title': 'Military Offer',
        'desc': 'This will replace your current career.',
        'optionA': 'Enlist in Military',
        'optionB': 'Decline Offer',
        'gameActionA': 'career.apply_group::Military',
        'effectA': {'discipline': 10},
        'effectB': {'happiness': 5},
        'resultA': 'You packed your bags for the academy!',
        'resultB': 'You thanked him but declined.',
      }
    },
    // --- EMOTIONAL MEMORY ECHOES ---
    {
      'title': 'Father\'s Pride',
      'desc': 'Years after your selection, you overhear your father bragging to a neighbor: "Mera beta officer hai!" (My son is an officer!). His chest is swelling with pride.',
      'type': 'Emotional',
      'cond': (c) => c.age >= 25 && c.memories.containsKey('passed_UPSC'),
      'weight': 15,
      'choice': {
        'title': 'React to Father',
        'desc': 'Will you feel proud or stay humble?',
        'optionA': 'Feel Proud',
        'optionB': 'Stay Humble',
        'effectA': {'happiness': 15},
        'effectB': {'happiness': 10, 'karma': 5},
        'resultA': 'You feel a deep sense of accomplishment.',
        'resultB': 'You smiled and touched his feet.',
      }
    },
    {
      'title': 'The Dim Library Lights',
      'desc': 'You pass by a library late at night and see students studying. You remember the years you spent doing the same for UPSC, before you failed.',
      'type': 'Emotional',
      'cond': (c) => c.age >= 30 && c.memories.containsKey('attempted_UPSC') && !c.memories.containsKey('passed_UPSC'),
      'weight': 15,
      'choice': {
        'title': 'Reflect on Past',
        'desc': 'Do you regret the years or cherish the effort?',
        'optionA': 'Regret the Years',
        'optionB': 'Cherish the Effort',
        'effectA': {'happiness': -10},
        'effectB': {'happiness': 5, 'smarts': 5},
        'resultA': 'A wave of sadness washes over you.',
        'resultB': 'You realize that struggle made you who you are today.',
      }
    },

    // --- COLLEGE SOCIALIZATION ---
    {
      'title': 'Hostel Roommate Drama',
      'desc': 'Your hostel roommate is playing music loudly late at night while you are trying to sleep before a class.',
      'type': 'College',
      'cond': (c) => c.age >= 19 && c.age <= 21 && c.educationLevel == 'Undergraduate',
      'weight': 20,
      'choice': {
        'title': 'React to Roommate',
        'desc': 'Will you ask them to stop or join them?',
        'optionA': 'Ask to Stop',
        'optionB': 'Join the Party',
        'effectA': {'stressLevel': -5},
        'effectB': {'happiness': 15, 'social': 10, 'smarts': -5},
        'resultA': 'They reluctantly turned it down.',
        'resultB': 'You had a great time and made memories, but missed the morning class.',
      }
    },

    // --- MID-LIFE DEPTH (45-60) ---
    {
      'title': 'Mid-Life Burnout',
      'desc': 'You wake up feeling a deep sense of exhaustion. The daily commute and routine tasks feel meaningless. You wonder what you sacrificed your youth for.',
      'type': 'Emotional',
      'cond': (c) => c.age >= 45 && c.age <= 55 && c.careerGroup != 'None',
      'weight': 20,
      'choice': {
        'title': 'Handle Burnout',
        'desc': 'Will you take a break or push through?',
        'optionA': 'Take a Break',
        'optionB': 'Push Through',
        'effectA': {'happiness': 10, 'stressLevel': -10},
        'effectB': {'stressLevel': 15, 'smarts': 5},
        'resultA': 'You took a few days off to reconnect with yourself.',
        'resultB': 'You kept working, but the feeling of emptiness grows.',
      }
    },

    // --- COLLEGE GRIND (19-21) ---
    {
      'title': 'Placement Anxiety',
      'desc': 'Companies are visiting campus for placements. The air is thick with tension as everyone wears formal clothes and carries resumes.',
      'type': 'College',
      'cond': (c) => c.age >= 20 && c.age <= 21 && c.educationLevel == 'Undergraduate',
      'weight': 20,
      'choice': {
        'title': 'Handle Placements',
        'desc': 'Will you focus on aptitude tests or mock interviews?',
        'optionA': 'Aptitude Prep',
        'optionB': 'Mock Interviews',
        'effectA': {'smarts': 10, 'stressLevel': 10},
        'effectB': {'social': 10, 'stressLevel': 10},
        'resultA': 'You cleared the written rounds easily.',
        'resultB': 'You impressed the HR with your communication.',
      }
    },
    {
      'title': 'CGPA Stress',
      'desc': 'The semester results are out. Your CGPA is not what you expected.',
      'type': 'College',
      'cond': (c) => c.age >= 19 && c.age <= 21 && c.educationLevel == 'Undergraduate',
      'weight': 20,
      'choice': {
        'title': 'React to Grades',
        'desc': 'Will you study harder or chill with friends?',
        'optionA': 'Study Harder',
        'optionB': 'Chill with Friends',
        'effectA': {'smarts': 10, 'happiness': -10},
        'effectB': {'happiness': 15, 'smarts': -5},
        'resultA': 'Your grades improved next semester.',
        'resultB': 'You had fun, but the stress remains.',
      }
    },

    // --- LATE LIFE PURPOSE (60+) ---
    {
      'title': 'Retirement Identity Crisis',
      'desc': 'You have retired from your job. The sudden silence is overwhelming. You miss the busy days.',
      'type': 'Emotional',
      'cond': (c) => c.age >= 60 && c.age <= 65,
      'weight': 20,
      'choice': {
        'title': 'Find New Purpose',
        'desc': 'Will you take up a hobby or mentor youngsters?',
        'optionA': 'Take Up Hobby',
        'optionB': 'Mentor Youngsters',
        'effectA': {'happiness': 10},
        'effectB': {'social': 10, 'karma': 10},
        'resultA': 'You started gardening. It brings you peace.',
        'resultB': 'Sharing your wisdom helped you feel valued.',
      }
    },
    {
      'title': 'Legacy Reflection',
      'desc': 'You sit on the porch looking at old photos. You wonder if you lived a good life.',
      'type': 'Emotional',
      'cond': (c) => c.age >= 70,
      'weight': 20,
      'choice': {
        'title': 'Reflect on Life',
        'desc': 'Focus on achievements or relationships?',
        'optionA': 'Focus on Achievements',
        'optionB': 'Focus on Relationships',
        'effectA': {'smarts': 5},
        'effectB': {'happiness': 10},
        'resultA': 'You are proud of what you built.',
        'resultB': 'You realize the people mattered most.',
      }
    },

    // --- UPSC PREP ATMOSPHERE ---
    {
      'title': 'Mukherjee Nagar Life',
      'desc': 'You are living in a tiny room in Delhi, surrounded by piles of books. The pressure of UPSC is immense.',
      'type': 'UPSC',
      'cond': (c) => c.memories.containsKey('upsc_prep') && !c.memories.containsKey('passed_UPSC'),
      'weight': 25,
      'choice': {
        'title': 'Daily Routine',
        'desc': 'Will you study 14 hours or take a walk?',
        'optionA': 'Study 14 Hours',
        'optionB': 'Take a Walk',
        'effectA': {'smarts': 15, 'stressLevel': 15},
        'effectB': {'happiness': 10, 'stressLevel': -10},
        'resultA': 'You covered a lot of syllabus but feel exhausted.',
        'resultB': 'A walk helped clear your head.',
      }
    },
    {
      'title': 'Relatively Asking',
      'desc': 'A relative asks your parents: "Beta ka selection kab hoga?" (When will he get selected?)',
      'type': 'UPSC',
      'cond': (c) => c.memories.containsKey('upsc_prep') && !c.memories.containsKey('passed_UPSC'),
      'weight': 25,
      'choice': {
        'title': 'Handle Relative',
        'desc': 'Ignore them or feel pressured?',
        'optionA': 'Ignore Them',
        'optionB': 'Feel Pressured',
        'effectA': {'happiness': 5, 'stressLevel': -5},
        'effectB': {'stressLevel': 15, 'happiness': -10},
        'resultA': 'You focused on your goals.',
        'resultB': 'The comparison hurt your confidence.',
      }
    },

    // --- STREAM-LOCKED EVENTS (20+) ---
    {
      'title': 'Engineering Burnout',
      'desc': 'The endless assignments and coding labs are taking a toll. You feel the burnout creeping in.',
      'type': 'Personal Growth',
      'cond': (c) => c.age >= 20 && c.age <= 25 && c.memories.containsKey('track_pcm'),
      'weight': 15,
      'choice': {
        'title': 'Handle Burnout',
        'desc': 'Will you push through or take a break?',
        'optionA': 'Push Through',
        'optionB': 'Take a Break',
        'effectA': {'smarts': 10, 'stressLevel': 15, 'happiness': -10},
        'effectB': {'happiness': 15, 'stressLevel': -10, 'smarts': -5},
        'resultA': 'You completed the project, but you feel exhausted.',
        'resultB': 'You feel refreshed, but your grades suffered slightly.',
      }
    },
    {
      'title': 'Hospital Duty Stress',
      'desc': 'Your night shift at the hospital was intense. A critical patient required all your attention.',
      'type': 'Medical',
      'cond': (c) => c.age >= 23 && c.age <= 30 && c.memories.containsKey('track_pcb'),
      'weight': 15,
      'choice': {
        'title': 'Handle the Pressure',
        'desc': 'How do you cope with the stress?',
        'optionA': 'Focus on Work',
        'optionB': 'Vent to Colleague',
        'effectA': {'smarts': 5, 'stressLevel': 10, 'karma': 5},
        'effectB': {'happiness': 10, 'stressLevel': -5, 'social': 5},
        'resultA': 'You saved the patient! But your own health is neglected.',
        'resultB': 'Sharing the burden helped you feel better.',
      }
    },

    // --- EXAM WAITING TENSION (18) ---
    {
      'title': 'The Agonizing Wait',
      'desc': 'It has been months since the exam. Every time the phone rings, your heart skips a beat thinking it is the results.',
      'type': 'Emotional',
      'cond': (c) => c.age == 18 && c.examResults.containsKey('pending_score'),
      'weight': 30,
      'choice': {
        'title': 'Cope with Anxiety',
        'desc': 'How do you handle the stress of waiting?',
        'optionA': 'Distract Yourself',
        'optionB': 'Obsess Over Cutoffs',
        'effectA': {'happiness': 10, 'stressLevel': -10},
        'effectB': {'stressLevel': 15, 'smarts': 5},
        'resultA': 'You played video games and hung out with friends. It helped.',
        'resultB': 'You analyzed every forum and past cutoff. You are more stressed now.',
      }
    },
    {
      'title': 'Nosy Relatives',
      'desc': 'A distant aunt calls and asks, "Beta, results kab aa rahe hain?" (When are the results coming?)',
      'type': 'Social',
      'cond': (c) => c.age == 18 && c.examResults.containsKey('pending_score'),
      'weight': 25,
      'choice': {
        'title': 'Respond to Aunt',
        'desc': 'How do you reply?',
        'optionA': 'Be Polite',
        'optionB': 'Give Short Answer',
        'effectA': {'karma': 5, 'stressLevel': 5},
        'effectB': {'happiness': 5, 'stressLevel': -5},
        'resultA': 'You talked politely, but felt drained.',
        'resultB': 'You said "Don\'t know" and hung up. Savage.',
      }
    },

    // --- CHILDHOOD DRAMA (5-16) ---
    {
      'title': 'School Rivalry',
      'desc': 'A classmate made fun of your grades in front of everyone.',
      'type': 'Drama',
      'cond': (c) => c.age >= 8 && c.age <= 14,
      'weight': 15,
      'choice': {
        'title': 'Handle the Bully',
        'desc': 'How will you respond to the public humiliation?',
        'optionA': 'Fight Back',
        'optionB': 'Ignore It',
        'successChanceA': 0.6,
        'effectA': {'social': 15, 'karma': -5},
        'resultA': 'You won the fight! Everyone in school knows not to mess with you.',
        'effectAFail': {'happiness': -20, 'health': -10, 'social': -10},
        'resultAFail': 'You got beaten up badly. The school was laughing as you limped to the nurse.',
        'effectB': {'happiness': -15, 'social': -5, 'karma': 5},
        'resultB': 'You walked away. You feel small, but you kept your record clean.',
        'memoryFlagA': 'school_fighter',
        'memoryFlagAFail': 'bullied_victim',
      }
    },
    {
      'title': 'Tuition Escape',
      'desc': 'Your friends are bunking tuition to play cricket.',
      'type': 'Drama',
      'cond': (c) => c.age >= 12 && c.age <= 16,
      'weight': 12,
      'choice': {
        'title': 'Bunk Class?',
        'desc': 'The Math teacher is strict, but the game is tempting.',
        'optionA': 'Join the Game',
        'optionB': 'Go to Tuition',
        'effectA': {'happiness': 20, 'smarts': -10, 'discipline': -15},
        'effectB': {'happiness': -10, 'smarts': 10, 'discipline': 15},
        'resultA': 'You hit a winning six! But your parents found out later.',
        'resultB': 'You aced the mock test, but missed the best game of the season.',
        'memoryFlagA': 'tuition_bunker',
      }
    },
    {
      'title': 'Sharma Ji ka Beta',
      'desc': 'Your neighbor topped the exams. Your parents are comparing you.',
      'type': 'Drama',
      'cond': (c) => c.age >= 10 && c.age <= 18,
      'weight': 10,
      'choice': {
        'title': 'The Comparison',
        'desc': '"Why can\'t you be like him?"',
        'optionA': 'Study Harder',
        'optionB': 'Rebel',
        'effectA': {'smarts': 15, 'happiness': -20, 'stressLevel': 20},
        'effectB': {'happiness': 10, 'smarts': -5, 'karma': -15, 'social': 5},
        'resultA': 'You spent the night studying. Your parents are pleased but you are exhausted.',
        'resultB': 'You told them marks don\'t define you. The house is silent now.',
        'memoryFlagB': 'rebellious_child',
      }
    },

    // --- CAREER DRAMA (22+) ---
    {
      'title': 'The Illegal Shortcut',
      'desc': 'A senior colleague offers to inflate your sales numbers.',
      'type': 'Career',
      'cond': (c) => c.annualIncome > 0 && c.age > 22,
      'weight': 8,
      'choice': {
        'title': 'Ethical Dilemma',
        'desc': 'This could mean a massive promotion or immediate firing.',
        'optionA': 'Take the Deal',
        'optionB': 'Refuse',
        'successChanceA': 0.7,
        'hiddenRiskA': true,
        'isTemptation': true,
        'effectA': {'money': 300000.0, 'karma': -40, 'reputation': -20, 'jobPerformance': 30},
        'resultA': 'The numbers went through! You got the bonus, but you live in fear of an audit.',
        'effectAFail': {'karma': -50, 'reputation': -60, 'jobPerformance': -100, 'happiness': -40},
        'resultAFail': 'You were caught immediately! You\'ve been fired and a police complaint was filed.',
        'effectB': {'karma': 20, 'reputation': 10, 'happiness': 5},
        'resultB': 'You kept your integrity. Your colleague was promoted instead.',
        'memoryFlagA': 'corrupt_worker',
        'memoryFlagAFail': 'caught_scamming',
      }
    },
    {
      'title': 'Office Romance',
      'desc': 'You have developed feelings for a colleague in your team.',
      'type': 'Career',
      'cond': (c) => c.annualIncome > 0 && c.age > 24 && c.social > 60,
      'weight': 7,
      'choice': {
        'title': 'Workplace Love',
        'desc': 'Relationships are discouraged in the office.',
        'optionA': 'Pursue It',
        'optionB': 'Stay Professional',
        'effectA': {'happiness': 25, 'social': 10, 'jobPerformance': -15, 'stressLevel': 10},
        'effectB': {'happiness': -10, 'jobPerformance': 10, 'discipline': 5},
        'resultA': 'You are dating! Every meeting feels like a secret mission.',
        'resultB': 'You kept your distance. You are focused, but lonely at lunch.',
        'memoryFlagA': 'office_romance',
      }
    },

    // --- FAMILY & RELATIONSHIP DRAMA ---
    {
      'title': 'Arranged Marriage Pressure',
      'desc': 'Your parents have found a "perfect match" from a respectable family.',
      'type': 'Family',
      'cond': (c) => c.age >= 24 && c.age <= 32 && !c.memories.containsKey('married'),
      'weight': 15,
      'choice': {
        'title': 'The Match',
        'desc': 'They want you to meet this weekend.',
        'optionA': 'Agree to Meet',
        'optionB': 'Reject the Idea',
        'effectA': {'social': 15, 'karma': 10, 'happiness': -5},
        'effectB': {'happiness': 15, 'social': -20, 'karma': -15, 'stressLevel': 15},
        'resultA': 'The meeting was okay. Your parents are overjoyed.',
        'resultB': 'You refused. Your mother has been crying since then.',
        'memoryFlagB': 'rejected_arranged_marriage',
      }
    },
    {
      'title': 'Risky Loan Request',
      'desc': 'A childhood friend asks for a large sum to start a business.',
      'type': 'Family',
      'cond': (c) => c.bankBalance > 100000 && c.age > 25,
      'weight': 9,
      'choice': {
        'title': 'Lend Money?',
        'desc': '₹1,00,000 is a lot, but he seems desperate.',
        'optionA': 'Lend it',
        'optionB': 'Politely Decline',
        'effectA': {'money': -100000.0, 'social': 20, 'karma': 15},
        'effectB': {'social': -15, 'happiness': 5},
        'resultA': 'He is very grateful. He promises to pay back in two years.',
        'resultB': 'He was hurt and hasn\'t called since.',
        'memoryFlagA': 'money_lender',
      }
    },
    {
      'title': 'The Secret Letter',
      'desc': 'You found a note in your bag from a secret admirer.',
      'type': 'Drama',
      'cond': (c) => c.age >= 13 && c.age <= 16 && c.social > 50,
      'weight': 8,
      'choice': {
        'title': 'A Crush?',
        'desc': 'The note is sweet. Who could it be?',
        'optionA': 'Find Out Who',
        'optionB': 'Throw it Away',
        'effectA': {'social': 10, 'happiness': 15, 'stressLevel': 5},
        'effectB': {'happiness': -5, 'discipline': 5},
        'resultA': 'It was your lab partner! You spent the whole afternoon talking.',
        'resultB': 'You ignored it. You stayed focused on your studies.',
        'memoryFlagA': 'first_crush',
      }
    },
    {
      'title': 'Report Card Day',
      'desc': 'Your final exam results are out. They are... average.',
      'type': 'Drama',
      'cond': (c) => c.age >= 7 && c.age <= 15 && c.smarts < 60,
      'weight': 12,
      'choice': {
        'title': 'The Grades',
        'desc': 'Your father is waiting in the living room.',
        'optionA': 'Show Honestly',
        'optionB': 'Hide the Card',
        'effectA': {'karma': 10, 'happiness': -20, 'stressLevel': 10},
        'effectB': {'karma': -20, 'happiness': 5, 'discipline': -10},
        'resultA': 'He was disappointed but appreciated the honesty. You are grounded for a week.',
        'resultB': 'You hid it under the sofa. You survived today, but the guilt is eating you.',
        'memoryFlagB': 'lied_about_grades',
      }
    },
    {
      'title': 'Cricket Match',
      'desc': 'Final over. Your team needs 12 runs to win. You are on strike.',
      'type': 'Drama',
      'cond': (c) => c.age >= 10 && c.age <= 16,
      'weight': 10,
      'choice': {
        'title': 'The Final Ball',
        'desc': 'The whole colony is watching.',
        'optionA': 'Go for a Six',
        'optionB': 'Play it Safe',
        'effectA': {'social': 20, 'happiness': 25, 'smarts': -5},
        'effectB': {'social': -10, 'happiness': -10, 'smarts': 10},
        'resultA': 'BOOM! You hit it out of the park! You are the colony hero!',
        'resultB': 'You took a single. Your team lost by 2 runs. Everyone looks annoyed.',
        'memoryFlagA': 'colony_cricket_hero',
      }
    },
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
      'weight': 0.5 // Rare weight
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

    // --- MICRO-DRAMA & ABSURDITY (NEW) ---
    // Childhood & School (5-18)
    {
      'title': 'The WhatsApp Accident',
      'desc': 'You accidentally sent a meme meant for friends to the family group.',
      'type': 'Drama',
      'cond': (c) => c.age >= 13 && c.age <= 18,
      'weight': 15,
      'choice': {
        'title': 'Immediate Panic!',
        'desc': 'The blue ticks are appearing. What do you do?',
        'optionA': 'Delete for Everyone',
        'optionB': 'Say your phone was hacked',
        'successChanceA': 0.7,
        'effectA': {'social': -5, 'stressLevel': 10},
        'resultA': 'You deleted it just in time, but your uncle is already asking "Kya tha beta?".',
        'effectAFail': {'social': -20, 'happiness': -10, 'stressLevel': 30},
        'resultAFail': 'The delete failed! Your father has called a "family meeting" in the living room.',
        'resultB': 'Nobody believed you. You are now the "Hacked One" in every family gathering.',
      }
    },
    {
      'title': 'Wedding Dance Disaster',
      'desc': 'You were forced to dance at a cousin\'s wedding. You tripped over the carpet.',
      'type': 'Drama',
      'cond': (c) => c.age >= 10 && c.age <= 25,
      'weight': 12,
      'effect': {'social': -15, 'happiness': -10, 'stressLevel': 10},
      'result': 'The video is already on the family group. You are a local meme for the week.'
    },
    {
      'title': '🐒 Monkey Heist',
      'desc': 'A monkey snatched your spectacles while you were walking to tuition.',
      'type': 'Chaos',
      'cond': (c) => c.age >= 10 && c.age <= 20,
      'weight': 3, // Reduced for rarity
      'choice': {
        'title': 'The Great Negotiation',
        'desc': 'The monkey is staring at you from a nearby tree.',
        'optionA': 'Bribe with a Banana',
        'optionB': 'Try to Scare it',
        'successChanceA': 0.8,
        'effectA': {'money': -50.0, 'happiness': 5, 'smarts': 5},
        'resultA': 'A successful trade! You got your glasses back, slightly chewed.',
        'effectAFail': {'money': -2000.0, 'happiness': -20, 'social': -10},
        'resultAFail': 'The monkey ate the banana and threw your glasses into a drain. Time for a new pair.',
        'resultB': 'The monkey hissed and threw a small branch at you. You ran away, blind and defeated.',
      }
    },
    // Adulthood & Career (22-50)
    {
      'title': 'The Office "Gift"',
      'desc': 'A colleague left an anonymous, slightly insulting self-help book on your desk.',
      'type': 'Drama',
      'cond': (c) => c.annualIncome > 0,
      'weight': 10,
      'choice': {
        'title': 'Toxic Office Vibes',
        'desc': 'How do you handle this passive-aggressive move?',
        'optionA': 'Throw it in the Trash',
        'optionB': 'Keep it on the Desk',
        'effectA': {'stressLevel': -5, 'reputation': 5},
        'resultA': 'You threw it away while maintaining eye contact with everyone. Power move.',
        'effectB': {'stressLevel': 15, 'reputation': -5},
        'resultB': 'You kept it. Now everyone thinks you actually have "Time Management Issues".',
      }
    },
    {
      'title': 'Sharma Ji\'s Return',
      'desc': 'Sharma Ji stopped your father in the park to announce his son bought a 3BHK in Bangalore.',
      'type': 'Family',
      'cond': (c) => c.age > 25 && c.bankBalance < 1000000,
      'weight': 15,
      'effect': {'happiness': -15, 'stressLevel': 20},
      'result': 'Your father didn\'t say anything, but he looked at your old car for a long time today.'
    },
    {
      'title': '🥛 The Milk-man Dispute',
      'desc': 'The milk-man claimed you didn\'t pay for 3 days last month. You are sure you did.',
      'type': 'Chaos',
      'cond': (c) => c.age > 22,
      'weight': 8,
      'choice': {
        'title': 'The ₹150 Battle',
        'desc': 'It\'s about the principle, not the money.',
        'optionA': 'Pay and Forget',
        'optionB': 'Argue till the End',
        'effectA': {'money': -150.0, 'happiness': -5, 'karma': 5},
        'resultA': 'You paid. You feel cheated, but at least the shouting stopped.',
        'successChanceB': 0.5,
        'effectB': {'happiness': 10, 'social': -5},
        'resultB': 'You won! He checked his book and found the error. Victory is sweet.',
        'effectBFail': {'happiness': -20, 'social': -15, 'stressLevel': 15},
        'resultBFail': 'You lost the argument and the neighborhood\'s respect. You paid ₹150 and a "Late Fee".',
      }
    },
    {
      'title': 'The WhatsApp Forward',
      'desc': 'Your aunt forwarded a message claiming that drinking hot water with lemon cures everything.',
      'type': 'Drama',
      'cond': (c) => c.age > 18,
      'weight': 10,
      'choice': {
        'title': 'Fact-Check her?',
        'desc': 'She is your favorite aunt, but this is nonsense.',
        'optionA': 'Send Fact-check Link',
        'optionB': 'Reply with "🙏 Nice Info"',
        'effectA': {'social': -10, 'karma': 5},
        'resultA': 'She is offended. She hasn\'t "liked" your profile picture since then.',
        'effectB': {'social': 10, 'smarts': -5},
        'resultB': 'Peace maintained. You are her favorite nephew/niece again.',
      }
    },
    // Late Life & Legacy (50+)
    {
      'title': 'The Retirement Hobby',
      'desc': 'You decided to take up gardening, but your neighbor claims your plants are "stealing" his sunlight.',
      'type': 'Drama',
      'cond': (c) => c.age > 55,
      'weight': 12,
      'effect': {'happiness': -5, 'social': -10, 'stressLevel': 10},
      'result': 'The "Garden War" has begun. You are now growing taller trees out of spite.'
    },
    {
      'title': '👵 Grandchild Comparison',
      'desc': 'You were boasting about your grandchild, but your friend showed a video of hers speaking 3 languages.',
      'type': 'Family',
      'cond': (c) => c.age > 60,
      'weight': 10,
      'effect': {'happiness': -10, 'social': -5},
      'result': 'You spent the evening wondering why your grandchild only speaks in "skibidi" slang.'
    },
    {
      'title': '🔮 The Astrologer',
      'desc': 'A local astrologer looked at your palm and went "Tsk tsk tsk...".',
      'type': 'Chaos',
      'cond': (c) => true,
      'weight': 8,
      'choice': {
        'title': 'Ask Why?',
        'desc': 'He looks worried. Should you care?',
        'optionA': 'Pay for a "Remedy"',
        'optionB': 'Laugh and Walk Away',
        'effectA': {'money': -5000.0, 'happiness': 10, 'stressLevel': -10},
        'resultA': 'You bought a special ring. You feel safer, even if your wallet is lighter.',
        'effectB': {'smarts': 10, 'happiness': 5},
        'resultB': 'You didn\'t fall for it. Logic wins today.',
        'hiddenRiskB': true,
        'successChanceB': 0.9,
        'effectBFail': {'happiness': -20, 'stressLevel': 30},
        'resultBFail': 'The next day, you tripped and broke your phone. Was he right? The paranoia begins.',
      }
    },
    // --- 50+ DYNAMIC REFLECTIONS & LIFESTYLE EVENTS ---
    // AMBITIOUS (Rising Star)
    {
      'title': 'Quiet Ambition',
      'desc': 'You spent the evening mapping out your 5-year plan. You can feel the top within reach.',
      'type': 'Neutral',
      'cond': (c) => c.ambition > 70 && c.age > 20,
      'weight': 2
    },
    {
      'title': 'Existential Jealousy',
      'desc': 'You saw an old schoolmate on Forbes "30 Under 30". You feel a sharp sting of inadequacy.',
      'type': 'Neutral',
      'cond': (c) => c.ambition > 80 && c.jobLevel < 4 && c.age < 30,
      'weight': 2,
      'effect': {'happiness': -10, 'stressLevel': 10}
    },
    // WEALTHY (Upper Class)
    {
      'title': 'Elite Networking',
      'desc': 'You attended a private gala. You made connections that your younger self wouldn\'t believe.',
      'type': 'Financial',
      'tier': 'Upper',
      'cond': (c) => c.lifestyleTier == 'Upper',
      'weight': 3,
      'effect': {'social': 20, 'fame': 10}
    },
    {
      'title': 'Luxury Anxiety',
      'desc': 'Your luxury SUV has a minor dent. The repair cost is more than a month\'s salary for some.',
      'type': 'Financial',
      'tier': 'Upper',
      'cond': (c) => c.lifestyleTier == 'Upper',
      'weight': 2,
      'effect': {'money': -80000.0, 'stressLevel': 10}
    },
    // LONELY / BURNT OUT
    {
      'title': 'The Silent Phone',
      'desc': 'You realized you haven\'t had a personal call in weeks. The silence is loud.',
      'type': 'Neutral',
      'cond': (c) => c.social < 30 && c.age > 25,
      'weight': 3,
      'effect': {'happiness': -15}
    },
    {
      'title': 'Coffee & Burnout',
      'desc': 'The third cup of coffee didn\'t help. You are staring at your screen, feeling like a ghost.',
      'type': 'Neutral',
      'cond': (c) => c.stressLevel > 75,
      'weight': 4,
      'effect': {'happiness': -10, 'health': -5}
    },
    // MID-LIFE FRICTION
    {
      'title': 'Parenting Stress',
      'desc': 'Your child is struggling with Math. You spent the weekend explaining algebra instead of resting.',
      'type': 'Family',
      'cond': (c) => c.age >= 35 && c.age <= 50 && c.memories.containsKey('married'),
      'weight': 4,
      'effect': {'stressLevel': 15, 'happiness': -5}
    },
    {
      'title': 'The "What If" Dream',
      'desc': 'You woke up from a dream where you took that other job 10 years ago. You felt a wave of regret.',
      'type': 'Neutral',
      'cond': (c) => c.age > 45 && c.happiness < 50,
      'weight': 2,
      'effect': {'happiness': -10}
    },
    // LATE-LIFE NOSTALGIA
    {
      'title': 'Grandchild\'s First Words',
      'desc': 'Your grandchild called you by name today. You felt your heart melt.',
      'type': 'Family',
      'cond': (c) => c.age > 60,
      'weight': 5,
      'effect': {'happiness': 20}
    },
    {
      'title': 'Old Photo Album',
      'desc': 'You found a dusty album from your school days. Everyone looked so young and certain.',
      'type': 'Neutral',
      'cond': (c) => c.age > 65,
      'weight': 4,
      'effect': {'happiness': 10}
    },
    {
      'title': 'The Fading Legacy',
      'desc': 'You walked past your old office. Nobody recognized you. Time has moved on.',
      'type': 'Neutral',
      'cond': (c) => c.age > 70,
      'weight': 3,
      'effect': {'social': -10, 'happiness': -5}
    },
    // LOWER CLASS SURVIVAL
    {
      'title': 'Debt Pressure',
      'desc': 'The monthly interest is eating your savings. You skipped a meal today to save ₹50.',
      'type': 'Financial',
      'tier': 'Lower',
      'cond': (c) => c.lifestyleTier == 'Lower' && c.bankBalance < 1000,
      'weight': 5,
      'effect': {'happiness': -15, 'health': -5, 'stressLevel': 20}
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
