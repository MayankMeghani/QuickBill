import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShopService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  Future<Map<String, dynamic>?> getShopData(String? email) async {
    try {
      if (email != null) {
        QuerySnapshot shopQuery = await _firestore
            .collection('shops')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (shopQuery.docs.isNotEmpty) {
          return shopQuery.docs.first.data() as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching shop data: $e');
      return null;
    }
  }

  Future<void> updateShopData(Map<String, dynamic> data) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        QuerySnapshot shopQuery = await _firestore
            .collection('shops')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

        if (shopQuery.docs.isNotEmpty) {
          await shopQuery.docs.first.reference.update(data);
        }
      }
    } catch (e) {
      print('Error updating shop data: $e');
      throw e;
    }
  }
}