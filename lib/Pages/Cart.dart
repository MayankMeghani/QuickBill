import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../Models/Cart.dart';
import '../Providers/ShopProvider.dart';
import '../Widgets/ItemCard.dart';
import '../api/billGenrerater.dart';


class CartPage extends StatelessWidget {
  Future<void> saveBillToDatabase(BuildContext context, String customerName, String mobileNumber) async {
    final cartModel = Provider.of<Cart>(context, listen: false);
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    final cartItems = cartModel.cartItems;
    final shopId = shopProvider.shopData?['userId'];

    try {
      final billData = {
        'customerName': customerName,
        'mobileNumber': mobileNumber,
        'items': cartItems.map((item) => {
          'itemId': item.id,
          'name': item.name,
          'price': item.price,
          'quantity': item.selectedQty,
        }).toList(),
        'totalPrice': cartModel.getTotalPrice(),
        'transactionDate': Timestamp.now(),
        'shopId': shopId,
      };

      await FirebaseFirestore.instance.collection('sales').add(billData);

      for (var item in cartItems) {
        final newQty = item.quantity - item.selectedQty;
        await FirebaseFirestore.instance.collection('items').doc(item.id).update({
          'quantity': newQty,
        });
      }

    } catch (e) {
      print('Error saving bill: $e');
    }
  }

  Future<void> generateAndPreviewPdf(BuildContext context, String customerName, String mobileNumber) async {
    // Generate the PDF document
    final pdf = await generatePdf(context, customerName, mobileNumber);

    // Navigate to a PDF preview screen
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('PDF Preview'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Center(

            child: PdfPreview(
              build: (format) => pdf.save(),
              canChangeOrientation: false,
          ),
          ),
        ),
      )
    );
  }

  void generateBill(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController mobileController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Customer Info'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Customer Name (Optional)'),
              ),
              TextField(
                controller: mobileController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'Mobile Number (Optional)'),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),

              Expanded( // Wrap with Expanded
                child: TextButton(
                  onPressed: () async {
                    String customerName = nameController.text.trim();
                    String mobileNumber = mobileController.text.trim();

                    if (customerName.isEmpty) {
                      customerName = 'unknown';
                    }

                    await saveBillToDatabase(context, customerName, mobileNumber);
                    final cartModel = Provider.of<Cart>(context, listen: false);
                    cartModel.clearCart();
                    Navigator.pop(context);

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Bill Saved'),
                        content: Text('Your bill has been saved to the database.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text('Save Bill'),
                ),
              ),
              Expanded( // Wrap with Expanded
                child: TextButton(
                  onPressed: () async {
                    String customerName = nameController.text.trim();
                    String mobileNumber = mobileController.text.trim();

                    if (customerName.isEmpty) {
                      customerName = 'unknown';
                    }


                    await saveBillToDatabase(context, customerName, mobileNumber);

                    await generateAndPreviewPdf(context, customerName, mobileNumber);

                    final cartModel = Provider.of<Cart>(context, listen: false);
                    cartModel.clearCart();

                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Bill Saved'),
                        content: Text('Your bill has been saved to the database.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );


                  },
                  child: Text('Generate pdf'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<Cart>(context);
    final cartItems = cartModel.cartItems;

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, cartItems);
            },
            child: Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: cartItems.isEmpty
          ? Center(child: Text('Your cart is empty'))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];

                final button = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        if (item.selectedQty > 0) {
                          cartModel.updateItemQty(item, item.selectedQty - 1);
                        }
                      },
                    ),
                    Text('${item.selectedQty}'),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        if (item.selectedQty < item.quantity) {
                          cartModel.updateItemQty(item, item.selectedQty + 1);
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
                  'Total: ₹${cartModel.getTotalPrice().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    generateBill(context);
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