import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('QuickBill Home'),
            SizedBox(width: 10),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/bill.jpg',
              width: 500,
              height: 175, // Adjust the height as needed
            ),
            HomePageButton(
              icon: Icons.store,
              text: 'Shop Management',
              onPressed: () {
                // Navigate to Shop Management page
              },
            ),
            SizedBox(height: 16),
            HomePageButton(
              icon: Icons.inventory,
              text: 'Stock Management',
              onPressed: () {
                // Navigate to Stock Management page
              },
            ),
            SizedBox(height: 16),
            HomePageButton(
              icon: Icons.receipt,
              text: 'Bill Generation',
              onPressed: () {
                Navigator.pushNamed(context, '/items');// Navigate to Bill Generation page
              },
            ),
            SizedBox(height: 16),
            HomePageButton(
              icon: Icons.analytics,
              text: 'Sales Records',
              onPressed: () {
                // Navigate to Sales Records page
              },
            ),
          ],
        ),
      ),
    );
  }
}

class HomePageButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  HomePageButton({
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        backgroundColor: Colors.blue,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28),
          SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
