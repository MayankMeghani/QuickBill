import 'package:flutter/material.dart';
import '../Models/Item.dart';
import '../Widgets/ItemCard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
      final data = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          items = data.map((user) => Item(
            name: user['name'],
            imageUrl: 'assets/images/bill.jpg',
            quantity: 1,
            price: user['id'].toDouble(),
          )).toList();
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

  void addItem() async{
    final result = await Navigator.pushNamed(context, '/modify');
  }
  void updateHandler(Item i) async {
    final result = await Navigator.pushNamed(
      context,
      '/modify',
      arguments: {
        'name': i.name,
        'quantity': i.quantity,
        'price': i.price
      },
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        int index = items.indexWhere((item) => item.name == i.name);
        if (index != -1) {
          items[index] = Item(
            name: result['name'] as String,
            imageUrl: i.imageUrl,
            quantity: result['quantity'] as int,
            price: result['price'] as double,
          );
          filterItems('');
        }
      });
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