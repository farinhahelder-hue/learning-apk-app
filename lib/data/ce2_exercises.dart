import '../models/exercise.dart';

// Exercices niveau début CE2 (pour les skills level=CE2)
class CE2Exercises {
  static List<Exercise> getBySkill(String skillId) {
    return _all.where((e) => e.id.startsWith(skillId)).toList();
  }

  static const List<Exercise> _all = [
    // --- NOMBRES JUSQU'À 1000 ---
    Exercise(
        id: 'sk_count1000_1',
        subject: 'math',
        type: 'qcm',
        question: 'Quel nombre vient après 299 ?',
        options: ['290', '300', '298', '399'],
        correctAnswer: '300',
        difficulty: 2,
        points: 15),
    Exercise(
        id: 'sk_count1000_2',
        subject: 'math',
        type: 'qcm',
        question: 'Combien y a-t-il de dizaines dans 350 ?',
        options: ['3', '5', '35', '350'],
        correctAnswer: '35',
        difficulty: 3,
        points: 20),
    Exercise(
        id: 'sk_count1000_3',
        subject: 'math',
        type: 'qcm',
        question: 'Quel est le chiffre des centaines dans 742 ?',
        options: ['2', '4', '7', '42'],
        correctAnswer: '7',
        difficulty: 2,
        points: 15),
    Exercise(
        id: 'sk_count1000_4',
        subject: 'math',
        type: 'qcm',
        question: 'Combien font 400 + 60 + 5 ?',
        options: ['465', '456', '645', '564'],
        correctAnswer: '465',
        difficulty: 2,
        points: 15),

    // --- TABLES ×6 À ×9 ---
    Exercise(
        id: 'sk_mult6_9_1',
        subject: 'math',
        type: 'qcm',
        question: 'Combien font 6 × 7 ?',
        options: ['36', '40', '42', '48'],
        correctAnswer: '42',
        difficulty: 2,
        points: 15),
    Exercise(
        id: 'sk_mult6_9_2',
        subject: 'math',
        type: 'qcm',
        question: 'Combien font 8 × 9 ?',
        options: ['63', '70', '72', '81'],
        correctAnswer: '72',
        difficulty: 2,
        points: 15),
    Exercise(
        id: 'sk_mult6_9_3',
        subject: 'math',
        type: 'qcm',
        question: 'Combien font 7 × 7 ?',
        options: ['42', '45', '49', '56'],
        correctAnswer: '49',
        difficulty: 2,
        points: 15),
    Exercise(
        id: 'sk_mult6_9_4',
        subject: 'math',
        type: 'qcm',
        question: 'Combien font 9 × 6 ?',
        options: ['48', '54', '56', '63'],
        correctAnswer: '54',
        difficulty: 3,
        points: 20),

    // --- DIVISION SIMPLE ---
    Exercise(
        id: 'sk_division_1',
        subject: 'math',
        type: 'qcm',
        question: 'Combien font 12 ÷ 4 ?',
        options: ['2', '3', '4', '6'],
        correctAnswer: '3',
        difficulty: 2,
        points: 15),
    Exercise(
        id: 'sk_division_2',
        subject: 'math',
        type: 'qcm',
        question: 'Combien font 20 ÷ 5 ?',
        options: ['3', '4', '5', '6'],
        correctAnswer: '4',
        difficulty: 2,
        points: 15),
    Exercise(
        id: 'sk_division_3',
        subject: 'math',
        type: 'qcm',
        question: 'Combien font 18 ÷ 3 ?',
        options: ['4', '5', '6', '7'],
        correctAnswer: '6',
        difficulty: 2,
        points: 15),
    Exercise(
        id: 'sk_division_4',
        subject: 'math',
        type: 'qcm',
        question:
            'Je partage 24 bonbons entre 6 enfants. Chacun en reçoit combien ?',
        options: ['3', '4', '5', '6'],
        correctAnswer: '4',
        difficulty: 2,
        points: 15),

    // --- PÉRIMÈTRE ---
    Exercise(
        id: 'sk_perimeter_1',
        subject: 'math',
        type: 'qcm',
        question: 'Un carré a des côtés de 4 cm. Quel est son périmètre ?',
        options: ['8 cm', '12 cm', '16 cm', '4 cm'],
        correctAnswer: '16 cm',
        difficulty: 2,
        points: 15),
    Exercise(
        id: 'sk_perimeter_2',
        subject: 'math',
        type: 'qcm',
        question: 'Un rectangle mesure 5 cm et 3 cm. Quel est son périmètre ?',
        options: ['8 cm', '15 cm', '16 cm', '10 cm'],
        correctAnswer: '16 cm',
        difficulty: 3,
        points: 20),

    // --- IMPARFAIT ---
    Exercise(
        id: 'sk_imparfait_1',
        subject: 'french',
        type: 'qcm',
        question: 'Conjugue à l’imparfait : Je ___ (jouer) au parc.',
        options: ['joue', 'jouais', 'jouera', 'jouons'],
        correctAnswer: 'jouais',
        difficulty: 2,
        points: 15),
    Exercise(
        id: 'sk_imparfait_2',
        subject: 'french',
        type: 'qcm',
        question: 'Conjugue à l’imparfait : Il ___ (être) content.',
        options: ['était', 'est', 'sera', 'étant'],
        correctAnswer: 'était',
        difficulty: 2,
        points: 15),
    Exercise(
        id: 'sk_imparfait_3',
        subject: 'french',
        type: 'qcm',
        question: 'Conjugue à l’imparfait : Nous ___ (manger) une pizza.',
        options: ['mangeons', 'mangions', 'mangerons', 'mangeais'],
        correctAnswer: 'mangions',
        difficulty: 3,
        points: 20),

    // --- ADJECTIF QUALIFICATIF ---
    Exercise(
        id: 'sk_gram_adj_1',
        subject: 'french',
        type: 'qcm',
        question:
            'Dans "une belle fleur rouge", combien y a-t-il d’adjectifs ?',
        options: ['0', '1', '2', '3'],
        correctAnswer: '2',
        difficulty: 2,
        points: 15),
    Exercise(
        id: 'sk_gram_adj_2',
        subject: 'french',
        type: 'qcm',
        question: 'Quel adjectif est au féminin ?',
        options: ['grand', 'petit', 'jolie', 'rapide'],
        correctAnswer: 'jolie',
        difficulty: 2,
        points: 15),
    Exercise(
        id: 'sk_gram_adj_3',
        subject: 'french',
        type: 'qcm',
        question: 'Comment met-on "beau" au pluriel ?',
        options: ['beau', 'beaux', 'beaus', 'belle'],
        correctAnswer: 'beaux',
        difficulty: 3,
        points: 20),

    // --- COMPLÉMENT CIRCONSTANCIEL ---
    Exercise(
        id: 'sk_gram_ccl_1',
        subject: 'french',
        type: 'qcm',
        question: 'Dans "Emilie joue dans le jardin", où joue-t-elle ?',
        options: ['Emilie', 'joue', 'dans le jardin', 'le jardin'],
        correctAnswer: 'dans le jardin',
        difficulty: 2,
        points: 15),
    Exercise(
        id: 'sk_gram_ccl_2',
        subject: 'french',
        type: 'qcm',
        question: 'Un complément circonstanciel de lieu répond à la question :',
        options: ['Qui ?', 'Que fait-il ?', 'Où ?', 'Pourquoi ?'],
        correctAnswer: 'Où ?',
        difficulty: 2,
        points: 15),

    // --- MOTS CE2 ---
    Exercise(
        id: 'sk_spell_ce2_1',
        subject: 'french',
        type: 'qcm',
        question: 'Quelle est la bonne orthographe ?',
        options: ['biccyclette', 'bicyclette', 'bisyclette', 'bisiclete'],
        correctAnswer: 'bicyclette',
        difficulty: 3,
        points: 20),
    Exercise(
        id: 'sk_spell_ce2_2',
        subject: 'french',
        type: 'qcm',
        question: 'Quelle est la bonne orthographe du repas du matin ?',
        options: [
          'ptit déjeuner',
          'petit déjeuner',
          'petit déjeuné',
          'pétit déjeuner'
        ],
        correctAnswer: 'petit déjeuner',
        difficulty: 2,
        points: 15),
    Exercise(
        id: 'sk_spell_ce2_3',
        subject: 'french',
        type: 'qcm',
        question: 'Quelle est la bonne orthographe ?',
        options: ['necessaire', 'nécessaire', 'néssessaire', 'nécéssaire'],
        correctAnswer: 'nécessaire',
        difficulty: 3,
        points: 20),
  ];
}
