class GameSession {
  final String id;
  final String skillId;
  final DateTime startTime;
  DateTime? endTime;
  int correctAnswers;
  int totalQuestions;
  int comboMax;
  int score;
  bool perfectScore;

  GameSession({
    required this.id,
    required this.skillId,
    DateTime? startTime,
    this.endTime,
    this.correctAnswers = 0,
    this.totalQuestions = 0,
    this.comboMax = 0,
    this.score = 0,
    this.perfectScore = false,
  }) : startTime = startTime ?? DateTime.now();

  double get successRate =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

  int get starsEarned {
    if (perfectScore) return 3;
    if (successRate >= 70) return 2;
    if (successRate >= 50) return 1;
    return 0;
  }

  void end() {
    endTime = DateTime.now();
    perfectScore = correctAnswers == totalQuestions && totalQuestions > 0;
  }

  Duration get duration =>
      (endTime ?? DateTime.now()).difference(startTime);

  Map<String, dynamic> toMap() => {
        'id': id,
        'skillId': skillId,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'correctAnswers': correctAnswers,
        'totalQuestions': totalQuestions,
        'comboMax': comboMax,
        'score': score,
        'perfectScore': perfectScore,
      };

  factory GameSession.fromMap(Map<String, dynamic> map) => GameSession(
        id: map['id'],
        skillId: map['skillId'],
        startTime: DateTime.parse(map['startTime']),
        endTime:
            map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
        correctAnswers: map['correctAnswers'] ?? 0,
        totalQuestions: map['totalQuestions'] ?? 0,
        comboMax: map['comboMax'] ?? 0,
        score: map['score'] ?? 0,
        perfectScore: map['perfectScore'] ?? false,
      );
}

class WorldProgress {
  final String worldId;
  final String name;
  final int totalStars;
  final int unlockedSkills;
  final int totalSkills;
  final List<String> completedSkillIds;

  const WorldProgress({
    required this.worldId,
    required this.name,
    this.totalStars = 0,
    this.unlockedSkills = 0,
    this.totalSkills = 0,
    this.completedSkillIds = const [],
  });

  bool get isCompleted => totalStars >= totalSkills * 3;

  double get progressPercent =>
      totalSkills > 0 ? (unlockedSkills / totalSkills) * 100 : 0;
}

class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final String subject;
  final int bonusXp;
  final DateTime date;
  bool completed;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.bonusXp,
    required this.date,
    this.completed = false,
  });

  String get emoji {
    switch (subject) {
      case 'math':
        return '🔢';
      case 'french':
        return '📚';
      case 'science':
        return '🔬';
      default:
        return '⭐';
    }
  }
}