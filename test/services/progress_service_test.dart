import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emilie_app/services/progress_service.dart';
import 'package:emilie_app/models/exercise.dart';
import 'package:emilie_app/utils/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProgressService', () {
    late ProgressService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initializes with default values when no data in SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();
      service = ProgressService(prefs);

      expect(service.progress.userId, 'emilie_001');
      expect(service.progress.totalPoints, 0);
      expect(service.progress.currentLevel, 1);
    });

    test('loads existing data from SharedPreferences', () async {
      final progressData = {
        'userId': 'emilie_001',
        'totalPoints': 150,
        'mathPoints': 50,
        'frenchPoints': 100,
        'sciencePoints': 0,
        'earnedBadges': ['first_exercise'],
        'exerciseScores': {},
        'currentLevel': 1,
        'streakDays': 2,
        'lastPlayDate': DateTime.now().toIso8601String(),
      };
      SharedPreferences.setMockInitialValues({'user_progress': json.encode(progressData)});
      final prefs = await SharedPreferences.getInstance();
      service = ProgressService(prefs);

      expect(service.progress.totalPoints, 150);
      expect(service.progress.mathPoints, 50);
      expect(service.progress.frenchPoints, 100);
      expect(service.progress.earnedBadges, contains('first_exercise'));
      expect(service.progress.streakDays, 2);
    });

    test('addPoints updates points and saves to SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();
      service = ProgressService(prefs);

      bool notified = false;
      service.addListener(() {
        notified = true;
      });

      await service.addPoints('math', 50);

      expect(service.progress.totalPoints, 50);
      expect(service.progress.mathPoints, 50);
      expect(notified, true);

      final savedData = prefs.getString('user_progress');
      expect(savedData, isNotNull);
      final decodedData = json.decode(savedData!);
      expect(decodedData['totalPoints'], 50);
      expect(decodedData['mathPoints'], 50);
    });

    test('addPoints calculates leveling up correctly', () async {
      final prefs = await SharedPreferences.getInstance();
      service = ProgressService(prefs);

      expect(service.progress.currentLevel, 1);

      await service.addPoints('math', AppConstants.pointsPerLevel);
      expect(service.progress.currentLevel, 2);

      await service.addPoints('science', AppConstants.pointsPerLevel * 2);
      expect(service.progress.currentLevel, 4);
    });

    test('addPoints earns badges correctly', () async {
      final prefs = await SharedPreferences.getInstance();
      service = ProgressService(prefs);

      await service.addPoints('math', 10);
      expect(service.progress.earnedBadges, contains('first_exercise'));

      await service.addPoints('math', 90);
      expect(service.progress.earnedBadges, contains('math_10'));
      expect(service.progress.earnedBadges, isNot(contains('total_500')));

      await service.addPoints('french', 400);
      expect(service.progress.earnedBadges, containsAll(['first_exercise', 'math_10', 'french_10', 'total_500']));
    });

    test('updateStreak calculates streaks correctly', () async {
      final prefs = await SharedPreferences.getInstance();

      // Setup a date 1 day ago
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final progressData = {
        'userId': 'emilie_001',
        'streakDays': 1,
        'lastPlayDate': yesterday.toIso8601String(),
      };

      SharedPreferences.setMockInitialValues({'user_progress': json.encode(progressData)});
      final prefsWithYesterday = await SharedPreferences.getInstance();
      service = ProgressService(prefsWithYesterday);

      await service.updateStreak();
      expect(service.progress.streakDays, 2);
    });

    test('updateStreak resets streak if missed a day', () async {
      // Setup a date 2 days ago
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final progressData = {
        'userId': 'emilie_001',
        'streakDays': 5,
        'lastPlayDate': twoDaysAgo.toIso8601String(),
      };

      SharedPreferences.setMockInitialValues({'user_progress': json.encode(progressData)});
      final prefsWithTwoDaysAgo = await SharedPreferences.getInstance();
      service = ProgressService(prefsWithTwoDaysAgo);

      await service.updateStreak();
      expect(service.progress.streakDays, 1);
    });

    test('getSubjectProgress returns correct points for each subject', () async {
      final prefs = await SharedPreferences.getInstance();
      service = ProgressService(prefs);

      await service.addPoints('math', 30);
      await service.addPoints('french', 40);
      await service.addPoints('science', 50);

      expect(service.getSubjectProgress('math'), 30);
      expect(service.getSubjectProgress('french'), 40);
      expect(service.getSubjectProgress('science'), 50);
      expect(service.getSubjectProgress('history'), 0);
    });

    test('resetProgress resets all progress values', () async {
      final prefs = await SharedPreferences.getInstance();
      service = ProgressService(prefs);

      await service.addPoints('math', 100);
      await service.updateStreak();

      expect(service.progress.totalPoints, 100);

      await service.resetProgress();

      expect(service.progress.totalPoints, 0);
      expect(service.progress.mathPoints, 0);
      expect(service.progress.earnedBadges, isEmpty);
      expect(service.progress.streakDays, 0);
      expect(service.progress.currentLevel, 1);

      final savedData = prefs.getString('user_progress');
      final decodedData = json.decode(savedData!);
      expect(decodedData['totalPoints'], 0);
    });
  });
}
