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
    {
      'icon': Icons.volunteer_activism,
      'title': 'Your stash, finally mapped',
      'description': 'Give every basket a home. Know which wool lives in which drawer before you start another sweater.',
    },
    {
      'icon': Icons.photo_outlined,
      'title': 'Photograph the fiber',
      'description': 'Snap the label or the cake so you remember the dye lot, the yardage, and the brand.',
    },
    {
      'icon': Icons.search,
      'title': 'Find the skein, not the pile',
      'description': 'Search merino, sock, or a project name and see the basket immediately.',
    },
    {
      'icon': Icons.lock_outline,
      'title': 'The studio stays private',
      'description': 'No account, no cloud, no yarn ads. The stash lives only on this phone.',
    },
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
      backgroundColor: VisualTheme.blush,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: _finish, child: const Text('Skip')),
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
                        Container(
                          width: 96,
                          height: 96,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(page['icon'] as IconData, size: 42, color: VisualTheme.secondaryColor),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          page['title'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.newsreader(fontSize: 34, height: 1.15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          page['description'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.karla(fontSize: 16, height: 1.5),
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
                      margin: const EdgeInsets.only(right: 6),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == i ? VisualTheme.secondaryColor : Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _finish();
                      } else {
                        _pageController.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
                      }
                    },
                    child: Text(_currentPage == _pages.length - 1 ? 'Open the studio' : 'Next'),
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
