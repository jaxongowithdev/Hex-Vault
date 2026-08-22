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
                          child: Text(
                            'Stash Loom',
                            style: GoogleFonts.newsreader(fontSize: 32, fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                          key: const ValueKey('favorites_button'),
                          icon: const Icon(Icons.favorite_border),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesView()))
                                .then((_) => _loadData());
                          },
                        ),
                        IconButton(
                          key: const ValueKey('search_button'),
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchView()));
                          },
                        ),
                      ],
                    ),
                    Text(
                      'A calmer map of the yarn you already own.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip('Baskets', _stats?['totalContainers']?.toString() ?? '0', VisualTheme.primaryColor),
                        _chip('Skeins', _stats?['totalItems']?.toString() ?? '0', VisualTheme.secondaryColor),
                        _chip('Empty', _stats?['emptyContainers']?.toString() ?? '0', VisualTheme.accentColor),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: VisualTheme.primaryColor,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Text(
                        (_stats?['totalItems'] ?? 0) == 0
                            ? 'The baskets are still empty. Start with one drawer.'
                            : '${_stats!['totalItems']} skeins waiting across ${_stats!['totalContainers']} baskets.',
                        style: GoogleFonts.newsreader(color: Colors.white, fontSize: 24, height: 1.25),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _cta(
                            key: const ValueKey('add_box_button'),
                            label: 'New basket',
                            color: VisualTheme.secondaryColor,
                            onTap: () async {
                              final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ContainerFormView()));
                              if (r == true) _loadData();
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _cta(
                            key: const ValueKey('add_item_button'),
                            label: 'Log skein',
                            color: VisualTheme.accentColor,
                            onTap: () async {
                              final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemFormView()));
                              if (r == true) _loadData();
                            },
                          ),
                        ),
                      ],
                    ),
                    if (_recentContainers != null && _recentContainers!.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Text('Recently wound', style: GoogleFonts.newsreader(fontSize: 24, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      ..._recentContainers!.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: VisualTheme.blush,
                                  child: Text(c.code.substring(0, 1), style: const TextStyle(color: VisualTheme.secondaryColor, fontWeight: FontWeight.w800)),
                                ),
                                title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                                subtitle: Text('${c.room} · ${c.shelf}'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () async {
                                  await Navigator.push(context, MaterialPageRoute(builder: (_) => ContainerDetailView(containerId: c.id!)));
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

  Widget _chip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(24)),
      child: Text('$value  $label', style: TextStyle(color: color, fontWeight: FontWeight.w800)),
    );
  }

  Widget _cta({required Key key, required String label, required Color color, required VoidCallback onTap}) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}
