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

    // --- CE2 : NOMBRES JUSQU'À 1000 ---
    Exercise(id: 'ce2_nombres_1', subject: 'math', type: 'qcm', question: 'Combien y a-t-il de centaines dans 400 ?',
        options: ['2', '3', '4', '5'], correctAnswer: '4', difficulty: 2, points: 15),
    Exercise(id: 'ce2_nombres_2', subject: 'math', type: 'qcm', question: 'Quel nombre vient juste après 999 ?',
        options: ['1000', '1001', '998', '9990'], correctAnswer: '1000', difficulty: 2, points: 15),
    Exercise(id: 'ce2_nombres_3', subject: 'math', type: 'qcm', question: 'Dans 735, quel est le chiffre des centaines ?',
        options: ['7', '3', '5', '735'], correctAnswer: '7', difficulty: 2, points: 15),
    Exercise(id: 'ce2_nombres_4', subject: 'math', type: 'qcm', question: '600 + 80 + 9 = ?',
        options: ['689', '6089', '6809', '609'], correctAnswer: '689', difficulty: 2, points: 15),
    Exercise(id: 'ce2_nombres_5', subject: 'math', type: 'qcm', question: 'Quel est le plus grand nombre : 456 / 546 / 465 / 654 ?',
        options: ['456', '546', '465', '654'], correctAnswer: '654', difficulty: 3, points: 20),

    // --- CE2 : TABLES DE MULTIPLICATION 6 À 9 ---
    Exercise(id: 'ce2_mult_1', subject: 'math', type: 'qcm', question: 'Combien font 6 × 7 ?',
        options: ['42', '48', '36', '54'], correctAnswer: '42', difficulty: 2, points: 15),
    Exercise(id: 'ce2_mult_2', subject: 'math', type: 'qcm', question: 'Combien font 8 × 9 ?',
        options: ['72', '81', '63', '56'], correctAnswer: '72', difficulty: 2, points: 15),
    Exercise(id: 'ce2_mult_3', subject: 'math', type: 'qcm', question: 'Combien font 7 × 8 ?',
        options: ['56', '63', '49', '42'], correctAnswer: '56', difficulty: 2, points: 15),
    Exercise(id: 'ce2_mult_4', subject: 'math', type: 'qcm', question: 'Combien font 9 × 9 ?',
        options: ['81', '72', '90', '99'], correctAnswer: '81', difficulty: 2, points: 15),
    Exercise(id: 'ce2_mult_5', subject: 'math', type: 'qcm', question: 'Si j\'ai 6 boîtes de 8 crayons, combien de crayons ?',
        options: ['42', '48', '56', '14'], correctAnswer: '48', difficulty: 3, points: 20),

    // --- CE2 : DIVISIONS ---
    Exercise(id: 'ce2_div_1', subject: 'math', type: 'qcm', question: 'Combien font 12 ÷ 3 ?',
        options: ['3', '4', '5', '6'], correctAnswer: '4', difficulty: 2, points: 15),
    Exercise(id: 'ce2_div_2', subject: 'math', type: 'qcm', question: '20 partagé en 4, ça fait ?',
        options: ['4', '5', '6', '3'], correctAnswer: '5', difficulty: 2, points: 15),
    Exercise(id: 'ce2_div_3', subject: 'math', type: 'qcm', question: 'Combien font 24 ÷ 6 ?',
        options: ['3', '4', '5', '6'], correctAnswer: '4', difficulty: 2, points: 15),
    Exercise(id: 'ce2_div_4', subject: 'math', type: 'qcm', question: 'Je distribue 18 cartes à 3 amis. Combien chacun ?',
        options: ['5', '6', '7', '4'], correctAnswer: '6', difficulty: 3, points: 20),
    Exercise(id: 'ce2_div_5', subject: 'math', type: 'qcm', question: 'Combien font 36 ÷ 4 ?',
        options: ['7', '8', '9', '10'], correctAnswer: '9', difficulty: 3, points: 20),

    // --- CE2 : PÉRIMÈTRE ---
    Exercise(id: 'ce2_perim_1', subject: 'math', type: 'qcm', question: 'Quel est le périmètre d\'un carré de 5 cm de côté ?',
        options: ['15 cm', '20 cm', '25 cm', '10 cm'], correctAnswer: '20 cm', difficulty: 2, points: 15),
    Exercise(id: 'ce2_perim_2', subject: 'math', type: 'qcm', question: 'Un rectangle fait 6 cm de long et 4 cm de large. Quel périmètre ?',
        options: ['10 cm', '20 cm', '24 cm', '12 cm'], correctAnswer: '20 cm', difficulty: 3, points: 20),
    Exercise(id: 'ce2_perim_3', subject: 'math', type: 'qcm', question: 'Le périmètre d\'un carré est 24 cm. Combien mesure un côté ?',
        options: ['4 cm', '5 cm', '6 cm', '8 cm'], correctAnswer: '6 cm', difficulty: 3, points: 20),

    // --- CE2 : FRACTIONS ---
    Exercise(id: 'ce2_frac_1', subject: 'math', type: 'qcm', question: 'Quelle fraction représente la partie colorée d\'un gâteau coupé en 4 parts égales dont 1 est prise ?',
        options: ['1/2', '1/4', '2/4', '3/4'], correctAnswer: '1/4', difficulty: 2, points: 15),
    Exercise(id: 'ce2_frac_2', subject: 'math', type: 'qcm', question: '1/2 est-il plus grand ou plus petit que 1/4 ?',
        options: ['Plus petit', 'Plus grand', 'Égal', 'On ne peut pas comparer'], correctAnswer: 'Plus grand', difficulty: 2, points: 15),
    Exercise(id: 'ce2_frac_3', subject: 'math', type: 'qcm', question: 'Deux quartiers de pizza sur quatre, c\'est la moitié. Vrai ou faux ?',
        options: ['Vrai', 'Faux', 'Ça dépend', 'Ni l\'un ni l\'autre'], correctAnswer: 'Vrai', difficulty: 2, points: 15),
  ];
}
