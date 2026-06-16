import '../../../models/character.dart';
import '../../../models/smart_event.dart';
import '../../enums.dart';

class _PremiumSpec {
  final String title;
  final String desc;
  final String type;
  final String category;
  final EventRarity rarity;
  final int minAge;
  final int maxAge;
  final double weight;

  const _PremiumSpec(
    this.title,
    this.desc,
    this.type,
    this.category,
    this.rarity, {
    this.minAge = 0,
    this.maxAge = 120,
    this.weight = 2,
  });
}

final List<SmartEvent> premiumPhase2Events =
    _premiumPhase2Specs.map(_premiumEvent).toList(growable: false);

SmartEvent _premiumEvent(_PremiumSpec spec) {
  final negative = _isNegative(spec.title);
  final legendary = spec.rarity == EventRarity.legendary;
  final epic = spec.rarity == EventRarity.epic;

  return SmartEvent(
    title: spec.title,
    desc: spec.desc,
    type: spec.type,
    category: spec.category,
    rarity: spec.rarity,
    weight: legendary ? 0.4 : spec.weight,
    happiness: negative
        ? (epic ? -35 : -24)
        : (legendary
            ? 55
            : epic
                ? 35
                : 22),
    health: _healthDelta(spec, negative),
    smarts: _smartsDelta(spec),
    social: _socialDelta(spec, negative),
    karma: _karmaDelta(spec, negative),
    money: _moneyDelta(spec, negative),
    fame: _fameDelta(spec, negative),
    stressLevel: negative ? (epic ? 38 : 24) : (legendary ? -20 : -8),
    discipline: _disciplineDelta(spec),
    reputation: negative
        ? (epic ? -28 : -16)
        : (legendary
            ? 42
            : epic
                ? 26
                : 14),
    cond: (c) => _conditionFor(c, spec),
  );
}

bool _conditionFor(Character c, _PremiumSpec spec) {
  if (c.age < spec.minAge || c.age > spec.maxAge) return false;

  switch (spec.type) {
    case 'Military':
      return c.careerGroup == 'Military';
    case 'Politics':
      return c.careerGroup == 'Government' || c.careerGroup == 'Politician';
    case 'Influencer':
      return c.careerGroup == 'Influencer' ||
          c.jobTitle == 'Influencer' ||
          c.followers >= 5000 ||
          c.fame >= 30;
    case 'Business':
      return c.careerGroup == 'Business' ||
          c.jobTitle.contains('Founder') ||
          c.jobTitle.contains('CEO') ||
          c.bankBalance >= 500000;
    case 'Relationships':
      return c.age >= 16;
    case 'Family':
      return c.age >= 18;
    case 'Health':
      return c.age >= 12;
  }
  return true;
}

bool _isNegative(String title) {
  final lower = title.toLowerCase();
  return lower.contains('scandal') ||
      lower.contains('suspension') ||
      lower.contains('backlash') ||
      lower.contains('attack') ||
      lower.contains('theft') ||
      lower.contains('lawsuit') ||
      lower.contains('crash') ||
      lower.contains('bankruptcy') ||
      lower.contains('recall') ||
      lower.contains('strike') ||
      lower.contains('risk') ||
      lower.contains('disaster') ||
      lower.contains('betrayal') ||
      lower.contains('argument') ||
      lower.contains('breakup') ||
      lower.contains('illness') ||
      lower.contains('injury') ||
      lower.contains('burnout') ||
      lower.contains('surgery') ||
      lower.contains('chronic') ||
      lower.contains('tribunal') ||
      lower.contains('missing') ||
      lower.contains('investigation') ||
      lower.contains('friendly fire') ||
      lower.contains('funeral');
}

int _healthDelta(_PremiumSpec spec, bool negative) {
  if (spec.type == 'Health') return negative ? -28 : 24;
  if (spec.type == 'Military' && negative) return -18;
  if (spec.title.contains('Fitness') || spec.title.contains('Marathon'))
    return 22;
  return 0;
}

int _smartsDelta(_PremiumSpec spec) {
  if (spec.title.contains('Intelligence') ||
      spec.title.contains('Policy') ||
      spec.title.contains('Academy') ||
      spec.title.contains('Scientific') ||
      spec.title.contains('Breakthrough')) return 12;
  if (spec.type == 'Business' || spec.type == 'Politics') return 6;
  return 0;
}

int _socialDelta(_PremiumSpec spec, bool negative) {
  if (spec.type == 'Relationships' || spec.type == 'Family') {
    return negative ? -18 : 22;
  }
  if (spec.title.contains('Summit') || spec.title.contains('Meetup')) return 16;
  return 0;
}

int _karmaDelta(_PremiumSpec spec, bool negative) {
  if (spec.title.contains('Rescue') ||
      spec.title.contains('Peace') ||
      spec.title.contains('Donation') ||
      spec.title.contains('Caregiving') ||
      spec.title.contains('Anti-Corruption')) return 20;
  return negative ? -12 : 0;
}

double _moneyDelta(_PremiumSpec spec, bool negative) {
  if (negative) {
    if (spec.type == 'Business') return -2500000;
    if (spec.type == 'Family') return -300000;
    return -100000;
  }
  if (spec.rarity == EventRarity.legendary) return 50000000;
  if (spec.rarity == EventRarity.epic) return 5000000;
  if (spec.type == 'Business') return 1500000;
  if (spec.type == 'Influencer') return 750000;
  return 150000;
}

int _fameDelta(_PremiumSpec spec, bool negative) {
  if (negative) return -12;
  if (spec.rarity == EventRarity.legendary) return 45;
  if (spec.rarity == EventRarity.epic) return 28;
  if (spec.type == 'Health') return 4;
  return 16;
}

int _disciplineDelta(_PremiumSpec spec) {
  if (spec.type == 'Military' || spec.type == 'Health') return 12;
  if (spec.title.contains('Training') || spec.title.contains('Recovery'))
    return 16;
  return 0;
}

const List<_PremiumSpec> _premiumPhase2Specs = [
  _PremiumSpec(
      'Border Skirmish',
      'A tense patrol turned into a real exchange of fire, and your decisions kept the unit alive.',
      'Military',
      'frontline_combat',
      EventRarity.rare,
      minAge: 20),
  _PremiumSpec(
      'Classified Mission',
      'You were briefed in a sealed room and sent on an operation your family may never hear about.',
      'Military',
      'classified_ops',
      EventRarity.epic,
      minAge: 24),
  _PremiumSpec(
      'Hostage Rescue',
      'Your team stormed a compound and brought civilians home before the deadline expired.',
      'Military',
      'rescue_operation',
      EventRarity.epic,
      minAge: 24),
  _PremiumSpec(
      'Military Intelligence Assignment',
      'Command moved you into intelligence work after noticing your pattern-reading under pressure.',
      'Military',
      'intelligence',
      EventRarity.rare,
      minAge: 25),
  _PremiumSpec(
      'Anti-Terror Operation',
      'You helped dismantle a terror cell before it could strike a crowded public place.',
      'Military',
      'counter_terror',
      EventRarity.epic,
      minAge: 25),
  _PremiumSpec(
      'UN Peacekeeping Award',
      'A UN commander recognized your restraint and courage during a volatile peacekeeping mission.',
      'Military',
      'peacekeeping',
      EventRarity.epic,
      minAge: 28),
  _PremiumSpec(
      'Friendly Fire Investigation',
      'A chaotic night operation led to a friendly fire inquiry, and your testimony could end careers.',
      'Military',
      'military_integrity',
      EventRarity.rare,
      minAge: 22),
  _PremiumSpec(
      'Military Academy Instructor',
      'You were invited back to the academy to shape the next generation of officers.',
      'Military',
      'training_command',
      EventRarity.rare,
      minAge: 32),
  _PremiumSpec(
      'War Hero Recognition',
      'Veterans, families, and reporters gathered as your wartime bravery was formally recognized.',
      'Military',
      'war_legacy',
      EventRarity.legendary,
      minAge: 28),
  _PremiumSpec(
      'Gallantry Medal',
      'Your conduct under fire earned a gallantry medal and permanent respect from your regiment.',
      'Military',
      'gallantry',
      EventRarity.epic,
      minAge: 25),
  _PremiumSpec(
      'Param Vir Chakra Citation',
      'The highest battlefield honor was placed beside your name after impossible courage.',
      'Military',
      'highest_gallantry',
      EventRarity.legendary,
      minAge: 25),
  _PremiumSpec(
      'Injury Rehabilitation',
      'Months of painful rehabilitation gave you a second chance at active duty.',
      'Military',
      'recovery',
      EventRarity.rare,
      minAge: 22),
  _PremiumSpec(
      'Missing In Action',
      'Your unit lost contact during an operation, and the country waited for news of your survival.',
      'Military',
      'combat_crisis',
      EventRarity.epic,
      minAge: 22),
  _PremiumSpec(
      'Military Tribunal',
      'A tribunal reviewed your battlefield choices, forcing you to defend every decision.',
      'Military',
      'military_law',
      EventRarity.rare,
      minAge: 24),
  _PremiumSpec(
      'Secret Commendation',
      'A senior officer quietly handed you a sealed commendation for a mission that cannot go public.',
      'Military',
      'classified_recognition',
      EventRarity.epic,
      minAge: 26),
  _PremiumSpec(
      'Presidential Military Recognition',
      'The President personally recognized your service before the nation.',
      'Military',
      'national_honor',
      EventRarity.legendary,
      minAge: 30),
  _PremiumSpec(
      'Foreign Training Program',
      'You were selected for elite training with a foreign military unit.',
      'Military',
      'foreign_training',
      EventRarity.rare,
      minAge: 24),
  _PremiumSpec(
      'International Exercise',
      'Your performance during a multinational exercise put your regiment in the global spotlight.',
      'Military',
      'international_exercise',
      EventRarity.rare,
      minAge: 24),
  _PremiumSpec(
      'Nuclear Security Detail',
      'You were assigned to protect one of the nation’s most sensitive strategic sites.',
      'Military',
      'strategic_security',
      EventRarity.epic,
      minAge: 28),
  _PremiumSpec(
      'Special Forces Graduation',
      'You completed the brutal final course and earned your place among special forces.',
      'Military',
      'special_forces',
      EventRarity.epic,
      minAge: 23),
  _PremiumSpec(
      'Combat Rescue',
      'You crossed exposed ground to pull wounded comrades out of fire.',
      'Military',
      'combat_rescue',
      EventRarity.epic,
      minAge: 22),
  _PremiumSpec(
      'Survival Training',
      'A harsh survival course stripped away comfort and rebuilt your discipline.',
      'Military',
      'survival',
      EventRarity.rare,
      minAge: 20),
  _PremiumSpec(
      'Veteran Recognition',
      'The community honored your service after years of sacrifice and silence.',
      'Military',
      'veteran_legacy',
      EventRarity.rare,
      minAge: 45),
  _PremiumSpec(
      'Honor Guard Selection',
      'You were selected for an honor guard at a historic national ceremony.',
      'Military',
      'ceremonial_honor',
      EventRarity.rare,
      minAge: 22),
  _PremiumSpec(
      'Military Funeral Duty',
      'You carried a fallen soldier home, a duty that changed how you understood service.',
      'Military',
      'sacrifice',
      EventRarity.rare,
      minAge: 22),
  _PremiumSpec(
      'Join Opposition',
      'You broke with the ruling faction and joined the opposition at real political cost.',
      'Politics',
      'party_strategy',
      EventRarity.rare,
      minAge: 25),
  _PremiumSpec(
      'Cabinet Reshuffle',
      'A sudden reshuffle placed your allies and rivals in dangerous new positions.',
      'Politics',
      'cabinet_power',
      EventRarity.rare,
      minAge: 30),
  _PremiumSpec(
      'Corruption Investigation',
      'Investigators opened files on your office, and every signature is now being questioned.',
      'Politics',
      'integrity_crisis',
      EventRarity.epic,
      minAge: 28),
  _PremiumSpec(
      'Public Approval Surge',
      'A bold public stand sent your approval numbers soaring overnight.',
      'Politics',
      'public_mandate',
      EventRarity.rare,
      minAge: 25),
  _PremiumSpec(
      'Media Scandal',
      'A leaked clip dominated every channel and forced your team into crisis mode.',
      'Politics',
      'media_crisis',
      EventRarity.rare,
      minAge: 25),
  _PremiumSpec(
      'Election Debate',
      'You faced your strongest rival in a debate watched across the state.',
      'Politics',
      'election_stage',
      EventRarity.rare,
      minAge: 25),
  _PremiumSpec(
      'National Address',
      'You addressed the nation during a moment of fear and uncertainty.',
      'Politics',
      'national_leadership',
      EventRarity.epic,
      minAge: 35),
  _PremiumSpec(
      'Parliamentary Walkout',
      'You led a walkout that became the image of the legislative session.',
      'Politics',
      'parliament_pressure',
      EventRarity.rare,
      minAge: 28),
  _PremiumSpec(
      'Political Defection',
      'Crossing the aisle brought power, enemies, and permanent questions about loyalty.',
      'Politics',
      'defection',
      EventRarity.epic,
      minAge: 30),
  _PremiumSpec(
      'Protest Movement',
      'A protest movement gathered around your words and forced the government to respond.',
      'Politics',
      'mass_movement',
      EventRarity.epic,
      minAge: 25),
  _PremiumSpec(
      'Emergency Declaration',
      'A crisis forced you into emergency powers that history will judge harshly.',
      'Politics',
      'constitutional_crisis',
      EventRarity.legendary,
      minAge: 35),
  _PremiumSpec(
      'Coalition Government',
      'You negotiated a fragile coalition that could either stabilize the state or collapse spectacularly.',
      'Politics',
      'coalition',
      EventRarity.epic,
      minAge: 30),
  _PremiumSpec(
      'Policy Success',
      'A policy you championed delivered real results and changed public opinion.',
      'Politics',
      'policy_win',
      EventRarity.rare,
      minAge: 28),
  _PremiumSpec(
      'Policy Disaster',
      'Your flagship policy backfired, hurting citizens and your credibility.',
      'Politics',
      'policy_failure',
      EventRarity.epic,
      minAge: 28),
  _PremiumSpec(
      'Anti-Corruption Drive',
      'You launched a crackdown that terrified fixers and thrilled ordinary voters.',
      'Politics',
      'reform',
      EventRarity.epic,
      minAge: 30),
  _PremiumSpec(
      'Party Leadership Race',
      'You entered the race to lead the party, risking every alliance you have built.',
      'Politics',
      'party_leadership',
      EventRarity.epic,
      minAge: 32),
  _PremiumSpec(
      'Chief Minister Election',
      'Your party won the state and lawmakers chose you as Chief Minister.',
      'Politics',
      'state_power',
      EventRarity.legendary,
      minAge: 35),
  _PremiumSpec(
      'Prime Minister Election Mandate',
      'A national mandate carried you to the Prime Minister’s office.',
      'Politics',
      'national_power',
      EventRarity.legendary,
      minAge: 40),
  _PremiumSpec(
      'Presidential Recognition',
      'The President recognized your public service in a formal ceremony.',
      'Politics',
      'constitutional_honor',
      EventRarity.epic,
      minAge: 35),
  _PremiumSpec(
      'International Summit',
      'You represented the country at a summit where every handshake mattered.',
      'Politics',
      'diplomacy',
      EventRarity.epic,
      minAge: 35),
  _PremiumSpec(
      'State Visit',
      'A foreign state visit turned into a defining moment for your public image.',
      'Politics',
      'state_visit',
      EventRarity.epic,
      minAge: 35),
  _PremiumSpec(
      'Foreign Policy Victory',
      'Your diplomatic gamble paid off and shifted the regional balance.',
      'Politics',
      'foreign_policy',
      EventRarity.legendary,
      minAge: 38),
  _PremiumSpec(
      'No Confidence Motion',
      'Your government faced a no confidence motion that could end everything.',
      'Politics',
      'survival_vote',
      EventRarity.epic,
      minAge: 32),
  _PremiumSpec(
      'Cabinet Appointment Triumph',
      'You were appointed to cabinet after years of disciplined political work.',
      'Politics',
      'cabinet_appointment',
      EventRarity.epic,
      minAge: 32),
  _PremiumSpec(
      'Lifetime Political Achievement',
      'Across decades, your political career became a chapter in public memory.',
      'Politics',
      'political_legacy',
      EventRarity.legendary,
      minAge: 60),
  _PremiumSpec(
      'Overnight Viral Fame',
      'You woke up to millions of views, interview requests, and strangers repeating your line.',
      'Influencer',
      'viral_breakout',
      EventRarity.epic,
      minAge: 16),
  _PremiumSpec(
      'Massive Collaboration',
      'A major creator invited you into a collaboration that changed your audience overnight.',
      'Influencer',
      'creator_network',
      EventRarity.rare,
      minAge: 16),
  _PremiumSpec(
      'Celebrity Collaboration',
      'A film star appeared in your content and turned your channel into national conversation.',
      'Influencer',
      'celebrity_collab',
      EventRarity.epic,
      minAge: 18),
  _PremiumSpec(
      'Brand Ambassador',
      'A national brand signed you as an official ambassador.',
      'Influencer',
      'brand_power',
      EventRarity.epic,
      minAge: 18),
  _PremiumSpec(
      'Major Sponsorship',
      'A sponsor offered life-changing money, but every post now carries expectations.',
      'Influencer',
      'major_sponsorship',
      EventRarity.epic,
      minAge: 18),
  _PremiumSpec(
      'Controversial Tweet',
      'One impulsive tweet became a week-long public trial of your character.',
      'Influencer',
      'online_crisis',
      EventRarity.rare,
      minAge: 16),
  _PremiumSpec(
      'Platform Suspension',
      'Your primary account was suspended during the most important week of your career.',
      'Influencer',
      'platform_risk',
      EventRarity.epic,
      minAge: 16),
  _PremiumSpec(
      'Verified Creator',
      'The blue check arrived, and with it came legitimacy and pressure.',
      'Influencer',
      'verification',
      EventRarity.rare,
      minAge: 16),
  _PremiumSpec(
      '1 Million Followers',
      'Your follower count crossed one million, a number that once felt impossible.',
      'Influencer',
      'audience_milestone',
      EventRarity.epic,
      minAge: 16),
  _PremiumSpec(
      '10 Million Followers',
      'Ten million people now follow your every move online.',
      'Influencer',
      'mass_audience',
      EventRarity.legendary,
      minAge: 18),
  _PremiumSpec(
      'Fan Meetup',
      'A simple fan meetup overflowed into a crowd control challenge.',
      'Influencer',
      'fan_moment',
      EventRarity.rare,
      minAge: 16),
  _PremiumSpec(
      'Public Backlash',
      'A wave of backlash hit your comments, sponsors, and confidence at once.',
      'Influencer',
      'backlash',
      EventRarity.rare,
      minAge: 16),
  _PremiumSpec(
      'Cancel Culture',
      'Old content resurfaced and the internet demanded consequences.',
      'Influencer',
      'cancellation',
      EventRarity.epic,
      minAge: 16),
  _PremiumSpec(
      'Trendsetter Award',
      'You received an award for shaping what an entire generation copied next.',
      'Influencer',
      'trend_award',
      EventRarity.epic,
      minAge: 18),
  _PremiumSpec(
      'Documentary Feature',
      'A documentary crew followed your life and revealed the cost of fame.',
      'Influencer',
      'documentary',
      EventRarity.epic,
      minAge: 18),
  _PremiumSpec(
      'Interview Invitation',
      'A respected interviewer invited you for a long-form conversation about your rise.',
      'Influencer',
      'media_profile',
      EventRarity.rare,
      minAge: 16),
  _PremiumSpec(
      'TV Appearance',
      'You appeared on prime-time television and reached families who had never heard of you.',
      'Influencer',
      'television',
      EventRarity.epic,
      minAge: 18),
  _PremiumSpec(
      'Podcast Explosion',
      'A podcast episode went viral and reframed your entire public image.',
      'Influencer',
      'podcast',
      EventRarity.rare,
      minAge: 16),
  _PremiumSpec(
      'Fan Gift',
      'A heartfelt fan gift reminded you that your work helped someone survive a hard year.',
      'Influencer',
      'fan_connection',
      EventRarity.rare,
      minAge: 16),
  _PremiumSpec(
      'Hacker Attack',
      'Hackers hijacked your account and threatened to erase years of work.',
      'Influencer',
      'cyber_attack',
      EventRarity.epic,
      minAge: 16),
  _PremiumSpec(
      'Content Theft',
      'A bigger creator stole your idea and received the credit you deserved.',
      'Influencer',
      'creative_theft',
      EventRarity.rare,
      minAge: 16),
  _PremiumSpec(
      'Award Show Invitation',
      'Your name appeared on the guest list for a major creator award show.',
      'Influencer',
      'award_invite',
      EventRarity.rare,
      minAge: 18),
  _PremiumSpec(
      'Creator Of The Year',
      'You won Creator of the Year and proved the grind was not invisible.',
      'Influencer',
      'creator_award',
      EventRarity.legendary,
      minAge: 18),
  _PremiumSpec(
      'Global Fame',
      'Your content crossed borders and made you recognizable far beyond home.',
      'Influencer',
      'global_fame',
      EventRarity.legendary,
      minAge: 18),
  _PremiumSpec(
      'Internet Legend',
      'Your name became shorthand for an entire era of the internet.',
      'Influencer',
      'internet_legacy',
      EventRarity.legendary,
      minAge: 21),
  _PremiumSpec(
      'Startup Launch',
      'You launched your startup with savings, fear, and one stubborn belief.',
      'Business',
      'startup',
      EventRarity.rare,
      minAge: 21),
  _PremiumSpec(
      'Angel Investor Round',
      'An angel investor backed your idea before the market believed in it.',
      'Business',
      'angel_round',
      EventRarity.rare,
      minAge: 21),
  _PremiumSpec(
      'Venture Capital Funding',
      'A venture firm wired a huge cheque and asked you to grow faster than feels sane.',
      'Business',
      'venture_capital',
      EventRarity.epic,
      minAge: 22),
  _PremiumSpec(
      'Seed Round',
      'Your seed round closed, giving the team enough runway to chase the impossible.',
      'Business',
      'seed_round',
      EventRarity.rare,
      minAge: 21),
  _PremiumSpec(
      'Series A',
      'Series A funding turned your scrappy company into a serious contender.',
      'Business',
      'series_a',
      EventRarity.epic,
      minAge: 23),
  _PremiumSpec(
      'Unicorn Startup',
      'Your company crossed unicorn valuation and changed your life in one board meeting.',
      'Business',
      'unicorn',
      EventRarity.legendary,
      minAge: 24),
  _PremiumSpec(
      'Business Expansion',
      'You opened a second market and proved the business was not a one-city miracle.',
      'Business',
      'expansion',
      EventRarity.rare,
      minAge: 24),
  _PremiumSpec(
      'Franchise Offer',
      'Investors offered to franchise your business across multiple cities.',
      'Business',
      'franchise',
      EventRarity.rare,
      minAge: 24),
  _PremiumSpec(
      'Acquisition Offer',
      'A larger company offered to buy your business for a number that made you sit down.',
      'Business',
      'acquisition',
      EventRarity.epic,
      minAge: 25),
  _PremiumSpec(
      'Competitor Attack',
      'A ruthless competitor copied your product and undercut your pricing overnight.',
      'Business',
      'competition',
      EventRarity.rare,
      minAge: 22),
  _PremiumSpec(
      'Bankruptcy Risk',
      'A cash crunch left payroll, rent, and your reputation hanging by a thread.',
      'Business',
      'bankruptcy_risk',
      EventRarity.epic,
      minAge: 22),
  _PremiumSpec(
      'Product Recall Crisis',
      'A defect forced a product recall that tested your ethics and finances.',
      'Business',
      'product_recall',
      EventRarity.epic,
      minAge: 22),
  _PremiumSpec(
      'Record Profit',
      'Your company posted record profit and the office erupted like a stadium.',
      'Business',
      'record_profit',
      EventRarity.epic,
      minAge: 24),
  _PremiumSpec(
      'Market Crash',
      'A market crash wiped out demand and forced emergency survival decisions.',
      'Business',
      'market_crash',
      EventRarity.epic,
      minAge: 22),
  _PremiumSpec(
      'Stock Market Boom',
      'A boom lifted your holdings and gave you the capital to move boldly.',
      'Business',
      'market_boom',
      EventRarity.rare,
      minAge: 22),
  _PremiumSpec(
      'Global Expansion',
      'Your business entered an international market and became a global story.',
      'Business',
      'global_expansion',
      EventRarity.legendary,
      minAge: 28),
  _PremiumSpec(
      'New Headquarters',
      'You opened a headquarters that made employees feel part of something permanent.',
      'Business',
      'headquarters',
      EventRarity.rare,
      minAge: 25),
  _PremiumSpec(
      'IPO Filing',
      'Your company filed for IPO, exposing every number and decision to public scrutiny.',
      'Business',
      'ipo_filing',
      EventRarity.epic,
      minAge: 28),
  _PremiumSpec(
      'IPO Success',
      'The IPO opened strong and turned years of risk into generational wealth.',
      'Business',
      'ipo_success',
      EventRarity.legendary,
      minAge: 30),
  _PremiumSpec(
      'Billionaire Status Confirmed',
      'Your net worth crossed billionaire status and the world started measuring you differently.',
      'Business',
      'billionaire',
      EventRarity.legendary,
      minAge: 30),
  _PremiumSpec(
      'Rich List Recognition',
      'Your name appeared on the rich list beside people you once read about.',
      'Business',
      'rich_list',
      EventRarity.legendary,
      minAge: 30),
  _PremiumSpec(
      'Business Award',
      'A national business award recognized your company as a genuine force.',
      'Business',
      'business_award',
      EventRarity.epic,
      minAge: 26),
  _PremiumSpec(
      'Employee Strike',
      'Employees walked out demanding better pay, forcing you to choose profit or loyalty.',
      'Business',
      'labor_crisis',
      EventRarity.rare,
      minAge: 24),
  _PremiumSpec(
      'Corporate Lawsuit',
      'A corporate lawsuit threatened your expansion and dragged your leadership into court.',
      'Business',
      'lawsuit',
      EventRarity.epic,
      minAge: 24),
  _PremiumSpec(
      'Lifetime Entrepreneur Award',
      'Decades of building earned you a lifetime entrepreneur award.',
      'Business',
      'entrepreneur_legacy',
      EventRarity.legendary,
      minAge: 55),
  _PremiumSpec(
      'First Love',
      'Your first love changed what music, rain, and waiting for messages felt like.',
      'Relationships',
      'first_love',
      EventRarity.rare,
      minAge: 16,
      maxAge: 25),
  _PremiumSpec(
      'Secret Admirer',
      'A secret admirer left notes that made ordinary days feel cinematic.',
      'Relationships',
      'romance',
      EventRarity.uncommon,
      minAge: 16,
      weight: 3),
  _PremiumSpec(
      'Long Distance Relationship',
      'Distance turned love into time zones, missed calls, and fierce commitment.',
      'Relationships',
      'long_distance',
      EventRarity.rare,
      minAge: 18),
  _PremiumSpec(
      'Proposal',
      'A proposal changed a normal evening into a memory you will replay for years.',
      'Relationships',
      'proposal',
      EventRarity.epic,
      minAge: 21),
  _PremiumSpec(
      'Engagement',
      'Families gathered, rings were exchanged, and the relationship became public destiny.',
      'Relationships',
      'engagement',
      EventRarity.rare,
      minAge: 21),
  _PremiumSpec(
      'Wedding',
      'Your wedding became a storm of rituals, promises, exhaustion, and joy.',
      'Relationships',
      'wedding',
      EventRarity.epic,
      minAge: 21),
  _PremiumSpec(
      'Honeymoon',
      'The first trip after marriage gave you quiet days away from everyone’s expectations.',
      'Relationships',
      'honeymoon',
      EventRarity.rare,
      minAge: 21),
  _PremiumSpec(
      'Major Argument',
      'A major argument forced both of you to say things that had been hidden for months.',
      'Relationships',
      'conflict',
      EventRarity.rare,
      minAge: 18),
  _PremiumSpec(
      'Couples Counseling',
      'Counseling gave the relationship a difficult but honest second language.',
      'Relationships',
      'repair',
      EventRarity.rare,
      minAge: 21),
  _PremiumSpec(
      'Breakup',
      'The breakup left routines, places, and songs feeling suddenly unsafe.',
      'Relationships',
      'breakup',
      EventRarity.rare,
      minAge: 16),
  _PremiumSpec(
      'Reconciliation',
      'A hard conversation reopened a door both of you thought was closed forever.',
      'Relationships',
      'reconciliation',
      EventRarity.epic,
      minAge: 18),
  _PremiumSpec(
      'Soulmate',
      'You found someone whose presence made ambition and peace feel possible together.',
      'Relationships',
      'soulmate',
      EventRarity.legendary,
      minAge: 21),
  _PremiumSpec(
      'Anniversary Celebration',
      'An anniversary celebration reminded you how much history two people can carry.',
      'Relationships',
      'anniversary',
      EventRarity.rare,
      minAge: 22),
  _PremiumSpec(
      'Trust Betrayal',
      'A betrayal broke something private and forced you to reconsider the whole relationship.',
      'Relationships',
      'betrayal',
      EventRarity.epic,
      minAge: 18),
  _PremiumSpec(
      'Relationship Scandal',
      'Your relationship became public gossip, and privacy vanished overnight.',
      'Relationships',
      'relationship_scandal',
      EventRarity.epic,
      minAge: 18),
  _PremiumSpec(
      'Partner Promotion',
      'Your partner’s promotion changed the household mood and future plans.',
      'Relationships',
      'partner_success',
      EventRarity.rare,
      minAge: 22),
  _PremiumSpec(
      'Partner Illness',
      'Your partner fell seriously ill, and love became hospital corridors and courage.',
      'Relationships',
      'partner_health',
      EventRarity.epic,
      minAge: 22),
  _PremiumSpec(
      'Growing Family',
      'The family began to grow, bringing joy, fear, and new responsibilities.',
      'Relationships',
      'family_growth',
      EventRarity.epic,
      minAge: 23),
  _PremiumSpec(
      'Relationship Adoption',
      'Together, you chose adoption and changed a child’s life as well as your own.',
      'Relationships',
      'adoption',
      EventRarity.epic,
      minAge: 25),
  _PremiumSpec(
      'Golden Anniversary',
      'Fifty years together turned love into living history.',
      'Relationships',
      'golden_anniversary',
      EventRarity.legendary,
      minAge: 68),
  _PremiumSpec(
      'Birth Of Child',
      'A child was born, and the center of your world quietly moved.',
      'Family',
      'childbirth',
      EventRarity.epic,
      minAge: 22),
  _PremiumSpec(
      'Twins',
      'Twins arrived, doubling the joy and the complete lack of sleep.',
      'Family',
      'twins',
      EventRarity.legendary,
      minAge: 22),
  _PremiumSpec(
      'Family Vacation',
      'A family vacation became the story everyone will exaggerate for years.',
      'Family',
      'vacation',
      EventRarity.rare,
      minAge: 18),
  _PremiumSpec(
      'Inheritance',
      'An inheritance arrived with money, grief, and complicated family expectations.',
      'Family',
      'inheritance',
      EventRarity.epic,
      minAge: 25),
  _PremiumSpec(
      'Family Business',
      'Your family asked you to join the business and protect what generations built.',
      'Family',
      'family_business',
      EventRarity.rare,
      minAge: 20),
  _PremiumSpec(
      'Parent Retirement',
      'A parent retired, shifting responsibility and pride onto your shoulders.',
      'Family',
      'parent_retirement',
      EventRarity.rare,
      minAge: 25),
  _PremiumSpec(
      'Parent Illness',
      'A parent’s illness changed your calendar, priorities, and sense of time.',
      'Family',
      'parent_health',
      EventRarity.epic,
      minAge: 20),
  _PremiumSpec(
      'Family Reunion',
      'A reunion brought old stories, old grudges, and unexpected healing into one room.',
      'Family',
      'reunion',
      EventRarity.rare,
      minAge: 18),
  _PremiumSpec(
      'Sibling Success',
      'A sibling achieved something huge, filling you with pride and a little pressure.',
      'Family',
      'sibling_success',
      EventRarity.rare,
      minAge: 18),
  _PremiumSpec(
      'Sibling Rivalry',
      'A sibling rivalry resurfaced and turned one family dinner into a battlefield.',
      'Family',
      'sibling_rivalry',
      EventRarity.rare,
      minAge: 16),
  _PremiumSpec(
      'Grandchild Born',
      'A grandchild was born, making time feel circular and strangely gentle.',
      'Family',
      'grandchild',
      EventRarity.epic,
      minAge: 45),
  _PremiumSpec(
      'Family Celebration',
      'A family celebration reminded everyone what they were protecting through all the chaos.',
      'Family',
      'celebration',
      EventRarity.rare,
      minAge: 18),
  _PremiumSpec(
      'Property Dispute',
      'A property dispute split relatives into camps and turned memories into paperwork.',
      'Family',
      'property_dispute',
      EventRarity.epic,
      minAge: 30),
  _PremiumSpec(
      'Family Secret',
      'A family secret surfaced and changed how you understood your childhood.',
      'Family',
      'family_secret',
      EventRarity.epic,
      minAge: 18),
  _PremiumSpec(
      'Family Adoption',
      'Your family welcomed an adopted child and rewrote its own idea of belonging.',
      'Family',
      'adoption',
      EventRarity.epic,
      minAge: 25),
  _PremiumSpec(
      'Caregiving Responsibility',
      'Caregiving became part of daily life, heavy with duty and tenderness.',
      'Family',
      'caregiving',
      EventRarity.rare,
      minAge: 25),
  _PremiumSpec(
      'Wedding In Family',
      'A wedding in the family became a beautiful logistical storm.',
      'Family',
      'family_wedding',
      EventRarity.rare,
      minAge: 18),
  _PremiumSpec(
      'Family Honor Award',
      'Your family received a public honor that made elders stand taller.',
      'Family',
      'family_honor',
      EventRarity.epic,
      minAge: 25),
  _PremiumSpec(
      'Generational Wealth',
      'Careful decisions turned family stability into generational wealth.',
      'Family',
      'generational_wealth',
      EventRarity.legendary,
      minAge: 40),
  _PremiumSpec(
      'Legacy Recognition',
      'The community recognized your family legacy as something larger than one lifetime.',
      'Family',
      'legacy',
      EventRarity.legendary,
      minAge: 55),
  _PremiumSpec(
      'Annual Checkup',
      'A routine checkup caught important signals early and changed your health priorities.',
      'Health',
      'preventive_care',
      EventRarity.uncommon,
      minAge: 18,
      weight: 3),
  _PremiumSpec(
      'Fitness Transformation',
      'Months of discipline transformed your body and self-respect.',
      'Health',
      'fitness',
      EventRarity.rare,
      minAge: 16),
  _PremiumSpec(
      'Weight Loss Journey',
      'Your weight loss journey became a daily proof that small choices compound.',
      'Health',
      'weight_loss',
      EventRarity.rare,
      minAge: 16),
  _PremiumSpec(
      'Marathon Completion',
      'You crossed a marathon finish line and cried before you could stop yourself.',
      'Health',
      'endurance',
      EventRarity.epic,
      minAge: 18),
  _PremiumSpec(
      'Sports Injury',
      'A sports injury forced you to rebuild patience before strength.',
      'Health',
      'injury',
      EventRarity.rare,
      minAge: 14),
  _PremiumSpec(
      'Surgery',
      'Surgery turned fear into recovery plans, bills, and gratitude for ordinary mornings.',
      'Health',
      'surgery',
      EventRarity.epic,
      minAge: 18),
  _PremiumSpec(
      'Recovery',
      'Recovery was slower than pride wanted, but your body began trusting you again.',
      'Health',
      'recovery',
      EventRarity.rare,
      minAge: 16),
  _PremiumSpec(
      'Mental Burnout',
      'Burnout emptied your ambition and forced you to admit you are not a machine.',
      'Health',
      'mental_health',
      EventRarity.epic,
      minAge: 18),
  _PremiumSpec(
      'Therapy Success',
      'Therapy helped you name patterns that had quietly controlled your life.',
      'Health',
      'therapy',
      EventRarity.rare,
      minAge: 18),
  _PremiumSpec(
      'Lifestyle Change',
      'A serious lifestyle change rewired your food, sleep, and relationship with stress.',
      'Health',
      'lifestyle',
      EventRarity.rare,
      minAge: 18),
  _PremiumSpec(
      'Health Scare',
      'A health scare made every postponed promise feel urgent.',
      'Health',
      'health_scare',
      EventRarity.epic,
      minAge: 30),
  _PremiumSpec(
      'Chronic Condition',
      'A chronic condition changed your routines and demanded humility.',
      'Health',
      'chronic_condition',
      EventRarity.epic,
      minAge: 25),
  _PremiumSpec(
      'Wellness Award',
      'Your transformation earned a wellness award and inspired people around you.',
      'Health',
      'wellness_award',
      EventRarity.rare,
      minAge: 18),
  _PremiumSpec(
      'Blood Donation',
      'A blood donation became unexpectedly personal when you learned who it helped.',
      'Health',
      'blood_donation',
      EventRarity.rare,
      minAge: 18),
  _PremiumSpec(
      'Organ Donation',
      'An organ donation decision turned compassion into someone else’s second chance.',
      'Health',
      'organ_donation',
      EventRarity.legendary,
      minAge: 18),
  _PremiumSpec(
      'Medical Breakthrough',
      'Doctors found a breakthrough treatment that changed your prognosis.',
      'Health',
      'medical_breakthrough',
      EventRarity.legendary,
      minAge: 25),
  _PremiumSpec(
      'Long Recovery',
      'A long recovery tested your patience more than the original injury.',
      'Health',
      'long_recovery',
      EventRarity.rare,
      minAge: 18),
  _PremiumSpec(
      'Fitness Influencer',
      'Your health journey inspired strangers to follow your routines.',
      'Health',
      'fitness_influence',
      EventRarity.epic,
      minAge: 18),
  _PremiumSpec(
      'Healthy Aging',
      'You aged with strength, clarity, and the quiet pride of consistency.',
      'Health',
      'healthy_aging',
      EventRarity.rare,
      minAge: 60),
  _PremiumSpec(
      'Centenarian Celebration',
      'Your hundredth birthday became a celebration of resilience across generations.',
      'Health',
      'centenarian',
      EventRarity.legendary,
      minAge: 100),
  _PremiumSpec(
      'Nobel Prize',
      'A lifetime of difficult work was recognized on the world stage, and your name entered history.',
      'Science',
      'nobel_prize',
      EventRarity.legendary,
      minAge: 35),
  _PremiumSpec(
      'Historic Scientific Discovery',
      'Your discovery changed textbooks, careers, and the way people understood the world.',
      'Science',
      'historic_discovery',
      EventRarity.legendary,
      minAge: 28),
  _PremiumSpec(
      'International Peace Prize',
      'Years of mediation and courage earned you an international peace prize.',
      'Politics',
      'peace_prize',
      EventRarity.legendary,
      minAge: 40),
  _PremiumSpec(
      'Presidential Medal',
      'The nation honored your public service with one of its highest civilian decorations.',
      'Politics',
      'presidential_medal',
      EventRarity.legendary,
      minAge: 40),
  _PremiumSpec(
      'National Award',
      'Your work became a matter of national pride and was honored before the country.',
      'Fame',
      'national_award',
      EventRarity.legendary,
      minAge: 25),
  _PremiumSpec(
      'World Cup Victory',
      'You stood in a roaring stadium as a world cup victory became a permanent national memory.',
      'Sports',
      'world_cup_victory',
      EventRarity.legendary,
      minAge: 18),
  _PremiumSpec(
      'Hall Of Fame',
      'Your career was inducted into the hall of fame, turning old highlights into legacy.',
      'Sports',
      'hall_of_fame',
      EventRarity.legendary,
      minAge: 35),
  _PremiumSpec(
      'Global Celebrity',
      'Your fame crossed languages, borders, and industries until privacy became a luxury.',
      'Fame',
      'global_celebrity',
      EventRarity.legendary,
      minAge: 21),
  _PremiumSpec(
      'Lifetime Achievement Award',
      'Decades of excellence were distilled into one standing ovation that would not end.',
      'Career',
      'lifetime_achievement',
      EventRarity.epic,
      minAge: 55),
  _PremiumSpec(
      'Richest Citizen',
      'Your fortune surpassed every local benchmark, making your choices part of public debate.',
      'Business',
      'richest_citizen',
      EventRarity.epic,
      minAge: 35),
];
