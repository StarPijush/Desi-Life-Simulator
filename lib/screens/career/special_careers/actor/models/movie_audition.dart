class MovieAudition {
  final String id;
  final String movieTitle;
  final String genre;
  final String roleType;
  final String productionHouse;
  final String director;
  final int budget;
  final int salary;
  final int signingBonus;
  final double revenueShare; // e.g. 0.02 for 2%
  final int contractDuration; // in days
  final int difficulty;
  final int requiredFame;
  final int requiredActing;
  final int requiredReputation;
  final int requiredAge;
  final int fameGain;
  final int reputationGain;
  final String awardPotential; // e.g. High, Medium, Low
  final String riskLevel;
  final String status; // e.g. 'Casting Phase'
  final int year;
  final String iconEmoji;

  const MovieAudition({
    required this.id,
    required this.movieTitle,
    required this.genre,
    required this.roleType,
    required this.productionHouse,
    required this.director,
    required this.budget,
    required this.salary,
    required this.signingBonus,
    required this.revenueShare,
    required this.contractDuration,
    required this.difficulty,
    required this.requiredFame,
    required this.requiredActing,
    required this.requiredReputation,
    required this.requiredAge,
    required this.fameGain,
    required this.reputationGain,
    required this.awardPotential,
    required this.riskLevel,
    required this.status,
    required this.year,
    required this.iconEmoji,
  });
}
