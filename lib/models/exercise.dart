class Exercise {
  final String id;
  final String subject;
  final String type;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final int difficulty;
  final int points;
  final String? hint;
  final String? imageAsset;

  const Exercise({
    required this.id,
    required this.subject,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.difficulty = 1,
    this.points = 10,
    this.hint,
    this.imageAsset,
  });
}

class UserProgress {
  final String userId;
  int totalPoints;
  int mathPoints;
  int frenchPoints;
  int sciencePoints;
  List<String> earnedBadges;
  Map<String, int> exerciseScores;
  int currentLevel;
  int streakDays;
  DateTime lastPlayDate;

  UserProgress({
    required this.userId,
    this.totalPoints = 0,
    this.mathPoints = 0,
    this.frenchPoints = 0,
    this.sciencePoints = 0,
    List<String>? earnedBadges,
    Map<String, int>? exerciseScores,
    this.currentLevel = 1,
    this.streakDays = 0,
    DateTime? lastPlayDate,
  })  : earnedBadges = earnedBadges ?? [],
        exerciseScores = exerciseScores ?? {},
        lastPlayDate = lastPlayDate ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'totalPoints': totalPoints,
        'mathPoints': mathPoints,
        'frenchPoints': frenchPoints,
        'sciencePoints': sciencePoints,
        'earnedBadges': earnedBadges,
        'exerciseScores': exerciseScores,
        'currentLevel': currentLevel,
        'streakDays': streakDays,
        'lastPlayDate': lastPlayDate.toIso8601String(),
      };

  factory UserProgress.fromMap(Map<String, dynamic> map) => UserProgress(
        userId: map['userId'],
        totalPoints: map['totalPoints'] ?? 0,
        mathPoints: map['mathPoints'] ?? 0,
        frenchPoints: map['frenchPoints'] ?? 0,
        sciencePoints: map['sciencePoints'] ?? 0,
        earnedBadges: List<String>.from(map['earnedBadges'] ?? []),
        exerciseScores: Map<String, int>.from(map['exerciseScores'] ?? {}),
        currentLevel: map['currentLevel'] ?? 1,
        streakDays: map['streakDays'] ?? 0,
        lastPlayDate: DateTime.parse(
            map['lastPlayDate'] ?? DateTime.now().toIso8601String()),
      );
}
