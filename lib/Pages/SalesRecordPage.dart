import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../Models/Item.dart';
import '../Providers/ShopProvider.dart';
import '../api/billGenrerater.dart';

enum SortOption {
  dateAsc,
  dateDesc,
}

class SalesRecordPage extends StatefulWidget {
  @override
  _SalesRecordPageState createState() => _SalesRecordPageState();
}

class _SalesRecordPageState extends State<SalesRecordPage> {
  List<Map<String, dynamic>> salesRecords = [];
  bool isLoading = true;
  SortOption selectedSortOption = SortOption.dateDesc; // Default sorting by date descending
  String? shopId;


  Future<void> fetchSalesRecords() async {
    setState(() {
      isLoading = true; // Show loader while fetching
    });

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('sales')
          .where('shopId', isEqualTo: shopId)
          .get();

      setState(() {
        salesRecords = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final documentId = doc.id;
          return {
            'documentId': documentId,
            ...data,
          };
        }).toList();
        sortSalesRecords(); // Sort after fetching
        isLoading = false; // Stop loader after fetching
      });
    } catch (e) {
      print('Error fetching sales records: $e');
      setState(() {
        isLoading = false; // Stop loader in case of error
      });
    }
  }

  // Function to sort records based on selected date option
  void sortSalesRecords() {
    if (selectedSortOption == SortOption.dateAsc) {
      salesRecords.sort((a, b) => (a['transactionDate'] as Timestamp).compareTo(b['transactionDate'] as Timestamp));
    } else {
      salesRecords.sort((a, b) => (b['transactionDate'] as Timestamp).compareTo(a['transactionDate'] as Timestamp));
    }
  }

  // Format Timestamp to readable date string (for time comparison)
  String formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('dd MMM yyyy').format(date); // Format: 12 Sept 2024
  }

  // Format Timestamp for showing the full date and time
  String formatDateTime(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(date); // Format: 12 Sept 2024, 08:30 PM
  }

  Future<void> deleteSalesRecord(String documentId) async {
    try {
      await FirebaseFirestore.instance.collection('sales').doc(documentId).delete();
      fetchSalesRecords();
    } catch (e) {
      print('Error deleting record: $e');
    }
  }

  // Function to show confirmation dialog before deleting
  Future<bool?> showDeleteConfirmation(BuildContext context, String documentId) async {
    return showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this sales record?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false on cancel
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true on delete
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
  Future<void> _generateAndPreviewPdf(BuildContext context,  record) async {
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    final shopData = shopProvider.shopData;
    List<Item> items = List<Item>.from(
      (record['items'] as List<dynamic>).map(
            (item) => Item(
            id: item['itemId'] ?? '',
            name: item['name'] ?? 'Unknown',
            purchaseQty: int.parse(item['quantity']?.toString() ?? '1'),
            price: (item['price'] ?? 0).toDouble(),
            imageUrl: item['imageUrl'] ?? 'assets/images/default.jpg',
            quantity: 0,
            shopId: item['shopId']
        ),
      ),
    );
    final pdf = await generatePdf(
      context,
      record['customerName'],
      record['mobileNumber'],
      record['gstNumber'],
      shopData,
      items,
    );

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
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    shopId = shopProvider.shopData?['userId'];
    fetchSalesRecords(); // Fetch sales on page load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Records'),
        actions: [
          IconButton(
            icon: Icon(
              selectedSortOption == SortOption.dateDesc
                  ? Icons.arrow_downward // Down arrow for descending
                  : Icons.arrow_upward,   // Up arrow for ascending
            ),
            onPressed: () {
              setState(() {
                selectedSortOption = selectedSortOption == SortOption.dateDesc
                    ? SortOption.dateAsc
                    : SortOption.dateDesc;
                sortSalesRecords(); // Re-sort based on the new option
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loader if still loading
          : RefreshIndicator(
        onRefresh: fetchSalesRecords, // Pull to refresh
        child: salesRecords.isEmpty
            ? Center(child: Text('No sales records found.'))
            : ListView.builder(
          itemCount: salesRecords.length,
          itemBuilder: (context, index) {
            final record = salesRecords[index];
            final documentId = record['documentId'] ;
            final currentDate = formatDate(record['transactionDate'] as Timestamp);
            final previousDate = index > 0 ? formatDate(salesRecords[index - 1]['transactionDate'] as Timestamp) : '';

            // Add a date header if it's a new day
            bool isNewDate = index == 0 || currentDate != previousDate;

            return Dismissible(
              key: Key(documentId),
              background: Container(color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) async {
                bool? confirmDelete = await showDeleteConfirmation(context, documentId);
                if (confirmDelete == true) {
                  deleteSalesRecord(documentId);
                } else {
                  // Optionally: Add code to handle the case where deletion was canceled
                  fetchSalesRecords(); // Refresh the list if needed
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isNewDate) // Display date header only if it's a new day
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        currentDate, // Display the formatted date
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ExpansionTile(
                    key: Key(documentId),
                    title: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Customer: ',
                            style: DefaultTextStyle.of(context).style, // Ensures it uses the default ListTile text style
                          ),
                          TextSpan(
                            text: record['customerName'] ?? 'Anonymous',
                            style: DefaultTextStyle.of(context).style.copyWith(fontWeight: FontWeight.bold), // Bold for customer name
                          ),
                        ],
                      ),
                    ),
                    subtitle: Text(
                      'Total: ₹${record['totalPrice']?.toStringAsFixed(2) ?? '0.00'}\nDate: ${formatDateTime(record['transactionDate'] as Timestamp)}',
                      style: TextStyle(color: Colors.black87),
                    ),
                    children: [
                      ListTile(
                        leading: Icon(Icons.receipt_long),
                        title: Text(record['mobileNumber'] != null && record['mobileNumber'].isNotEmpty ? 'Mobile: ${record['mobileNumber']}' : 'Mobile: N/A'),
                        subtitle: Text('Gst No: ${record['gstNo'] ?? 'N/A'}'),
                      ),
                      if (record['items'] != null)
                        ...ListTile.divideTiles(
                          context: context,
                          tiles: (record['items'] as List).map((item) {
                            return ListTile(
                              title: Text(item['name']),
                              subtitle: Text('Price: ₹${item['price']} x ${item['quantity']}'),
                            );
                          }),
                        ).toList(),
                      // Delete option displayed after expansion
                      ListTile(
                        title: Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () {
                                  _generateAndPreviewPdf(context, record);
                                },
                                child: Text('View Bill', style: TextStyle(color: Colors.blue)),
                              ),
                              SizedBox(width: 8), // Space between buttons
                              TextButton(
                                onPressed: () async {
                                  bool? confirmDelete =  await showDeleteConfirmation(context, documentId);
                                  if (confirmDelete == true) {
                                    deleteSalesRecord(documentId);
                                  } else {
                                    // Optionally: Add code to handle the case where deletion was canceled
                                    fetchSalesRecords(); // Refresh the list if needed
                                  }
                                },
                                child: Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}