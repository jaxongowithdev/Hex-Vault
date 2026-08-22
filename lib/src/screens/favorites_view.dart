import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/inventory_item_model.dart';
import '../models/container_model.dart';
import '../utils/visual_theme.dart';
import 'item_detail_view.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  final _storage = StorageManager.instance;
  List<InventoryItemModel>? _favoriteItems;
  Map<int, ContainerModel> _containersCache = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final favorites = await _storage.getFavoriteItems();
      final containers = <int, ContainerModel>{};
      for (final item in favorites) {
        if (!containers.containsKey(item.containerId)) {
          final container = await _storage.getContainer(item.containerId);
          if (container != null) containers[item.containerId] = container;
        }
      }
      setState(() {
        _favoriteItems = favorites;
        _containersCache = containers;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('The rotation')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteItems == null || _favoriteItems!.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.favorite_border, size: 48),
                        const SizedBox(height: 14),
                        Text('No rotation yet', style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        const Text('Pin the pressings you reach for every week.', textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _favoriteItems!.length,
                    itemBuilder: (_, i) {
                      final item = _favoriteItems![i];
                      final crate = _containersCache[item.containerId];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          child: ListTile(
                            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                            subtitle: Text(
                              '${item.category} · ${item.quantity}'
                              '${crate != null ? '\n${crate.name} · ${crate.room}' : ''}',
                            ),
                            isThreeLine: crate != null,
                            trailing: IconButton(
                              key: ValueKey('favorite_toggle_${item.id}'),
                              icon: Icon(
                                item.isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: item.isFavorite ? VisualTheme.primaryColor : null,
                              ),
                              onPressed: () async {
                                await _storage.updateItem(item.copyWith(isFavorite: !item.isFavorite));
                                _loadFavorites();
                              },
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ItemDetailView(itemId: item.id!)),
                              );
                              _loadFavorites();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
