import 'package:flutter_test/flutter_test.dart';
import 'package:emilie_app/models/adaptive_engine.dart';

void main() {
  group('AdaptiveEngine.recommendedDifficulty', () {
    late AdaptiveEngine engine;

    setUp(() {
      engine = AdaptiveEngine();
    });

    test('returns 1 when history is empty or skillId is not found', () {
      expect(engine.recommendedDifficulty('math_addition'), 1);
    });

    test('returns 1 when average success rate is below targetMin (0.75)', () {
      engine.recordSession('math_addition', 0.5);
      engine.recordSession('math_addition', 0.6);
      // avg = 0.55
      expect(engine.recommendedDifficulty('math_addition'), 1);
    });

    test('returns 3 when average success rate is above targetMax (0.85)', () {
      engine.recordSession('math_addition', 0.9);
      engine.recordSession('math_addition', 0.9);
      // avg = 0.9
      expect(engine.recommendedDifficulty('math_addition'), 3);
    });

    test('returns 2 when average success rate is within target range [0.75, 0.85]', () {
      engine.recordSession('math_addition', 0.8);
      // avg = 0.8
      expect(engine.recommendedDifficulty('math_addition'), 2);
    });

    test('returns 2 at exactly targetMin (0.75)', () {
      engine.recordSession('math_addition', 0.75);
      expect(engine.recommendedDifficulty('math_addition'), 2);
    });

    test('returns 2 at exactly targetMax (0.85)', () {
      engine.recordSession('math_addition', 0.85);
      expect(engine.recommendedDifficulty('math_addition'), 2);
    });
  });
}
