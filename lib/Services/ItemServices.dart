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
              shopId: (data['shopId'])
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

  Future<bool> AddShopItem(Item item) async{
    try{
      final itemRef = await FirebaseFirestore.instance.collection('items').add(item.toMap());
      final shopRef = FirebaseFirestore.instance.collection('shops').doc(item.shopId);
      await shopRef.update({
        'items': FieldValue.arrayUnion([itemRef.id])
      });
      return true;
    }catch(e){
      print("unable to add item");
      print(e);
      return false;
    }

  }


  Future<void> removeItem(Item item) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      DocumentReference itemRef = FirebaseFirestore.instance.collection('items').doc(item.id);

      DocumentReference shopRef = FirebaseFirestore.instance.collection('shops').doc(item.shopId);

      batch.delete(itemRef);

      batch.update(shopRef, {
        'items': FieldValue.arrayRemove([item.id]),  // Assuming 'items' is an array of item IDs
      });

      await batch.commit();

      print('Item deleted successfully from both items and shop!');
    } catch (e) {
      print('Failed to delete item: $e');
    }
  }

  Future<void> updateItem  (String Id,Item item) async{
    await FirebaseFirestore.instance.collection('items').doc(Id).update(item.toMap());
  }


}