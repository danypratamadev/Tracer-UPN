import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracer_upn/alumni/biodata.dart';
import 'package:tracer_upn/signin.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ProfileState();
  }

}

class ProfileState extends State {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _name, _email;

  @override
  void initState() {
    _getCurrentUser();
    super.initState();
  }

  _getCurrentUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String name = preferences.getString('name');
    String email = preferences.getString('email');
    setState(() {
      _name = name;
      _email = email;
    });
  }

  _signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (_auth.currentUser() != null) {
      await _auth.signOut();
      if (mounted) {
        await preferences.clear();
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SigninPage()), (route) => false);
      }
    }
  }

  _showProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          alignment: FractionalOffset.centerLeft,
          width: 190.0,
          height: 60.0,
          margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0, bottom: 5.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 30.0,
                height: 30.0,
                child: CircularProgressIndicator(
                  strokeWidth: 3.0,
                ),
              ),
              SizedBox(
                width: 20.0,
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text(
                  "Mengeluarkan Anda...",
                  style: TextStyle(
                    fontFamily: 'Noto',
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  _showAlertDialog(){
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Wrap(
          children: <Widget>[
            Column(
              children: [
                SizedBox(height: 35.0,),
                Text(
                  'Halo, $_name',
                  style: TextStyle(
                    fontFamily: 'Google',
                    fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 5.0,),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                  child: Text(
                    'Apakah Anda yakin ingin keluar dari Aplikasi?',
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 35.0,),
                Divider(height: 0.5,),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: FlatButton(
                    onPressed: (){
                      Navigator.pop(context);
                      _showProgressDialog();
                      _signOut();
                    }, 
                    child: Text(
                      'Keluar',
                    ),
                    textColor: Theme.of(context).accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0)
                    ),
                  ),
                ),
                Divider(height: 0.5,),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: FlatButton(
                    onPressed: (){
                      Navigator.pop(context);
                    }, 
                    child: Text(
                      'Batal',
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8.0), bottomRight: Radius.circular(8.0))
                    ),
                  ),
                )
              ],
            ),
          ],
        )
      )
    );
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
        appBar: AppBar(
          title: Text(
            'Profil Saya'
          ),
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: <Widget>[
                    ClipOval(
                      child: Container(
                        width: 40.0,
                        height: 40.0,
                        color: Theme.of(context).accentColor,
                        child: Center(
                          child: Text(
                            _name.substring(0,1),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                              fontWeight: FontWeight.bold
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ),
                    ),
                    SizedBox(width: 16.0,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _name,
                          style: TextStyle(
                            fontFamily: 'Google',
                            fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: 3.0,),
                        Text(
                          _email,
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.caption.fontSize,
                            color: Theme.of(context).textTheme.caption.color,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Divider(height: 0.0,),
              ListTile(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => BiodataPage()));
                },
                contentPadding: EdgeInsets.only(left: 20.0, right: 20.0),
                leading: Icon(
                  LineIcons.clipboard,
                ),
                title: Text(
                  'Biodata',
                  style: TextStyle(
                    fontFamily: 'Google',
                    fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                ),
              ),
              Divider(height: 0.0,),
              ListTile(
                onTap: (){
                  _showAlertDialog();
                },
                contentPadding: EdgeInsets.only(left: 20.0, right: 20.0),
                leading: Icon(
                  LineIcons.sign_out,
                ),
                title: Text(
                  'Keluar Akun',
                  style: TextStyle(
                    fontFamily: 'Google',
                    fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}