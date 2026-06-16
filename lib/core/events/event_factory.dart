import 'dart:ui';

import '../../models/character.dart';
import '../../models/life_event.dart';
import '../../widgets/events/event_types.dart';
import '../enums.dart';

class EventFactory {
  const EventFactory._();

  static ActionEvent promotion({
    required Character character,
    required String previousPosition,
    required String newPosition,
    required double oldSalary,
    required double newSalary,
    required EventCategory category,
    bool pinnacle = false,
  }) {
    return ActionEvent(
      title: pinnacle ? 'PINNACLE REACHED' : 'PROMOTED',
      description: '$previousPosition -> $newPosition',
      type: LifeEventType.positive,
      category: category,
      mode: EventCardMode.success,
      emojiIllustration: pinnacle ? 'crown' : 'promotion',
      infoRows: [
        EventInfoRow(label: 'Old Position', value: previousPosition),
        EventInfoRow(label: 'New Position', value: newPosition),
        EventInfoRow(label: 'Old Salary', value: money(oldSalary)),
        EventInfoRow(
          label: 'New Salary',
          value: money(newSalary),
          valueColor: const Color(0xFF006D37),
        ),
        EventInfoRow(
          label: 'Increase',
          value: '+${(((newSalary - oldSalary) / oldSalary) * 100).round()}%',
          valueColor: const Color(0xFF006D37),
        ),
      ],
      metadata: {
        'age': character.age,
        'eventKind': 'promotion',
        'tier': 'premium',
        'previousPosition': previousPosition,
        'newPosition': newPosition,
        'oldSalary': oldSalary,
        'newSalary': newSalary,
      },
    );
  }

  static ActionEvent offer({
    required Character character,
    required String title,
    required String description,
    required EventCategory category,
    List<EventInfoRow> infoRows = const [],
    List<EventRequirement> requirements = const [],
    String risk = 'Low',
    String reward = 'Career Progress',
  }) {
    return ActionEvent(
      title: title,
      description: description,
      type: LifeEventType.neutral,
      category: category,
      mode: EventCardMode.offer,
      infoRows: [
        ...infoRows,
        EventInfoRow(label: 'Risk', value: risk),
        EventInfoRow(label: 'Reward', value: reward),
      ],
      requirements: requirements,
      metadata: {
        'age': character.age,
        'eventKind': 'offer',
        'hasOfferData': true,
      },
    );
  }

  static ActionEvent requirements({
    required Character character,
    required String title,
    required String description,
    required EventCategory category,
    required List<EventRequirement> requirements,
    List<EventInfoRow> infoRows = const [],
  }) {
    return ActionEvent(
      title: title == 'Requirements Not Met' ? 'Requirements' : title,
      description: description,
      type: LifeEventType.negative,
      category: category,
      mode: EventCardMode.requirement,
      requirements: requirements,
      infoRows: infoRows,
      metadata: {
        'age': character.age,
        'eventKind': 'requirement',
        'hasRequirementData': true,
      },
    );
  }

  static ActionEvent success({
    required Character character,
    required String title,
    required String description,
    required EventCategory category,
    List<EventInfoRow> infoRows = const [],
  }) {
    return ActionEvent(
      title: title,
      description: description,
      type: LifeEventType.positive,
      category: category,
      mode: EventCardMode.success,
      infoRows: infoRows,
      metadata: {'age': character.age, 'eventKind': 'success', 'tier': 'good'},
    );
  }

  static ActionEvent failure({
    required Character character,
    required String title,
    required String description,
    required EventCategory category,
    List<EventInfoRow> infoRows = const [],
  }) {
    return ActionEvent(
      title: title,
      description: description,
      type: LifeEventType.negative,
      category: category,
      mode: EventCardMode.failure,
      infoRows: infoRows,
      metadata: {'age': character.age, 'eventKind': 'failure', 'tier': 'good'},
    );
  }

  static ActionEvent scholarshipAward({
    required Character character,
    required String scholarshipName,
    required double amount,
    String duration = '1 Year',
  }) {
    return ActionEvent(
      title: 'SCHOLARSHIP AWARDED',
      description: 'You received $scholarshipName.',
      type: LifeEventType.positive,
      category: EventCategory.scholarship,
      mode: EventCardMode.success,
      infoRows: [
        EventInfoRow(label: 'Scholarship', value: scholarshipName),
        EventInfoRow(label: 'Amount', value: currency(amount)),
        EventInfoRow(label: 'Duration', value: duration),
        const EventInfoRow(label: 'Coverage', value: 'Full Tuition'),
      ],
      metadata: {'age': character.age, 'eventKind': 'scholarship_award', 'tier': 'premium'},
    );
  }

  static ActionEvent scholarshipRejected({
    required Character character,
    required String reason,
    required num requiredValue,
    required num currentValue,
  }) {
    return ActionEvent(
      title: 'SCHOLARSHIP REJECTED',
      description: 'Your scholarship application did not meet the cutoff.',
      type: LifeEventType.negative,
      category: EventCategory.scholarship,
      mode: EventCardMode.failure,
      infoRows: [
        EventInfoRow(label: 'Reason', value: reason),
        EventInfoRow(label: 'Required', value: '$requiredValue'),
        EventInfoRow(label: 'Current', value: '$currentValue'),
        EventInfoRow(label: 'Missing', value: '${requiredValue - currentValue}'),
      ],
      metadata: {'age': character.age, 'eventKind': 'scholarship_rejected', 'tier': 'good'},
    );
  }

  static ActionEvent viralVideo({
    required Character character,
    required String title,
    required String platform,
    required int views,
    required double revenue,
    required int followersGained,
    required int totalFollowers,
    required int fameGain,
  }) {
    return ActionEvent(
      title: 'VIRAL VIDEO',
      description: 'Your content reached a massive audience.',
      type: LifeEventType.positive,
      category: EventCategory.fame,
      mode: EventCardMode.success,
      infoRows: [
        EventInfoRow(label: 'Views', value: compactNumber(views)),
        EventInfoRow(label: 'Revenue', value: currency(revenue)),
        EventInfoRow(label: 'Followers Gained', value: '+${compactNumber(followersGained)}'),
        EventInfoRow(label: 'Platform', value: platform),
      ],
      metadata: {
        'age': character.age,
        'eventKind': 'viral_video',
        'tier': 'premium',
        'sourceTitle': title,
        'totalFollowers': totalFollowers,
        'fameGain': fameGain,
      },
    );
  }

  static ActionEvent channelCreated({
    required Character character,
    required String platform,
    required String niche,
    required int followers,
  }) {
    return ActionEvent(
      title: 'CHANNEL CREATED',
      description: 'Your first audience is watching.',
      type: LifeEventType.positive,
      category: EventCategory.fame,
      mode: EventCardMode.success,
      infoRows: [
        EventInfoRow(label: 'Platform', value: platform),
        EventInfoRow(label: 'Niche', value: niche),
        EventInfoRow(label: 'Followers', value: compactNumber(followers)),
        const EventInfoRow(label: 'Monetization', value: 'Locked'),
      ],
      metadata: {'age': character.age, 'eventKind': 'channel_created', 'tier': 'good'},
    );
  }

  static ActionEvent verificationApproved({
    required Character character,
    required String platform,
    required int followers,
    required int fameBoost,
  }) {
    return ActionEvent(
      title: 'VERIFIED CREATOR',
      description: 'Your account received the official creator badge.',
      type: LifeEventType.positive,
      category: EventCategory.fame,
      mode: EventCardMode.success,
      infoRows: [
        EventInfoRow(label: 'Platform', value: platform),
        EventInfoRow(label: 'Followers', value: compactNumber(followers)),
        EventInfoRow(label: 'Fame Boost', value: '+$fameBoost'),
        const EventInfoRow(label: 'Status', value: 'Verified'),
      ],
      metadata: {'age': character.age, 'eventKind': 'verification_approved', 'tier': 'premium'},
    );
  }

  static ActionEvent verificationRejected({
    required Character character,
    required int requiredFollowers,
    required int currentFollowers,
  }) {
    return ActionEvent(
      title: 'VERIFICATION DENIED',
      description: 'Your audience is not large enough for verification yet.',
      type: LifeEventType.negative,
      category: EventCategory.fame,
      mode: EventCardMode.failure,
      infoRows: [
        EventInfoRow(label: 'Required', value: '${compactNumber(requiredFollowers)} Followers'),
        EventInfoRow(label: 'Current', value: compactNumber(currentFollowers)),
        EventInfoRow(label: 'Missing', value: compactNumber(requiredFollowers - currentFollowers)),
      ],
      metadata: {'age': character.age, 'eventKind': 'verification_rejected', 'tier': 'good'},
    );
  }

  static ActionEvent missionSuccess({
    required Character character,
    required String operation,
    required int respectGain,
    double reward = 15000,
  }) {
    return ActionEvent(
      title: 'MISSION ACCOMPLISHED',
      description: 'Your unit completed the operation with distinction.',
      type: LifeEventType.positive,
      category: EventCategory.military,
      mode: EventCardMode.success,
      infoRows: [
        EventInfoRow(label: 'Operation', value: operation),
        const EventInfoRow(label: 'Performance', value: 'Excellent'),
        EventInfoRow(label: 'Respect', value: '+$respectGain'),
        EventInfoRow(label: 'Reward', value: currency(reward)),
      ],
      metadata: {'age': character.age, 'eventKind': 'mission_success', 'tier': 'premium'},
    );
  }

  static ActionEvent missionFailure({
    required Character character,
    required String operation,
    required int healthLost,
    required int respectLost,
  }) {
    return ActionEvent(
      title: 'MISSION FAILED',
      description: 'Command opened a review after the operation went wrong.',
      type: LifeEventType.negative,
      category: EventCategory.military,
      mode: EventCardMode.failure,
      infoRows: [
        EventInfoRow(label: 'Operation', value: operation),
        EventInfoRow(label: 'Health Lost', value: '-$healthLost'),
        EventInfoRow(label: 'Respect Lost', value: '-$respectLost'),
        const EventInfoRow(label: 'Status', value: 'Under Review'),
      ],
      metadata: {'age': character.age, 'eventKind': 'mission_failure', 'tier': 'premium'},
    );
  }

  static ActionEvent militaryAward({
    required Character character,
    required String award,
    required int respectGain,
    required int performanceGain,
    double salaryBonus = 5000,
  }) {
    return ActionEvent(
      title: 'MILITARY MEDAL',
      description: 'Your service record earned formal recognition.',
      type: LifeEventType.positive,
      category: EventCategory.military,
      mode: EventCardMode.success,
      infoRows: [
        EventInfoRow(label: 'Award', value: award),
        EventInfoRow(label: 'Respect', value: '+$respectGain'),
        EventInfoRow(label: 'Performance', value: '+$performanceGain'),
        EventInfoRow(label: 'Salary Bonus', value: currency(salaryBonus)),
      ],
      metadata: {'age': character.age, 'eventKind': 'military_award', 'tier': 'premium'},
    );
  }

  static ActionEvent deploymentOrders({
    required Character character,
    String location = 'Kashmir',
    String duration = '12 Months',
    String dangerLevel = 'High',
    double allowance = 10000,
  }) {
    return ActionEvent(
      title: 'DEPLOYMENT ORDERS',
      description: 'Command assigned you to a high-alert forward posting.',
      type: LifeEventType.milestone,
      category: EventCategory.military,
      mode: EventCardMode.info,
      infoRows: [
        EventInfoRow(label: 'Location', value: location),
        EventInfoRow(label: 'Duration', value: duration),
        EventInfoRow(label: 'Danger Level', value: dangerLevel),
        EventInfoRow(label: 'Allowance', value: currency(allowance)),
      ],
      metadata: {'age': character.age, 'eventKind': 'deployment_orders', 'tier': 'premium'},
    );
  }

  static ActionEvent militaryRetirement({
    required Character character,
    required int yearsServed,
    required String finalRank,
    required double monthlyPension,
  }) {
    return ActionEvent(
      title: 'HONORABLE RETIREMENT',
      description: 'You completed a long military career with dignity.',
      type: LifeEventType.positive,
      category: EventCategory.military,
      mode: EventCardMode.success,
      infoRows: [
        EventInfoRow(label: 'Years Served', value: '$yearsServed'),
        EventInfoRow(label: 'Final Rank', value: finalRank),
        EventInfoRow(label: 'Pension', value: currency(monthlyPension)),
        const EventInfoRow(label: 'Respect', value: 'High'),
      ],
      metadata: {'age': character.age, 'eventKind': 'military_retirement', 'tier': 'premium'},
    );
  }

  static ActionEvent militaryInjury({
    required Character character,
    required String severity,
    required int healthLoss,
    required String guidance,
  }) {
    return failure(
      character: character,
      title: '$severity Injury',
      description: 'Service took a physical toll this year.',
      category: EventCategory.military,
      infoRows: [
        EventInfoRow(label: 'Health', value: '-$healthLoss'),
        EventInfoRow(label: 'Recovery', value: guidance),
      ],
    );
  }

  static ActionEvent politics({
    required Character character,
    required String title,
    required String description,
    required EventCardMode mode,
    List<EventInfoRow> infoRows = const [],
  }) {
    final type = mode == EventCardMode.failure
        ? LifeEventType.negative
        : LifeEventType.positive;
    return ActionEvent(
      title: title,
      description: description,
      type: type,
      category: EventCategory.politics,
      mode: mode,
      infoRows: infoRows,
      metadata: {'age': character.age, 'eventKind': 'politics', 'tier': 'good'},
    );
  }

  static ActionEvent electionVictory({
    required Character character,
    required String office,
    required int voteShare,
    required String opponent,
    required int turnout,
    required double campaignCost,
  }) {
    return ActionEvent(
      title: office == 'Prime Minister' ? 'PRIME MINISTER ELECTION' : 'ELECTION VICTORY',
      description: 'You won the mandate for $office.',
      type: LifeEventType.positive,
      category: EventCategory.politics,
      mode: EventCardMode.success,
      infoRows: [
        EventInfoRow(label: 'Office', value: office),
        EventInfoRow(label: 'Vote Share', value: '$voteShare%'),
        EventInfoRow(label: 'Opponent', value: opponent),
        const EventInfoRow(label: 'Term', value: '5 Years'),
      ],
      metadata: {
        'age': character.age,
        'eventKind': 'election_victory',
        'tier': 'premium',
        'turnout': turnout,
        'campaignCost': campaignCost,
      },
    );
  }

  static ActionEvent electionDefeat({
    required Character character,
    required String office,
    required int voteShare,
    required String opponent,
    required int voteMargin,
  }) {
    return ActionEvent(
      title: 'ELECTION DEFEAT',
      description: 'You lost the race for $office and need to rebuild.',
      type: LifeEventType.negative,
      category: EventCategory.politics,
      mode: EventCardMode.failure,
      infoRows: [
        EventInfoRow(label: 'Office', value: office),
        EventInfoRow(label: 'Vote Share', value: '$voteShare%'),
        EventInfoRow(label: 'Opponent', value: opponent),
        EventInfoRow(label: 'Vote Margin', value: '$voteMargin%'),
      ],
      metadata: {'age': character.age, 'eventKind': 'election_defeat', 'tier': 'premium'},
    );
  }

  static ActionEvent politicalScandal({
    required Character character,
    required String severity,
    required int trustLost,
    required int popularityLost,
    required String mediaCoverage,
  }) {
    return ActionEvent(
      title: 'POLITICAL SCANDAL',
      description: 'A scandal broke into the public conversation.',
      type: LifeEventType.negative,
      category: EventCategory.politics,
      mode: EventCardMode.failure,
      infoRows: [
        EventInfoRow(label: 'Severity', value: severity),
        EventInfoRow(label: 'Trust Lost', value: '-$trustLost'),
        EventInfoRow(label: 'Popularity Lost', value: '-$popularityLost'),
        EventInfoRow(label: 'Coverage', value: mediaCoverage),
      ],
      metadata: {'age': character.age, 'eventKind': 'political_scandal', 'tier': 'premium'},
    );
  }

  static ActionEvent cabinetAppointment({
    required Character character,
    required String position,
    required double salary,
    required int influenceGain,
  }) {
    return ActionEvent(
      title: 'CABINET APPOINTMENT',
      description: 'You were elevated into a powerful cabinet role.',
      type: LifeEventType.positive,
      category: EventCategory.politics,
      mode: EventCardMode.success,
      infoRows: [
        EventInfoRow(label: 'Position', value: position),
        EventInfoRow(label: 'Salary', value: currency(salary)),
        EventInfoRow(label: 'Influence', value: '+$influenceGain'),
        const EventInfoRow(label: 'Power', value: 'High'),
      ],
      metadata: {'age': character.age, 'eventKind': 'cabinet_appointment', 'tier': 'premium'},
    );
  }

  static ActionEvent examResult({
    required Character character,
    required String exam,
    required bool passed,
    int? rank,
    required int score,
    required int cutoff,
  }) {
    return ActionEvent(
      title: passed ? 'EXAM PASSED' : 'EXAM FAILED',
      description: passed
          ? 'You cleared $exam and opened the next path.'
          : 'You missed the $exam cutoff this attempt.',
      type: passed ? LifeEventType.positive : LifeEventType.negative,
      category: EventCategory.education,
      mode: passed ? EventCardMode.success : EventCardMode.failure,
      infoRows: [
        EventInfoRow(label: 'Exam', value: exam),
        EventInfoRow(label: 'Score', value: '$score%'),
        EventInfoRow(label: 'Cutoff', value: '$cutoff%'),
        if (rank != null) EventInfoRow(label: 'Rank', value: 'AIR $rank'),
        if (!passed) EventInfoRow(label: 'Missing', value: '${cutoff - score}%'),
      ],
      metadata: {'age': character.age, 'eventKind': 'exam_result', 'tier': passed ? 'premium' : 'good'},
    );
  }

  static ActionEvent graduation({
    required Character character,
    required String college,
    required String degree,
    required String gpa,
    required String careerUnlocks,
  }) {
    return ActionEvent(
      title: 'GRADUATED',
      description: 'You earned your $degree and unlocked new career paths.',
      type: LifeEventType.positive,
      category: EventCategory.education,
      mode: EventCardMode.success,
      infoRows: [
        EventInfoRow(label: 'College', value: college),
        EventInfoRow(label: 'Degree', value: degree),
        EventInfoRow(label: 'GPA', value: gpa),
        EventInfoRow(label: 'Career Unlocks', value: careerUnlocks),
      ],
      metadata: {'age': character.age, 'eventKind': 'graduation', 'tier': 'premium'},
    );
  }

  static ActionEvent universityAdmission({
    required Character character,
    required String university,
    required String program,
    required String duration,
    required double fees,
  }) {
    return ActionEvent(
      title: 'UNIVERSITY ADMISSION',
      description: 'You secured admission into $program at $university.',
      type: LifeEventType.milestone,
      category: EventCategory.education,
      mode: EventCardMode.success,
      infoRows: [
        EventInfoRow(label: 'University', value: university),
        EventInfoRow(label: 'Program', value: program),
        EventInfoRow(label: 'Duration', value: duration),
        EventInfoRow(label: 'Fees', value: currency(fees)),
      ],
      metadata: {'age': character.age, 'eventKind': 'university_admission', 'tier': 'premium'},
    );
  }

  static ActionEvent projectOffer({
    required Character character,
    required String client,
    required double payout,
    required String deadline,
    required String difficulty,
  }) {
    return ActionEvent(
      title: 'PROJECT OFFER',
      description: '$client wants to hire you for a freelance project.',
      type: LifeEventType.neutral,
      category: EventCategory.freelance,
      mode: EventCardMode.offer,
      infoRows: [
        EventInfoRow(label: 'Client', value: client),
        EventInfoRow(label: 'Payout', value: currency(payout)),
        EventInfoRow(label: 'Deadline', value: deadline),
        EventInfoRow(label: 'Difficulty', value: difficulty),
      ],
      metadata: {'age': character.age, 'eventKind': 'project_offer', 'tier': 'good', 'hasOfferData': true},
    );
  }

  static ActionEvent projectCompletion({
    required Character character,
    required String client,
    required double payment,
    required String rating,
    required int skillGain,
  }) {
    return ActionEvent(
      title: 'PROJECT COMPLETED',
      description: 'You delivered the project for $client.',
      type: LifeEventType.positive,
      category: EventCategory.freelance,
      mode: EventCardMode.success,
      infoRows: [
        EventInfoRow(label: 'Client', value: client),
        EventInfoRow(label: 'Payment', value: currency(payment)),
        EventInfoRow(label: 'Rating', value: rating),
        EventInfoRow(label: 'Skill Gain', value: '+$skillGain'),
      ],
      metadata: {'age': character.age, 'eventKind': 'project_completion', 'tier': 'premium'},
    );
  }

  static ActionEvent clientComplaint({
    required Character character,
    required String issue,
    required int reputationLost,
    String client = 'Startup Founder',
  }) {
    return ActionEvent(
      title: 'CLIENT COMPLAINT',
      description: 'A client complained about your freelance delivery.',
      type: LifeEventType.negative,
      category: EventCategory.freelance,
      mode: EventCardMode.failure,
      infoRows: [
        EventInfoRow(label: 'Issue', value: issue),
        EventInfoRow(label: 'Reputation Lost', value: '-$reputationLost'),
        EventInfoRow(label: 'Client', value: client),
      ],
      metadata: {'age': character.age, 'eventKind': 'client_complaint', 'tier': 'good'},
    );
  }

  static ActionEvent bonusPayment({
    required Character character,
    required String client,
    required double bonus,
    required String reason,
  }) {
    return ActionEvent(
      title: 'BONUS RECEIVED',
      description: '$client paid extra for standout work.',
      type: LifeEventType.positive,
      category: EventCategory.freelance,
      mode: EventCardMode.success,
      infoRows: [
        EventInfoRow(label: 'Client', value: client),
        EventInfoRow(label: 'Bonus', value: currency(bonus)),
        EventInfoRow(label: 'Reason', value: reason),
      ],
      metadata: {'age': character.age, 'eventKind': 'bonus_payment', 'tier': 'good'},
    );
  }

  static ActionEvent raiseReceived({
    required Character character,
    required double oldSalary,
    required double newSalary,
  }) {
    return ActionEvent(
      title: 'RAISE RECEIVED',
      description: 'Your employer increased your compensation after a strong review.',
      type: LifeEventType.positive,
      category: EventCategory.career,
      mode: EventCardMode.success,
      infoRows: [
        EventInfoRow(label: 'Old Salary', value: currency(oldSalary)),
        EventInfoRow(label: 'New Salary', value: currency(newSalary)),
        EventInfoRow(label: 'Increase', value: currency(newSalary - oldSalary)),
      ],
      metadata: {'age': character.age, 'eventKind': 'raise_received', 'tier': 'good'},
    );
  }

  static ActionEvent fired({
    required Character character,
    required String reason,
    required String position,
    required double incomeLost,
  }) {
    return ActionEvent(
      title: 'FIRED',
      description: 'Your employer terminated your role after performance concerns.',
      type: LifeEventType.negative,
      category: EventCategory.career,
      mode: EventCardMode.failure,
      infoRows: [
        EventInfoRow(label: 'Reason', value: reason),
        EventInfoRow(label: 'Position', value: position),
        EventInfoRow(label: 'Income Lost', value: currency(incomeLost)),
      ],
      metadata: {'age': character.age, 'eventKind': 'fired', 'tier': 'good'},
    );
  }

  static ActionEvent resignation({
    required Character character,
    required String position,
    required int yearsServed,
    required double severance,
  }) {
    return ActionEvent(
      title: 'RESIGNATION',
      description: 'You resigned and stepped back into the job market.',
      type: LifeEventType.neutral,
      category: EventCategory.career,
      mode: EventCardMode.info,
      infoRows: [
        EventInfoRow(label: 'Position', value: position),
        EventInfoRow(label: 'Years Served', value: '$yearsServed'),
        EventInfoRow(label: 'Severance', value: currency(severance)),
      ],
      metadata: {'age': character.age, 'eventKind': 'resignation', 'tier': 'good'},
    );
  }

  static ActionEvent joinParty({
    required Character character,
    required String party,
    required int influenceGain,
  }) {
    return ActionEvent(
      title: 'JOIN PARTY',
      description: 'You officially joined a political party as an active member.',
      type: LifeEventType.positive,
      category: EventCategory.politics,
      mode: EventCardMode.success,
      infoRows: [
        EventInfoRow(label: 'Party', value: party),
        EventInfoRow(label: 'Influence', value: '+$influenceGain'),
        const EventInfoRow(label: 'Membership', value: 'Active'),
      ],
      metadata: {'age': character.age, 'eventKind': 'join_party', 'tier': 'good'},
    );
  }

  static ActionEvent sponsorshipOffer({
    required Character character,
    required String brand,
    required double payout,
    required int followersBonus,
    String risk = 'Medium',
  }) {
    return ActionEvent(
      title: 'SPONSORSHIP OFFER',
      description: '$brand wants to sponsor your next post.',
      type: LifeEventType.neutral,
      category: EventCategory.fame,
      mode: EventCardMode.offer,
      infoRows: [
        EventInfoRow(label: 'Brand', value: brand),
        EventInfoRow(label: 'Payout', value: currency(payout)),
        EventInfoRow(label: 'Followers Bonus', value: '+${compactNumber(followersBonus)}'),
        EventInfoRow(label: 'Risk', value: risk),
        EventInfoRow(label: 'Reward', value: currency(payout)),
      ],
      metadata: {
        'age': character.age,
        'eventKind': 'sponsorship_offer',
        'tier': 'good',
        'hasOfferData': true,
      },
    );
  }

  static EventRequirement requirement({
    required String label,
    required bool isMet,
    required String current,
    required String requiredValue,
    required String guidance,
  }) {
    return EventRequirement(
      label: label,
      isMet: isMet,
      currentValue: current,
      requiredValue: requiredValue,
      guidance: guidance,
    );
  }

  static String money(num value) {
    return '${currency(value)}/yr';
  }

  static String currency(num value) {
    final rounded = value.round();
    final raw = rounded.toString();
    final negative = raw.startsWith('-');
    final digits = negative ? raw.substring(1) : raw;
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final fromRight = digits.length - i;
      buffer.write(digits[i]);
      if (fromRight > 1 && fromRight % 3 == 1) buffer.write(',');
    }
    return '₹${negative ? '-' : ''}${buffer.toString()}';
  }

  static String compactNumber(num value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.round().toString();
  }
  static ActionEvent movieReleased({
    required Character character,
    required String title,
    required String outcome,
    required int criticScore,
    required int audienceScore,
  }) {
    final isPositive = outcome == 'HIT' || outcome == 'SUPER HIT' || outcome == 'BLOCKBUSTER';
    final isNegative = outcome == 'FLOP';
    final type = isPositive ? LifeEventType.positive : (isNegative ? LifeEventType.negative : LifeEventType.neutral);
    final mode = isPositive ? EventCardMode.success : (isNegative ? EventCardMode.failure : EventCardMode.info);

    return ActionEvent(
      title: isNegative ? 'BOX OFFICE DISASTER' : 'MOVIE RELEASED',
      description: 'Your movie "$title" has hit theaters.',
      type: type,
      category: EventCategory.actor,
      mode: mode,
      infoRows: [
        EventInfoRow(label: 'Movie', value: title),
        EventInfoRow(label: 'Outcome', value: outcome),
        EventInfoRow(label: 'Critics', value: '$criticScore/100'),
        EventInfoRow(label: 'Audience', value: '$audienceScore/100'),
      ],
      metadata: {'age': character.age, 'eventKind': 'movie_released', 'tier': 'premium'},
    );
  }

  static ActionEvent tvPremiere({
    required Character character,
    required String title,
    required String outcome,
    required int criticScore,
    required int audienceScore,
  }) {
    final isPositive = outcome == 'HIT' || outcome == 'SUPER HIT' || outcome == 'BLOCKBUSTER';
    final isNegative = outcome == 'FLOP';
    final type = isPositive ? LifeEventType.positive : (isNegative ? LifeEventType.negative : LifeEventType.neutral);
    final mode = isPositive ? EventCardMode.success : (isNegative ? EventCardMode.failure : EventCardMode.info);

    return ActionEvent(
      title: isNegative ? 'CANCELLED AFTER PILOT' : 'TV SHOW PREMIERE',
      description: 'Your new show "$title" just premiered.',
      type: type,
      category: EventCategory.actor,
      mode: mode,
      infoRows: [
        EventInfoRow(label: 'Show', value: title),
        EventInfoRow(label: 'Outcome', value: outcome),
        EventInfoRow(label: 'Critics', value: '$criticScore/100'),
        EventInfoRow(label: 'Audience', value: '$audienceScore/100'),
      ],
      metadata: {'age': character.age, 'eventKind': 'tv_premiere', 'tier': 'premium'},
    );
  }

  static ActionEvent blockbusterHit({
    required Character character,
    required String title,
    required String type,
  }) {
    return ActionEvent(
      title: 'BLOCKBUSTER HIT',
      description: 'Your $type "$title" has shattered box office records!',
      type: LifeEventType.positive,
      category: EventCategory.actor,
      mode: EventCardMode.success,
      infoRows: [
        EventInfoRow(label: 'Title', value: title),
        const EventInfoRow(label: 'Status', value: 'Global Phenomenon'),
      ],
      emojiIllustration: '🌟',
      metadata: {'age': character.age, 'eventKind': 'blockbuster_hit', 'tier': 'premium'},
    );
  }

  static ActionEvent careerDefiningPerformance({
    required Character character,
    required String title,
  }) {
    return ActionEvent(
      title: 'CAREER DEFINING PERFORMANCE',
      description: 'Critics are calling your role in "$title" the performance of a lifetime.',
      type: LifeEventType.rare,
      category: EventCategory.actor,
      mode: EventCardMode.success,
      infoRows: [
        EventInfoRow(label: 'Title', value: title),
        const EventInfoRow(label: 'Impact', value: 'Overnight Sensation'),
        const EventInfoRow(label: 'Fame Boost', value: 'Massive'),
      ],
      emojiIllustration: '🎭',
      metadata: {'age': character.age, 'eventKind': 'career_defining_performance', 'tier': 'premium'},
    );
  }

  static ActionEvent awardNomination({
    required Character character,
    required String awardName,
    required String projectTitle,
    required String category,
    required int priority,
  }) {
    return ActionEvent(
      title: 'AWARD NOMINATION',
      description: 'Your performance in "$projectTitle" earned a $awardName nomination.',
      type: LifeEventType.milestone,
      category: EventCategory.actor,
      mode: EventCardMode.success,
      infoRows: [
        EventInfoRow(label: 'Award', value: awardName),
        EventInfoRow(label: 'Project', value: projectTitle),
        EventInfoRow(label: 'Category', value: category),
        const EventInfoRow(label: 'Result', value: 'Nominated'),
      ],
      metadata: {
        'age': character.age,
        'eventKind': 'award_nomination',
        'tier': 'premium',
        'popupEligible': true,
        'popupPriority': priority,
      },
    );
  }

  static ActionEvent awardWon({
    required Character character,
    required String awardName,
    required String projectTitle,
    required String category,
    required int priority,
  }) {
    return ActionEvent(
      title: '${awardName.toUpperCase()} WIN',
      description: 'You won $awardName for "$projectTitle".',
      type: LifeEventType.rare,
      category: EventCategory.actor,
      mode: EventCardMode.success,
      infoRows: [
        EventInfoRow(label: 'Award', value: awardName),
        EventInfoRow(label: 'Project', value: projectTitle),
        EventInfoRow(label: 'Category', value: category),
        const EventInfoRow(label: 'Result', value: 'Won'),
      ],
      metadata: {
        'age': character.age,
        'eventKind': 'award_won',
        'tier': 'premium',
        'popupEligible': true,
        'popupPriority': priority,
      },
    );
  }

  static ActionEvent risingStarAward({
    required Character character,
    required String awardName,
  }) {
    return ActionEvent(
      title: 'RISING STAR AWARD',
      description: 'The industry named you one of its brightest new stars.',
      type: LifeEventType.rare,
      category: EventCategory.actor,
      mode: EventCardMode.success,
      infoRows: [
        EventInfoRow(label: 'Award', value: awardName),
        const EventInfoRow(label: 'Recognition', value: 'Breakthrough Talent'),
        const EventInfoRow(label: 'Fame', value: '+15'),
      ],
      metadata: {
        'age': character.age,
        'eventKind': 'rising_star_award',
        'tier': 'premium',
        'popupEligible': true,
        'popupPriority': 95,
      },
    );
  }

  static ActionEvent nationalIconAward({
    required Character character,
    required String awardName,
  }) {
    return ActionEvent(
      title: 'NATIONAL ICON',
      description: 'Your career has become part of the national conversation.',
      type: LifeEventType.critical,
      category: EventCategory.actor,
      mode: EventCardMode.success,
      infoRows: [
        EventInfoRow(label: 'Award', value: awardName),
        const EventInfoRow(label: 'Status', value: 'National Icon'),
        const EventInfoRow(label: 'Reputation', value: '+10'),
      ],
      metadata: {
        'age': character.age,
        'eventKind': 'national_icon_award',
        'tier': 'premium',
        'popupEligible': true,
        'popupPriority': 100,
      },
    );
  }

  static ActionEvent careerAchievementAward({
    required Character character,
    required String awardName,
  }) {
    return ActionEvent(
      title: 'CAREER ACHIEVEMENT AWARD',
      description: 'The industry honored your body of work and lasting influence.',
      type: LifeEventType.critical,
      category: EventCategory.actor,
      mode: EventCardMode.success,
      infoRows: [
        EventInfoRow(label: 'Award', value: awardName),
        const EventInfoRow(label: 'Recognition', value: 'Lifetime Contribution'),
        const EventInfoRow(label: 'Reputation', value: '+20'),
      ],
      metadata: {
        'age': character.age,
        'eventKind': 'career_achievement_award',
        'tier': 'premium',
        'popupEligible': true,
        'popupPriority': 100,
      },
    );
  }

  // ── Phase 7: Agency & Stardom Events ──────────────────────

  static ActionEvent agencyOffer({
    required Character character,
    required String agencyName,
  }) {
    return ActionEvent(
      title: 'AGENCY OFFER',
      description: '$agencyName has expressed interest in representing you.',
      type: LifeEventType.positive,
      category: EventCategory.actor,
      mode: EventCardMode.info,
      infoRows: [
        EventInfoRow(label: 'Agency', value: agencyName),
        const EventInfoRow(label: 'Status', value: 'Offer Received'),
      ],
      metadata: {
        'age': character.age,
        'eventKind': 'agency_offer',
        'tier': 'premium',
        'popupEligible': true,
        'popupPriority': 75,
      },
    );
  }

  static ActionEvent agencySigned({
    required Character character,
    required String agencyName,
  }) {
    return ActionEvent(
      title: 'SIGNED BY AGENCY',
      description: 'You are now officially represented by $agencyName.',
      type: LifeEventType.milestone,
      category: EventCategory.actor,
      mode: EventCardMode.success,
      infoRows: [
        EventInfoRow(label: 'Agency', value: agencyName),
        const EventInfoRow(label: 'Status', value: 'Under Contract'),
      ],
      emojiIllustration: '🤝',
      metadata: {
        'age': character.age,
        'eventKind': 'agency_signed',
        'tier': 'premium',
        'popupEligible': true,
        'popupPriority': 85,
      },
    );
  }

  static ActionEvent agencyDropped({
    required Character character,
    required String agencyName,
  }) {
    return ActionEvent(
      title: 'DROPPED BY AGENCY',
      description: '$agencyName has terminated your representation.',
      type: LifeEventType.negative,
      category: EventCategory.actor,
      mode: EventCardMode.failure,
      infoRows: [
        EventInfoRow(label: 'Agency', value: agencyName),
        const EventInfoRow(label: 'Status', value: 'Contract Ended'),
      ],
      metadata: {
        'age': character.age,
        'eventKind': 'agency_dropped',
        'tier': 'premium',
        'popupEligible': true,
        'popupPriority': 80,
      },
    );
  }

  static ActionEvent stardomPromotion({
    required Character character,
    required String newTier,
  }) {
    return ActionEvent(
      title: '${newTier.toUpperCase()} STATUS',
      description: 'The industry now recognizes you as a $newTier.',
      type: LifeEventType.milestone,
      category: EventCategory.actor,
      mode: EventCardMode.success,
      infoRows: [
        EventInfoRow(label: 'New Tier', value: newTier),
        const EventInfoRow(label: 'Impact', value: 'Better Projects Unlocked'),
      ],
      emojiIllustration: '⭐',
      metadata: {
        'age': character.age,
        'eventKind': 'stardom_promotion',
        'tier': 'premium',
        'popupEligible': true,
        'popupPriority': 90,
      },
    );
  }

  static ActionEvent legendStatus({
    required Character character,
  }) {
    return ActionEvent(
      title: 'LEGEND STATUS',
      description: 'You have achieved what few actors ever do. You are now a Legend of the industry.',
      type: LifeEventType.critical,
      category: EventCategory.actor,
      mode: EventCardMode.success,
      infoRows: [
        const EventInfoRow(label: 'Tier', value: 'Legend'),
        const EventInfoRow(label: 'Access', value: 'All Projects Unlocked'),
        const EventInfoRow(label: 'Legacy', value: 'Eternal'),
      ],
      emojiIllustration: '👑',
      metadata: {
        'age': character.age,
        'eventKind': 'legend_status',
        'tier': 'premium',
        'popupEligible': true,
        'popupPriority': 100,
      },
    );
  }
}
