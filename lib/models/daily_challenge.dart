class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final String subject;
  final String category;
  final int targetScore;
  final int bonusPoints;
  bool completed;
  DateTime date;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.subject,
    required this.category,
    required this.targetScore,
    required this.bonusPoints,
    this.completed = false,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  static DailyChallenge generate(DateTime day) {
    final challenges = [
      DailyChallenge(
        id: 'dc_math_speed',
        title: 'Défi Calcul Rapide ⚡',
        description: 'Réponds à 10 additions en moins de 60 secondes !',
        emoji: '⚡',
        subject: 'math',
        category: 'addition',
        targetScore: 80,
        bonusPoints: 50,
        date: day,
      ),
      DailyChallenge(
        id: 'dc_french_spell',
        title: 'Champion Orthographe 💫',
        description: '5 mots sans fautes — tu deviens légende !',
        emoji: '💫',
        subject: 'french',
        category: 'orthographe',
        targetScore: 70,
        bonusPoints: 40,
        date: day,
      ),
      DailyChallenge(
        id: 'dc_science',
        title: 'Petit Scientifique 🔬',
        description: 'Découvre 5 secrets de la nature !',
        emoji: '🔬',
        subject: 'science',
        category: 'nature',
        targetScore: 60,
        bonusPoints: 35,
        date: day,
      ),
      DailyChallenge(
        id: 'dc_tables',
        title: 'Maître des Tables ×',
        description: 'Tables de 2, 3, 4 et 5 — prouve que tu les connais !',
        emoji: '🔢',
        subject: 'math',
        category: 'multiplication',
        targetScore: 80,
        bonusPoints: 50,
        date: day,
      ),
    ];
    return challenges[day.weekday % challenges.length];
  }
}
