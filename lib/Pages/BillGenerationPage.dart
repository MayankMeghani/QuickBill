import 'dart:convert';
import 'package:flutter/material.dart';
import '../Models/Item.dart';
import '../Widgets/ItemCard.dart';
import 'package:http/http.dart' as http;
import 'Cart.dart';

class BillGenerationPage extends StatefulWidget {
  @override
  _BillGenerationPageState createState() => _BillGenerationPageState();
}

class _BillGenerationPageState extends State<BillGenerationPage> {
  List<Item> items = [];
  List<Item> cartItems = [];
  List<Item> filteredItems = [];
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchItems() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;

        setState(() {
          items = data.map((user) =>
              Item(
                id: user['id'].toString(),
                name: user['name'].toString(),
                imageUrl: 'assets/images/bill.jpg',
                quantity: 10,
                price: (user['id'] as int).toDouble(),
              )).toList();
          filteredItems = items;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load items. Server responded with status code ${response.statusCode}.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching items: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchItems();
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

  void _navigateToCart() async {
     await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(cartItems: cartItems),
      ),
    );
    setState(() {
      cartItems = cartItems;
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
                : ListView.builder(
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
            onPressed: _navigateToCart,
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
