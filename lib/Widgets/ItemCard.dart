import 'package:flutter/material.dart';
import '../Models/Item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final Widget trailingButton;
  final Color? highlightColor; // New parameter to highlight the item

  const ItemCard({Key? key, required this.item, required this.trailingButton, this.highlightColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: highlightColor ?? Colors.white, // Apply highlight color if provided
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          child: item.imageUrl.startsWith('http')
              ? Image.network(
            item.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/images/bill.jpg',
                fit: BoxFit.cover,
              );
            },
          )
              : Image.asset(
            'assets/images/bill.jpg',
            fit: BoxFit.cover,
          ),
        ),
        title: Text(item.name),
        subtitle: Text('Quantity: ${item.quantity}\nPrice: ₹ ${item.price.toStringAsFixed(2)}'),
        trailing: trailingButton,
      ),
    );
  }
}