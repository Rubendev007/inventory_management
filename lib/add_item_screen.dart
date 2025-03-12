import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'inventory_item.dart';

class AddItemScreen extends StatefulWidget {
  final InventoryItem? itemToEdit; // New parameter for editing

  // Constructor to handle item edit
  AddItemScreen({this.itemToEdit});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _lowStockThresholdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // If an item is passed to edit, fill the form fields with its data
    if (widget.itemToEdit != null) {
      _nameController.text = widget.itemToEdit!.name;
      _categoryController.text = widget.itemToEdit!.category;
      _quantityController.text = widget.itemToEdit!.quantity.toString();
      _unitController.text = widget.itemToEdit!.unit;
      _lowStockThresholdController.text = widget.itemToEdit!.lowStockThreshold.toString();
    }
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final category = _categoryController.text;
      final quantity = double.parse(_quantityController.text);
      final unit = _unitController.text;
      final lowStockThreshold = double.parse(_lowStockThresholdController.text);

      final newItem = InventoryItem(
        id: widget.itemToEdit?.id, // Use existing ID for editing
        name: name,
        category: category,
        quantity: quantity,
        unit: unit,
        lowStockThreshold: lowStockThreshold,
      );

      final dbHelper = DatabaseHelper.instance;
      if (newItem.id == null) {
        // If no ID exists, it’s a new item
        await dbHelper.insertInventoryItem(newItem);
      } else {
        // Otherwise, update the existing item
        await dbHelper.updateInventoryItem(newItem);
      }

      Navigator.pop(context); // Go back to the Home Screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemToEdit == null ? "Add Inventory Item" : "Edit Inventory Item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Item Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the item name";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: "Category"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the category";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: "Quantity"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the quantity";
                  }
                  if (double.tryParse(value) == null) {
                    return "Please enter a valid number for quantity";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _unitController,
                decoration: InputDecoration(labelText: "Unit"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the unit";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lowStockThresholdController,
                decoration: InputDecoration(labelText: "Low Stock Threshold"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the low stock threshold";
                  }
                  if (double.tryParse(value) == null) {
                    return "Please enter a valid number for low stock threshold";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveItem,
                child: Text(widget.itemToEdit == null ? "Save Item" : "Update Item"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
