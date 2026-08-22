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
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _loadContainers();
  }

  Future<void> _loadContainers() async {
    setState(() => _isLoading = true);

    try {
      final containers = await _storage.getAllContainers(sortBy: _sortBy);

      Map<int, int> counts = {};
      for (var container in containers) {
        final count = await _storage.getItemCountInContainer(container.id!);
        counts[container.id!] = count;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Larders'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_agenda_outlined : Icons.grid_view),
            onPressed: () {
              setState(() => _isGridView = !_isGridView);
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() => _sortBy = value);
              _loadContainers();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name', child: Text('By name')),
              const PopupMenuItem(value: 'room', child: Text('By kitchen zone')),
              const PopupMenuItem(value: 'updated', child: Text('Recently tended')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _containers == null || _containers!.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadContainers,
                  child: _isGridView ? _buildGridView() : _buildListView(),
                ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('fab_add_container'),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ContainerFormView()),
          );
          if (result == true) _loadContainers();
        },
        icon: const Icon(Icons.add),
        label: const Text('New larder'),
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
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: VisualTheme.parchment,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.kitchen_outlined, size: 48),
            ),
            const SizedBox(height: 20),
            Text(
              'No larders yet',
              style: GoogleFonts.fraunces(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a shelf, bin, or cupboard so staples have a home.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _containers!.length,
      itemBuilder: (context, index) => _buildGridCard(_containers![index]),
    );
  }

  Widget _buildGridCard(ContainerModel container) {
    final itemCount = _itemCounts[container.id] ?? 0;
    final capacity = container.capacity;
    final percentage = capacity > 0 ? (itemCount / capacity * 100).round() : 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContainerDetailView(containerId: container.id!),
            ),
          );
          _loadContainers();
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 46,
                    height: 46,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: percentage / 100,
                          strokeWidth: 5,
                          backgroundColor: VisualTheme.parchment,
                          color: VisualTheme.secondaryColor,
                        ),
                        Text(
                          '$percentage',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    container.code,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                container.name,
                style: GoogleFonts.fraunces(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${container.room} · ${container.shelf}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text('$itemCount / $capacity staples'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: _containers!.length,
      itemBuilder: (context, index) => _buildListCard(_containers![index]),
    );
  }

  Widget _buildListCard(ContainerModel container) {
    final itemCount = _itemCounts[container.id] ?? 0;
    final capacity = container.capacity;
    final percentage = capacity > 0 ? (itemCount / capacity * 100).round() : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ContainerDetailView(containerId: container.id!),
              ),
            );
            _loadContainers();
          },
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 7, color: VisualTheme.secondaryColor),
                Expanded(
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                    title: Text(
                      container.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${container.room} · ${container.shelf}'),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 7,
                            backgroundColor: VisualTheme.parchment,
                            color: VisualTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('$itemCount / $capacity staples · $percentage%'),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
