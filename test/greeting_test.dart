import 'package:ecg_app/utils/greeting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clock/clock.dart';

void main() {
  test('returns Good Morning for morning hours', () {
    withClock(Clock.fixed(DateTime(2025, 5, 5, 2, 30)), () {
      expect(greetOnTimeOfDay(), "Good Morning!");
    });
  });

  test('returns Good Afternoon for afternoon hours', () {
    withClock(Clock.fixed(DateTime(2025, 1, 1, 17, 30)), () {
      expect(greetOnTimeOfDay(), "Good Afternoon!");
    });
  });

  test('returns Good Evening for evening hours', () {
    withClock(Clock.fixed(DateTime(2025, 5, 5, 22, 0)), () {
      expect(greetOnTimeOfDay(), "Good Evening!");
    });
  });
}
