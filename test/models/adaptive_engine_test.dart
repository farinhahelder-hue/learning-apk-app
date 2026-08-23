import 'package:flutter_test/flutter_test.dart';
import 'package:emilie_app/models/adaptive_engine.dart';
import 'package:emilie_app/models/exercise.dart';

void main() {
  group('AdaptiveEngine', () {
    late AdaptiveEngine engine;

    setUp(() {
      engine = AdaptiveEngine();
    });

    group('recordSession', () {
      test('records success rates correctly', () {
        engine.recordSession('math', 0.8);
        engine.recordSession('math', 0.85); // average is 0.825

        expect(engine.recommendedDifficulty('math'), 2); // 0.825 is in [0.75, 0.85] -> 2
      });

      test('keeps only the last 5 sessions', () {
        for (int i = 0; i < 6; i++) {
          engine.recordSession('math', i * 0.1);
        }

        // Sum of 0.1, 0.2, 0.3, 0.4, 0.5 is 1.5
        // Average is 1.5 / 5 = 0.3 -> difficulty 1
        expect(engine.recommendedDifficulty('math'), 1);
      });
    });

    group('recommendedDifficulty', () {
      test('returns 1 when no history', () {
        expect(engine.recommendedDifficulty('math'), 1);
      });

      test('returns 3 (hard) when average success > 0.85', () {
        engine.recordSession('math', 0.9);
        expect(engine.recommendedDifficulty('math'), 3);
      });

      test('returns 1 (easy) when average success < 0.75', () {
        engine.recordSession('math', 0.7);
        expect(engine.recommendedDifficulty('math'), 1);
      });

      test('returns 2 (medium) when average success is between 0.75 and 0.85', () {
        engine.recordSession('math', 0.8);
        expect(engine.recommendedDifficulty('math'), 2);
      });
    });

    group('filterExercises', () {
      final exercises = [
        Exercise(id: '1', subject: 'math', type: 'addition', question: '1+1', correctAnswer: '2', difficulty: 1),
        Exercise(id: '2', subject: 'math', type: 'addition', question: '10+10', correctAnswer: '20', difficulty: 2),
        Exercise(id: '3', subject: 'math', type: 'addition', question: '100+100', correctAnswer: '200', difficulty: 3),
        Exercise(id: '4', subject: 'math', type: 'addition', question: '1000+1000', correctAnswer: '2000', difficulty: 4),
      ];

      test('filters exercises based on recommended difficulty (+/- 1 level)', () {
        engine.recordSession('math', 0.8); // Difficulty is 2
        final filtered = engine.filterExercises('math', exercises);

        expect(filtered.length, 3); // Should include difficulty 1, 2, 3
        expect(filtered.map((e) => e.id), containsAll(['1', '2', '3']));
      });

      test('returns all exercises if the filtered list is empty', () {
        final hardExercises = [
          Exercise(id: '4', subject: 'math', type: 'addition', question: '1000+1000', correctAnswer: '2000', difficulty: 5),
        ];

        engine.recordSession('math', 0.7); // Difficulty is 1
        final filtered = engine.filterExercises('math', hardExercises);

        // Allowed is 0, 1, 2. No matching exercises. So it should return all.
        expect(filtered.length, 1);
        expect(filtered.first.id, '4');
      });
    });

    group('coachMessage', () {
      test('returns the correct message for >= 0.9', () {
        expect(engine.coachMessage(0.9), '🤩 Incroyable Emilie ! Tu es une vraie championne ! Je vais rendre les exercices un peu plus challengeants pour toi !');
      });

      test('returns the correct message for >= 0.75', () {
        expect(engine.coachMessage(0.75), '🌟 Super ! Tu es exactement dans la bonne zone ! Continue comme ça !');
      });

      test('returns the correct message for >= 0.5', () {
        expect(engine.coachMessage(0.5), '💪 Bien essayé ! On va reprendre depuis le début pour que tu te sentes plus à l’aise. Tu vas y arriver !');
      });

      test('returns the correct message for < 0.5', () {
        expect(engine.coachMessage(0.4), '🤗 Pas de souci ! Chaque erreur est une leçon. Je vais t’aider avec des exercices plus simples d’abord !');
      });
    });

    group('gentleErrorMessage', () {
      test('returns appropriate messages for different attempts', () {
        expect(AdaptiveEngine.gentleErrorMessage(0), '🤔 Hmm, pas tout à fait ! Réessaie !');
        expect(AdaptiveEngine.gentleErrorMessage(1), '🔍 Regarde bien la question...');
        expect(AdaptiveEngine.gentleErrorMessage(2), '🌈 Tu es près du but ! Encore un essai !');
        expect(AdaptiveEngine.gentleErrorMessage(3), '💡 Conseil : lis la question très lentement !');
        expect(AdaptiveEngine.gentleErrorMessage(4), '❤️ C’est difficile, mais tu es capable !');
      });

      test('clamps attempt numbers out of range', () {
        expect(AdaptiveEngine.gentleErrorMessage(-1), '🤔 Hmm, pas tout à fait ! Réessaie !');
        expect(AdaptiveEngine.gentleErrorMessage(10), '❤️ C’est difficile, mais tu es capable !');
      });
    });
  });
}
