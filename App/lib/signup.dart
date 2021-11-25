import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proxima_ibm/authentication.dart';
import 'package:proxima_ibm/home.dart';
import 'package:proxima_ibm/input_field.dart';
import 'package:proxima_ibm/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  User user;
  Future isUserExist() async {
    Future<QuerySnapshot<Map<String, dynamic>>> result = FirebaseFirestore
        .instance
        .collection('users')
        .where("uid", isEqualTo: FirebaseAuth.instance.currentUser.uid)
        .get();
    result.then((value) {
      if (value.docs.length > 0) {
        // Navigator.pop(context);
        Future<SharedPreferences> prefs = SharedPreferences.getInstance();
        final SharedPreferences prefsData = prefs as SharedPreferences;
        prefsData.setInt('loggedin', 1);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      } else {
        //  Navigator.pop(context);
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser.uid)
            .set({
          "email": user.email,
          "phone": user.phoneNumber,
          "uid": FirebaseAuth.instance.currentUser.uid,
          "name": user.displayName
        });
      }
    }).whenComplete(() {
      Future<SharedPreferences> prefs = SharedPreferences.getInstance();
      final SharedPreferences prefsData = prefs as SharedPreferences;
      prefsData.setInt('loggedin', 1);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    });
  }

  bool isSelected = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  Future<void> createUserDoc() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .set({
      "uid": FirebaseAuth.instance.currentUser.uid,
      "name": namecontroller.text,
      "email": emailcontroller.text,
      "phone": phonecontroller.text,
    }).onError((error, stackTrace) => print(error));
  }

  TextEditingController emailcontroller = TextEditingController(),
      namecontroller = TextEditingController(),
      dobcontroller = TextEditingController(),
      phonecontroller = TextEditingController(),
      passwordcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        centerTitle: true,
        title: Text('Sign Up',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 15.0, top: 15.0),
              child: Text(
                "Name",
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
            ),
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: InputField('', namecontroller),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 15.0, top: 15.0),
              child: Text(
                "Email",
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
            ),

            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: InputField('', emailcontroller),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 15.0, top: 15.0),
              child: Text(
                "Phone Number",
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
            ),
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.montserrat(
                      color: Colors.white, fontWeight: FontWeight.w600),
                  cursorColor: Colors.white,
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return "Phone Number can't be empty";
                    }
                    return null;
                  },
                  obscureText: false,
                  controller: phonecontroller,
                  decoration: InputDecoration(
                    labelText: '',
                    labelStyle:
                        GoogleFonts.montserrat(color: const Color(0xff181818)),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4.0),
                        topRight: Radius.circular(4.0),
                        bottomLeft: Radius.circular(4.0),
                        bottomRight: Radius.circular(4.0),
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4.0),
                        topRight: Radius.circular(4.0),
                        bottomLeft: Radius.circular(4.0),
                        bottomRight: Radius.circular(4.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, top: 15.0),
              child: Text(
                "Password",
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
            ),
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                style: GoogleFonts.montserrat(
                    color: Colors.white, fontWeight: FontWeight.w600),
                cursorColor: Colors.white,
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return "Password field can't be empty";
                  }
                  return null;
                },
                obscureText: true,
                controller: passwordcontroller,
                decoration: InputDecoration(
                  labelText: '',
                  labelStyle:
                      GoogleFonts.montserrat(color: const Color(0xff181818)),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4.0),
                      topRight: Radius.circular(4.0),
                      bottomLeft: Radius.circular(4.0),
                      bottomRight: Radius.circular(4.0),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4.0),
                      topRight: Radius.circular(4.0),
                      bottomLeft: Radius.circular(4.0),
                      bottomRight: Radius.circular(4.0),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Center(
                child: Container(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.white),
                    onPressed: () {
                      AuthenticationHelper()
                          .signUp(emailcontroller.text, passwordcontroller.text)
                          .then((result) {
                        if (result == null) {
                          createUserDoc();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Account Created Succesfully. Please login to continue"),
                            duration: const Duration(seconds: 3),
                            action: SnackBarAction(
                              label: 'Ok',
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                              },
                            ),
                          ));
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(result.toString()),
                            duration: const Duration(seconds: 3),
                            action: SnackBarAction(
                              label: 'Ok',
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                              },
                            ),
                          ));
                        }
                      });
                    },
                    child: Text(
                      "Sign Up",
                      style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(15.0),
            //   child: Container(
            //     decoration: BoxDecoration(
            //       shape: BoxShape.rectangle,
            //       borderRadius: BorderRadius.circular(50.0),
            //       gradient: const LinearGradient(
            //           colors: <Color>[Color(0xffF9DB39), Color(0xffFFEF62)],
            //           begin: FractionalOffset.topLeft,
            //           end: FractionalOffset.bottomRight,
            //           stops: [0.1, 0.4],
            //           tileMode: TileMode.mirror),
            //     ),
            //     width: MediaQuery.of(context).size.width * 0.9,
            //     child: ElevatedButton(
            //       style: ElevatedButton.styleFrom(
            //         shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(50.0)),
            //         elevation: 0,
            //         primary: Colors.transparent,
            //         padding: const EdgeInsets.all(15),
            //       ),
            //       onPressed: () async {
            //         final albabprovider =
            //             Provider.of<HelloAlbabProvider>(context, listen: false);
            //         user = await albabprovider.googleLogin(context);

            //         print(user!.email.toString());
            //         if (user != null) {
            //           isUserExist();
            //         }
            //       },
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           const Icon(
            //             Icons.mail,
            //             color: Colors.black,
            //           ),
            //           const SizedBox(
            //             width: 5,
            //           ),
            //           Text(
            //             "Continue with Gmail",
            //             style: GoogleFonts.montserrat(
            //                 color: Colors.black,
            //                 fontSize: 15,
            //                 fontWeight: FontWeight.w600),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
