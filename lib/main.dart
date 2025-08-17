import 'package:ecg_app/data/classes/constants.dart';
import 'package:ecg_app/data/classes/notifiers.dart';
import 'package:flutter/material.dart';
import 'package:ecg_app/views/pages/sign_up.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    initBrightnessTheme();
    super.initState();
  }

  // Used to read the KV stored in phone's memory to get brightness pref
  void initBrightnessTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? savedThemeIsDark = prefs.getBool(KConstants.brightnessKey);
    isDarkModeNotifier.value = savedThemeIsDark ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          title: 'ECG app',
          // Removes the ugly debug banner
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Color(0xFF086788),
              brightness: isDarkMode ? Brightness.dark : Brightness.light,
            ),
          ),
          home: SignUpPage(),
        );
      },
    );
  }
}
