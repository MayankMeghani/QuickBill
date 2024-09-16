import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../Providers/ShopProvider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final shopProvider = Provider.of<ShopProvider>(context);
    final bool isProfileComplete = shopProvider.shopData?['isProfileComplete'] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('QuickBill Home'),
            SizedBox(width: 10),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/bill.jpg',
              width: 500,
              height: 175,
            ),
            HomePageButton(
              icon: Icons.store,
              text: 'Shop Management',
              onPressed: () => Navigator.pushNamed(context, '/shopManagement'),
              isHighlighted: !isProfileComplete,
            ),
            SizedBox(height: 16),
            HomePageButton(
              icon: Icons.inventory,
              text: 'Stock Management',
              onPressed: () => _navigateTo(context, '/stockManagement', isProfileComplete),
            ),
            SizedBox(height: 16),
            HomePageButton(
              icon: Icons.receipt,
              text: 'Bill Generation',
              onPressed: () => _navigateTo(context, '/billGeneration', isProfileComplete),
            ),
            SizedBox(height: 16),
            HomePageButton(
              icon: Icons.analytics,
              text: 'Sales Record',
              onPressed: () => _navigateTo(context, '/salesRecords', isProfileComplete),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, String route, bool isProfileComplete) {
    if (!isProfileComplete) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Profile Incomplete'),
            content: Text('Please complete your shop profile before proceeding.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/shopManagement');
                },
              ),
            ],
          );
        },
      );
    } else {
      Navigator.pushNamed(context, route);
    }
  }
}

class HomePageButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;
  final bool isHighlighted;

  HomePageButton({
    required this.icon,
    required this.text,
    required this.onPressed,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        backgroundColor: isHighlighted ? Colors.red : Colors.blue,
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
          if (isHighlighted)
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Icon(Icons.warning, color: Colors.yellow),
            ),
        ],
      ),
    );
  }
}