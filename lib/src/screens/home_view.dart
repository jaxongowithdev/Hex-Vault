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
      setState(() {
        _stats = stats;
        _recentContainers = recentMaps.map(ContainerModel.fromMap).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading home data: $e');
      setState(() => _isLoading = false);
    }
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
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'VINYL FOLIO',
                                style: GoogleFonts.figtree(
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  color: VisualTheme.primaryColor,
                                ),
                              ),
                              Text(
                                'The listening room',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          key: const ValueKey('favorites_button'),
                          icon: const Icon(Icons.favorite_border),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const FavoritesView()),
                            ).then((_) => _loadData());
                          },
                        ),
                        IconButton(
                          key: const ValueKey('search_button'),
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SearchView()),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: VisualTheme.primaryColor,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ON THE SHELF',
                            style: GoogleFonts.figtree(
                              color: VisualTheme.secondaryColor,
                              letterSpacing: 1.6,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            (_stats?['totalItems'] ?? 0) == 0
                                ? 'The crates are still quiet.'
                                : '${_stats!['totalItems']} pressings across ${_stats!['totalContainers']} crates.',
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 26,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _metric('Crates', _stats?['totalContainers']?.toString() ?? '0'),
                        const SizedBox(width: 10),
                        _metric('Pressings', _stats?['totalItems']?.toString() ?? '0'),
                        const SizedBox(width: 10),
                        _metric('Empty', _stats?['emptyContainers']?.toString() ?? '0'),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: _cta(
                            key: const ValueKey('add_box_button'),
                            label: 'New crate',
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ContainerFormView()),
                              );
                              if (result == true) _loadData();
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _cta(
                            key: const ValueKey('add_item_button'),
                            label: 'Log pressing',
                            gold: true,
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ItemFormView()),
                              );
                              if (result == true) _loadData();
                            },
                          ),
                        ),
                      ],
                    ),
                    if (_recentContainers != null && _recentContainers!.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Text(
                        'Recently filed',
                        style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      ..._recentContainers!.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: VisualTheme.linen,
                                  child: Text(
                                    c.code.substring(0, 1),
                                    style: const TextStyle(
                                      color: VisualTheme.primaryColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                                subtitle: Text('${c.room} · ${c.shelf}'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ContainerDetailView(containerId: c.id!),
                                    ),
                                  );
                                  _loadData();
                                },
                              ),
                            ),
                          )),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(value, style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w600)),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cta({
    required Key key,
    required String label,
    required VoidCallback onTap,
    bool gold = false,
  }) {
    return Material(
      color: gold ? VisualTheme.secondaryColor : VisualTheme.primaryColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: gold ? VisualTheme.ink : Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
