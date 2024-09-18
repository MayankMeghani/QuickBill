import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickbill/Models/Item.dart';

class ItemServices{

Future<List<Item>> FetchShopItems(String shopId) async{
  if(shopId!= null){
  try {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(
        'items')
        .where('shopId', isEqualTo: shopId).get();

    List<Item> items = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Item(
        id: doc.id,
        name: data['name'],
        imageUrl: data['imageUrl'] ?? 'assets/images/bill.jpg',
        quantity: data['quantity'] ?? 0,
        price: (data['price']).toDouble(),
      );
    }).toList();
    return items;
  }
  catch(e){
    return [];
  }
  }
  else{
    return [];
  }
}
}