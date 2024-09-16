import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../Services/ShopService.dart';

class ShopProvider with ChangeNotifier {
  final ShopService _shopService = ShopService();
  Map<String, dynamic>? _shopData;

  Map<String, dynamic>? get shopData => _shopData;


  Future<void> updateShopData(Map<String, dynamic> data) async {
    await _shopService.updateShopData(data);
    // await loadShopData();
  }

  Future<void> loadShopData() async {
    _shopData = await _shopService.getShopData();
    notifyListeners();
  }
}