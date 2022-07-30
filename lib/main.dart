import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracer_upn/alumni/home.dart' as alumnus;
import 'package:tracer_upn/fakultas/home.dart' as faculty;
import 'package:tracer_upn/jurusan/departement.dart';
import 'package:tracer_upn/jurusan/home.dart' as departement;
import 'package:tracer_upn/signin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Sans',
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[200],
        backgroundColor: Colors.white,
        primarySwatch: Colors.blue,
        accentColor: Colors.blue,
        primaryColor: Colors.blue,
        buttonColor: Colors.blue,
        dialogBackgroundColor: Colors.white,
        textSelectionHandleColor: Colors.blue,
        cursorColor: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          elevation: 0.5,
          color: Colors.white,
          iconTheme: IconThemeData(
            size: 20.0,
            color: Colors.black87,
          ),
          textTheme: TextTheme(
              title: TextStyle(
              color: Colors.black87,
              fontSize: 18.0,
              fontFamily: 'Google',
              fontWeight: FontWeight.bold,
            )
          )
        ),
        textTheme: TextTheme(
          button: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Google',
          )
        ),
      ),
      home: SplashPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashState();
  }

}

class SplashState extends State {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    _getCurrentUser();
    super.initState(); 
  }

  _getCurrentUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    FirebaseUser currentUser = await _auth.currentUser();
    if(currentUser != null){
      if(preferences.getInt('role') == 3){
        Timer(Duration(seconds: 2), (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => alumnus.HomePage()));
        });
      } else if(preferences.getInt('role') == 2){
        if(preferences.getBool('isChoose') && preferences.getString('departement') == null){
          Timer(Duration(seconds: 2), (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DepartementPage()));
          });
        } else {
          Timer(Duration(seconds: 2), (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => departement.HomePage(title: preferences.getString('departementName'),)));
          });
        }
      } else if(preferences.getInt('role') == 1){
        Timer(Duration(seconds: 2), (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => faculty.HomePage()));
        });
      }
    } else {
      Timer(Duration(seconds: 2), (){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SigninPage()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      )
    );
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                'assets/images/icon_trans.png',
                width: MediaQuery.of(context).size.width * 0.4,
              ),
              Text(
                'TRACER STUDI UPN',
                style: TextStyle(
                  fontFamily: 'Noto',
                  fontWeight: FontWeight.bold,
                  fontSize: Theme.of(context).textTheme.headline5.fontSize,
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              SizedBox(
                width: 30.0,
                height: 30.0,
                child: CircularProgressIndicator(
                  strokeWidth: 3.0,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.25,
              ),
            ],
          ),
        ),
      ),
    );
  }

}
