import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/Item.dart';
import '../Providers/ShopProvider.dart';
import '../Widgets/ItemCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StockManagementPage extends StatefulWidget {
  @override
  _StockManagementPageState createState() => _StockManagementPageState();
}

class _StockManagementPageState extends State<StockManagementPage> {
  List<Item> items = [];
  List<Item> filteredItems = [];
  bool isLoading = false;
  String errorMessage = '';
  bool isQuantityAsc = true; // State variable to track sorting order for quantity
  String? shopId; // Property to store the shopId

  Future<void> fetchItems() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    if (shopId == null) {
      setState(() {
        errorMessage = 'Shop ID not found. Please try again later.';
        isLoading = false;
      });
      return;
    }

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('items')
          .where('shopId', isEqualTo: shopId)
          .get();

      setState(() {
        items = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Item(
            id: doc.id,
            name: data['name'] ?? '',
            imageUrl: data['imageUrl'] ?? 'assets/images/bill.jpg',
            quantity: data['quantity'] ?? 0,
            price: (data['price'] ?? 0).toDouble(),
          );
        }).toList();
        filteredItems = items;
        sortItemsByQuantity(); // Sort items by quantity when loaded
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

  void updateHandler(Item i) async {
    final result = await Navigator.pushNamed(
      context,
      '/modify',
      arguments: {
        'id': i.id,
        'name': i.name,
        'quantity': i.quantity,
        'price': i.price,
        'imageUrl': i.imageUrl
      },
    );
        await fetchItems(); // Refresh the list after updating
  }

  void addHandler() async{
    final result = await Navigator.pushNamed(context, '/modify');
      await fetchItems(); // Refresh the list after adding the item
  }

  void filterItems(String query) {
    setState(() {
      filteredItems = items
          .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Sorting function based on the current sorting order for quantity
  void sortItemsByQuantity() {
    setState(() {
      if (isQuantityAsc) {
        filteredItems.sort((a, b) => a.quantity.compareTo(b.quantity));
      } else {
        filteredItems.sort((a, b) => b.quantity.compareTo(a.quantity));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Management'),
        actions: [
          IconButton(
            icon: Icon(isQuantityAsc ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () {
              setState(() {
                isQuantityAsc = !isQuantityAsc; // Toggle sorting order
                sortItemsByQuantity(); // Sort items after toggling
              });
            },
            tooltip: 'Sort by Quantity',
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
              onRefresh: fetchItems,  // Trigger fetch when pulled down
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : errorMessage.isNotEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: fetchItems,
                      child: Text('Retry'),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  final button = ElevatedButton(
                    onPressed: () => updateHandler(item),
                    child: Text('Modify'),
                  );
                  return ItemCard(item: item, trailingButton: button);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:()=> addHandler(),
        child: Icon(Icons.add),
        tooltip: 'Add item',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
