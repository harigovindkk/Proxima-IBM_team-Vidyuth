import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistModel {
  String item_id, shop_id, user_id, key;

  WishlistModel({this.item_id, this.user_id, this.shop_id, this.key});
  factory WishlistModel.fromJson(Map<String, dynamic> json) => (WishlistModel(
      item_id: json['item_id'],
      user_id: json['user_id'],
      shop_id: json['shop_id'],
      key: json['key']));
}
