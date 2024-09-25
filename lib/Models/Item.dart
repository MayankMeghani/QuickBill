class Item {
  String id;
  String name;
  String imageUrl;
  int quantity; // available quantity
  double price;
  int purchaseQty;
  String shopId;

  Item({
    this.id = "",
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.price,
    this.purchaseQty = 1,
    required this.shopId ,
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
    return 'Item{id: $id, name: $name,shopId: $shopId}';
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'price': price,
      'purchaseQty': purchaseQty,
      'shopId': shopId
    };
  }


  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        imageUrl: map['imageUrl'] ?? '',
        quantity: map['quantity'] ?? 0,
        price: map['price'] ?? 0.0,
        purchaseQty: map['purchaseQty'] ?? 1,
        shopId: map['shopId']
    );
  }
}