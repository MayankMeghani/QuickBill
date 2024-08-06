import 'package:flutter/material.dart';

class Item {
  final String name;
  final String imageUrl;
  final int quantity;
  final double price;

  Item({required this.name, required this.imageUrl, required this.quantity, required this.price});
}

class ItemsListPage extends StatelessWidget {
  final List<Item> items = [
    Item(name: 'Item 1', imageUrl: 'assets/images/bill.jpg', quantity: 10, price: 15.0),
    Item(name: 'Item 2', imageUrl: 'assets/images/bill.jpg', quantity: 5, price: 20.0),
    Item(name: 'Item 3', imageUrl: 'assets/images/bill.jpg', quantity: 8, price: 10.0),
    // Add more items as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bill Generation'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            child: ListTile(
              leading: Image.asset(item.imageUrl, width: 50, height: 50),
              title: Text(item.name),
              subtitle: Text('Qty: ${item.quantity} \n Price: ₹${item.price}'),
              trailing: ElevatedButton(
                onPressed: () {
                  // Handle add to cart action
                },
                child: Text('Add to Cart'),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle navigation to cart page
        },
        child: Icon(Icons.shopping_cart),
        tooltip: 'Go to Cart',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
