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

  Future<void> _loadInventoryItems() async {
    final dbHelper = DatabaseHelper.instance;
    final items = await dbHelper.getAllInventoryItems();
    setState(() {
      _inventoryItems = items;
      _applyFilters();
    });
  }

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

  void _deleteItem(int id) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.deleteInventoryItem(id);
    _loadInventoryItems();
    _loadCategories();
  }

  void _confirmDeleteItem(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text("Delete Item", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete this item?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteItem(id);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inventory Management", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search Items",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 10),

            // Category Dropdown
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
                  ? Center(
                child: Text(
                  "No items found",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  bool isLowStock = item.quantity <= item.lowStockThreshold;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10),
                      leading: Icon(
                        isLowStock ? Icons.warning_amber_rounded : Icons.inventory,
                        color: isLowStock ? Colors.redAccent : Colors.blue,
                        size: 30,
                      ),
                      title: Text(
                        item.name,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Qty: ${item.quantity} ${item.unit}  |  Category: ${item.category}",
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
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
          ).then((_) {
            _loadInventoryItems();
            _loadCategories();
          });
        },
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add, size: 30),
      ),
    );
  }
}
