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
      appBar: AppBar(
        title: Text('REEL BAY', style: GoogleFonts.spaceGrotesk(letterSpacing: 2, fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        actions: [
          IconButton(
            key: const ValueKey('favorites_button'),
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesView())).then((_) => _loadData());
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    color: VisualTheme.primaryColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DOCK CHECK', style: GoogleFonts.spaceGrotesk(color: VisualTheme.accentColor, letterSpacing: 1.6, fontSize: 11, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(
                          (_stats?['totalItems'] ?? 0) == 0
                              ? 'No trays staged yet.'
                              : '${_stats!['totalItems']} lures across ${_stats!['totalContainers']} bays.',
                          style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _cell('BAYS', _stats?['totalContainers']?.toString() ?? '0'),
                      const SizedBox(width: 8),
                      _cell('LURES', _stats?['totalItems']?.toString() ?? '0'),
                      const SizedBox(width: 8),
                      _cell('EMPTY', _stats?['emptyContainers']?.toString() ?? '0'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _cta(key: const ValueKey('add_box_button'), label: 'NEW BAY', onTap: () async {
                          final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ContainerFormView()));
                          if (r == true) _loadData();
                        }),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _cta(key: const ValueKey('add_item_button'), label: 'LOG LURE', onTap: () async {
                          final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemFormView()));
                          if (r == true) _loadData();
                        }),
                      ),
                    ],
                  ),
                  if (_recentContainers != null && _recentContainers!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Last rigged', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    ..._recentContainers!.map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                color: VisualTheme.mist,
                                child: Text(c.code.substring(0, 1), style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
                              ),
                              title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Text('${c.room} / ${c.shelf}'),
                              trailing: const Icon(Icons.arrow_forward, size: 18),
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
    );
  }

  Widget _cell(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0x330E4D5A))),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700)),
            Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 10, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _cta({required Key key, required String label, required VoidCallback onTap}) {
    return Material(
      color: VisualTheme.secondaryColor,
      child: InkWell(
        key: key,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(label, textAlign: TextAlign.center, style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}
