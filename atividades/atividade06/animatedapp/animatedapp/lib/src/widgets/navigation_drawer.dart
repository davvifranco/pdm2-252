import 'package:flutter/material.dart';

class MyNavigationDrawer extends StatelessWidget {
  const MyNavigationDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      children: const [
        NavigationDrawerDestination(
          icon: Icon(Icons.mail),
          label: Text('Inbox'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.people),
          label: Text('Contacts'),
        ),
      ],
    );
  }
}
