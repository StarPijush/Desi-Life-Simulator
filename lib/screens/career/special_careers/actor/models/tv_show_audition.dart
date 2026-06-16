class TVShowAudition {
  final String id;
  final String showTitle;
  final String genre;
  final String roleType;
  final String network;
  final int episodes;
  final int seasonNumber;
  final int salaryPerEpisode;
  final int difficulty;
  final int requiredFame;
  final int requiredActing;
  final int year;
  final String iconEmoji;

  const TVShowAudition({
    required this.id,
    required this.showTitle,
    required this.genre,
    required this.roleType,
    required this.network,
    required this.episodes,
    required this.seasonNumber,
    required this.salaryPerEpisode,
    required this.difficulty,
    required this.requiredFame,
    required this.requiredActing,
    required this.year,
    required this.iconEmoji,
  });
}
