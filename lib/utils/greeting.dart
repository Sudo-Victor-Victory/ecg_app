/// Free widget that displays a greeting based on the time of day
String greetOnTimeOfDay() {
  DateTime now = DateTime.now();
  String greeting = "Good Morning!!";

  greeting = (now.hour >= 12 && now.hour < 18)
      ? "Good Afternoon!"
      : "Good Evening!";
  greeting = now.hour < 12 ? "Good Morning!!" : greeting;
  return greeting;
}
