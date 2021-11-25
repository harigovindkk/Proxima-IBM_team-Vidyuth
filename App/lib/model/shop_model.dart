import 'package:cloud_firestore/cloud_firestore.dart';

class ShopModel {
  String address;
  String id;
  GeoPoint location;
  String name;
  ShopModel({this.address, this.id, this.location, this.name});
  factory ShopModel.fromJson(Map<String, dynamic> json) => (ShopModel(
      address: json['address'],
      id: json['id'],
      location: json['location'],
      name: json['name']));
}
