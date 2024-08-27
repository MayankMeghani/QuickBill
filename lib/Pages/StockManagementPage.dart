import 'package:flutter/material.dart';
import '../Models/Item.dart';
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

  Future<void> fetchItems() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('items').get();
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
    fetchItems();
  }

  void addItem() async {
    final result = await Navigator.pushNamed(context, '/modify');

    if (result != null && result is Map<String, dynamic>) {
      try {
        await FirebaseFirestore.instance.collection('items').add({
          'name': result['name'],
          'quantity': result['quantity'],
          'price': result['price'],
          'imageUrl': 'assets/images/bill.jpg', // You might want to allow image upload in your app
        });

        // Refresh the list after adding
        await fetchItems();
      } catch (e) {
        print('Error adding item: $e');
        // You might want to show an error message to the user here
      }
    }
  }

  void updateHandler(Item i) async {
    final result = await Navigator.pushNamed(
      context,
      '/modify',
      arguments: {
        'id':i.id,
        'name': i.name,
        'quantity': i.quantity,
        'price': i.price
      },
    );

    if (result != null && result is Map<String, dynamic>) {
      try {
        await FirebaseFirestore.instance.collection('items').doc(i.id).update({
          'name': result['name'],
          'quantity': result['quantity'],
          'price': result['price'],
        });

        await fetchItems();
      } catch (e) {
        print('Error updating item: $e');
        // You might want to show an error message to the user here
      }
    }
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
        title: Text('Stock Management'),
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
        ],
      ),
      floatingActionButton: Stack(
        clipBehavior: Clip.none,
        children: [
          FloatingActionButton(
            onPressed: () => addItem(),
            child: Icon(Icons.add),
            tooltip: 'Add item',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}