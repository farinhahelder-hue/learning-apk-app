class AppConstants {
  static const String childName = 'Emilie';
  static const String appName = 'Emilie App';

  static const int levelEasy = 1;
  static const int levelMedium = 2;
  static const int levelHard = 3;

  static const int pointsPerCorrectAnswer = 10;
  static const int pointsPerExercise = 50;
  static const int pointsPerLevel = 200;

  static const List<Map<String, dynamic>> badges = [
    {'id': 'first_exercise', 'name': 'Premier exercice !', 'icon': '⭐'},
    {'id': 'math_10', 'name': 'Mathématicienne', 'icon': '🔢'},
    {'id': 'french_10', 'name': 'Lectrice', 'icon': '📚'},
    {'id': 'science_10', 'name': 'Scientifique', 'icon': '🔬'},
    {'id': 'perfect_score', 'name': 'Parfait !', 'icon': '🏆'},
    {'id': 'streak_5', 'name': '5 jours de suite', 'icon': '🔥'},
    {'id': 'total_500', 'name': 'Super Emilie', 'icon': '👑'},
  ];

  static const List<String> encouragements = [
    'Bravo Emilie ! Tu es incroyable ! 🌟',
    'Excellent travail ! Continue comme ça ! 🎉',
    'Super ! Tu apprends si vite ! 🚀',
    'Magnifique ! Tu es une championne ! 🏆',
    'Fantastique ! Emilie, tu es la meilleure ! ⭐',
    'Wow ! Quelle intelligence ! 🧠',
    'Parfait ! Tu es trop forte ! 💪',
  ];

  static const List<String> tryAgainMessages = [
    'Presque ! Essaie encore une fois ! 💪',
    'Tu peux le faire ! Réessaie ! 🌈',
    'Pas tout à fait, mais continue ! ⭐',
    'Courage Emilie ! Tu vas y arriver ! 🤗',
  ];
}
