import 'package:flutter_test/flutter_test.dart';
import 'package:emilie_app/models/screen_time.dart';

void main() {
  group('ScreenTimeService.sessionTimeLabel edge cases', () {
    late ScreenTimeService service;

    setUp(() {
      service = ScreenTimeService();
      service.startSession();
    });

    test('shows 00:00 for 0 seconds', () {
      expect(service.sessionTimeLabel, '00:00');
    });

    test('shows correctly formatted string under 10 minutes (1 min 5 secs)', () {
      // 1 minute and 5 seconds = 65 seconds
      for (var i = 0; i < 65; i++) {
        service.tick();
      }
      expect(service.sessionTimeLabel, '01:05');
    });

    test('shows correctly formatted string over 10 minutes (12 mins 34 secs)', () {
      // 12 minutes and 34 seconds = 754 seconds
      for (var i = 0; i < 754; i++) {
        service.tick();
      }
      expect(service.sessionTimeLabel, '12:34');
    });
  });
}
