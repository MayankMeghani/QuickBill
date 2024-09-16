import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Providers/ShopProvider.dart'; // For formatting date

enum SortOption {
  dateAsc,
  dateDesc, // Default sorting by date descending
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
  // Function to fetch sales records from Firestore
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
          final documentId = doc.id; // Access auto-generated document ID
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

  // Function to delete a record from Firestore
  Future<void> deleteSalesRecord(String documentId) async {
    try {
      await FirebaseFirestore.instance.collection('sales').doc(documentId).delete();
      fetchSalesRecords(); // Refresh the sales records after deletion
    } catch (e) {
      print('Error deleting record: $e');
    }
  }

  // Function to show confirmation dialog before deleting
  Future<void> showDeleteConfirmation(BuildContext context, String documentId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this sales record?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteSalesRecord(documentId);
                Navigator.of(context).pop(); // Close the dialog after deletion
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
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
            final documentId = record['documentId'] ; // Provide default value if null
            final currentDate = formatDate(record['transactionDate'] as Timestamp);
            final previousDate = index > 0 ? formatDate(salesRecords[index - 1]['transactionDate'] as Timestamp) : '';

            // Add a date header if it's a new day
            bool isNewDate = index == 0 || currentDate != previousDate;

            return Column(
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
                Dismissible(
                  key: Key(documentId),
                  direction: DismissDirection.endToStart, // Swipe from right to left
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    await showDeleteConfirmation(context, documentId);
                    return false; // Prevent automatic dismissal
                  },
                  child: ListTile(
                    leading: Icon(Icons.receipt_long),
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (record['mobileNumber'] != null && record['mobileNumber'].isNotEmpty)
                          Text('Mobile: ${record['mobileNumber']}'),
                        Text('Total: ₹${record['totalPrice']?.toStringAsFixed(2) ?? '0.00'}'), // Provide default value if null
                      ],
                    ),
                    trailing: Text(formatDateTime(record['transactionDate'] as Timestamp)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
