import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/inventory_item_model.dart';
import '../models/container_model.dart';
import '../utils/visual_theme.dart';
import 'item_detail_view.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _storage = StorageManager.instance;
  final _searchController = TextEditingController();
  List<InventoryItemModel>? _results;
  Map<int, ContainerModel> _containersCache = {};
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = null;
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await _storage.searchItems(query);

      Map<int, ContainerModel> containers = {};
      for (var item in results) {
        if (!containers.containsKey(item.containerId)) {
          final container = await _storage.getContainer(item.containerId);
          if (container != null) {
            containers[item.containerId] = container;
          }
        }
      }

      setState(() {
        _results = results;
        _containersCache = containers;
        _isSearching = false;
      });
    } catch (e) {
      debugPrint('Error searching: $e');
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          key: const ValueKey('search_field'),
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Paprika, oats, olive oil…',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
          ),
          onChanged: _performSearch,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchController.text.isEmpty) {
      return _emptyHint(
        Icons.travel_explore_outlined,
        'Search the pantry',
        'Try a staple name, aisle, or a note you left.',
      );
    }

    if (_results == null || _results!.isEmpty) {
      return _emptyHint(
        Icons.search_off,
        'Nothing matches',
        'Try a shorter word or a different aisle.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _results!.length,
      itemBuilder: (context, index) {
        final item = _results![index];
        final container = _containersCache[item.containerId];

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: VisualTheme.getCategoryColor(item.category)
                    .withValues(alpha: 0.18),
                child: Icon(
                  Icons.spa_outlined,
                  color: VisualTheme.getCategoryColor(item.category),
                ),
              ),
              title: Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${item.category} · Count ${item.quantity}'),
                  if (container != null)
                    Text(
                      '${container.name} · ${container.room}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemDetailView(itemId: item.id!),
                  ),
                ).then((_) {
                  _performSearch(_searchController.text);
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _emptyHint(IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: VisualTheme.primaryColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.fraunces(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
