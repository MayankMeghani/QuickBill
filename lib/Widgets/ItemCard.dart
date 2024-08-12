
import 'package:flutter/material.dart';
import '../Classes/Item.dart';
class ItemCard extends StatelessWidget {
  final Item item;
  final Widget trailingButton;

  const ItemCard({
    Key? key,
    required this.item,
    required this.trailingButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.asset(item.imageUrl, width: 50, height: 50),
        title: Text(item.name),
        subtitle: Text('Qty: ${item.quantity} \n Price: ₹${item.price}'),
        trailing: trailingButton,  // Use the passed button
      ),
    );
  }
}
