import 'package:flutter/material.dart';
import '../Models/Item.dart';
import '../Widgets/ItemCard.dart';

class BillGenerationPage extends StatefulWidget {
  @override
  _BillGenerationPageState createState() => _BillGenerationPageState();
}

class _BillGenerationPageState extends State<BillGenerationPage> {
  List<Item> items = [
    Item(name: 'Item 1', imageUrl: 'assets/images/bill.jpg', quantity: 10, price: 15.0),
    Item(name: 'Item 2', imageUrl: 'assets/images/bill.jpg', quantity: 5, price: 20.0),
    Item(name: 'Item 3', imageUrl: 'assets/images/bill.jpg', quantity: 8, price: 10.0),
    Item(name: 'Item 1', imageUrl: 'assets/images/bill.jpg', quantity: 10, price: 15.0),
    Item(name: 'Item 2', imageUrl: 'assets/images/bill.jpg', quantity: 5, price: 20.0),
    Item(name: 'Item 3', imageUrl: 'assets/images/bill.jpg', quantity: 8, price: 10.0),
    Item(name: 'Item 1', imageUrl: 'assets/images/bill.jpg', quantity: 10, price: 15.0),
    Item(name: 'Item 2', imageUrl: 'assets/images/bill.jpg', quantity: 5, price: 20.0),
    Item(name: 'Item 3', imageUrl: 'assets/images/bill.jpg', quantity: 8, price: 10.0),

  ];

  List<Item> cartItems = [];
  List<Item> filteredItems = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    isLoading = true;
    filteredItems = items;

    isLoading = false;
  }

  void addToCart(Item item) {
    setState(() {
      cartItems.add(item);
    });
  }

  void removeFromCart(Item item) {
    setState(() {
      cartItems.remove(item);
    });
  }

  bool isItemInCart(Item item) {
    return cartItems.contains(item);
  }

  void filterItems(String query) {
    setState(() {
      filteredItems = items
          .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bill Generation'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Items',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: filterItems,
            ),
          ),
          Expanded(
          child: isLoading
          ? Center(child: CircularProgressIndicator())
              :ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                final inCart = isItemInCart(item);

                final button = ElevatedButton(
                  onPressed: inCart
                      ? () => removeFromCart(item)
                      : () => addToCart(item),
                  child: Text(inCart ? 'Remove from Cart' : 'Add to Cart'),
                );

                return ItemCard(item: item, trailingButton: button);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        clipBehavior: Clip.none,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Handle navigation to cart page or display cart items
            },
            child: Icon(Icons.shopping_cart),
            tooltip: 'Go to Cart',
          ),
          if (cartItems.isNotEmpty)
            Positioned(
              top: -10,
              right: -10,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                constraints: BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
                child: Text(
                  '${cartItems.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}