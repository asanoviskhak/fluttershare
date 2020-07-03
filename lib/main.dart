import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterShare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xff283c86),
        accentColor: Color(0xff45a247),
      ),
      home: Home(),
    );
  }
}
