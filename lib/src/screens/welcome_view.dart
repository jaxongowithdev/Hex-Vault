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

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.kitchen_outlined,
      'eyebrow': 'Larder Haven',
      'title': 'A quieter kitchen inventory',
      'description':
          'Map every jar, tin, and sack on your shelves. Know what is waiting before you write a shopping list.',
      'tone': VisualTheme.primaryColor,
    },
    {
      'icon': Icons.photo_camera_outlined,
      'eyebrow': 'Visual notes',
      'title': 'Snap the label, not just the name',
      'description':
          'Keep a photo with each staple so you remember the brand, the grind, or the bag you already opened.',
      'tone': VisualTheme.secondaryColor,
    },
    {
      'icon': Icons.travel_explore_outlined,
      'eyebrow': 'Find it fast',
      'title': 'Search the pantry, not the cupboard',
      'description':
          'Look up paprika, pasta, or tea and see exactly which larder and bay holds it.',
      'tone': const Color(0xFF6B7C59),
    },
    {
      'icon': Icons.lock_outline,
      'eyebrow': 'Stays local',
      'title': 'Your kitchen stays on this phone',
      'description':
          'No account, no cloud, no grocery ads. The catalog lives only on your device.',
      'tone': VisualTheme.ink,
    },
  ];

  Future<void> _finishOnboarding() async {
    final storage = StorageManager.instance;
    final prefs = await storage.getPreferences();
    await storage.updatePreferences(prefs.copyWith(showOnboarding: false));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DashboardView(
            onSettingsChanged: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final tone = page['tone'] as Color;

    return Scaffold(
      backgroundColor: tone,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: const Text(
                  'Skip tour',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final item = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(28, 12, 28, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          (item['eyebrow'] as String).toUpperCase(),
                          style: GoogleFonts.nunito(
                            color: Colors.white70,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item['title'] as String,
                          style: GoogleFonts.fraunces(
                            fontSize: 36,
                            height: 1.15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          item['description'] as String,
                          style: GoogleFonts.nunito(
                            fontSize: 17,
                            height: 1.45,
                            color: Colors.white.withValues(alpha: 0.86),
                          ),
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
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.only(right: 6),
                        width: _currentPage == index ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white38,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: tone,
                    ),
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _finishOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                        );
                      }
                    },
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'Open the larder'
                          : 'Continue',
                    ),
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
