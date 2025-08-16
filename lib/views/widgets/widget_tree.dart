import 'package:ecg_app/data/classes/notifiers.dart';
import 'package:ecg_app/views/pages/home.dart';
import 'package:ecg_app/views/widgets/navbar_widget.dart';
import 'package:flutter/material.dart';

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
    title: "Profile page",
    color: Colors.green,
    page: const Center(child: Text("Profile page")),
    icon: Icons.person,
    label: Text("Profile page"),
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
                onPressed: () {
                  isDarkModeNotifier.value = !isDarkModeNotifier.value;
                },
                icon: const Icon(Icons.dark_mode),
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
