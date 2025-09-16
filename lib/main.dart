import 'package:ecg_app/data/classes/constants.dart';
import 'package:ecg_app/data/classes/notifiers.dart';
import 'package:flutter/material.dart';
import 'package:ecg_app/views/pages/sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
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
          home: LogInPage(),
        );
      },
    );
  }
}
