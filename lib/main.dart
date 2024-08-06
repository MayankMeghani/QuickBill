import 'package:flutter/material.dart';
import 'package:quickbill/ItemsList.dart';

import 'HomePage.dart';

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
      home: ItemsListPage(),
    );
  }
}
