class TVCastMember {
  final String name;
  final String role;

  const TVCastMember({
    required this.name,
    required this.role,
  });
}

class TVProject {
  final String id;
  final String title;
  final String genre;
  final String network;
  final String showStatus;
  final int seasonNumber;
  final int totalEpisodes;
  final int completedEpisodes;
  final double productionProgress;
  final String director;
  final String producer;
  final String productionCompany;
  final String roleName;
  final String roleType;
  final int salaryPerEpisode;
  final int signingBonus;
  final int contractLength; // in days
  final double rating;
  final int fanGrowth;
  final int reputationImpact;
  final int fameImpact;
  final List<TVCastMember> castMembers;

  const TVProject({
    required this.id,
    required this.title,
    required this.genre,
    required this.network,
    required this.showStatus,
    required this.seasonNumber,
    required this.totalEpisodes,
    required this.completedEpisodes,
    required this.productionProgress,
    required this.director,
    required this.producer,
    required this.productionCompany,
    required this.roleName,
    required this.roleType,
    required this.salaryPerEpisode,
    required this.signingBonus,
    required this.contractLength,
    required this.rating,
    required this.fanGrowth,
    required this.reputationImpact,
    required this.fameImpact,
    required this.castMembers,
  });
}

// Mock data for UI development
const mockTVProject = TVProject(
  id: 'tv_proj_1',
  title: 'Cyber Pulse',
  genre: 'Sci-Fi',
  network: 'Nebula Network',
  showStatus: 'IN PRODUCTION',
  seasonNumber: 1,
  totalEpisodes: 12,
  completedEpisodes: 5,
  productionProgress: 0.45,
  director: 'Sarah Mehta',
  producer: 'Arjun Kapoor',
  productionCompany: 'Nebula Studios',
  roleName: 'Commander Arya',
  roleType: 'Lead Actor',
  salaryPerEpisode: 1200000,
  signingBonus: 500000,
  contractLength: 180,
  rating: 8.5,
  fanGrowth: 15,
  reputationImpact: 10,
  fameImpact: 12,
  castMembers: [
    TVCastMember(name: 'Priya Kapoor', role: 'Commander Arya'),
    TVCastMember(name: 'Raj Malhotra', role: 'Dr. Vance'),
    TVCastMember(name: 'Vikram Singh', role: 'Cyborg Alpha'),
    TVCastMember(name: 'Rakesh Das', role: 'Tech Expert'),
  ],
);
