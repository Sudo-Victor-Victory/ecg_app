import 'package:ecg_app/views/widgets/widget_tree.dart';
import 'package:flutter/material.dart';

class NavbarWidget extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  const NavbarWidget({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      destinations: [
        for (var page in navbarPages)
          NavigationDestination(icon: Icon(page.icon), label: page.label),
      ],

      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
    );
  }
}
