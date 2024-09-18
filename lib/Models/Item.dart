class Item {
  String id;
  String name;
  String imageUrl;
  int quantity; // available quantity
  double price;
  int purchaseQty; // the fluctuating quantity for user selection

  Item({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.price,
    this.purchaseQty = 1,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Item &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Item{id: $id, name: $name}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'price': price,
      'purchaseQty': purchaseQty,
    };
  }

  // Creates an Item object from a map (usually when retrieving from the database)
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: map['price'] ?? 0.0,
      purchaseQty: map['purchaseQty'] ?? 1, // fallback to 1 if not present
    );
  }
}
