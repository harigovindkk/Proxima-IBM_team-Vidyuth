//  @dart=2.9
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'package:proxima_ibm/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proxima_ibm/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  getStatus();
  runApp(const MyApp());
}

bool signedIn = false;
void getStatus() async {
  FirebaseAuth.instance.authStateChanges().listen((User user) {
    if (user == null) {
      signedIn = false;
      print('User is currently signed out!');
    } else {
      signedIn = true;
      print('User is signed in!');
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Proxima',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: signedIn ? HomePage() : LoginPage(),
    );
  }
}
