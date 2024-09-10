import 'package:flutter/material.dart';
import '../Models/Item.dart';
import '../Widgets/ItemCard.dart';

class CartPage extends StatefulWidget {
  final List<Item> cartItems;

  CartPage({required this.cartItems});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String errorMessage = '';

  double getTotalPrice() {
    return widget.cartItems.fold(
      0,
      (total, item) => total + (item.price * item.selectedQty),
    );
  }

  void updateItemSelectedQty(Item item, int newQty) {
    setState(() {
      if (newQty > item.quantity) {
        errorMessage = 'Selected quantity has exceeded available stock for ${item.name}!';
      } else if (newQty <= 0) {
        widget.cartItems.remove(item);
      } else {
        errorMessage = '';
        item.selectedQty = newQty;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    for (var item in widget.cartItems) {
      item.selectedQty = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, widget.cartItems);
            },
            child: Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: widget.cartItems.isEmpty
          ? Center(child: Text('Your cart is empty'))
          : Column(
        children: [
          if (errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                errorMessage,
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final item = widget.cartItems[index];

                final button = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        updateItemSelectedQty(item, item.selectedQty - 1);
                      },
                    ),
                    Text('${item.selectedQty}'),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        if (item.selectedQty < item.quantity) {
                          updateItemSelectedQty(item, item.selectedQty + 1);
                        } else {
                          setState(() {
                            errorMessage = 'Selected quantity has exceeded available stock for ${item.name}!';
                          });
                        }
                      },
                    ),
                  ],
                );

                return ItemCard(
                  item: item,
                  trailingButton: button,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Total: ₹${getTotalPrice().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Handle bill generation logic here
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Bill Generated'),
                        content: Text('Your bill total is ₹${getTotalPrice().toStringAsFixed(2)}'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text('Generate Bill'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
