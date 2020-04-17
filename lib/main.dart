import 'package:flutter/material.dart';
import 'package:parkly/constant.dart';
import 'package:parkly/pages/maps.dart';
import 'package:parkly/setup/logIn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parkly/setup/globals.dart' as globals;

void main() {
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    home: new MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void getCurrentUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      if (this.mounted) {
        setState(() {
          globals.userId = user.uid; //"ymRHvUb4CqRyStXNuaNz3hbbrhg1"
        });
      }
    } else {
      if (this.mounted) {
        setState(() {
          globals.userId = null;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Blauw,
          accentColor: Zwart,
          fontFamily: "Montserrat",
          scaffoldBackgroundColor: LichtGrijs,
          canvasColor: Wit),
      home: checkUser(),
    );
  }

  checkUser() {
    if (globals.userId != null) {
      return MapsPage();
    } else {
      return LogInPage();
    }
  }
}
