import 'package:flutter/material.dart';

class MyNavigationRail extends StatelessWidget {
  const MyNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.selected,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.mail),
          label: Text('Inbox'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.people),
          label: Text('Contacts'),
        ),
      ],
    );
  }
}
