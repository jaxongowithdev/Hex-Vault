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
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.auto_awesome_mosaic_outlined), selectedIcon: Icon(Icons.auto_awesome_mosaic), label: 'Bench'),
          NavigationDestination(icon: Icon(Icons.camera_roll_outlined), selectedIcon: Icon(Icons.camera_roll), label: 'Cans'),
          NavigationDestination(icon: Icon(Icons.equalizer_outlined), selectedIcon: Icon(Icons.equalizer), label: 'Stock'),
          NavigationDestination(icon: Icon(Icons.science_outlined), selectedIcon: Icon(Icons.science), label: 'Lab'),
        ],
      ),
    );
  }
}
