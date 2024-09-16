import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../Models/Cart.dart';
import '../Providers/ShopProvider.dart';

Future<pw.Document> generatePdf(BuildContext context, String customerName, String mobileNumber) async {
  final pdf = pw.Document();
  final shopProvider = Provider.of<ShopProvider>(context, listen: false);
  final cart = Provider.of<Cart>(context, listen: false);

  final shopData = shopProvider.shopData;
  final cartItems = cart.cartItems;
  final totalAmount = cart.getTotalPrice();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Bill Receipt', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text('${shopData?['name'] ?? 'Shop Name'}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text('${shopData?['address'] ?? 'Shop Address'}'),
          pw.Text('GST No: ${shopData?['gstNo'] ?? 'N/A'}'),
          pw.SizedBox(height: 20),
          pw.Text('Customer: $customerName'),
          pw.Text('Mobile: $mobileNumber'),
          pw.Text('Date: ${DateTime.now().toString().split(' ')[0]}'),
          pw.SizedBox(height: 20),
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
              ...cartItems.map((item) => pw.TableRow(
                children: [
                  pw.Text(item.name),
                  pw.Text(item.selectedQty.toString()),
                  pw.Text('${item.price.toStringAsFixed(2)}'),
                  pw.Text('${(item.selectedQty * item.price).toStringAsFixed(2)}'),
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