class MovieCastMember {
  final String name;
  final String role;

  const MovieCastMember({
    required this.name,
    required this.role,
  });
}

class MovieProject {
  final String id;
  final String title;
  final String genre;
  final String stage;
  final double progress;
  final String director;
  final int budget;
  final String productionHouse;
  final String characterName;
  final String roleType;
  final int salary;
  final List<MovieCastMember> cast;

  const MovieProject({
    required this.id,
    required this.title,
    required this.genre,
    required this.stage,
    required this.progress,
    required this.director,
    required this.budget,
    required this.productionHouse,
    required this.characterName,
    required this.roleType,
    required this.salary,
    required this.cast,
  });
}

// Mock data for UI development
const mockMovieProject = MovieProject(
  id: 'proj_1',
  title: 'The Great Indian Heist',
  genre: 'Crime Thriller',
  stage: 'Filming',
  progress: 0.45,
  director: 'Rohit Mehra',
  budget: 1200000000,
  productionHouse: 'Stellar Pictures',
  characterName: 'Arjun Varma',
  roleType: 'Lead Actor',
  salary: 50000000,
  cast: [
    MovieCastMember(name: 'Priya Kapoor', role: 'Lead Actress'),
    MovieCastMember(name: 'Raj Malhotra', role: 'Supporting Actor'),
    MovieCastMember(name: 'Vikram Singh', role: 'Villain'),
    MovieCastMember(name: 'Rakesh Das', role: 'Comedian'),
  ],
);
