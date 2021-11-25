import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  String p_image, p_id, p_name, shop_id;
  bool availability;
  num price;

  ProductModel(
      {this.p_id,
      this.p_image,
      this.p_name,
      this.price,
      this.availability,
      this.shop_id});
  factory ProductModel.fromJson(Map<String, dynamic> json) => (ProductModel(
      p_image: json['p_image'],
      p_id: json['p_id'],
      p_name: json['p_name'],
      shop_id: json['shop_id'],
      price: json['price'],
      availability: json['availability']));
}
