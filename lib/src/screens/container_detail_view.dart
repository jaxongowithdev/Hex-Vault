import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/visual_theme.dart';
import 'container_form_view.dart';
import 'item_form_view.dart';
import 'item_detail_view.dart';

class ContainerDetailView extends StatefulWidget {
  final int containerId;
  const ContainerDetailView({super.key, required this.containerId});

  @override
  State<ContainerDetailView> createState() => _ContainerDetailViewState();
}

class _ContainerDetailViewState extends State<ContainerDetailView> {
  final _storage = StorageManager.instance;
  ContainerModel? _container;
  List<InventoryItemModel>? _items;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final container = await _storage.getContainer(widget.containerId);
      final items = await _storage.getItemsByContainer(widget.containerId);
      setState(() {
        _container = container;
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading container: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteContainer() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear this crate?'),
        content: const Text('Every pressing filed here will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _storage.deleteContainer(widget.containerId);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    }
    if (_container == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Crate not found')));
    }

    final count = _items?.length ?? 0;
    final pct = _container!.capacity > 0 ? (count / _container!.capacity * 100).round() : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_container!.name),
        actions: [
          PopupMenuButton(
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit crate')),
              PopupMenuItem(value: 'delete', child: Text('Clear crate')),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ContainerFormView(container: _container)),
                ).then((r) { if (r == true) _loadData(); });
              } else if (value == 'delete') {
                _deleteContainer();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_container!.code, style: const TextStyle(color: VisualTheme.secondaryColor, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(_container!.name, style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Text('${_container!.room} · ${_container!.shelf}'),
                    const SizedBox(height: 14),
                    LinearProgressIndicator(
                      value: pct / 100,
                      minHeight: 8,
                      backgroundColor: VisualTheme.linen,
                      color: VisualTheme.primaryColor,
                    ),
                    const SizedBox(height: 8),
                    Text('$count / ${_container!.capacity} pressings · $pct% full'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: Text('Pressings ($count)', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w600)),
                ),
                FilledButton.icon(
                  key: const ValueKey('add_item_button'),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemFormView(preselectedContainerId: widget.containerId),
                      ),
                    );
                    if (result == true) _loadData();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Pressing'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_items == null || _items!.isEmpty)
              const Card(child: Padding(padding: EdgeInsets.all(28), child: Center(child: Text('Nothing filed here yet'))))
            else
              ..._items!.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: VisualTheme.getCategoryColor(item.category).withValues(alpha: 0.16),
                          child: Icon(Icons.album, color: VisualTheme.getCategoryColor(item.category)),
                        ),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Text('${item.category} · ${item.quantity} · ${item.condition}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ItemDetailView(itemId: item.id!)),
                          );
                          _loadData();
                        },
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
