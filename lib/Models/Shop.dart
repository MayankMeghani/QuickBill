import 'package:cloud_firestore/cloud_firestore.dart';

import 'Item.dart';

class Shop {
  final String id;
  final String userId;
  final String name;
  final String address;
  final String gstNo;
  final String ownerName;
  final String email;           // New field
  final String mobileNo;         // New field
  final List<Item> items;
  final String? profilePictureUrl;

  Shop({
    required this.id,
    required this.userId,
    required this.name,
    required this.address,
    required this.gstNo,
    required this.ownerName,
    required this.email,         // New field
    required this.mobileNo,      // New field
    required this.items,
    this.profilePictureUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'userId': userId,
      'name': name,
      'address': address,
      'gstNo': gstNo,
      'ownerName': ownerName,
      'email': email,             // New field
      'mobileNo': mobileNo,       // New field
      'items': items.map((item) => item.toMap()).toList(),
      'profilePictureUrl': profilePictureUrl,
    };
  }

  factory Shop.fromMap(Map<String, dynamic> map) {
    return Shop(
      id : map['id']??'',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      gstNo: map['gstNo'] ?? '',
      ownerName: map['ownerName'] ?? '',
      email: map['email'] ?? '',             // New field
      mobileNo: map['mobileNo'] ?? '',       // New field
      items: List<Item>.from(map['items']?.map((x) => Item.fromMap(x)) ?? []),
      profilePictureUrl: map['profilePictureUrl'],
    );
  }

  factory Shop.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Shop.fromMap({...data, 'id': doc.id});
  }
}
