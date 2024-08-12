import 'package:flutter/material.dart';
import 'Pages/HomePage.dart';
import 'Pages/BillGenerationPage.dart';
import 'Pages/sample.dart';
void main() {
  runApp(QuickBillApp());
}

class QuickBillApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickBill: Business Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
      routes: {
        '/shopManagement': (context) => ShopManagementPage(),
        '/stockManagement': (context) => StockManagementPage(),
        '/billGeneration': (context) => BillGenerationPage(),
        '/salesRecords': (context) => SalesRecordsPage(),
      },
    );
  }
}
