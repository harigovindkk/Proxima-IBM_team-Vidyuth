import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tflite/tflite.dart';
import 'package:proxima_ibm/model/product_model.dart';
import 'package:proxima_ibm/result_card_widget.dart';
import 'package:expandable_text/expandable_text.dart';

class ResultPage extends StatefulWidget {
  final String textQuery;
  final File imageQuery;
  final String type;
  ResultPage({Key key, this.type, this.textQuery, this.imageQuery})
      : super(key: key);
  // const ResultPage({Key? key, String? query}) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  static const String ssd = "SSD MobileNet";
  static const String yolo = "Tiny YOLOv2";
  String _model = yolo;
  bool _busy = false;
  List _recognitions;
  Map<String, int> labels = {};
  String final_result;
  double _imageWidth;
  double _imageHeight;
  File _image;
  ProductModel searchResult;

  @override
  void initState() {
    super.initState();
    _busy = true;
    final_result = widget.textQuery;
    print("textQuery is $final_result");
    print("scan type is ${widget.type}");

    //Image Processing
    _image = widget.imageQuery;
    if (_image != null) {
      // Text Recognition
      if (final_result == null && widget.type == "Text") {
        TextDetector textDetector = GoogleMlKit.vision.textDetector();
        textDetector.processImage(InputImage.fromFile(_image)).then((value) {
          print("inside text detector text is ${value.text}");
          if (value.text.isNotEmpty) {
            setState(() {
              final_result = "";
              value.blocks.forEach((element) {
                final_result += " ${element.text}";
              });
              final_result = final_result.replaceAll("\n", " ");
              print(final_result);
              // List words = final_result.split(' ');
              //   print(words);
              _busy = false;
            });
          }
        });
      }
      // Object detection
      else if (final_result == null && widget.type == "Image") {
        print("in object");
        _image = widget.imageQuery;
        if (widget.imageQuery != null) {
          loadModel().then((val) {
            predictImage(_image).then((value) {
              setObject();
            });
          });
        }
      } else {
        print("image processing didn't work. final_result  is $final_result");
        setState(() {
          final_result = " ";
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Center(
              child: Text('Search Results',
                  style: GoogleFonts.montserrat(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                Text(
                  'Showing results for : ',
                  style:
                      GoogleFonts.montserrat(fontSize: 15, color: Colors.white),
                ),
                Expanded(
                  child: ExpandableText(
                    final_result ?? " ",
                    expandText: 'show more',
                    collapseText: 'show less',
                    style: GoogleFonts.montserrat(
                        fontSize: 15, color: Colors.white),
                  ),
                )
              ],
            ),
            final_result != null
                ? StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('products')
                        .where('p_name',
                            whereIn:
                                final_result.toLowerCase().split(' ').length >
                                        10
                                    ? final_result
                                        .toLowerCase()
                                        .split(' ')
                                        .sublist(0, 10)
                                    : final_result.toLowerCase().split(' '))
                        .where('availability', isEqualTo: true)
                        .orderBy('price')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(50.0),
                          child: Center(
                              child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                          )),
                        );
                      }
                      if (snapshot.data.docs.isEmpty) {
                        return Column(
                          children: [
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.10),
                            Padding(
                                padding: EdgeInsets.only(left: 50),
                                child: Image.asset('images/Logo.png',
                                    height: MediaQuery.of(context).size.height *
                                        0.40)),
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
                            searchResult = ProductModel.fromJson(
                                doc.data() as Map<String, dynamic>);

                            return ResultCardWidget(
                                searchResult as ProductModel);
                          }).toList(),
                        );
                      } else {
                        return Center(
                          child: Text(
                            "Unknown Error Occured!",
                            style: GoogleFonts.poppins(
                                color: Colors.black, fontSize: 15),
                          ),
                        );
                      }
                    },
                  )
                : const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  loadModel() async {
    Tflite.close();
    try {
      String res;
      if (_model == yolo) {
        res = await Tflite.loadModel(
          model: "assets/tflite/yolov2_tiny.tflite",
          labels: "assets/tflite/yolov2_tiny.txt",
        );
      } else {
        res = await Tflite.loadModel(
          model: "assets/tflite/ssd_mobilenet.tflite",
          labels: "assets/tflite/ssd_mobilenet.txt",
        );
      }
      print(res);
    } on PlatformException {
      print("Failed to load the model");
    }
  }

  Future<File> predictImage(File image) async {
    if (image == null) return null;

    if (_model == yolo) {
      await yolov2Tiny(image);
    } else {
      await ssdMobileNet(image);
    }

    FileImage(image)
        .resolve(ImageConfiguration())
        .addListener((ImageStreamListener((ImageInfo info, bool _) {
          setState(() {
            _imageWidth = info.image.width.toDouble();
            _imageHeight = info.image.height.toDouble();
          });
        })));
    return image;
  }

  yolov2Tiny(File image) async {
    var recognitions = await Tflite.detectObjectOnImage(
        path: image.path,
        model: "YOLO",
        threshold: 0.3,
        imageMean: 0.0,
        imageStd: 255.0,
        numResultsPerClass: 1);

    setState(() {
      _recognitions = recognitions;
    });
  }

  ssdMobileNet(File image) async {
    var recognitions = await Tflite.detectObjectOnImage(
        path: image.path, numResultsPerClass: 1);

    setState(() {
      _recognitions = recognitions;
    });
  }

  setObject() {
    // if (_recognitions == null) return [];
    // if (_imageWidth == null || _imageHeight == null) return [];
    // double factorX = screen.width;
    // double factorY = _imageHeight / _imageHeight * screen.width;

    // Color blue = Colors.red;
    List<String> results = _recognitions.map((re) {
      return "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}";
    }).toList();
    results.forEach((unit) {
      labels[unit.split(' ')[0]] = int.parse(unit.split(' ')[1]);
    });
    print(results);
    int max = 0;
    if (labels.isNotEmpty) {
      labels.forEach((key, value) {
        print("inside loop");
        if (value > max) {
          final_result = key;
          max = value;
        }
        print(final_result);
        setState(() {
          _busy = false;
        });
      });
    } else {
      final_result = " ";
    }
  }
}
