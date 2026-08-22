import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path_pkg;
import '../database/storage_manager.dart';
import '../models/container_model.dart';
import '../models/inventory_item_model.dart';

class ItemFormView extends StatefulWidget {
  final InventoryItemModel? item;
  final int? preselectedContainerId;

  const ItemFormView({super.key, this.item, this.preselectedContainerId});

  @override
  State<ItemFormView> createState() => _ItemFormViewState();
}

class _ItemFormViewState extends State<ItemFormView> {
  final _formKey = GlobalKey<FormState>();
  final _storage = StorageManager.instance;

  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _quantityController;
  late TextEditingController _notesController;
  late TextEditingController _valueController;

  List<ContainerModel>? _containers;
  int? _selectedContainerId;
  String _selectedCondition = 'Fresh';
  String? _photoPath;
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _conditions = ['Fresh', 'Opened', 'Low', 'Expired'];
  final List<String> _categories = [
    'Grains',
    'Spices',
    'Oils',
    'Canned',
    'Baking',
    'Snacks',
    'Tea & Coffee',
    'Dairy',
    'Produce',
    'Frozen',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name);
    _categoryController = TextEditingController(text: widget.item?.category);
    _quantityController = TextEditingController(
      text: widget.item?.quantity.toString() ?? '1',
    );
    _notesController = TextEditingController(text: widget.item?.notes);
    _valueController = TextEditingController(
      text: widget.item?.estimatedValue?.toString(),
    );
    _selectedCondition = widget.item?.condition ?? 'Fresh';
    _selectedContainerId =
        widget.item?.containerId ?? widget.preselectedContainerId;
    _photoPath = widget.item?.photoPath;

    _loadContainers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _loadContainers() async {
    try {
      final containers = await _storage.getAllContainers();
      setState(() => _containers = containers);
    } catch (e) {
      debugPrint('Error loading containers: $e');
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo == null) return;

      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          'staple_${DateTime.now().millisecondsSinceEpoch}${path_pkg.extension(photo.path)}';
      final savedPath = path_pkg.join(appDir.path, 'photos', fileName);

      final photosDir = Directory(path_pkg.join(appDir.path, 'photos'));
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      await File(photo.path).copy(savedPath);

      setState(() {
        _photoPath = savedPath;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not add photo: $e')),
        );
      }
    }
  }

  Future<void> _removePhoto() async {
    if (_photoPath != null) {
      try {
        final file = File(_photoPath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Error deleting photo: $e');
      }
    }

    setState(() {
      _photoPath = null;
    });
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedContainerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a larder first')),
      );
      return;
    }

    try {
      final item = InventoryItemModel(
        id: widget.item?.id,
        containerId: _selectedContainerId!,
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        quantity: int.parse(_quantityController.text.trim()),
        condition: _selectedCondition,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        estimatedValue: _valueController.text.trim().isEmpty
            ? null
            : double.tryParse(_valueController.text.trim()),
        photoPath: _photoPath,
      );

      if (widget.item == null) {
        await _storage.createItem(item);
      } else {
        await _storage.updateItem(item);
      }

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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit staple' : 'New staple'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Label photo',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (_photoPath != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(_photoPath!),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.white,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: _removePhoto,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              key: const ValueKey('camera_button'),
                              onPressed: () => _pickPhoto(ImageSource.camera),
                              icon: const Icon(Icons.photo_camera_outlined),
                              label: const Text('Snap'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              key: const ValueKey('gallery_button'),
                              onPressed: () => _pickPhoto(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library_outlined),
                              label: const Text('Album'),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('item_name_field'),
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Staple name',
                hintText: 'e.g., Smoked paprika',
                prefixIcon: Icon(Icons.spa_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name this staple';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: const ValueKey('category_dropdown'),
              value: _categories.contains(_categoryController.text)
                  ? _categoryController.text
                  : null,
              decoration: const InputDecoration(
                labelText: 'Aisle',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _categoryController.text = value;
                }
              },
              validator: (value) {
                if (_categoryController.text.isEmpty) {
                  return 'Pick an aisle';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              key: const ValueKey('container_dropdown'),
              value: _selectedContainerId,
              decoration: const InputDecoration(
                labelText: 'Larder',
                prefixIcon: Icon(Icons.kitchen_outlined),
              ),
              items: _containers?.map((container) {
                return DropdownMenuItem(
                  value: container.id,
                  child: Text('${container.name} (${container.code})'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedContainerId = value);
              },
              validator: (value) {
                if (value == null) {
                  return 'Choose a larder';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: const ValueKey('quantity_field'),
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Count',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value.trim()) == null) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: const ValueKey('condition_dropdown'),
                    value: _selectedCondition,
                    decoration: const InputDecoration(
                      labelText: 'Stock',
                      prefixIcon: Icon(Icons.eco_outlined),
                    ),
                    items: _conditions.map((condition) {
                      return DropdownMenuItem(
                        value: condition,
                        child: Text(condition),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCondition = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('value_field'),
              controller: _valueController,
              decoration: const InputDecoration(
                labelText: 'Typical cost (optional)',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('notes_field'),
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Kitchen note',
                hintText: 'Brand, grind, or recipe it belongs to',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 28),
            FilledButton(
              key: const ValueKey('save_item_button'),
              onPressed: _saveItem,
              child: Text(isEditing ? 'Save staple' : 'File staple'),
            ),
          ],
        ),
      ),
    );
  }
}
