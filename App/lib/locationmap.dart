import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

class locationmap extends StatefulWidget {
  double latitude, longitude;
  locationmap(this.latitude, this.longitude);
  @override
  _locationmapState createState() => _locationmapState();
}

class _locationmapState extends State<locationmap> {
  bool isLoading = true;
  void getDetails() async {
    setState(() {
      isLoading = true;
    });
    p = await Geolocator.getCurrentPosition();
    setState(() {
      isLoading = false;
    });
  }

  Position p;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDetails();
  }

  @override
  Widget build(BuildContext context) {
    var points = <LatLng>[
      LatLng(p.latitude, p.longitude),
      LatLng(widget.latitude, widget.longitude),
    ];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Shop Location',
          style: GoogleFonts.montserrat(color: Colors.white),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
              backgroundColor: Colors.white,
            ))
          : FlutterMap(
              options: MapOptions(
                center: LatLng(widget.latitude, widget.longitude),
                minZoom: 10.0,
              ),
              layers: [
                TileLayerOptions(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayerOptions(markers: [
                  Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(widget.latitude, widget.longitude),
                      builder: (context) => Container(
                          child: IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 35.0,
                              )))),
                  Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(p.latitude, p.longitude),
                      builder: (context) => Container(
                          child: IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.home,
                                color: Colors.blue,
                                size: 35.0,
                              )))),
                ]),
                PolylineLayerOptions(
                  polylines: [
                    Polyline(
                        points: points, strokeWidth: 4.0, color: Colors.purple),
                  ],
                ),
              ],
            ),
    );
  }
}
