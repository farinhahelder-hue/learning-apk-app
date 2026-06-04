import 'exercise.dart';

enum GameType {
  arcade,       // Calcul mental très rapide
  quiz,         // QCM classique
  dragDrop,     // Glisser-déposer
  fillBlank,    // Trou à combler
  memory,       // Paires à trouver
  wordBuilder,  // Construire un mot
  storyQuest,   // Mini-histoire avec questions
  escape,       // Énigmes enchâínées
}

class GameSession {
  final String worldId;
  final String skillId;
  final GameType gameType;
  final List<Exercise> exercises;
  int score;
  int stars;        // 1, 2, 3 étoiles
  int timeSeconds;  // temps passé
  bool completed;
  DateTime playedAt;

  GameSession({
    required this.worldId,
    required this.skillId,
    required this.gameType,
    required this.exercises,
    this.score = 0,
    this.stars = 0,
    this.timeSeconds = 0,
    this.completed = false,
    DateTime? playedAt,
  }) : playedAt = playedAt ?? DateTime.now();

  int get maxScore => exercises.length * 10;
  double get percentScore => exercises.isEmpty ? 0 : score / maxScore;

  // 1⭐ >= 50%, 2⭐ >= 70%, 3⭐ = 100%
  int computeStars() {
    if (percentScore >= 1.0)    return 3;
    if (percentScore >= 0.7)   return 2;
    if (percentScore >= 0.5)   return 1;
    return 0;
  }
}

class WorldProgress {
  final String worldId;
  Map<String, int> skillStars;  // skillId -> étoiles (0–3)
  int totalStars;

  WorldProgress({
    required this.worldId,
    Map<String, int>? skillStars,
    this.totalStars = 0,
  }) : skillStars = skillStars ?? {};

  bool isSkillUnlocked(String skillId, List<Map<String, dynamic>> skills) {
    final idx = skills.indexWhere((s) => s['id'] == skillId);
    if (idx == 0) return true;        // première compétence toujours disponible
    if (idx < 0)  return false;
    final prev = skills[idx - 1]['id'] as String;
    return (skillStars[prev] ?? 0) >= 1;  // débloqué si précédent ≥ 1 étoile
  }

  Map<String, dynamic> toMap() => {
    'worldId': worldId,
    'skillStars': skillStars,
    'totalStars': totalStars,
  };

  factory WorldProgress.fromMap(Map<String, dynamic> m) => WorldProgress(
    worldId: m['worldId'],
    skillStars: Map<String, int>.from(m['skillStars'] ?? {}),
    totalStars: m['totalStars'] ?? 0,
  );
}
