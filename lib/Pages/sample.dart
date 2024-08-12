import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShopManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Shop Management')),
      // body: Text('Shop Management Page'),
      body: SafeArea(child: Text('HOME SCREEN')),
    );
  }
}

class StockManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stock Management')),
      body: Center(child: Text('Stock Management Page')),
    );
  }
}

class SalesRecordsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sales Records')),
      body: Center(child: Text('Sales Records Page')),
    );
  }
}
