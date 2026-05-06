// lib/core/institute_data.dart

class InstituteDefinition {
  final String name;
  final String city;
  final int minRank;
  final int maxRank;
  final List<String> availableStreams;
  final double feesPerYear;
  final String tier; // 'IIT', 'NIT', 'Top Private', 'Govt'

  const InstituteDefinition({
    required this.name,
    required this.city,
    required this.minRank,
    required this.maxRank,
    required this.availableStreams,
    required this.feesPerYear,
    required this.tier,
  });
}

class InstituteData {
  static const List<InstituteDefinition> topInstitutes = [
    // ── IITs ──
    InstituteDefinition(
      name: 'IIT Bombay',
      city: 'Mumbai',
      minRank: 1,
      maxRank: 500,
      availableStreams: ['PCM'],
      feesPerYear: 200000,
      tier: 'IIT',
    ),
    InstituteDefinition(
      name: 'IIT Delhi',
      city: 'Delhi',
      minRank: 1,
      maxRank: 600,
      availableStreams: ['PCM'],
      feesPerYear: 200000,
      tier: 'IIT',
    ),
    InstituteDefinition(
      name: 'IIT Madras',
      city: 'Chennai',
      minRank: 1,
      maxRank: 800,
      availableStreams: ['PCM'],
      feesPerYear: 200000,
      tier: 'IIT',
    ),
    InstituteDefinition(
      name: 'IIT Kanpur',
      city: 'Kanpur',
      minRank: 1,
      maxRank: 1000,
      availableStreams: ['PCM'],
      feesPerYear: 200000,
      tier: 'IIT',
    ),
    InstituteDefinition(
      name: 'IIT Kharagpur',
      city: 'Kharagpur',
      minRank: 1,
      maxRank: 1200,
      availableStreams: ['PCM'],
      feesPerYear: 180000,
      tier: 'IIT',
    ),
    InstituteDefinition(
      name: 'IIT Roorkee',
      city: 'Roorkee',
      minRank: 1,
      maxRank: 1500,
      availableStreams: ['PCM'],
      feesPerYear: 180000,
      tier: 'IIT',
    ),
    InstituteDefinition(
      name: 'IIT Guwahati',
      city: 'Guwahati',
      minRank: 1,
      maxRank: 2000,
      availableStreams: ['PCM'],
      feesPerYear: 180000,
      tier: 'IIT',
    ),

    // ── NITs ──
    InstituteDefinition(
      name: 'NIT Trichy',
      city: 'Tiruchirappalli',
      minRank: 2001,
      maxRank: 5000,
      availableStreams: ['PCM'],
      feesPerYear: 150000,
      tier: 'NIT',
    ),
    InstituteDefinition(
      name: 'NIT Surathkal',
      city: 'Mangaluru',
      minRank: 2001,
      maxRank: 6000,
      availableStreams: ['PCM'],
      feesPerYear: 150000,
      tier: 'NIT',
    ),
    InstituteDefinition(
      name: 'NIT Warangal',
      city: 'Warangal',
      minRank: 2001,
      maxRank: 7000,
      availableStreams: ['PCM'],
      feesPerYear: 150000,
      tier: 'NIT',
    ),
    InstituteDefinition(
      name: 'MNNIT Allahabad',
      city: 'Prayagraj',
      minRank: 4000,
      maxRank: 9000,
      availableStreams: ['PCM'],
      feesPerYear: 140000,
      tier: 'NIT',
    ),
    InstituteDefinition(
      name: 'VNIT Nagpur',
      city: 'Nagpur',
      minRank: 5000,
      maxRank: 12000,
      availableStreams: ['PCM'],
      feesPerYear: 130000,
      tier: 'NIT',
    ),

    // ── AIIMS (Medical) ──
    InstituteDefinition(
      name: 'AIIMS Delhi',
      city: 'Delhi',
      minRank: 1,
      maxRank: 100,
      availableStreams: ['PCB'],
      feesPerYear: 5000,
      tier: 'Govt',
    ),
    InstituteDefinition(
      name: 'AIIMS Jodhpur',
      city: 'Jodhpur',
      minRank: 1,
      maxRank: 500,
      availableStreams: ['PCB'],
      feesPerYear: 5000,
      tier: 'Govt',
    ),
    InstituteDefinition(
      name: 'CMC Vellore',
      city: 'Vellore',
      minRank: 1,
      maxRank: 300,
      availableStreams: ['PCB'],
      feesPerYear: 50000,
      tier: 'Top Private',
    ),

    // ── Law / Commerce / Others ──
    InstituteDefinition(
      name: 'NLSIU Bangalore',
      city: 'Bengaluru',
      minRank: 1,
      maxRank: 100,
      availableStreams: ['Arts', 'Commerce'],
      feesPerYear: 250000,
      tier: 'Govt',
    ),
    InstituteDefinition(
      name: 'SRCC Delhi',
      city: 'Delhi',
      minRank: 1,
      maxRank: 500,
      availableStreams: ['Commerce'],
      feesPerYear: 30000,
      tier: 'Govt',
    ),
  ];
}
