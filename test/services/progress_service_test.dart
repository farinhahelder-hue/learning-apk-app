import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emilie_app/services/progress_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ProgressService.addPoints', () {
    test('adds total points and subject points for math', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = ProgressService(prefs);

      expect(service.progress.totalPoints, 0);
      expect(service.progress.mathPoints, 0);

      await service.addPoints('math', 50);

      expect(service.progress.totalPoints, 50);
      expect(service.progress.mathPoints, 50);

      // French and Science should remain 0
      expect(service.progress.frenchPoints, 0);
      expect(service.progress.sciencePoints, 0);
    });

    test('adds total points and subject points for french', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = ProgressService(prefs);

      await service.addPoints('french', 30);

      expect(service.progress.totalPoints, 30);
      expect(service.progress.frenchPoints, 30);
      expect(service.progress.mathPoints, 0);
      expect(service.progress.sciencePoints, 0);
    });

    test('adds total points and subject points for science', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = ProgressService(prefs);

      await service.addPoints('science', 40);

      expect(service.progress.totalPoints, 40);
      expect(service.progress.sciencePoints, 40);
      expect(service.progress.mathPoints, 0);
      expect(service.progress.frenchPoints, 0);
    });

    test('checks level up when points exceed threshold', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = ProgressService(prefs);

      expect(service.progress.currentLevel, 1);

      // Threshold is 200 points per level (from AppConstants)
      await service.addPoints('math', 200);

      expect(service.progress.currentLevel, 2);
    });

    test('checks badges when points meet criteria', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = ProgressService(prefs);

      expect(service.progress.earnedBadges, isEmpty);

      // Add 10 points (first exercise)
      await service.addPoints('math', 10);
      expect(service.progress.earnedBadges, contains('first_exercise'));
      expect(service.progress.earnedBadges.length, 1);

      // Add 90 more points to get to 100 for math (math_10 badge)
      await service.addPoints('math', 90);
      expect(service.progress.earnedBadges, contains('first_exercise'));
      expect(service.progress.earnedBadges, contains('math_10'));
      expect(service.progress.earnedBadges.length, 2);
    });

    test('saves progress to SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = ProgressService(prefs);

      await service.addPoints('science', 15);

      final data = prefs.getString('user_progress');
      expect(data, isNotNull);
      expect(data, contains('"sciencePoints":15'));
      expect(data, contains('"totalPoints":15'));
    });
  });
}
