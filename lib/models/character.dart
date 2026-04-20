// lib/models/character.dart
import 'package:hive/hive.dart';
import 'relationship.dart';

part 'character.g.dart';

const int kCurrentSaveVersion = 1;

@HiveType(typeId: 0)
class Character extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int age;

  @HiveField(2)
  String city;

  @HiveField(3)
  double bankBalance;

  @HiveField(4)
  String jobTitle;

  @HiveField(5)
  int happiness;

  @HiveField(6)
  int health;

  @HiveField(7)
  int smarts;

  @HiveField(8)
  int social;

  @HiveField(9)
  int karma;

  @HiveField(10)
  bool isDead;

  // ── Extended Fields ──────────────────────────────────
  @HiveField(11)
  String personality; // 'Smart', 'Kind', 'Lazy', 'Aggressive', 'Lucky'

  @HiveField(12)
  String educationLevel; // 'None', 'Primary', 'Secondary', 'Graduate', 'Postgraduate'

  @HiveField(13)
  String degree; // 'Engineering', 'Medicine', 'Commerce', 'Arts', 'Science', 'Law', 'None'

  @HiveField(14)
  double totalEarned; // lifetime career earnings

  @HiveField(15)
  List<String> achievements; // badge IDs

  @HiveField(16)
  String gender; // 'Male', 'Female'

  @HiveField(17)
  double annualIncome; // current salary per year (added each ageUp)

  @HiveField(18)
  double annualExpenses; // current yearly spend

  @HiveField(19)
  String careerGroup; // 'Tech', 'Government', 'Corporate', 'Medical', 'Business', 'Arts', 'None'

  @HiveField(20)
  int careerStep; // index in career ladder (0 = entry level)

  @HiveField(21)
  int yearsInRole; // years spent in current step

  @HiveField(22)
  List<String> ownedAssets; // asset IDs

  @HiveField(23)
  List<Relationship> relationships; // dynamic NPC connections

  @HiveField(24)
  int cibilScore;

  @HiveField(25)
  String bankName;

  @HiveField(26)
  String accountType;

  @HiveField(27)
  double savingsBalance;

  @HiveField(28)
  double loanAmount;

  @HiveField(29)
  bool hasCreditCard;

  @HiveField(30)
  String loanType; // 'Student', 'Personal', 'Home', 'None'

  @HiveField(31)
  double creditUsed;

  @HiveField(32)
  int lastActivityAge;

  @HiveField(33)
  List<Map<dynamic, dynamic>> stockPortfolio;

  @HiveField(34)
  List<Map<dynamic, dynamic>> cryptoPortfolio;

  @HiveField(35)
  List<Map<dynamic, dynamic>> bondPortfolio;

  @HiveField(36)
  Map<dynamic, dynamic> marketPrices;

  @HiveField(37)
  Map<String, int> eventChains; // Story chain tracking

  @HiveField(38)
  int momentumStreak; // +ve for wins, -ve for losses

  @HiveField(39)
  int version;

  @HiveField(40)
  int lastSavedAt;

  @HiveField(41)
  Map<String, int> personalityScores; // Intensity of each trait (0-100)

  @HiveField(42)
  String activeDominantTrait; // The stable, locked identity

  @HiveField(43)
  int lastTraitShiftAge; // When the identity last evolved

  @HiveField(44)
  int lastAutoDecisionAge; // Cooldown for autonomous actions

  @HiveField(45)
  String momentumState; // e.g. "Steady", "Flow State", "Emotional Collapse"

  @HiveField(46)
  String identityPhase; // e.g. "The Rising Star", "The Burnout"

  @HiveField(47)
  int phaseYearsStored; // Duration spent in current dominant state

  @HiveField(48)
  Map<String, double> hiddenModifiers; // Secret buffs/debuffs

  @HiveField(49)
  List<Map<String, dynamic>> majorDecisions; // e.g. [{age: 18, choice: "Quit School", regretPotential: 80}]

  @HiveField(50)
  int legacyPoints; // Permanent points from past lives

  @HiveField(51)
  List<String> tensionSignals; // Tension/Anticipation signals for the UI

  @HiveField(52)
  String universityType; // 'Government', 'Private', 'None'

  @HiveField(53)
  Map<String, int> examResults; // 'JEE', 'NEET', etc.

  @HiveField(54)
  bool isDroppedYear; // Gap year tracking

  @HiveField(55)
  int stateVersion; // Internal version to track state mutations for simulation validation

  String get dominantTrait {
    if (personalityScores.isEmpty) return personality;
    String top = personality;
    int max = -1;
    personalityScores.forEach((k, v) {
      if (v > max) {
        max = v;
        top = k;
      }
    });
    return top;
  }

  /// Manually increment the state version to signal mutation to the buffer system
  void triggerMutation() {
    stateVersion++;
  }

  String get identityTitle {
    final topTraits = personalityScores.entries.where((e) => e.value > 70).toList();
    topTraits.sort((a, b) => b.value.compareTo(a.value));
    
    if (topTraits.isEmpty) return "Common Soul";
    
    final t1 = topTraits[0].key;
    if (topTraits.length < 2) {
      switch (t1) {
        case 'Disciplined': return "The Sentinel";
        case 'Lazy': return "Carefree Spirit";
        case 'Aggressive': return "The Firebrand";
        case 'Kind': return "Kindred Soul";
        case 'Emotional': return "Vivid Spirit";
        case 'Logical': return "The Analyst";
        case 'Risk-taker': return "Daredevil";
        default: return "Nuanced Persona";
      }
    }

    final t2 = topTraits[1].key;
    final pair = {t1, t2};
    
    if (pair.contains('Disciplined') && pair.contains('Logical')) return "The Architect";
    if (pair.contains('Kind') && pair.contains('Emotional')) return "Radiant Heart";
    if (pair.contains('Aggressive') && pair.contains('Risk-taker')) return "Chaos Agent";
    if (pair.contains('Lazy') && pair.contains('Logical')) return "Observationist";
    if (pair.contains('Kind') && pair.contains('Disciplined')) return "Modern Saint";
    if (pair.contains('Aggressive') && pair.contains('Emotional')) return "The Storm";
    if (pair.contains('Logical') && pair.contains('Risk-taker')) return "The Speculator";
    
    return "$t1 $t2 Blend";
  }

  String get suggestedGoal {
    if (age < 6) return "Goal: LEARN TO WALK 👶";
    if (age < 13) return "Goal: SCORE HIGH IN SCHOOL 🎒";
    if (age < 18) return "Goal: ACE YOUR BOARD EXAMS 📚";

    // Persona-Driven Goals
    switch (activeDominantTrait) {
      case 'Disciplined':
        if (careerGroup == 'None') return "Goal: ESTABLISH A CAREER 💼";
        if (bankBalance < 100000) return "Goal: GROW YOUR SAVINGS 💰";
        return "Goal: REACH PEAK PERFORMANCE 🏆";
      case 'Risk-taker':
        if (stockPortfolio.isEmpty && cryptoPortfolio.isEmpty) return "Goal: START INVESTING 📈";
        return "Goal: CHASE THE BIG WIN 💎";
      case 'Aggressive':
        if (jobTitle != 'CEO' && jobTitle != 'CTO' && jobTitle != 'Founder') return "Goal: RISE TO THE TOP 🚀";
        return "Goal: DOMINATE YOUR INDUSTRY 👑";
      case 'Kind':
        if (karma < 80) return "Goal: HELP OTHERS 🕊️";
        return "Goal: BECOME A RADIANT SOUL ✨";
      case 'Lazy':
        if (happiness < 70) return "Goal: FIND COMFORT 🛋️";
        return "Goal: ENJOY THE SIMPLE LIFE 🍹";
      case 'Emotional':
        return "Goal: FIND DEEPER CONNECTIONS 💖";
      case 'Logical':
        return "Goal: MASTER YOUR CRAFT 🧠";
    }

    if (health < 50) return "Goal: RECOVER YOUR HEALTH 🏥";
    if (momentumState == 'Emotional Collapse') return "Goal: SURVIVE THE STORM ⛈️";
    
    return "Goal: THRIVE IN LIFE 🌟";
  }

  Character({
    required this.name,
    required this.age,
    required this.city,
    this.bankBalance = 5000.0,
    this.jobTitle = 'Student',
    this.happiness = 70,
    this.health = 80,
    this.smarts = 60,
    this.social = 65,
    this.karma = 50,
    this.isDead = false,
    this.personality = 'Balanced',
    this.educationLevel = 'None',
    this.degree = 'None',
    this.totalEarned = 0,
    this.gender = 'Male',
    this.annualIncome = 0,
    this.annualExpenses = 36000,
    this.careerGroup = 'None',
    this.careerStep = 0,
    this.yearsInRole = 0,
    this.cibilScore = 650,
    this.bankName = '',
    this.accountType = '',
    this.savingsBalance = 0.0,
    this.loanAmount = 0.0,
    this.hasCreditCard = false,
    this.loanType = 'None',
    this.creditUsed = 0.0,
    this.lastActivityAge = -1,
    this.momentumStreak = 0,
    this.version = kCurrentSaveVersion,
    this.lastSavedAt = 0,
    this.activeDominantTrait = 'Balanced',
    this.lastTraitShiftAge = -1,
    this.lastAutoDecisionAge = -1,
    this.momentumState = 'Steady',
    this.identityPhase = 'The Beginning',
    this.phaseYearsStored = 0,
    this.legacyPoints = 0,
    this.universityType = 'None',
    this.isDroppedYear = false,
    this.stateVersion = 0,
    List<String>? achievements,
    List<String>? ownedAssets,
    List<Relationship>? relationships,
    List<Map<dynamic, dynamic>>? stockPortfolio,
    List<Map<dynamic, dynamic>>? cryptoPortfolio,
    List<Map<dynamic, dynamic>>? bondPortfolio,
    Map<dynamic, dynamic>? marketPrices,
    Map<String, int>? eventChains,
    Map<String, int>? personalityScores,
    Map<String, double>? hiddenModifiers,
    List<Map<String, dynamic>>? majorDecisions,
    List<String>? tensionSignals,
    Map<String, int>? examResults,
  })  : achievements = achievements != null ? List<String>.from(achievements) : [],
        ownedAssets = ownedAssets != null ? List<String>.from(ownedAssets) : [],
        relationships = relationships != null ? List<Relationship>.from(relationships) : [],
        stockPortfolio = stockPortfolio != null ? List<Map<dynamic, dynamic>>.from(stockPortfolio) : [],
        cryptoPortfolio = cryptoPortfolio != null ? List<Map<dynamic, dynamic>>.from(cryptoPortfolio) : [],
        bondPortfolio = bondPortfolio != null ? List<Map<dynamic, dynamic>>.from(bondPortfolio) : [],
        marketPrices = marketPrices != null ? Map<dynamic, dynamic>.from(marketPrices) : {},
        eventChains = eventChains != null ? Map<String, int>.from(eventChains) : {},
        personalityScores = personalityScores != null ? Map<String, int>.from(personalityScores) : {
          'Disciplined': 30,
          'Lazy': 30,
          'Aggressive': 30,
          'Kind': 30,
          'Emotional': 30,
          'Logical': 30,
          'Risk-taker': 30,
        },
        hiddenModifiers = hiddenModifiers != null ? Map<String, double>.from(hiddenModifiers) : {},
        majorDecisions = majorDecisions != null ? List<Map<String, dynamic>>.from(majorDecisions) : [],
        tensionSignals = tensionSignals != null ? List<String>.from(tensionSignals) : [],
        examResults = examResults != null ? Map<String, int>.from(examResults) : {} {
    // Initialize primary personality if scores are default
    if (this.personalityScores.values.every((v) => v == 30)) {
      final Map<String, int> scores = Map<String, int>.from(this.personalityScores);
      if (scores.containsKey(personality)) {
        scores[personality] = 70;
      } else {
        scores['Logical'] = 70; // Fallback
      }
      this.personalityScores = scores;
      activeDominantTrait = personality;
    }
  }

  /// Part of robust save system: Default Safe Character
  factory Character.defaultCharacter() => Character(
        name: 'New Soul',
        age: 0,
        city: 'Mumbai',
        bankBalance: 5000.0,
        happiness: 100,
        health: 100,
        smarts: 50,
        social: 50,
        karma: 50,
      );

  int _clamp(int value) => value.clamp(0, 100);

  void updateStats({
    int happinessDelta = 0,
    int healthDelta = 0,
    int smartsDelta = 0,
    int socialDelta = 0,
    int karmaDelta = 0,
    double moneyDelta = 0,
  }) {
    happiness = _clamp(happiness + happinessDelta);
    health = _clamp(health + healthDelta);
    smarts = _clamp(smarts + smartsDelta);
    social = _clamp(social + socialDelta);
    karma = _clamp(karma + karmaDelta);
    bankBalance = (bankBalance + moneyDelta).clamp(0, double.infinity);
    if (moneyDelta > 0) totalEarned += moneyDelta;
    if (health <= 0) isDead = true;
  }

  void shiftPersonality(String trait, int delta) {
    if (delta == 0) return;
    final scores = Map<String, int>.from(personalityScores);
    int current = scores[trait] ?? 30;
    
    // Diminishing Returns: It's harder to shift extreme traits further
    double factor = 1.0;
    if (delta > 0) {
      factor = (110 - current) / 80.0;
    } else {
      factor = (current + 10) / 80.0;
    }
    int adjustedDelta = (delta * factor.clamp(0.4, 1.5)).round();
    if (adjustedDelta == 0 && delta != 0) adjustedDelta = delta.sign;
    
    scores[trait] = (current + adjustedDelta).clamp(0, 100);
    
    // Soft Balance (instead of hard zero-sum) 
    // Increasing a trait only reduces the opposite by 40% of the movement
    final opposite = _getOppositeTrait(trait);
    if (opposite != null) {
      int oppVal = scores[opposite]!;
      int reduction = (adjustedDelta * 0.4).round();
      scores[opposite] = (oppVal - reduction).clamp(0, 100);
    }
    
    personalityScores = scores;
  }

  String? _getOppositeTrait(String trait) {
    switch (trait) {
      case 'Disciplined': return 'Lazy';
      case 'Lazy': return 'Disciplined';
      case 'Logical': return 'Emotional';
      case 'Emotional': return 'Logical';
      case 'Kind': return 'Aggressive';
      case 'Aggressive': return 'Kind';
      default: return null;
    }
  }

  /// Part of robust save system: Data Repair (Aggressive Clamping)
  void repair() {
    name = name.isEmpty ? "New Soul" : name;
    age = age.clamp(0, 120);
    city = city.isEmpty ? "Mumbai" : city;
    bankBalance = bankBalance.isNaN ? 0.0 : bankBalance.clamp(0, double.infinity);
    annualIncome = annualIncome.isNaN ? 0.0 : annualIncome.clamp(0, double.infinity);
    annualExpenses = annualExpenses.isNaN ? 36000.0 : annualExpenses.clamp(0, double.infinity);
    
    happiness = _clamp(happiness);
    health = _clamp(health);
    smarts = _clamp(smarts);
    social = _clamp(social);
    karma = _clamp(karma);
    
    // Ensure collections are initialized
    achievements = List<String>.from(achievements);
    ownedAssets = List<String>.from(ownedAssets);
    relationships = List<Relationship>.from(relationships);
    stockPortfolio = List<Map<dynamic, dynamic>>.from(stockPortfolio);
    cryptoPortfolio = List<Map<dynamic, dynamic>>.from(cryptoPortfolio);
    bondPortfolio = List<Map<dynamic, dynamic>>.from(bondPortfolio);
    marketPrices = Map<dynamic, dynamic>.from(marketPrices);
    eventChains = Map<String, int>.from(eventChains);
    personalityScores = Map<String, int>.from(personalityScores);
    majorDecisions = List<Map<String, dynamic>>.from(majorDecisions);
    tensionSignals = List<String>.from(tensionSignals);
    examResults = Map<String, int>.from(examResults);
    universityType = universityType.isEmpty ? 'None' : universityType;
    if (personalityScores.isEmpty) {
      personalityScores = {
        'Disciplined': 30, 'Lazy': 30, 'Aggressive': 30, 
        'Kind': 30, 'Emotional': 30, 'Logical': 30, 'Risk-taker': 30,
      };
      personalityScores[personality] = 70;
    }
  }

  /// Part of robust save system: Critical Check Only
  bool isUnusable() {
    // Only discard if basic identity is missing or age is impossible
    return name.isEmpty || age < 0 || age > 130;
  }

  void addAchievement(String id) {
    if (!achievements.contains(id)) {
      achievements = [...achievements, id];
    }
  }

  String get karmaLabel {
    if (karma >= 80) return 'Saintly 😇';
    if (karma >= 60) return 'Good Soul 🙏';
    if (karma >= 40) return 'Neutral ⚖️';
    if (karma >= 20) return 'Reckless 😈';
    return 'Wicked 💀';
  }

  String get lifeStage {
    if (age < 6) return 'Toddler';
    if (age < 13) return 'Child';
    if (age < 18) return 'Teenager';
    if (age < 25) return 'Young Adult';
    if (age < 40) return 'Adult';
    if (age < 60) return 'Middle-Aged';
    if (age < 80) return 'Senior';
    return 'Elder';
  }

  String get netWorthLabel {
    final total = bankBalance;
    if (total >= 10000000) return 'Crorepati 🤑';
    if (total >= 500000) return 'Lakhpati 💰';
    if (total >= 100000) return 'Comfortable 😊';
    if (total > 0) return 'Struggling 😐';
    return 'Bankrupt 😰';
  }

  double get creditLimit {
    if (!hasCreditCard) return 0;
    // Base 25k + CIBIL factor + 10% of income
    double cibilFactor = (cibilScore - 300).clamp(0, 600) * 100.0;
    double incomeFactor = (annualIncome / 12) * 2; // 2 months salary
    return 25000 + cibilFactor + incomeFactor;
  }

  double get creditMinDue => creditUsed * 0.05;

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'city': city,
        'bankBalance': bankBalance,
        'jobTitle': jobTitle,
        'happiness': happiness,
        'health': health,
        'smarts': smarts,
        'social': social,
        'karma': karma,
        'isDead': isDead,
        'personality': personality,
        'educationLevel': educationLevel,
        'degree': degree,
        'totalEarned': totalEarned,
        'achievements': achievements,
        'gender': gender,
        'annualIncome': annualIncome,
        'annualExpenses': annualExpenses,
        'cibilScore': cibilScore,
        'bankName': bankName,
        'accountType': accountType,
        'savingsBalance': savingsBalance,
        'loanAmount': loanAmount,
        'hasCreditCard': hasCreditCard,
        'ownedAssets': ownedAssets,
        'loanType': loanType,
        'creditUsed': creditUsed,
        'lastActivityAge': lastActivityAge,
        'stockPortfolio': stockPortfolio,
        'cryptoPortfolio': cryptoPortfolio,
        'bondPortfolio': bondPortfolio,
        'marketPrices': marketPrices,
        'eventChains': eventChains,
        'momentumStreak': momentumStreak,
        'version': version,
        'lastSavedAt': lastSavedAt,
        'activeDominantTrait': activeDominantTrait,
        'lastTraitShiftAge': lastTraitShiftAge,
        'lastAutoDecisionAge': lastAutoDecisionAge,
        'personalityScores': personalityScores,
        'universityType': universityType,
        'examResults': examResults,
        'isDroppedYear': isDroppedYear,
        'stateVersion': stateVersion,
        'relationships': relationships.map((r) => r.toJson()).toList(),
      };

  factory Character.fromJson(Map<String, dynamic> json) => Character(
        name: json['name'] as String,
        age: json['age'] as int,
        city: json['city'] as String,
        bankBalance: (json['bankBalance'] as num).toDouble(),
        jobTitle: json['jobTitle'] as String,
        happiness: json['happiness'] as int,
        health: json['health'] as int,
        smarts: json['smarts'] as int,
        social: json['social'] as int,
        karma: json['karma'] as int,
        isDead: json['isDead'] as bool? ?? false,
        personality: json['personality'] as String? ?? 'Balanced',
        educationLevel: json['educationLevel'] as String? ?? 'None',
        degree: json['degree'] as String? ?? 'None',
        totalEarned: (json['totalEarned'] as num?)?.toDouble() ?? 0,
        achievements: List<String>.from(json['achievements'] as List? ?? []),
        gender: json['gender'] as String? ?? 'Male',
        annualIncome: (json['annualIncome'] as num?)?.toDouble() ?? 0,
        annualExpenses: (json['annualExpenses'] as num?)?.toDouble() ?? 36000,
        cibilScore: json['cibilScore'] as int? ?? 650,
        bankName: json['bankName'] as String? ?? '',
        accountType: json['accountType'] as String? ?? '',
        savingsBalance: (json['savingsBalance'] as num?)?.toDouble() ?? 0.0,
        loanAmount: (json['loanAmount'] as num?)?.toDouble() ?? 0.0,
        hasCreditCard: json['hasCreditCard'] as bool? ?? false,
        loanType: json['loanType'] as String? ?? 'None',
        ownedAssets: List<String>.from(json['ownedAssets'] as List? ?? []),
        creditUsed: (json['creditUsed'] as num?)?.toDouble() ?? 0.0,
        lastActivityAge: json['lastActivityAge'] as int? ?? -1,
        stockPortfolio: List<Map<dynamic, dynamic>>.from(json['stockPortfolio'] as List? ?? []),
        cryptoPortfolio: List<Map<dynamic, dynamic>>.from(json['cryptoPortfolio'] as List? ?? []),
        bondPortfolio: List<Map<dynamic, dynamic>>.from(json['bondPortfolio'] as List? ?? []),
        marketPrices: Map<dynamic, dynamic>.from(json['marketPrices'] as Map? ?? {}),
        eventChains: Map<String, int>.from(json['eventChains'] as Map? ?? {}),
        momentumStreak: json['momentumStreak'] as int? ?? 0,
        lastSavedAt: json['lastSavedAt'] as int? ?? 0,
        personalityScores: Map<String, int>.from(json['personalityScores'] as Map? ?? {}),
        activeDominantTrait: json['activeDominantTrait'] as String? ?? 'Balanced',
        lastTraitShiftAge: json['lastTraitShiftAge'] as int? ?? -1,
        lastAutoDecisionAge: json['lastAutoDecisionAge'] as int? ?? -1,
        universityType: json['universityType'] as String? ?? 'None',
        examResults: Map<String, int>.from(json['examResults'] as Map? ?? {}),
        isDroppedYear: json['isDroppedYear'] as bool? ?? false,
        stateVersion: json['stateVersion'] as int? ?? 0,
        relationships: (json['relationships'] as List?)
                ?.map((r) => Relationship.fromJson(r as Map<String, dynamic>))
                .toList() ??
            List<Relationship>.from([]),
      );

  Character copyWith({
    String? name, int? age, String? city, double? bankBalance, String? jobTitle,
    int? happiness, int? health, int? smarts, int? social, int? karma, bool? isDead,
    String? personality, String? educationLevel, String? degree, double? totalEarned,
    List<String>? achievements, String? gender, double? annualIncome, double? annualExpenses,
    int? cibilScore, String? bankName, String? accountType, double? savingsBalance, 
    double? loanAmount, bool? hasCreditCard, List<String>? ownedAssets, String? loanType,
    double? creditUsed, int? lastActivityAge,
    List<Map<dynamic, dynamic>>? stockPortfolio,
    List<Map<dynamic, dynamic>>? cryptoPortfolio,
    List<Map<dynamic, dynamic>>? bondPortfolio,
    Map<dynamic, dynamic>? marketPrices,
    Map<String, int>? eventChains,
    int? momentumStreak,
    int? version,
    int? lastSavedAt,
    Map<String, int>? personalityScores,
    String? activeDominantTrait,
    int? lastTraitShiftAge,
    int? lastAutoDecisionAge,
    String? universityType,
    Map<String, int>? examResults,
    bool? isDroppedYear,
    int? stateVersion,
  }) => Character(
        name: name ?? this.name,
        age: age ?? this.age,
        city: city ?? this.city,
        bankBalance: bankBalance ?? this.bankBalance,
        jobTitle: jobTitle ?? this.jobTitle,
        happiness: happiness ?? this.happiness,
        health: health ?? this.health,
        smarts: smarts ?? this.smarts,
        social: social ?? this.social,
        karma: karma ?? this.karma,
        isDead: isDead ?? this.isDead,
        personality: personality ?? this.personality,
        educationLevel: educationLevel ?? this.educationLevel,
        degree: degree ?? this.degree,
        totalEarned: totalEarned ?? this.totalEarned,
        achievements: achievements ?? this.achievements,
        gender: gender ?? this.gender,
        annualIncome: annualIncome ?? this.annualIncome,
        annualExpenses: annualExpenses ?? this.annualExpenses,
        cibilScore: cibilScore ?? this.cibilScore,
        bankName: bankName ?? this.bankName,
        accountType: accountType ?? this.accountType,
        savingsBalance: savingsBalance ?? this.savingsBalance,
        loanAmount: loanAmount ?? this.loanAmount,
        hasCreditCard: hasCreditCard ?? this.hasCreditCard,
        ownedAssets: ownedAssets ?? this.ownedAssets,
        loanType: loanType ?? this.loanType,
        creditUsed: creditUsed ?? this.creditUsed,
        lastActivityAge: lastActivityAge ?? this.lastActivityAge,
        stockPortfolio: stockPortfolio ?? this.stockPortfolio,
        cryptoPortfolio: cryptoPortfolio ?? this.cryptoPortfolio,
        bondPortfolio: bondPortfolio ?? this.bondPortfolio,
        marketPrices: marketPrices ?? this.marketPrices,
        eventChains: eventChains ?? this.eventChains,
        momentumStreak: momentumStreak ?? this.momentumStreak,
        version: version ?? this.version,
        lastSavedAt: lastSavedAt ?? this.lastSavedAt,
        personalityScores: personalityScores ?? this.personalityScores,
        activeDominantTrait: activeDominantTrait ?? this.activeDominantTrait,
        lastTraitShiftAge: lastTraitShiftAge ?? this.lastTraitShiftAge,
        lastAutoDecisionAge: lastAutoDecisionAge ?? this.lastAutoDecisionAge,
        universityType: universityType ?? this.universityType,
        examResults: examResults ?? this.examResults,
        isDroppedYear: isDroppedYear ?? this.isDroppedYear,
        stateVersion: stateVersion ?? this.stateVersion,
      );
}
