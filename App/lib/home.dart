import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:proxima_ibm/authentication.dart';
import 'package:proxima_ibm/constants.dart';
import 'package:proxima_ibm/login.dart';
import 'package:proxima_ibm/model/wishlist_model.dart';
import 'package:proxima_ibm/recent.dart';
import 'package:proxima_ibm/results.dart';
import 'package:firebase_core/firebase_core.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position position, p;
  List<Placemark> placemarks;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    p = await Geolocator.getCurrentPosition();
    return await Geolocator.getCurrentPosition();
  }

  String searchFileName;
  File _searchImageFile;
  bool imageSearched = false;
  // void _fromgallery() async {
  //   final _picker = ImagePicker();

  //   PickedFile? pickedImageFile = await _picker.getImage(
  //       source: ImageSource.gallery,
  //       imageQuality: 100,
  //       maxWidth: 3000,
  //       maxHeight: 4000);

  //   //print(fileName);

  //   setState(() {
  //     searchFileName = pickedImageFile!.path.split('/').last;
  //     _searchImageFile = File(pickedImageFile.path);
  //     //artremoved = false;
  //     imageSearched = true;
  //   });
  // }

  Future _getImage(int val) async {
    final _picker = ImagePicker();
    PickedFile pickedImageFile = await _picker.getImage(
        source: val == 1 ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 100,
        maxWidth: 3000,
        maxHeight: 4000);
    setState(() {
      searchFileName = pickedImageFile.path.split('/').last;
      _searchImageFile = File(pickedImageFile.path);
      //artremoved = false;
      imageSearched = true;
    });
  }

  // void _fromCamera() async {
  //   final _picker = ImagePicker();
  //   PickedFile? pickedImageFile = await _picker.getImage(
  //       source: ImageSource.camera,
  //       imageQuality: 100,
  //       maxWidth: 3000,
  //       maxHeight: 4000);

  //   // print(fileName);

  //   setState(() {
  //     print(searchFileName);
  //     searchFileName = pickedImageFile!.path.split('.').last;
  //     print(searchFileName);
  //     _searchImageFile = File(pickedImageFile.path);
  //     //artremoved = false;
  //     imageSearched = true;
  //   });
  // }

  Future getLocationName() async {
    placemarks = await placemarkFromCoordinates(p.latitude, p.longitude);
  }

  // Future getLocation() async {
  //   position = await Geolocator.getCurrentPosition(
  //           desiredAccuracy: LocationAccuracy.high)
  //       .whenComplete(() {
  //     getLocationName();
  //     print("position is");
  //     print(position!.timestamp);
  //   });
  // }
  // Location location = new Location();

  // bool _serviceEnabled;
  // PermissionStatus _permissionGranted;
  // LocationData _locationData;

  // _serviceEnabled = await location.serviceEnabled();
  // if (!_serviceEnabled) {
  //   _serviceEnabled = await location.requestService();
  //   if (!_serviceEnabled) {
  //     return;
  //   }
  // }

  // _permissionGranted = await location.hasPermission();
  // if (_permissionGranted == PermissionStatus.denied) {
  //   _permissionGranted = await location.requestPermission();
  //   if (_permissionGranted != PermissionStatus.granted) {
  //     return;
  //   }
  // }

  // _locationData = await location.getLocation().whenComplete(() {
  //   setState(() {
  //     isLoading = false;

  //   });
  // });

  void getLocationDetails() {
    setState(() {
      isLoading = true;
    });

    _determinePosition().whenComplete(() {
      // print(p!.latitude);
      // print(p!.longitude);
      getLocationName().whenComplete(() {
        print(placemarks[0].subAdministrativeArea);
        setState(() {
          locationName = placemarks[0].subAdministrativeArea as String;
          isLoading = false;
        });
      });
    });
  }

  bool isLoading = false;
  String locationName = '';
  WishlistModel wishListModel;
  @override
  initState() {
    // TODO: implement initState
    super.initState();
    getLocationDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_city, color: Colors.white),
              const SizedBox(width: 5),
              Text(
                isLoading ? "Loading.." : locationName,
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
              const SizedBox(width: 5),
              InkWell(
                child: const Icon(Icons.refresh, color: Colors.white),
                onTap: () {
                  setState(() {
                    getLocationDetails();
                  });
                },
              )
            ],
          ),
          //SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Welcome ' +
                      FirebaseAuth.instance.currentUser.email.toString(),
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    AuthenticationHelper().signOut();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (BuildContext context) => LoginPage()));
                  },
                  icon: Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey,
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.70,
              height: 50,
              child: TextField(
                style: GoogleFonts.montserrat(),
                onSubmitted: (textquery) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          ResultPage(textQuery: textquery)));
                },
                cursorColor: Colors.black,
                decoration: InputDecoration(
                    focusColor: Colors.grey,
                    hoverColor: Colors.grey,
                    alignLabelWithHint: true,
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),

                    // suffixIcon: InkWell(
                    //   child: const Icon(
                    //     Icons.camera_alt,
                    //     color: Colors.grey,
                    //   ),
                    //   onTap: () {
                    //     showDialog<void>(
                    //       context: context,
                    //       //barrierDismissible: false, // user must tap button!
                    //       builder: (BuildContext context) {
                    //         return AlertDialog(
                    //           backgroundColor: Colors.white,
                    //           title: Text(
                    //             'Search By Image',
                    //             style: GoogleFonts.montserrat(
                    //                 fontWeight: FontWeight.bold,
                    //                 color: Colors.black),
                    //             textAlign: TextAlign.left,
                    //           ),
                    //           content: SingleChildScrollView(
                    //             child: ListBody(
                    //               children: <Widget>[
                    //                 Text(
                    //                   'It’s recommended to use a picture that’s at least 98 x 98 pixels and 2MB or less.',
                    //                   style: GoogleFonts.montserrat(
                    //                       color: Colors.black),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //           actions: <Widget>[
                    //             TextButton(
                    //               child: Text(
                    //                 'Select from Gallery',
                    //                 style: GoogleFonts.montserrat(
                    //                     color: Colors.black),
                    //               ),
                    //               onPressed: () {
                    //                 _getImage(1).whenComplete(() {
                    //                   Navigator.of(context).pop();
                    //                   if (imageSearched) {
                    //                     Navigator.of(context).push(
                    //                       MaterialPageRoute(
                    //                         builder: (BuildContext context) =>
                    //                             ResultPage(
                    //                           imageQuery: _searchImageFile,
                    //                         ),
                    //                       ),
                    //                     );
                    //                   }
                    //                 });
                    //               },
                    //             ),
                    //             TextButton(
                    //               child: Text(
                    //                 'Take a Picture',
                    //                 style: GoogleFonts.montserrat(
                    //                     color: Colors.black),
                    //               ),
                    //               onPressed: () {
                    //                 _getImage(2).whenComplete(() {
                    //                   Navigator.of(context).pop();
                    //                   if (imageSearched) {
                    //                     Navigator.of(context).push(
                    //                       MaterialPageRoute(
                    //                         builder: (BuildContext context) =>
                    //                             ResultPage(
                    //                           imageQuery: _searchImageFile,
                    //                         ),
                    //                       ),
                    //                     );
                    //                   }
                    //                 });
                    //               },
                    //             ),
                    //           ],
                    //         );
                    //       },
                    //     );
                    //   },
                    // ),

                    // suffixIcon: PopUpMenuIcon(),
                    suffixIcon: PopupMenuButton(
                        color: Colors.black,
                        icon: Icon(Icons.scanner, color: Colors.grey),
                        itemBuilder: (BuildContext context) {
                          return <PopupMenuEntry>[
                            PopupMenuItem(
                              child: Text(
                                "Scan Text",
                                style:
                                    GoogleFonts.montserrat(color: Colors.white),
                              ),
                              value: 'Text',
                            ),
                            PopupMenuItem(
                              child: Text("Scan Image",
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white)),
                              value: 'Image',
                            ),
                          ];
                        },
                        onSelected: (selectedvalue) {
                          showDialog<void>(
                            context: context,
                            //barrierDismissible: false, // user must tap button!
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: Text(
                                  'Search By Scanning ' +
                                      selectedvalue.toString(),
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                  textAlign: TextAlign.left,
                                ),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      Text(
                                        'It’s recommended to use a picture that’s at least 98 x 98 pixels and 2MB or less.',
                                        style: GoogleFonts.montserrat(
                                            color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text(
                                      'Select from Gallery',
                                      style: GoogleFonts.montserrat(
                                          color: Colors.black),
                                    ),
                                    onPressed: () {
                                      _getImage(1).whenComplete(() {
                                        Navigator.of(context).pop();
                                        if (imageSearched) {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  ResultPage(
                                                type: selectedvalue.toString(),
                                                imageQuery: _searchImageFile,
                                              ),
                                            ),
                                          );
                                        }
                                      });
                                    },
                                  ),
                                  TextButton(
                                    child: Text(
                                      'Take a Picture',
                                      style: GoogleFonts.montserrat(
                                          color: Colors.black),
                                    ),
                                    onPressed: () {
                                      _getImage(2).whenComplete(() {
                                        Navigator.of(context).pop();
                                        if (imageSearched) {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  ResultPage(
                                                type: selectedvalue.toString(),
                                                imageQuery: _searchImageFile,
                                              ),
                                            ),
                                          );
                                        }
                                      });
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    filled: true,
                    hintStyle: GoogleFonts.montserrat(color: Colors.grey[800]),
                    hintText: "Type product name",
                    fillColor: Colors.white70),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          Row(
            children: [
              const SizedBox(width: 20),
              Text('Favourites',
                  style: GoogleFonts.montserrat(
                      fontSize: 20, color: Colors.white)),
            ],
          ),
          SingleChildScrollView(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('wishlist')
                  .where('user_id', isEqualTo: userId)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ));
                }
                if (snapshot.data.docs.isEmpty) {
                  return Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.10),
                      Padding(
                          padding: EdgeInsets.only(left: 50),
                          child: Image.asset('images/Logo.png',
                              height:
                                  MediaQuery.of(context).size.height * 0.40)),
                      Center(
                        child: Text(
                          "Nothing to show!",
                          style: GoogleFonts.montserrat(
                              color: Colors.white, fontSize: 15),
                        ),
                      ),
                    ],
                  );
                }
                if (snapshot.hasData) {
                  return ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: snapshot.data.docs.map((doc) {
                      wishListModel = WishlistModel.fromJson(
                          doc.data() as Map<String, dynamic>);

                      return RecentSearch(wishListModel as WishlistModel);
                    }).toList(),
                  );
                } else {
                  return Center(
                    child: Text(
                      "Unknown Error Occured!",
                      style: GoogleFonts.montserrat(
                          color: Colors.black, fontSize: 15),
                    ),
                  );
                }
              },
            ),
          ),

          //const SizedBox(height: 10),

          const SizedBox(height: 20),
          //const RecentSearch(),
        ],
      ),
    );
  }
}
