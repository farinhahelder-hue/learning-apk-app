import 'package:flutter_test/flutter_test.dart';
import 'package:emilie_app/models/game_session.dart';

void main() {
  group('WorldProgress.isSkillUnlocked', () {
    late WorldProgress worldProgress;
    late List<Map<String, dynamic>> skills;

    setUp(() {
      worldProgress = WorldProgress(worldId: 'world1');
      skills = [
        {'id': 'skill1'},
        {'id': 'skill2'},
        {'id': 'skill3'},
      ];
    });

    test('first skill is always unlocked', () {
      expect(worldProgress.isSkillUnlocked('skill1', skills), isTrue);
    });

    test('skill not in list is not unlocked', () {
      expect(worldProgress.isSkillUnlocked('unknown_skill', skills), isFalse);
    });

    test('second skill is unlocked if first skill has 1 star', () {
      worldProgress.skillStars['skill1'] = 1;
      expect(worldProgress.isSkillUnlocked('skill2', skills), isTrue);
    });

    test('second skill is unlocked if first skill has more than 1 star', () {
      worldProgress.skillStars['skill1'] = 3;
      expect(worldProgress.isSkillUnlocked('skill2', skills), isTrue);
    });

    test('second skill is locked if first skill has 0 stars', () {
      worldProgress.skillStars['skill1'] = 0;
      expect(worldProgress.isSkillUnlocked('skill2', skills), isFalse);
    });

    test('second skill is locked if first skill is not in skillStars', () {
      // worldProgress.skillStars is empty
      expect(worldProgress.isSkillUnlocked('skill2', skills), isFalse);
    });

    test('third skill is locked even if first has stars, but second has none', () {
      worldProgress.skillStars['skill1'] = 3;
      // skill2 is missing or 0
      expect(worldProgress.isSkillUnlocked('skill3', skills), isFalse);
    });
  });
}
