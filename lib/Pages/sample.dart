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


class SalesRecordsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sales Records')),
      body: Center(child: Text('Sales Records Page')),
    );
  }
}
