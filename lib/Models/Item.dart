class Item {
  String id;
  String name;
  String imageUrl;
  int quantity; // available quantity
  double price;
  int selectedQty; // the fluctuating quantity for user selection

  Item({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.price,
    this.selectedQty = 1, // initial selected quantity
  });
}
