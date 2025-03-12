import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'inventory_item.dart';
import 'add_item_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<InventoryItem> _inventoryItems = [];
  List<InventoryItem> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInventoryItems();
    _searchController.addListener(_filterItems);
  }

  // Fetch inventory items from the database
  Future<void> _loadInventoryItems() async {
    final dbHelper = DatabaseHelper.instance;
    final items = await dbHelper.getAllInventoryItems();
    setState(() {
      _inventoryItems = items;
      _filteredItems = items;
    });
  }

  // Filter items based on search input
  void _filterItems() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _inventoryItems.where((item) {
        return item.name.toLowerCase().contains(query) ||
            item.category.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Function to delete an inventory item
  void _deleteItem(int id) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.deleteInventoryItem(id);
    _loadInventoryItems();
  }

  // Show confirmation dialog before deleting an item
  void _confirmDeleteItem(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Item"),
        content: Text("Are you sure you want to delete this item?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _deleteItem(id); // Delete item
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inventory Management"),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: _filteredItems.isEmpty
                  ? Center(child: Text("No items found"))
                  : ListView.builder(
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text("Quantity: ${item.quantity} ${item.unit}"),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == "edit") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddItemScreen(itemToEdit: item),
                            ),
                          );
                        } else if (value == "delete") {
                          _confirmDeleteItem(item.id!);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(value: "edit", child: Text("Edit")),
                        PopupMenuItem(
                          value: "delete",
                          child: Text("Delete", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddItemScreen()),
          ).then((_) => _loadInventoryItems());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
