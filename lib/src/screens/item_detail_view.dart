import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/inventory_item_model.dart';
import '../models/container_model.dart';
import '../utils/visual_theme.dart';
import 'item_form_view.dart';
import 'container_detail_view.dart';
import 'move_item_view.dart';

class ItemDetailView extends StatefulWidget {
  final int itemId;

  const ItemDetailView({super.key, required this.itemId});

  @override
  State<ItemDetailView> createState() => _ItemDetailViewState();
}

class _ItemDetailViewState extends State<ItemDetailView> {
  final _storage = StorageManager.instance;
  InventoryItemModel? _item;
  ContainerModel? _container;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final item = await _storage.getItem(widget.itemId);
      if (item != null) {
        final container = await _storage.getContainer(item.containerId);
        setState(() {
          _item = item;
          _container = container;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading item: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite() async {
    if (_item == null) return;

    try {
      final updated = _item!.copyWith(isFavorite: !_item!.isFavorite);
      await _storage.updateItem(updated);
      setState(() {
        _item = updated;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updated.isFavorite
                  ? 'Pinned to weekly staples'
                  : 'Removed from weekly staples',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove this staple?'),
        content: const Text('It will leave the larder catalog.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _storage.deleteItem(widget.itemId);
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Staple not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_item!.name),
        actions: [
          IconButton(
            key: const ValueKey('favorite_toggle'),
            icon: Icon(
              _item!.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _item!.isFavorite ? VisualTheme.secondaryColor : null,
            ),
            onPressed: _toggleFavorite,
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'move', child: Text('Move to another larder')),
              const PopupMenuItem(value: 'edit', child: Text('Edit staple')),
              const PopupMenuItem(value: 'delete', child: Text('Remove staple')),
            ],
            onSelected: (value) {
              if (value == 'move') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MoveItemView(item: _item!),
                  ),
                ).then((result) {
                  if (result == true) _loadData();
                });
              } else if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemFormView(item: _item),
                  ),
                ).then((result) {
                  if (result == true) _loadData();
                });
              } else if (value == 'delete') {
                _deleteItem();
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_item!.photoPath != null && _item!.photoPath!.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(_item!.photoPath!),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 160,
                            color: VisualTheme.parchment,
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 48),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: VisualTheme.getCategoryColor(_item!.category)
                          .withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _item!.category,
                      style: TextStyle(
                        color: VisualTheme.getCategoryColor(_item!.category),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _item!.name,
                    style: GoogleFonts.fraunces(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.numbers, 'Count', _item!.quantity.toString()),
                  _buildInfoRow(
                    Icons.eco_outlined,
                    'Stock',
                    _item!.condition,
                  ),
                  if (_item!.estimatedValue != null)
                    _buildInfoRow(
                      Icons.payments_outlined,
                      'Typical cost',
                      '\$${_item!.estimatedValue}',
                    ),
                  if (_item!.notes != null && _item!.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Kitchen note',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(_item!.notes!),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: const CircleAvatar(
                backgroundColor: VisualTheme.parchment,
                child: Icon(Icons.kitchen_outlined, color: VisualTheme.primaryColor),
              ),
              title: Text(_container?.name ?? 'Unknown larder'),
              subtitle: _container != null
                  ? Text(
                      '${_container!.room} · ${_container!.shelf}\nMark: ${_container!.code}',
                    )
                  : null,
              isThreeLine: _container != null,
              trailing: const Icon(Icons.chevron_right),
              onTap: _container != null
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContainerDetailView(
                            containerId: _container!.id!,
                          ),
                        ),
                      );
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: VisualTheme.primaryColor),
          const SizedBox(width: 8),
          Text('$label: '),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
