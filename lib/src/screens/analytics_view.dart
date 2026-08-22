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
      appBar: AppBar(title: const Text('Gauge')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  _overview(),
                  if (_categoryStats != null && _categoryStats!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('By fiber', style: GoogleFonts.newsreader(fontSize: 22, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    _chart(_categoryStats!, true),
                  ],
                  if (_roomStats != null && _roomStats!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('By studio corner', style: GoogleFonts.newsreader(fontSize: 22, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    _chart(_roomStats!, false),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _overview() {
    if (_stats == null) return const SizedBox.shrink();
    final baskets = _stats!['totalContainers'] ?? 0;
    final items = _stats!['totalItems'] ?? 0;
    final empty = _stats!['emptyContainers'] ?? 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: VisualTheme.blush, borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Stash snapshot', style: GoogleFonts.newsreader(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            children: [
              _cell('Baskets', baskets.toString()),
              _cell('Skeins', items.toString()),
              _cell('In use', (baskets - empty).toString()),
              _cell('Empty', empty.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cell(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: GoogleFonts.newsreader(fontSize: 22, fontWeight: FontWeight.w600)),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _chart(Map<String, int> data, bool fiber) {
    final sorted = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final total = _stats?['totalItems'] ?? 1;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: sorted.map((e) {
            final pct = (e.value / total * 100).round();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text('${e.value} · $pct%'),
                    ],
                  ),
                  const SizedBox(height: 5),
                  LinearProgressIndicator(
                    value: e.value / total,
                    minHeight: 7,
                    backgroundColor: VisualTheme.blush,
                    color: fiber ? VisualTheme.getCategoryColor(e.key) : VisualTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
