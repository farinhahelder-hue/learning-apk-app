import '../models/exercise.dart';

class MathExercises {
  static List<Exercise> getByCategory(String category) {
    return _all.where((e) => e.id.startsWith(category)).toList();
  }

  static const List<Exercise> _all = [
    // --- ADDITIONS ---
    Exercise(id: 'addition_1', subject: 'math', type: 'qcm', question: 'Combien font 5 + 3 ?',
        options: ['6', '7', '8', '9'], correctAnswer: '8', difficulty: 1, points: 10),
    Exercise(id: 'addition_2', subject: 'math', type: 'qcm', question: 'Combien font 12 + 7 ?',
        options: ['17', '18', '19', '20'], correctAnswer: '19', difficulty: 1, points: 10),
    Exercise(id: 'addition_3', subject: 'math', type: 'qcm', question: 'Combien font 24 + 15 ?',
        options: ['37', '38', '39', '40'], correctAnswer: '39', difficulty: 2, points: 15),
    Exercise(id: 'addition_4', subject: 'math', type: 'qcm', question: 'Combien font 36 + 48 ?',
        options: ['82', '83', '84', '85'], correctAnswer: '84', difficulty: 2, points: 15),
    Exercise(id: 'addition_5', subject: 'math', type: 'qcm', question: 'Combien font 57 + 38 ?',
        options: ['93', '94', '95', '96'], correctAnswer: '95', difficulty: 3, points: 20),
    Exercise(id: 'addition_6', subject: 'math', type: 'qcm', question: 'Quel nombre manque ? 14 + __ = 21',
        options: ['5', '6', '7', '8'], correctAnswer: '7', difficulty: 2, points: 15),
    Exercise(id: 'addition_7', subject: 'math', type: 'qcm', question: 'Combien font 0 + 45 ?',
        options: ['44', '45', '46', '0'], correctAnswer: '45', difficulty: 1, points: 10),
    Exercise(id: 'addition_8', subject: 'math', type: 'qcm', question: 'J’ai 13 bonbons et j’en reçois 9. Combien en ai-je ?',
        options: ['20', '21', '22', '23'], correctAnswer: '22', difficulty: 2, points: 15),

    // --- SOUSTRACTIONS ---
    Exercise(id: 'subtraction_1', subject: 'math', type: 'qcm', question: 'Combien font 10 - 4 ?',
        options: ['5', '6', '7', '8'], correctAnswer: '6', difficulty: 1, points: 10),
    Exercise(id: 'subtraction_2', subject: 'math', type: 'qcm', question: 'Combien font 20 - 8 ?',
        options: ['10', '11', '12', '13'], correctAnswer: '12', difficulty: 1, points: 10),
    Exercise(id: 'subtraction_3', subject: 'math', type: 'qcm', question: 'Combien font 45 - 17 ?',
        options: ['26', '27', '28', '29'], correctAnswer: '28', difficulty: 2, points: 15),
    Exercise(id: 'subtraction_4', subject: 'math', type: 'qcm', question: 'Combien font 63 - 28 ?',
        options: ['33', '34', '35', '36'], correctAnswer: '35', difficulty: 2, points: 15),
    Exercise(id: 'subtraction_5', subject: 'math', type: 'qcm', question: 'Quel nombre manque ? 30 - __ = 14',
        options: ['14', '15', '16', '17'], correctAnswer: '16', difficulty: 2, points: 15),
    Exercise(id: 'subtraction_6', subject: 'math', type: 'qcm', question: 'Combien font 100 - 37 ?',
        options: ['61', '62', '63', '64'], correctAnswer: '63', difficulty: 3, points: 20),

    // --- MULTIPLICATIONS ---
    Exercise(id: 'multiplication_1', subject: 'math', type: 'qcm', question: 'Combien font 2 × 3 ?',
        options: ['4', '5', '6', '7'], correctAnswer: '6', difficulty: 1, points: 10),
    Exercise(id: 'multiplication_2', subject: 'math', type: 'qcm', question: 'Combien font 2 × 7 ?',
        options: ['12', '13', '14', '15'], correctAnswer: '14', difficulty: 1, points: 10),
    Exercise(id: 'multiplication_3', subject: 'math', type: 'qcm', question: 'Combien font 3 × 4 ?',
        options: ['10', '11', '12', '13'], correctAnswer: '12', difficulty: 1, points: 10),
    Exercise(id: 'multiplication_4', subject: 'math', type: 'qcm', question: 'Combien font 5 × 5 ?',
        options: ['20', '25', '30', '35'], correctAnswer: '25', difficulty: 1, points: 10),
    Exercise(id: 'multiplication_5', subject: 'math', type: 'qcm', question: 'Combien font 4 × 6 ?',
        options: ['22', '24', '26', '28'], correctAnswer: '24', difficulty: 2, points: 15),
    Exercise(id: 'multiplication_6', subject: 'math', type: 'qcm', question: 'Combien font 3 × 8 ?',
        options: ['21', '22', '23', '24'], correctAnswer: '24', difficulty: 2, points: 15),
    Exercise(id: 'multiplication_7', subject: 'math', type: 'qcm', question: 'Combien font 5 × 9 ?',
        options: ['40', '45', '50', '55'], correctAnswer: '45', difficulty: 2, points: 15),

    // --- GEOMETRIE ---
    Exercise(id: 'geometry_1', subject: 'math', type: 'qcm', question: 'Combien de côtés a un carré ?',
        options: ['3', '4', '5', '6'], correctAnswer: '4', difficulty: 1, points: 10),
    Exercise(id: 'geometry_2', subject: 'math', type: 'qcm', question: 'Combien de côtés a un triangle ?',
        options: ['2', '3', '4', '5'], correctAnswer: '3', difficulty: 1, points: 10),
    Exercise(id: 'geometry_3', subject: 'math', type: 'qcm', question: 'Quelle forme est ronde ?',
        options: ['Carré', 'Triangle', 'Cercle', 'Rectangle'], correctAnswer: 'Cercle', difficulty: 1, points: 10),
    Exercise(id: 'geometry_4', subject: 'math', type: 'qcm', question: 'Un rectangle a combien de côtés ?',
        options: ['3', '4', '5', '6'], correctAnswer: '4', difficulty: 1, points: 10),
    Exercise(id: 'geometry_5', subject: 'math', type: 'qcm', question: 'Quelle forme a 6 côtés ?',
        options: ['Pentagone', 'Hexagone', 'Carré', 'Triangle'], correctAnswer: 'Hexagone', difficulty: 2, points: 15),

    // --- LOGIQUE ---
    Exercise(id: 'logic_1', subject: 'math', type: 'qcm', question: 'Quel nombre vient après 19 ?',
        options: ['18', '20', '21', '22'], correctAnswer: '20', difficulty: 1, points: 10),
    Exercise(id: 'logic_2', subject: 'math', type: 'qcm', question: 'Combien y a-t-il de jours dans une semaine ?',
        options: ['5', '6', '7', '8'], correctAnswer: '7', difficulty: 1, points: 10),
    Exercise(id: 'logic_3', subject: 'math', type: 'qcm', question: 'Combien y a-t-il de mois dans une année ?',
        options: ['10', '11', '12', '13'], correctAnswer: '12', difficulty: 1, points: 10),
    Exercise(id: 'logic_4', subject: 'math', type: 'qcm', question: 'Quel est le double de 8 ?',
        options: ['14', '15', '16', '17'], correctAnswer: '16', difficulty: 2, points: 15),
    Exercise(id: 'logic_5', subject: 'math', type: 'qcm', question: 'Quel est la moitié de 20 ?',
        options: ['8', '9', '10', '11'], correctAnswer: '10', difficulty: 2, points: 15),

    // ============================================================
    // EXERCICES POUR DEVOIRS "NUM 13" (Laura Diaz - CE2)
    // ============================================================
    // Exercice 13 - Numération : les nombres jusqu'à 9999
    Exercise(
      id: 'num13_1', subject: 'math', type: 'qcm',
      question: 'Num 13 - Exercice 1 : Quel nombre est égal à 3 milliers + 4 centaines + 5 dizaines + 2 unités ?',
      options: ['3425', '3452', '3245', '3542'], correctAnswer: '3452',
      difficulty: 2, points: 15,
      hint: '3 000 + 400 + 50 + 2 = ?'
    ),
    Exercise(
      id: 'num13_2', subject: 'math', type: 'qcm',
      question: 'Num 13 - Exercice 2 : Comment écrit-on "deux mille quatre cent dix-sept" en chiffres ?',
      options: ['2417', '24017', '20417', '24170'], correctAnswer: '2417',
      difficulty: 2, points: 15,
      hint: '2 000 + 400 + 10 + 7'
    ),
    Exercise(
      id: 'num13_3', subject: 'math', type: 'qcm',
      question: 'Num 13 - Exercice 3 : Le nombre 5 738 a quel chiffre des centaines ?',
      options: ['5', '7', '3', '8'], correctAnswer: '7',
      difficulty: 2, points: 15,
      hint: '5 7 3 8 = 5 milliers, 7 centaines, 3 dizaines, 8 unités'
    ),
    Exercise(
      id: 'num13_4', subject: 'math', type: 'qcm',
      question: 'Num 13 - Exercice 4 : Compare : 4 502 ___ 4 520',
      options: ['<', '>', '=', '≈'], correctAnswer: '<',
      difficulty: 2, points: 15,
      hint: '502 est plus petit que 520'
    ),
    Exercise(
      id: 'num13_5', subject: 'math', type: 'qcm',
      question: 'Num 13 - Exercice 5 : Range ces nombres du plus petit au plus grand : 2345, 2543, 2435, 2354',
      options: [
        '2345, 2354, 2435, 2543',
        '2543, 2435, 2354, 2345',
        '2345, 2435, 2354, 2543',
        '2354, 2345, 2435, 2543'
      ],
      correctAnswer: '2345, 2354, 2435, 2543',
      difficulty: 3, points: 20,
      hint: 'Commence par comparer les milliers, puis les centaines...'
    ),
    Exercise(
      id: 'num13_6', subject: 'math', type: 'qcm',
      question: 'Num 13 - Exercice 6 : Le nombre qui vient juste avant 4 000 est :',
      options: ['3999', '3990', '4001', '3998'], correctAnswer: '3999',
      difficulty: 2, points: 15,
      hint: '4 000 - 1 = ?'
    ),
    Exercise(
      id: 'num13_7', subject: 'math', type: 'qcm',
      question: 'Num 13 - Exercice 7 : Le nombre 8 291 est composé de :',
      options: [
        '8 milliers + 2 centaines + 9 dizaines + 1 unité',
        '8 milliers + 2 centaines + 9 dizaines + 0 unité',
        '8 milliers + 2 centaines + 1 dizaine + 9 unités',
        '8 milliers + 9 centaines + 2 dizaines + 1 unité'
      ],
      correctAnswer: '8 milliers + 2 centaines + 9 dizaines + 1 unité',
      difficulty: 2, points: 15,
      hint: '8 291 = 8 000 + 200 + 90 + 1'
    ),
    Exercise(
      id: 'num13_8', subject: 'math', type: 'qcm',
      question: 'Num 13 - Exercice 8 : Quel est le plus grand nombre ?',
      options: ['3456', '3546', '3645', '3465'], correctAnswer: '3645',
      difficulty: 2, points: 15,
      hint: 'Compare d\'abord les milliers, puis les centaines...'
    ),
    Exercise(
      id: 'num13_9', subject: 'math', type: 'qcm',
      question: 'Num 13 - Exercice 9 : Encadre 2 580 entre les centaines les plus proches :',
      options: [
        '2 500 et 2 600',
        '2 580 et 2 590',
        '2 000 et 3 000',
        '2 500 et 2 700'
      ],
      correctAnswer: '2 500 et 2 600',
      difficulty: 3, points: 20,
      hint: '2 580 est entre 2 500 et 2 600'
    ),
    Exercise(
      id: 'num13_10', subject: 'math', type: 'qcm',
      question: 'Num 13 - Exercice 10 : Combien de chiffres a le nombre "six mille huit cent quarante-trois" ?',
      options: ['3', '4', '5', '6'], correctAnswer: '4',
      difficulty: 2, points: 15,
      hint: '6 8 4 3 = 4 chiffres'
    ),
    Exercise(
      id: 'num13_11', subject: 'math', type: 'qcm',
      question: 'Num 13 - Exercice 11 : Dans 7 654, le chiffre 6 représente :',
      options: ['6 unités', '6 dizaines', '6 centaines', '6 milliers'],
      correctAnswer: '6 centaines',
      difficulty: 2, points: 15,
      hint: '7 6 5 4 = 7 milliers, 6 centaines, 5 dizaines, 4 unités'
    ),
    Exercise(
      id: 'num13_12', subject: 'math', type: 'qcm',
      question: 'Num 13 - Exercice 12 : 3 000 + 500 + 40 + 9 = ?',
      options: ['3549', '3594', '3495', '3459'], correctAnswer: '3549',
      difficulty: 2, points: 15,
      hint: '3 000 + 500 + 40 + 9 = 3 549'
    ),
  ];
}
