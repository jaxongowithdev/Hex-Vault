import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../models/inventory_item_model.dart';
import '../models/container_model.dart';
import '../utils/visual_theme.dart';

class MoveItemView extends StatefulWidget {
  final InventoryItemModel item;

  const MoveItemView({super.key, required this.item});

  @override
  State<MoveItemView> createState() => _MoveItemViewState();
}

class _MoveItemViewState extends State<MoveItemView> {
  final _storage = StorageManager.instance;
  final _notesController = TextEditingController();

  List<ContainerModel>? _containers;
  ContainerModel? _currentContainer;
  ContainerModel? _selectedContainer;
  Map<int, int> _itemCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final currentContainer = await _storage.getContainer(widget.item.containerId);
      final allContainers = await _storage.getAllContainers();
      final otherContainers =
          allContainers.where((c) => c.id != widget.item.containerId).toList();

      Map<int, int> counts = {};
      for (var container in otherContainers) {
        final count = await _storage.getItemCountInContainer(container.id!);
        counts[container.id!] = count;
      }

      setState(() {
        _currentContainer = currentContainer;
        _containers = otherContainers;
        _itemCounts = counts;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading containers: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _moveItem() async {
    if (_selectedContainer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a destination larder')),
      );
      return;
    }

    final destinationCount = _itemCounts[_selectedContainer!.id] ?? 0;
    if (destinationCount >= _selectedContainer!.capacity) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('That larder is full'),
          content: Text(
            '"${_selectedContainer!.name}" is already at capacity. File it there anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('File anyway'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    try {
      await _storage.moveItem(
        widget.item.id!,
        widget.item.containerId,
        _selectedContainer!.id!,
        _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Moved to ${_selectedContainer!.name}'),
            backgroundColor: VisualTheme.primaryColor,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not move staple: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reshelve'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MOVING',
                            style: GoogleFonts.nunito(
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              color: VisualTheme.secondaryColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.item.name,
                            style: GoogleFonts.fraunces(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${widget.item.category} · Count ${widget.item.quantity}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    color: VisualTheme.primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.place_outlined, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Currently in',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                                Text(
                                  _currentContainer?.name ?? 'Unknown',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                if (_currentContainer != null)
                                  Text(
                                    '${_currentContainer!.room} · ${_currentContainer!.shelf}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Move into',
                    style: GoogleFonts.fraunces(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_containers == null || _containers!.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: Text('No other larders yet')),
                      ),
                    )
                  else
                    ..._containers!.map((container) {
                      final itemCount = _itemCounts[container.id] ?? 0;
                      final percentage = container.capacity > 0
                          ? (itemCount / container.capacity * 100).round()
                          : 0;
                      final isFull = itemCount >= container.capacity;
                      final isSelected = _selectedContainer?.id == container.id;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          color: isSelected
                              ? VisualTheme.parchment
                              : null,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedContainer = container;
                              });
                            },
                            borderRadius: BorderRadius.circular(22),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Radio<int>(
                                    value: container.id!,
                                    groupValue: _selectedContainer?.id,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedContainer = container;
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          container.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Text(
                                          '${container.room} · ${container.shelf}',
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: LinearProgressIndicator(
                                                value: percentage / 100,
                                                backgroundColor: Colors.black12,
                                                color: isFull
                                                    ? Colors.red
                                                    : VisualTheme.primaryColor,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text('$itemCount/${container.capacity}'),
                                          ],
                                        ),
                                        if (isFull)
                                          const Padding(
                                            padding: EdgeInsets.only(top: 4),
                                            child: Text(
                                              'This larder is full',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 20),
                  TextField(
                    key: const ValueKey('move_notes_field'),
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Why the move?',
                      hintText: 'e.g., Closer to the stove',
                      prefixIcon: Icon(Icons.notes),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const ValueKey('confirm_move_button'),
                      onPressed: _selectedContainer == null ? null : _moveItem,
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('Reshelve staple'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
