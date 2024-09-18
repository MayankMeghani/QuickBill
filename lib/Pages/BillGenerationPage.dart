import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/Item.dart';
import '../Providers/ShopProvider.dart';
import '../Widgets/ItemCard.dart';
import 'Cart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/Cart.dart'; // Import the CartModel

class BillGenerationPage extends StatefulWidget {
  @override
  _BillGenerationPageState createState() => _BillGenerationPageState();
}

class _BillGenerationPageState extends State<BillGenerationPage> {
  List<Item> items = [];
  List<Item> filteredItems = [];
  bool isLoading = false;
  String errorMessage = '';
  bool isNameAsc = true;
  String? shopId; // Property to store the shopId

  Future<void> fetchItems() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('items')
          .where('shopId', isEqualTo: shopId).get();
      setState(() {
        items = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Item(
            id: doc.id,
            name: data['name'],
            imageUrl: data['imageUrl'] ?? 'assets/images/bill.jpg',
            quantity: data['quantity'],
            price: (data['price']).toDouble(),
          );
        }).toList();
        filteredItems = items;
        sortItemsByName();
      });
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
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    shopId = shopProvider.shopData?['userId'];
    fetchItems();
  }

  void filterItems(String query) {
    setState(() {
      filteredItems = items
          .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Sorting function based on the current sorting order
  void sortItemsByName() {
    setState(() {
      if (isNameAsc) {
        filteredItems.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      } else {
        filteredItems.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      }
    });
  }

  // Navigate to Cart Page
  void _navigateToCart() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(),
      ),
    );
    fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bill Generation'),
        actions: [
          IconButton(
            icon: Icon(isNameAsc ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () {
              setState(() {
                isNameAsc = !isNameAsc; // Toggle sorting order
                sortItemsByName(); // Sort items after toggling
              });
            },
            tooltip: 'Sort by Name',
          ),
        ],
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
            child: RefreshIndicator(
              onRefresh: fetchItems,
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  final inCart = cartModel.isItemInCart(item);

                  final button = ElevatedButton(
                    onPressed: item.quantity > 0
                        ? (inCart
                        ? () => cartModel.removeItem(item)
                        : () => cartModel.addItem(item))
                        : null,  // Disable button if out of stock
                    child: Text(item.quantity > 0
                        ? (inCart ? 'Remove from Cart' : 'Add to Cart')
                        : 'Out of Stock'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: item.quantity > 0 ? null : Colors.grey, // Grey color if out of stock
                    ),
                  );

                  return ItemCard(item: item, trailingButton: button);
                },
              ),
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
          if (cartModel.cartItems.isNotEmpty)
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
                  '${cartModel.cartItems.length}',
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
