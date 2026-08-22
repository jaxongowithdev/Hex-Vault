import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../utils/visual_theme.dart';
import 'dashboard_view.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _pages = [
    {'icon': Icons.camera_roll, 'title': 'Canister Press', 'description': 'Stage every film can before you load. Know which roll lives in which canister.'},
    {'icon': Icons.photo_camera_outlined, 'title': 'Snap the stock', 'description': 'Photograph a box, a canister, or a developing note so you remember the ISO you own.'},
    {'icon': Icons.search, 'title': 'Find it in the fridge', 'description': 'Search “Portra” or “120” and see the can immediately.'},
    {'icon': Icons.wifi_off, 'title': 'Works in the darkroom', 'description': 'No account and no signal required. The catalog stays on this phone.'},
  ];

  Future<void> _finish() async {
    final storage = StorageManager.instance;
    final prefs = await storage.getPreferences();
    await storage.updatePreferences(prefs.copyWith(showOnboarding: false));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => DashboardView(onSettingsChanged: () {})),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VisualTheme.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _finish,
                child: Text('SKIP', style: GoogleFonts.dmSans(color: Colors.white54, letterSpacing: 1.4)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(28, 8, 28, 8),
                    child: Column(
                      children: [
                        const Spacer(),
                        Icon(page['icon'] as IconData, size: 72, color: VisualTheme.secondaryColor),
                        const SizedBox(height: 24),
                        Text(
                          page['title'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.instrumentSerif(fontSize: 36, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          page['description'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(fontSize: 16, height: 1.45, color: Colors.white70),
                        ),
                        const Spacer(),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  ...List.generate(
                    _pages.length,
                    (i) => Container(
                      margin: const EdgeInsets.only(right: 5),
                      width: 18,
                      height: 3,
                      color: _currentPage == i ? VisualTheme.secondaryColor : Colors.white24,
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _finish();
                      } else {
                        _pageController.nextPage(duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
                      }
                    },
                    child: Text(_currentPage == _pages.length - 1 ? 'Enter the lab' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
