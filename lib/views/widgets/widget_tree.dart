import 'package:ecg_app/data/classes/constants.dart';
import 'package:ecg_app/data/classes/notifiers.dart';
import 'package:ecg_app/views/pages/ecg_page.dart';
import 'package:ecg_app/views/pages/home.dart';
import 'package:ecg_app/views/pages/sessions.dart';
import 'package:ecg_app/views/widgets/navbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Defines params for navbarPages within navbar
// without it, we would need to create a new navbar + buttons
class PageConfig {
  final String title;
  final Color color;
  final Widget page;
  final IconData icon;
  final Text label;

  const PageConfig({
    required this.title,
    required this.color,
    required this.page,
    required this.icon,
    required this.label,
  });
}

final List<PageConfig> navbarPages = [
  PageConfig(
    title: "Home page",
    color: const Color(0xFF086788),
    page: HomePage(appBarTitle: "Home page", appBarColor: Color(0xFF086788)),
    icon: Icons.home,
    label: Text("Home page"),
  ),
  PageConfig(
    title: "BLE devices",
    color: const Color(0xFFF0C808),
    page: EcgPage(
      appBarColor: Color.fromARGB(255, 206, 157, 24),
      appBarTitle: "Connect to ECG",
    ),
    icon: Icons.bluetooth,
    label: Text("Bluetooth devices"),
  ),
  PageConfig(
    title: "Profile page",
    color: Colors.green,
    page: const Center(child: Text("Profile page")),
    icon: Icons.person,
    label: Text("Profile page"),
  ),
  PageConfig(
    title: "Chart from previous sessions",
    color: const Color(0xFF07A0C3),
    page: Sessions(),
    icon: Icons.show_chart_sharp,
    label: Text("idk what label was"),
  ),
];

// This widget is what handles the navbar logic after logging in
// without the need of rebuilding the appbar.
// tl;dr builds the appbar and the navbar thats shared between pages
class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        final config = navbarPages[selectedPage];

        return Scaffold(
          appBar: AppBar(
            title: Text(config.title),
            backgroundColor: config.color,
            centerTitle: true,
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
              IconButton(
                onPressed: () async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool(
                    KConstants.brightnessKey,
                    !isDarkModeNotifier.value,
                  );
                  isDarkModeNotifier.value = !isDarkModeNotifier.value;
                },
                icon: ValueListenableBuilder(
                  valueListenable: isDarkModeNotifier,
                  builder: (context, isDarkMode, child) {
                    return Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    );
                  },
                ),
              ),
            ],
          ),
          body: config.page,
          bottomNavigationBar: NavbarWidget(
            selectedIndex: selectedPage,
            onDestinationSelected: (newSelectedPage) =>
                selectedPageNotifier.value = newSelectedPage,
          ),
        );
      },
    );
  }
}
