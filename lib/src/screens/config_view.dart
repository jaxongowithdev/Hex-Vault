import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../database/storage_manager.dart';
import '../models/user_preferences.dart';
import '../utils/visual_theme.dart';

class ConfigView extends StatefulWidget {
  final VoidCallback onSettingsChanged;

  const ConfigView({super.key, required this.onSettingsChanged});

  @override
  State<ConfigView> createState() => _ConfigViewState();
}

class _ConfigViewState extends State<ConfigView> {
  final _storage = StorageManager.instance;
  UserPreferences? _preferences;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await _storage.getPreferences();
      setState(() => _preferences = prefs);
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  Future<void> _updateTheme(String theme) async {
    if (_preferences == null) return;

    try {
      final updated = _preferences!.copyWith(theme: theme);
      await _storage.updatePreferences(updated);
      setState(() => _preferences = updated);
      widget.onSettingsChanged();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _exportData() async {
    try {
      final data = await _storage.exportData();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      await Share.shareXFiles(
        [
          XFile.fromData(
            Uint8List.fromList(jsonString.codeUnits),
            mimeType: 'application/json',
            name: 'larder_haven_${DateTime.now().millisecondsSinceEpoch}.json',
          )
        ],
        text: 'Larder Haven catalog',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catalog exported')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not export: $e')),
        );
      }
    }
  }

  Future<void> _importData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore a catalog?'),
        content: const Text(
          'The current larder list will be replaced by the file you pick.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.bytes == null) {
        throw Exception('Could not read file');
      }

      final jsonString = String.fromCharCodes(file.bytes!);
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      await _storage.importData(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catalog restored')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not restore: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Studio'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Card(
            color: VisualTheme.primaryColor,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Larder Haven',
                    style: GoogleFonts.fraunces(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'A private kitchen catalog. Nothing leaves this phone.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _section('Look'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('Theme'),
              subtitle: Text(_getThemeLabel(_preferences?.theme ?? 'system')),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showThemeDialog,
            ),
          ),
          const SizedBox(height: 16),
          _section('Catalog'),
          Card(
            child: Column(
              children: [
                ListTile(
                  key: const ValueKey('backup_button'),
                  leading: const Icon(Icons.ios_share),
                  title: const Text('Export catalog'),
                  subtitle: const Text('Share a JSON snapshot'),
                  onTap: _exportData,
                ),
                const Divider(height: 1),
                ListTile(
                  key: const ValueKey('import_button'),
                  leading: const Icon(Icons.file_open_outlined),
                  title: const Text('Restore catalog'),
                  subtitle: const Text('Replace from a JSON file'),
                  onTap: _importData,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section('About'),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Version 1.0.0'),
                  subtitle: Text('Offline kitchen inventory'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.lock_outline),
                  title: Text('Privacy'),
                  subtitle: Text('No account. No tracking. Local only.'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.nunito(
          fontWeight: FontWeight.w800,
          color: VisualTheme.primaryColor,
        ),
      ),
    );
  }

  String _getThemeLabel(String theme) {
    switch (theme) {
      case 'light':
        return 'Daylight';
      case 'dark':
        return 'Evening';
      case 'system':
      default:
        return 'Follow the phone';
    }
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kitchen light'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Daylight'),
              value: 'light',
              groupValue: _preferences?.theme ?? 'system',
              onChanged: (value) {
                if (value != null) {
                  _updateTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Evening'),
              value: 'dark',
              groupValue: _preferences?.theme ?? 'system',
              onChanged: (value) {
                if (value != null) {
                  _updateTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Follow the phone'),
              value: 'system',
              groupValue: _preferences?.theme ?? 'system',
              onChanged: (value) {
                if (value != null) {
                  _updateTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
