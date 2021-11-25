import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proxima_ibm/authentication.dart';
import 'package:proxima_ibm/home.dart';
import 'package:proxima_ibm/input_field.dart';
import 'package:proxima_ibm/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Widget _buildSignUpPop(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Account doesn't exist",
        style:
            GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "There is no account exist with this email id. Please sign up for new account.",
            style: GoogleFonts.montserrat(),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          //textColor: Colors.black,
          child: Text(
            "Close",
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700, color: Colors.black),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const SignUpPage(),
              ),
            );
          },
          //textColor: Colors.black,
          child: Text("Goto sign up",
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w700, color: Colors.black)),
        ),
      ],
    );
  }

  void setLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('loggedin', 1);
  }

  TextEditingController emailcontroller = TextEditingController(),
      passwordcontroller = TextEditingController();
  User user;
  Future isUserExist(User user) async {
    Future<QuerySnapshot<Map<String, dynamic>>> result = FirebaseFirestore
        .instance
        .collection('users')
        .where("email", isEqualTo: user.email)
        .get();
    result.then((value) async {
      if (value.docs.length > 0) {
        // Navigator.pop(context);
        print("account exists");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('loggedin', 1);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      } else {
        //  Navigator.pop(context);
        print(user.email);
        print("account doesnot exist");
        setState(() {
          user = user;
        });
        FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          "createdTime": Timestamp.now(),
          "dob": "",
          "email": user?.email,
          "phone": "",
          "profilePicture": user?.photoURL,
          "uid": user?.uid,
          "name": user?.displayName,
          "loginMethod": "GoogleSignIn"
        }).whenComplete(() async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setInt('loggedin', 1);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        // leading: IconButton(
        //   onPressed: () {
        //     Navigator.of(context).pop();
        //   },
        //   icon: const Icon(Icons.arrow_back_ios, color: primary),
        // ),
        centerTitle: true,
        title: Text('Sign In to Proxima',
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
                      if (emailcontroller.text.contains('@') == false ||
                          emailcontroller.text.contains('.') == false) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('Enter a valid Email ID'),
                          duration: const Duration(seconds: 1),
                          action: SnackBarAction(
                            label: 'Ok',
                            onPressed: () {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                            },
                          ),
                        ));
                      } else if (passwordcontroller.text == "") {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('Password cannot be null'),
                          duration: const Duration(seconds: 1),
                          action: SnackBarAction(
                            label: 'Ok',
                            onPressed: () {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                            },
                          ),
                        ));
                      } else {
                        AuthenticationHelper()
                            .signIn(
                                emailcontroller.text, passwordcontroller.text)
                            .then((result) {
                          if (result == null) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage()));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(result),
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
                      }
                    },
                    child: Text(
                      "Sign In",
                      style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {},
                  child: RichText(
                    text: TextSpan(
                        text: 'Don\'t have an account in Proxima ? ',
                        style: GoogleFonts.montserrat(
                            fontSize: 15, color: Colors.white),
                        children: [
                          TextSpan(
                            text: 'Sign Up',
                            style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SignUpPage()))
                                  },
                          ),
                        ]),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
