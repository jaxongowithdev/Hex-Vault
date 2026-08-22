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

      Map<int, ContainerModel> containers = {};
      for (var item in favorites) {
        if (!containers.containsKey(item.containerId)) {
          final container = await _storage.getContainer(item.containerId);
          if (container != null) {
            containers[item.containerId] = container;
          }
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

  Future<void> _toggleFavorite(InventoryItemModel item) async {
    try {
      final updated = item.copyWith(isFavorite: !item.isFavorite);
      await _storage.updateItem(updated);
      _loadFavorites();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly staples'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteItems == null || _favoriteItems!.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _favoriteItems!.length,
                    itemBuilder: (context, index) {
                      final item = _favoriteItems![index];
                      final container = _containersCache[item.containerId];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  VisualTheme.getCategoryColor(item.category)
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
                            trailing: IconButton(
                              key: ValueKey('favorite_toggle_${item.id}'),
                              icon: Icon(
                                item.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: item.isFavorite
                                    ? VisualTheme.secondaryColor
                                    : null,
                              ),
                              onPressed: () => _toggleFavorite(item),
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ItemDetailView(itemId: item.id!),
                                ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 56, color: VisualTheme.secondaryColor),
            const SizedBox(height: 16),
            Text(
              'No weekly staples yet',
              style: GoogleFonts.fraunces(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pin the jars you reach for every week so they sit at the top of your mind.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
