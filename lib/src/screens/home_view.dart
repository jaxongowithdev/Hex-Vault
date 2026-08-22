import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../utils/visual_theme.dart';
import 'container_detail_view.dart';
import 'item_form_view.dart';
import 'search_view.dart';
import 'container_form_view.dart';
import 'favorites_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _storage = StorageManager.instance;
  Map<String, int>? _stats;
  List<ContainerModel>? _recentContainers;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final stats = await _storage.getStatistics();
      final recentMaps = await _storage.getRecentlyUpdatedContainers(limit: 5);
      final recent = recentMaps.map((m) => ContainerModel.fromMap(m)).toList();

      setState(() {
        _stats = stats;
        _recentContainers = recent;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading home data: $e');
      setState(() => _isLoading = false);
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _greeting,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                'Larder Haven',
                                style: GoogleFonts.fraunces(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _roundAction(
                          key: const ValueKey('favorites_button'),
                          icon: Icons.favorite_border,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FavoritesView(),
                              ),
                            ).then((_) => _loadData());
                          },
                        ),
                        const SizedBox(width: 8),
                        _roundAction(
                          key: const ValueKey('search_button'),
                          icon: Icons.search,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SearchView(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildHeroCard(),
                    const SizedBox(height: 16),
                    _buildStatsGrid(),
                    const SizedBox(height: 24),
                    Text(
                      'Start a shelf',
                      style: GoogleFonts.fraunces(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildQuickActions(),
                    if (_recentContainers != null &&
                        _recentContainers!.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Text(
                        'Recently tended',
                        style: GoogleFonts.fraunces(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildRecentContainers(),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _roundAction({
    required Key key,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        key: key,
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, size: 22),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    final total = _stats?['totalItems'] ?? 0;
    final larders = _stats?['totalContainers'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [VisualTheme.primaryColor, Color(0xFF2C4234)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PANTRY PULSE',
            style: GoogleFonts.nunito(
              color: Colors.white70,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            total == 0
                ? 'Your shelves are still empty.'
                : '$total staples across $larders larders.',
            style: GoogleFonts.fraunces(
              color: Colors.white,
              fontSize: 24,
              height: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Restock with intention. Cook without rummaging.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    if (_stats == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _metricTile(
            'Larders',
            _stats!['totalContainers'].toString(),
            Icons.kitchen_outlined,
            VisualTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _metricTile(
            'Staples',
            _stats!['totalItems'].toString(),
            Icons.spa_outlined,
            VisualTheme.secondaryColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _metricTile(
            'Bare',
            _stats!['emptyContainers'].toString(),
            Icons.inbox_outlined,
            VisualTheme.accentColor,
          ),
        ),
      ],
    );
  }

  Widget _metricTile(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.fraunces(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _actionCard(
            key: const ValueKey('add_box_button'),
            title: 'New larder',
            subtitle: 'A shelf or bin',
            icon: Icons.add_home_work_outlined,
            color: VisualTheme.primaryColor,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContainerFormView(),
                ),
              );
              if (result == true) _loadData();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionCard(
            key: const ValueKey('add_item_button'),
            title: 'Add staple',
            subtitle: 'Jar, tin, sack',
            icon: Icons.add_circle_outline,
            color: VisualTheme.secondaryColor,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ItemFormView()),
              );
              if (result == true) _loadData();
            },
          ),
        ),
      ],
    );
  }

  Widget _actionCard({
    required Key key,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Card(
      child: InkWell(
        key: key,
        onTap: onPressed,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentContainers() {
    return Column(
      children: _recentContainers!.map((container) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: CircleAvatar(
                backgroundColor: VisualTheme.parchment,
                foregroundColor: VisualTheme.primaryColor,
                child: Text(
                  container.code.substring(0, 1),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              title: Text(
                container.name,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text('${container.room} · ${container.shelf}'),
              trailing: const Icon(Icons.north_east, size: 18),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ContainerDetailView(containerId: container.id!),
                  ),
                );
                _loadData();
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}
