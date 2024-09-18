import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import '../Models/Item.dart';

Future<pw.Document> generatePdf(
    BuildContext context,
    String customerName,
    String mobileNumber,
    String gstNumber,
    Map<String, dynamic>? shopData,
    List<Item> items,
    ) async {
  final pdf = pw.Document();

  // Calculate total amount
  final totalAmount = items.fold<double>(
    0.0,
        (sum, item) => sum + (item.price * item.quantity),
  );

  // Add a page with the complete bill receipt
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Shop Information
          pw.Text('Shop Information', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text('Shop Name: ${shopData?['name'] ?? 'Shop Name'}'),
          pw.Text('Owner Name: ${shopData?['ownerName'] ?? 'N/A'}'),
          pw.Text('Mobile: ${shopData?['mobileNumber'] ?? 'N/A'}'),
          pw.Text('Email: ${shopData?['email'] ?? 'N/A'}'),
          pw.Text('Address: ${shopData?['address'] ?? 'Shop Address'}'),
          pw.Text('GST No: ${shopData?['gstNo'] ?? 'N/A'}'),
          pw.SizedBox(height: 20),

          // Customer Information
          pw.Text('Customer Information', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text('Name: $customerName'),
          pw.Text('Mobile: $mobileNumber'),
          pw.Text('GST No: $gstNumber'),
          pw.SizedBox(height: 20),

          // Item Details
          pw.Text('Item Details', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                children: [
                  pw.Text('Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              ...items.map((item) => pw.TableRow(
                children: [
                  pw.Text(item.name),
                  pw.Text(item.quantity.toString()), // Changed from selectedQty
                  pw.Text('${item.price.toStringAsFixed(2)}'),
                  pw.Text('${(item.quantity * item.price).toStringAsFixed(2)}'), // Changed from selectedQty
                ],
              )).toList(),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('Total Amount: ${totalAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    ),
  );

  return pdf;
}
