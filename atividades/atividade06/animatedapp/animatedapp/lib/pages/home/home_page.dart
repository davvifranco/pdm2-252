import 'package:flutter/material.dart';
import 'home.dart';
import 'settings.dart';

// IMPORTAÇÕES CORRETAS
import '../../src/widgets/navigation_bar.dart';
import '../../src/widgets/navigation_drawer.dart';
import '../../src/widgets/navigation_rail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [Home(), Settings()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // SMALL SCREEN (CELULAR)
        if (constraints.maxWidth < 600) {
          return Scaffold(
            drawer: MyNavigationDrawer(
              onDestinationSelected: _onItemTapped,
              selectedIndex: _selectedIndex,
            ),
            appBar: AppBar(title: const Text("Responsive App")),
            body: _screens[_selectedIndex],
            bottomNavigationBar: MyNavigationBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          );
        }

        // MEDIUM SCREEN (TABLET)
        if (constraints.maxWidth < 1000) {
          return Scaffold(
            appBar: AppBar(title: const Text("Responsive App")),
            body: Row(
              children: [
                MyNavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onItemTapped,
                ),
                Expanded(child: _screens[_selectedIndex]),
              ],
            ),
          );
        }

        // LARGE SCREEN (DESKTOP)
        return Scaffold(
          appBar: AppBar(title: const Text("Responsive App")),
          body: Row(
            children: [
              MyNavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onItemTapped,
              ),
              Expanded(child: _screens[_selectedIndex]),
            ],
          ),
        );
      },
    );
  }
}
