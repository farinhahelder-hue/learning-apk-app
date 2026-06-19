class AppConstants {
  static const String childName   = 'Emilie';
  static const String appName     = 'Emilie App';
  // Code parental sécurisé - À modifier par les parents
  static const String parentalCode = '0000';

  static const int levelEasy   = 1;
  static const int levelMedium = 2;
  static const int levelHard   = 3;

  static const int pointsPerCorrectAnswer = 10;
  static const int pointsPerExercise      = 50;
  static const int pointsPerLevel         = 200;

  static const List<Map<String, dynamic>> badges = [
    {'id': 'first_exercise', 'name': 'Premier exercice !',  'icon': '⭐'},
    {'id': 'math_10',        'name': 'Mathématicienne',     'icon': '🔢'},
    {'id': 'french_10',      'name': 'Lectrice',            'icon': '📚'},
    {'id': 'science_10',     'name': 'Scientifique',        'icon': '🔬'},
    {'id': 'perfect_score',  'name': 'Parfait !',           'icon': '🏆'},
    {'id': 'streak_5',       'name': '5 jours de suite',    'icon': '🔥'},
    {'id': 'total_500',      'name': 'Super Emilie',        'icon': '👑'},
    {'id': 'first_game',     'name': 'Premiere partie !',   'icon': '🎮'},
    {'id': 'streak_3',       'name': '3 jours de suite',   'icon': '🔥'},
    {'id': 'all_subjects',   'name': 'Curieuse !',          'icon': '📖'},
  ];

  // Messages d'encouragement personnalisés avec les mascottes
  static const List<String> encouragements = [
    '🐿️🌟 Bravo Emilie ! Tu es incroyable ! Noisette est fier de toi !',
    '🪼✨ Excellent travail ! Continue comme ça ! Bulle t\'applaudit !',
    '🦭🚀 Super ! Tu apprends si vite ! Câlin te congratule !',
    '⭐🏆 Magnifique ! Tu es une championne ! Toutes les mascottes dansent !',
    '🌈✨ Fantastique ! Emilie, tu es la meilleure ! Les étoiles brillent !',
    '🧠💡 Wow ! Quelle intelligence ! Noisette fait la cabriole !',
    '💪🎉 Parfait ! Tu es trop forte ! Bulle te fait un High-five !',
    '🌟🦭 Excellent ! Câlin te fait un gros câlin !',
    '🏆✨ Tu gères ! Les mascottes sont impressionnées !',
    '⭐🪼 Super star ! Ta fusée monte vers les étoiles !',
  ];

  // Messages pour réessayer avec encouragement
  static const List<String> tryAgainMessages = [
    '🐿️💪 Presque ! Essaie encore une fois ! Noisette croit en toi !',
    '🪼🌈 Tu peux le faire ! Réessaie ! Bulle t\'aide !',
    '🦭⭐ Pas tout à fait, mais continue ! Câlin t\'encourage !',
    '💪🤗 Courage Emilie ! Tu vas y arriver ! Les mascottes sont avec toi !',
    '🌟🔄 Pas grave ! Chaque erreur est une occasion d\'apprendre !',
    '✨💫 On se concentre et on recommence ! Tu es capable !',
    '🦭🌟 Câlin sait que tu peux réussir ! Retente ta chance !',
    '🐿️💪 Ne lâche rien ! Noisette t\'attend au tournant !',
  ];
}
