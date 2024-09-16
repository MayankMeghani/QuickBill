import 'package:flutter/material.dart';
import '../Models/Item.dart';

class Cart with ChangeNotifier {
  List<Item> _cartItems = [];

  List<Item> get cartItems => _cartItems;

  void addItem(Item item) {
    _cartItems.add(item);
    notifyListeners();
  }

  void removeItem(Item item) {
    _cartItems.remove(item);
    notifyListeners();
  }

  void updateItemQty(Item item, int newQty) {
    if (newQty > 0 && newQty <= item.quantity) {
      // Find the item in the cart and update its quantity
      final index = _cartItems.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _cartItems[index].selectedQty = newQty;
        notifyListeners();
      }
    } else if (newQty <= 0) {
      removeItem(item);
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  bool isItemInCart(Item item) {
    final contains = _cartItems.contains(item);
    return contains;
  }

  double getTotalPrice() {
    double totalPrice = _cartItems.fold(
      0,
          (total, item) => total + (item.price * item.selectedQty),
    );

    return double.parse(totalPrice.toStringAsFixed(2));
  }

}
