import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'inventory_item.dart';
import 'add_item_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<InventoryItem> _inventoryItems = [];
  List<InventoryItem> _filteredItems = [];
  List<String> _categories = ["All"];
  String _selectedCategory = "All";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInventoryItems();
    _loadCategories();
    _searchController.addListener(_applyFilters);
  }

  // Fetch all inventory items
  Future<void> _loadInventoryItems() async {
    final dbHelper = DatabaseHelper.instance;
    final items = await dbHelper.getAllInventoryItems();
    setState(() {
      _inventoryItems = items;
      _applyFilters();
    });
  }

  // Fetch unique categories from the database
  Future<void> _loadCategories() async {
    final dbHelper = DatabaseHelper.instance;
    final items = await dbHelper.getAllInventoryItems();
    Set<String> uniqueCategories = {"All"};
    for (var item in items) {
      uniqueCategories.add(item.category);
    }
    setState(() {
      _categories = uniqueCategories.toList();
    });
  }

  // Apply search and category filters
  void _applyFilters() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _inventoryItems.where((item) {
        bool matchesSearch = item.name.toLowerCase().contains(query) ||
            item.category.toLowerCase().contains(query);
        bool matchesCategory =
            _selectedCategory == "All" || item.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  // Function to delete an inventory item
  void _deleteItem(int id) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.deleteInventoryItem(id);
    _loadInventoryItems();
    _loadCategories();
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
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteItem(id);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Function to check if an item is low in stock
  bool _isLowStock(InventoryItem item) {
    return item.quantity <= item.lowStockThreshold;
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

            // Category Filter Dropdown
            DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                  _applyFilters();
                });
              },
            ),
            SizedBox(height: 10),

            // Inventory List
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
                              builder: (context) =>
                                  AddItemScreen(itemToEdit: item),
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
                    // Low stock alert
                    leading: _isLowStock(item)
                        ? Icon(Icons.warning, color: Colors.red)
                        : null,
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
          ).then((_) {
            _loadInventoryItems();
            _loadCategories();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
