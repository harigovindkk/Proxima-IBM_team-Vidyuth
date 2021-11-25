import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proxima_ibm/model/product_model.dart';
import 'package:proxima_ibm/model/shop_model.dart';
import 'package:proxima_ibm/model/wishlist_model.dart';
import 'package:proxima_ibm/skeletol_loader.dart';

class RecentSearch extends StatefulWidget {
  WishlistModel wishlistModel;
  RecentSearch(this.wishlistModel, {Key key}) : super(key: key);

  @override
  _RecentSearchState createState() => _RecentSearchState();
}

class _RecentSearchState extends State<RecentSearch> {
  ShopModel shopModel;
  ProductModel productModel;
  bool isLoading = false;
  Future<void> getProductDetails() async {
    setState(() {
      isLoading = true;
    });

    return FirebaseFirestore.instance
        .collection('products')
        .doc(widget.wishlistModel.item_id)
        .get()
        .then((value) {
      setState(() {
        productModel = ProductModel.fromJson(value.data());
      });
    }).whenComplete(() => getShopDetails());
  }

  Future<void> getShopDetails() async {
    return FirebaseFirestore.instance
        .collection('shops')
        .doc(widget.wishlistModel.shop_id)
        .get()
        .then((value) {
      setState(() {
        shopModel = ShopModel.fromJson(value.data());
      });
    }).whenComplete(() => setState(() {
              isLoading = false;
            }));
  }

  @override
  void initState() {
    getProductDetails();
    super.initState();
  }

  void removeFromFavourite() async {
    try {
      print(widget.wishlistModel.key);
      await FirebaseFirestore.instance
          .doc('wishlist/${widget.wishlistModel.key}')
          .delete()
          .whenComplete(() {
        print('removed');

        // checkExist(widget.channelId);
      }).catchError((error) => print("error"));
    } catch (e) {
      print("Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading

        ? Center(
            child: SkeletonContainer.square(
              width: MediaQuery.of(context).size.width,
              height: 100,
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(20)),
              //height: MediaQuery.of(context).size.height * 0.1,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          productModel.p_image,
                          width: 80.0,
                          height: 80.0,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productModel.p_name,
                            style: GoogleFonts.montserrat(
                                color: Colors.white, fontSize: 15),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            shopModel.name,
                            style: GoogleFonts.montserrat(
                                color: Colors.white54, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                      onPressed: () {
                        removeFromFavourite();
                        // FirebaseFirestore.instance
                        //     .doc('wishlist/${widget.wishlistModel.key}')
                        //     .delete()
                        //     .then((value) => print('deleted'))
                        //     .onError((error, stackTrace) => print(error));
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ))
                ],
              ),
            ),
          );
  }
}
