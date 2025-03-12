import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'inventory_item.dart';
import 'add_item_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Fetch inventory items from the database
  Future<List<InventoryItem>> _fetchInventoryItems() async {
    final dbHelper = DatabaseHelper.instance;
    return await dbHelper.getAllInventoryItems();
  }

  // Function to delete an inventory item
  void _deleteItem(int id) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.deleteInventoryItem(id);

    // Refresh UI after deletion
    setState(() {});
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
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Search functionality will be implemented later
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // Filter functionality will be implemented later
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: FutureBuilder<List<InventoryItem>>(
          future: _fetchInventoryItems(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final inventoryItems = snapshot.data ?? [];

            if (inventoryItems.isEmpty) {
              return Center(child: Text("No inventory items available"));
            }

            return ListView.builder(
              itemCount: inventoryItems.length,
              itemBuilder: (context, index) {
                final item = inventoryItems[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text("Quantity: ${item.quantity} ${item.unit}"),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == "edit") {
                        // Navigate to edit item screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddItemScreen(itemToEdit: item),
                          ),
                        );
                      } else if (value == "delete") {
                        _confirmDeleteItem(item.id!);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: "edit",
                        child: Text("Edit"),
                      ),
                      PopupMenuItem(
                        value: "delete",
                        child: Text("Delete", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to edit item screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddItemScreen(itemToEdit: item),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add item screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddItemScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
