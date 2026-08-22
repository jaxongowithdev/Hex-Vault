import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/storage_manager.dart';
import '../utils/visual_theme.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  final _storage = StorageManager.instance;
  Map<String, int>? _stats;
  Map<String, int>? _categoryStats;
  Map<String, int>? _roomStats;
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
      final categories = await _storage.getItemsByCategory();
      final rooms = await _storage.getItemsByRoom();

      setState(() {
        _stats = stats;
        _categoryStats = categories;
        _roomStats = rooms;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading statistics: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  _buildOverviewCard(),
                  if (_categoryStats != null && _categoryStats!.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Text(
                      'By aisle',
                      style: GoogleFonts.fraunces(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryChart(),
                  ],
                  if (_roomStats != null && _roomStats!.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Text(
                      'By kitchen zone',
                      style: GoogleFonts.fraunces(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRoomChart(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewCard() {
    if (_stats == null) return const SizedBox.shrink();

    final totalContainers = _stats!['totalContainers'] ?? 0;
    final totalItems = _stats!['totalItems'] ?? 0;
    final emptyContainers = _stats!['emptyContainers'] ?? 0;
    final occupiedContainers = totalContainers - emptyContainers;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kitchen snapshot',
              style: GoogleFonts.fraunces(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Larders',
                    totalContainers.toString(),
                    Icons.kitchen_outlined,
                    VisualTheme.primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Staples',
                    totalItems.toString(),
                    Icons.spa_outlined,
                    VisualTheme.secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'In use',
                    occupiedContainers.toString(),
                    Icons.check_circle_outline,
                    VisualTheme.accentColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Bare',
                    emptyContainers.toString(),
                    Icons.inbox_outlined,
                    const Color(0xFF7A8478),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 28, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.fraunces(fontSize: 26, fontWeight: FontWeight.w600),
        ),
        Text(label, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildCategoryChart() {
    final sortedCategories = _categoryStats!.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: sortedCategories.map((entry) {
            return _buildBarItem(
              entry.key,
              entry.value,
              VisualTheme.getCategoryColor(entry.key),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRoomChart() {
    final sortedRooms = _roomStats!.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: sortedRooms.map((entry) {
            return _buildBarItem(entry.key, entry.value, VisualTheme.primaryColor);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBarItem(String label, int value, Color color) {
    final total = _stats?['totalItems'] ?? 1;
    final percentage = (value / total * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text('$value · $percentage%'),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value / total,
              minHeight: 9,
              backgroundColor: VisualTheme.parchment,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
