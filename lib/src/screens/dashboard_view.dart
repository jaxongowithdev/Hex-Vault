import 'package:flutter/material.dart';
import 'home_view.dart';
import 'container_list_view.dart';
import 'analytics_view.dart';
import 'config_view.dart';

class DashboardView extends StatefulWidget {
  final VoidCallback onSettingsChanged;

  const DashboardView({super.key, required this.onSettingsChanged});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeView(),
      const ContainerListView(),
      const AnalyticsView(),
      ConfigView(onSettingsChanged: widget.onSettingsChanged),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.weekend_outlined),
            selectedIcon: Icon(Icons.weekend),
            label: 'Lounge',
          ),
          NavigationDestination(
            icon: Icon(Icons.album_outlined),
            selectedIcon: Icon(Icons.album),
            label: 'Crates',
          ),
          NavigationDestination(
            icon: Icon(Icons.graphic_eq),
            selectedIcon: Icon(Icons.graphic_eq),
            label: 'Spin',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune),
            selectedIcon: Icon(Icons.tune),
            label: 'Booth',
          ),
        ],
      ),
    );
  }
}
