import 'package:flutter/material.dart';
import '../database/storage_manager.dart';
import '../models/container_model.dart';

class ContainerFormView extends StatefulWidget {
  final ContainerModel? container;

  const ContainerFormView({super.key, this.container});

  @override
  State<ContainerFormView> createState() => _ContainerFormViewState();
}

class _ContainerFormViewState extends State<ContainerFormView> {
  final _formKey = GlobalKey<FormState>();
  final _storage = StorageManager.instance;

  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _roomController;
  late TextEditingController _shelfController;
  late TextEditingController _capacityController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.container?.name);
    _codeController = TextEditingController(text: widget.container?.code);
    _roomController = TextEditingController(text: widget.container?.room);
    _shelfController = TextEditingController(text: widget.container?.shelf);
    _capacityController = TextEditingController(
      text: widget.container?.capacity.toString() ?? '24',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _roomController.dispose();
    _shelfController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _saveContainer() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final container = ContainerModel(
        id: widget.container?.id,
        name: _nameController.text.trim(),
        code: _codeController.text.trim().toUpperCase(),
        room: _roomController.text.trim(),
        shelf: _shelfController.text.trim(),
        capacity: int.parse(_capacityController.text.trim()),
      );

      if (widget.container == null) {
        await _storage.createContainer(container);
      } else {
        await _storage.updateContainer(container);
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
    final isEditing = widget.container != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit larder' : 'New larder'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              key: const ValueKey('name_field'),
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Larder name',
                hintText: 'e.g., Spice drawer',
                prefixIcon: Icon(Icons.local_dining_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Give this larder a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('code_field'),
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Shelf mark',
                hintText: 'e.g., LAR-01, SPICE',
                prefixIcon: Icon(Icons.tag),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Add a short mark for the shelf';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('room_field'),
              controller: _roomController,
              decoration: const InputDecoration(
                labelText: 'Kitchen zone',
                hintText: 'e.g., Pantry, Island, Fridge',
                prefixIcon: Icon(Icons.cottage_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Where does this larder live?';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('shelf_field'),
              controller: _shelfController,
              decoration: const InputDecoration(
                labelText: 'Bay / row',
                hintText: 'e.g., Top bay, Left row',
                prefixIcon: Icon(Icons.view_week_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Add a bay or row';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('capacity_field'),
              controller: _capacityController,
              decoration: const InputDecoration(
                labelText: 'How many staples fit',
                prefixIcon: Icon(Icons.stacked_bar_chart),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a capacity';
                }
                final capacity = int.tryParse(value.trim());
                if (capacity == null || capacity <= 0) {
                  return 'Use a positive number';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),
            FilledButton(
              key: const ValueKey('save_button'),
              onPressed: _saveContainer,
              child: Text(isEditing ? 'Save larder' : 'Create larder'),
            ),
          ],
        ),
      ),
    );
  }
}
