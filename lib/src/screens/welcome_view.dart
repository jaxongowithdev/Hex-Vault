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
      'icon': Icons.album,
      'title': 'A quieter record folio',
      'description':
          'Map every crate in the den. Know which pressing lives on which shelf before you flip for twenty minutes.',
    },
    {
      'icon': Icons.photo_outlined,
      'title': 'Keep the sleeve in view',
      'description':
          'Photograph the cover or the dead-wax so you remember the exact pressing you own.',
    },
    {
      'icon': Icons.search,
      'title': 'Find the cut, not the pile',
      'description':
          'Search an artist, a label, or a scribbled note and see the crate immediately.',
    },
    {
      'icon': Icons.lock_outline,
      'title': 'The collection stays here',
      'description':
          'No account, no cloud, no marketplace. The folio lives only on this phone.',
    },
  ];

  Future<void> _finishOnboarding() async {
    final storage = StorageManager.instance;
    final prefs = await storage.getPreferences();
    await storage.updatePreferences(prefs.copyWith(showOnboarding: false));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DashboardView(onSettingsChanged: () {}),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VisualTheme.ivory,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(32, 12, 32, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        Icon(page['icon'] as IconData, size: 64, color: VisualTheme.primaryColor),
                        const SizedBox(height: 28),
                        Text(
                          page['title'] as String,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 36,
                            height: 1.15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page['description'] as String,
                          style: GoogleFonts.figtree(fontSize: 17, height: 1.5),
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
                    (index) => Container(
                      margin: const EdgeInsets.only(right: 6),
                      width: _currentPage == index ? 20 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? VisualTheme.primaryColor
                            : VisualTheme.linen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _finishOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    child: Text(_currentPage == _pages.length - 1 ? 'Open the folio' : 'Continue'),
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
