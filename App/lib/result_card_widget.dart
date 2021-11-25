import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:proxima_ibm/constants.dart';
import 'package:proxima_ibm/locationmap.dart';
import 'package:proxima_ibm/model/product_model.dart';
import 'package:proxima_ibm/model/shop_model.dart';
import 'package:proxima_ibm/skeletol_loader.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ResultCardWidget extends StatefulWidget {
  ProductModel myModel;
  ResultCardWidget(this.myModel, {Key key}) : super(key: key);
  @override
  _ResultState createState() => _ResultState();
}

class _ResultState extends State<ResultCardWidget> {
  bool isLoading = false;
  Color heartcolor = Colors.white;
  double distance = 0.0;
  ShopModel shopModel;
  Future<void> getDetails() async {
    setState(() {
      isLoading = true;
    });
    Position p = await Geolocator.getCurrentPosition();
    return FirebaseFirestore.instance
        .collection('shops')
        .doc(widget.myModel.shop_id)
        .get()
        .then((value) {
      setState(() {
        shopModel = ShopModel.fromJson(value.data());

        distance = Geolocator.distanceBetween(p.latitude, p.longitude,
                shopModel.location.latitude, shopModel.location.longitude) /
            1000;
      });
    }).whenComplete(() => setState(() {
              isLoading = false;
            }));
  }

  @override
  void initState() {
    getDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: SkeletonContainer.square(
              width: MediaQuery.of(context).size.width,
              height: 210,
            ),
          )
        : Container(
            height: 210,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Colors.black,
                margin: const EdgeInsets.all(5.0),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              widget.myModel.p_image,
                              width: 100.0,
                              height: 100.0,
                            ),
                          ),
                          const SizedBox(width: 30),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.myModel.p_name,
                                style: GoogleFonts.montserrat(
                                    fontSize: 21.0, color: Colors.white),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                width: 10,
                                height: 10,
                              ),
                              Text(
                                shopModel.name.length > 20
                                    ? shopModel.name.substring(0, 20) + ".."
                                    : shopModel.name,
                                style: GoogleFonts.montserrat(
                                    fontSize: 18.0, color: Colors.white70),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                width: 10,
                                height: 10,
                              ),
                              Text(
                                shopModel.address.length > 20
                                    ? shopModel.address.substring(0, 20) + ".."
                                    : shopModel.address,
                                style: GoogleFonts.montserrat(
                                    fontSize: 18.0, color: Colors.white70),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            // width: 100,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20)),
                            child: Center(
                              child: Text(
                                distance.toStringAsFixed(1) + ' km',
                                style: GoogleFonts.montserrat(
                                    fontSize: 18.0, color: Colors.black),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            width: 100,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20)),
                            child: Center(
                              child: Text(
                                '₹ ' + widget.myModel.price.toString() + '',
                                style: GoogleFonts.montserrat(
                                    fontSize: 18.0, color: Colors.black),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                heartcolor = Colors.red;
                              });
                              FirebaseFirestore.instance
                                  .collection('wishlist')
                                  .doc(userId +
                                      '_' +
                                      widget.myModel.p_id.toString())
                                  .set({
                                'item_id': widget.myModel.p_id,
                                "shop_id": shopModel.id,
                                "user_id": userId,
                                'key': userId +
                                    '_' +
                                    widget.myModel.p_id.toString(),
                              });
                            },
                            icon: const Icon(
                              Icons.favorite,
                              size: 30,
                            ),
                            color: heartcolor,
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => locationmap(
                                          shopModel.location.latitude,
                                          shopModel.location.longitude)));
                            },
                            icon: const Icon(
                              Icons.location_on,
                              size: 30,
                            ),
                            color: Colors.white,
                          ),
                          IconButton(
                            onPressed: () {
                              String qrCode = '';
                              FirebaseFirestore.instance
                                  .collection('promocodes')
                                  .where('shop_id',
                                      isEqualTo: widget.myModel.shop_id)
                                  .where('purchased_user_id', isEqualTo: '')
                                  .get()
                                  .then((value) {
                                setState(() {
                                  qrCode = value.docs.first.data()['code'];
                                });
                              }).whenComplete(() {
                                showDialog<void>(
                                  context: context,
                                  //barrierDismissible: false, // user must tap button!
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      title: Text(
                                        'Discount Coupon Code',
                                        style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                        textAlign: TextAlign.left,
                                      ),
                                      content: qrCode == ''
                                          ? Text(
                                              'No Coupons Available for the specified shop!',
                                              style: GoogleFonts.montserrat(),
                                            )
                                          : Container(
                                              width: 200.0,
                                              height: 200.0,
                                              child: Center(
                                                child: QrImage(
                                                  data: qrCode,
                                                  version: QrVersions.auto,
                                                ),
                                              ),
                                            ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text(
                                            'OK',
                                            style: GoogleFonts.montserrat(
                                                color: Colors.black),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              });
                            },
                            icon: const Icon(
                              Icons.qr_code,
                              size: 30,
                            ),
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
