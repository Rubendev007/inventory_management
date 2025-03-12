class InventoryItem {
  int? id;  // This will be the unique ID for each item
  String name;
  String category;
  double quantity;
  String unit;
  double lowStockThreshold;

  // Constructor
  InventoryItem({
    this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.lowStockThreshold,
  });

  // Convert an InventoryItem into a map (for storing in SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'lowStockThreshold': lowStockThreshold,
    };
  }

  // Convert a map into an InventoryItem
  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      quantity: map['quantity'],
      unit: map['unit'],
      lowStockThreshold: map['lowStockThreshold'],
    );
  }
}
