import 'package:flutter_test/flutter_test.dart';
import 'package:emilie_app/models/game_session.dart';
import 'package:emilie_app/models/exercise.dart';

void main() {
  group('GameSession.computeStars', () {
    test('returns 0 stars for score < 50%', () {
      final session = GameSession(
        worldId: 'math',
        skillId: 'addition',
        gameType: GameType.quiz,
        exercises: [
          Exercise(id: '1', subject: 'math', type: 'quiz', question: '1+1', correctAnswer: '2'),
          Exercise(id: '2', subject: 'math', type: 'quiz', question: '2+2', correctAnswer: '4'),
        ],
      );
      session.score = 9; // 9/20 = 45%
      expect(session.computeStars(), 0);
    });

    test('returns 1 star for 50% <= score < 70%', () {
      final session = GameSession(
        worldId: 'math',
        skillId: 'addition',
        gameType: GameType.quiz,
        exercises: [
          Exercise(id: '1', subject: 'math', type: 'quiz', question: '1+1', correctAnswer: '2'),
          Exercise(id: '2', subject: 'math', type: 'quiz', question: '2+2', correctAnswer: '4'),
        ],
      );
      session.score = 10; // 10/20 = 50%
      expect(session.computeStars(), 1);

      session.score = 13; // 13/20 = 65%
      expect(session.computeStars(), 1);
    });

    test('returns 2 stars for 70% <= score < 100%', () {
      final session = GameSession(
        worldId: 'math',
        skillId: 'addition',
        gameType: GameType.quiz,
        exercises: [
          Exercise(id: '1', subject: 'math', type: 'quiz', question: '1+1', correctAnswer: '2'),
          Exercise(id: '2', subject: 'math', type: 'quiz', question: '2+2', correctAnswer: '4'),
        ],
      );
      session.score = 14; // 14/20 = 70%
      expect(session.computeStars(), 2);

      session.score = 19; // 19/20 = 95%
      expect(session.computeStars(), 2);
    });

    test('returns 3 stars for score >= 100%', () {
      final session = GameSession(
        worldId: 'math',
        skillId: 'addition',
        gameType: GameType.quiz,
        exercises: [
          Exercise(id: '1', subject: 'math', type: 'quiz', question: '1+1', correctAnswer: '2'),
          Exercise(id: '2', subject: 'math', type: 'quiz', question: '2+2', correctAnswer: '4'),
        ],
      );
      session.score = 20; // 20/20 = 100%
      expect(session.computeStars(), 3);

      session.score = 25; // 25/20 = 125%
      expect(session.computeStars(), 3);
    });

    test('returns 0 stars for empty exercises list', () {
      final session = GameSession(
        worldId: 'math',
        skillId: 'addition',
        gameType: GameType.quiz,
        exercises: [],
      );
      session.score = 10;
      expect(session.computeStars(), 0);
    });
  });
}
