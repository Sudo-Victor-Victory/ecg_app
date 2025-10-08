import 'package:clock/clock.dart';

/// Free widget that displays a greeting based on the time of day
String greetOnTimeOfDay() {
  // utilizes clock to make it testable
  DateTime now = clock.now();
  String greeting = "Good Morning!";

  greeting = (now.hour >= 12 && now.hour < 18)
      ? "Good Afternoon!"
      : "Good Evening!";
  greeting = now.hour < 12 ? "Good Morning!" : greeting;
  return greeting;
}
