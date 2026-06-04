class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int requiredValue;
  final String type; // 'points', 'streak', 'perfect', 'combo', 'stars'
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.requiredValue,
    required this.type,
    this.unlockedAt,
  });

  Achievement copyWith({DateTime? unlockedAt}) => Achievement(
        id: id,
        name: name,
        description: description,
        icon: icon,
        requiredValue: requiredValue,
        type: type,
        unlockedAt: unlockedAt ?? this.unlockedAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon,
        'requiredValue': requiredValue,
        'type': type,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };

  factory Achievement.fromMap(Map<String, dynamic> map) => Achievement(
        id: map['id'],
        name: map['name'],
        description: map['description'],
        icon: map['icon'],
        requiredValue: map['requiredValue'],
        type: map['type'],
        unlockedAt:
            map['unlockedAt'] != null ? DateTime.parse(map['unlockedAt']) : null,
      );
}

class AchievementDefinition {
  static const List<Achievement> all = [
    Achievement(
      id: 'first_steps',
      name: 'Premiers pas',
      description: 'Complète ton premier exercice',
      icon: '👣',
      requiredValue: 1,
      type: 'points',
    ),
    Achievement(
      id: 'math_wizard',
      name: 'Sorcier des maths',
      description: 'Gagne 500 points en maths',
      icon: '🧙',
      requiredValue: 500,
      type: 'points',
    ),
    Achievement(
      id: 'french_master',
      name: 'Maître du français',
      description: 'Gagne 500 points en français',
      icon: '📖',
      requiredValue: 500,
      type: 'points',
    ),
    Achievement(
      id: 'science_explorer',
      name: 'Explorateur scientifique',
      description: 'Gagne 500 points en sciences',
      icon: '🔬',
      requiredValue: 500,
      type: 'points',
    ),
    Achievement(
      id: 'streak_3',
      name: 'Surveillance 3 jours',
      description: 'Joue 3 jours de suite',
      icon: '🔥',
      requiredValue: 3,
      type: 'streak',
    ),
    Achievement(
      id: 'streak_7',
      name: 'Semaine parfaite',
      description: 'Joue 7 jours de suite',
      icon: '💫',
      requiredValue: 7,
      type: 'streak',
    ),
    Achievement(
      id: 'streak_30',
      name: 'Champion du mois',
      description: 'Joue 30 jours de suite',
      icon: '🏆',
      requiredValue: 30,
      type: 'streak',
    ),
    Achievement(
      id: 'perfect_run',
      name: 'Score parfait',
      description: 'Obtiens 100% à un exercice',
      icon: '🌟',
      requiredValue: 1,
      type: 'perfect',
    ),
    Achievement(
      id: 'combo_5',
      name: 'Combo x5',
      description: '5 bonnes réponses consécutives',
      icon: '🔥',
      requiredValue: 5,
      type: 'combo',
    ),
    Achievement(
      id: 'combo_10',
      name: 'Mega Combo x10',
      description: '10 bonnes réponses consécutives',
      icon: '⚡',
      requiredValue: 10,
      type: 'combo',
    ),
    Achievement(
      id: 'star_collector_10',
      name: 'Collectionneur d\'étoiles',
      description: '收集10颗星',
      icon: '⭐',
      requiredValue: 10,
      type: 'stars',
    ),
    Achievement(
      id: 'star_collector_50',
      name: 'Étoile du ciel',
      description: 'Collecte 50 étoiles',
      icon: '🌠',
      requiredValue: 50,
      type: 'stars',
    ),
    Achievement(
      id: 'total_1000',
      name: 'Millénaire',
      description: 'Atteins 1000 points au total',
      icon: '💎',
      requiredValue: 1000,
      type: 'points',
    ),
    Achievement(
      id: 'total_5000',
      name: 'Champion',
      description: 'Atteins 5000 points au total',
      icon: '👑',
      requiredValue: 5000,
      type: 'points',
    ),
  ];
}