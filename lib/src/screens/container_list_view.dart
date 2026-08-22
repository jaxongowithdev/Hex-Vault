import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../utils/visual_theme.dart';
import 'container_detail_view.dart';
import 'container_form_view.dart';

class ContainerListView extends StatefulWidget {
  const ContainerListView({super.key});

  @override
  State<ContainerListView> createState() => _ContainerListViewState();
}

class _ContainerListViewState extends State<ContainerListView> {
  final _storage = StorageManager.instance;
  List<ContainerModel>? _containers;
  Map<int, int> _itemCounts = {};
  bool _isLoading = true;
  String _sortBy = 'updated';
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _loadContainers();
  }

  Future<void> _loadContainers() async {
    setState(() => _isLoading = true);
    try {
      final containers = await _storage.getAllContainers(sortBy: _sortBy);
      final counts = <int, int>{};
      for (final c in containers) {
        counts[c.id!] = await _storage.getItemCountInContainer(c.id!);
      }
      setState(() {
        _containers = containers;
        _itemCounts = counts;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading containers: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _open(ContainerModel c) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => ContainerDetailView(containerId: c.id!)));
    _loadContainers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baskets'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_agenda_outlined : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              setState(() => _sortBy = v);
              _loadContainers();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'name', child: Text('By name')),
              PopupMenuItem(value: 'room', child: Text('By studio')),
              PopupMenuItem(value: 'updated', child: Text('Recently wound')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _containers == null || _containers!.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_basket_outlined, size: 52),
                        const SizedBox(height: 12),
                        Text('No baskets yet', style: GoogleFonts.newsreader(fontSize: 26, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        const Text('Start a sock drawer, a leftover bin, or the project tote.', textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadContainers,
                  child: _isGridView ? _grid() : _list(),
                ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('fab_add_container'),
        onPressed: () async {
          final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ContainerFormView()));
          if (r == true) _loadContainers();
        },
        icon: const Icon(Icons.add),
        label: const Text('Basket'),
      ),
    );
  }

  Widget _grid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.86, crossAxisSpacing: 12, mainAxisSpacing: 12,
      ),
      itemCount: _containers!.length,
      itemBuilder: (_, i) {
        final c = _containers![i];
        final count = _itemCounts[c.id] ?? 0;
        final pct = c.capacity > 0 ? (count / c.capacity * 100).round() : 0;
        return Card(
          child: InkWell(
            onTap: () => _open(c),
            borderRadius: BorderRadius.circular(28),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: VisualTheme.blush,
                    child: Text(c.code.substring(0, 1), style: const TextStyle(color: VisualTheme.secondaryColor, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 12),
                  Text(c.name, style: GoogleFonts.newsreader(fontSize: 20, fontWeight: FontWeight.w600), maxLines: 2),
                  const Spacer(),
                  Text('${c.room} · ${c.shelf}', maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: pct / 100, minHeight: 6, backgroundColor: VisualTheme.blush, color: VisualTheme.primaryColor, borderRadius: BorderRadius.circular(8)),
                  const SizedBox(height: 6),
                  Text('$count / ${c.capacity} skeins'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _list() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: _containers!.length,
      itemBuilder: (_, i) {
        final c = _containers![i];
        final count = _itemCounts[c.id] ?? 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text('${c.room} · ${c.shelf}\n$count / ${c.capacity} skeins'),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _open(c),
            ),
          ),
        );
      },
    );
  }
}
