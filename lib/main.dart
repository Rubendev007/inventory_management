import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'inventory_item.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Add sample data to the database
  final dbHelper = DatabaseHelper.instance;
  await dbHelper.insertInventoryItem(InventoryItem(
    name: "Shoes",
    category: "Footwear",
    quantity: 10,
    unit: "pcs",
    lowStockThreshold: 2,
  ));
  await dbHelper.insertInventoryItem(InventoryItem(
    name: "Sugar",
    category: "Groceries",
    quantity: 5,
    unit: "kg",
    lowStockThreshold: 1,
  ));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}
