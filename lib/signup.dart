import 'dart:async';

import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:tracer_upn/alumni/home.dart';
import 'package:tracer_upn/signin.dart';

class SignupPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SignupState();
  }

}

class SignupState extends State {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _passController = TextEditingController();
  bool _passVisible = false, _readOnly = false, _buttonActive = false, _isLoading = false, _canVibrate = false, _reverse = false;
  int _position = 0;

  @override
  void initState() {
    _checkDeviceVibrate();
    super.initState();
  }

  _checkDeviceVibrate() async {
    bool canVibrate = await Vibrate.canVibrate;
    setState(() {
      _canVibrate = canVibrate;
    });
  }

  _enableButton(int action){
    switch(action){
      case 10: 
        if(_emailController.text.length > 0){
          setState(() {
            _buttonActive = true;
          });
        } else {
          setState(() {
            _buttonActive = false;
          });
        }
      break;
      case 20:
        if(_nameController.text.length > 0 && _nimController.text.length > 0 && _passController.text.length > 0){
          setState(() {
            _buttonActive = true;
          });
        } else {
          setState(() {
            _buttonActive = false;
          });
        }
      break;
    }
  }

  _checkEmail(){
    _firestore.collection('user').where('email', isEqualTo: _emailController.text).getDocuments().then((value){
      if(value.documents.isNotEmpty){
        setState(() {
          _isLoading = false;
          _readOnly = false;
        });
        Toast.show(
          'Email telah terdaftar!', 
          context, 
          duration: Toast.LENGTH_SHORT, 
          gravity:  Toast.BOTTOM,
          backgroundColor: Colors.black87,
          backgroundRadius: 8.0
        );
      } else {
        setState(() {
          _reverse = false;
          _position = 1;
          _isLoading = false;
          _readOnly = false;
          _buttonActive = false;
        });
      }
    });
  }

  _checkNim(){
    _firestore.collection('user').where('username', isEqualTo: _nimController.text).getDocuments().then((value){
      if(value.documents.isNotEmpty){
        String email;
        value.documents.forEach((f) {
          email = f.data['email'];
        });
        setState(() {
          _isLoading = false;
          _readOnly = false;
        });
        Toast.show(
          // 'NIM telah terdaftar pada Akun $email!',
          'NIM telah terdaftar!',
          context, 
          duration: Toast.LENGTH_SHORT, 
          gravity:  Toast.BOTTOM,
          backgroundColor: Colors.black87,
          backgroundRadius: 8.0
        );
      } else {
        _signUp();
      }
    });
  }

  _signUp() async {
    try {
      FirebaseUser user = (await _auth.createUserWithEmailAndPassword(email: _emailController.text, password: _passController.text)).user;
      assert(user != null);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      if (user.uid == currentUser.uid) {
        _saveUserToCloudFirestore();
      }
    } catch (e) {
      print('Error Login: $e');
      setState(() {
        _readOnly = false;
        _isLoading = false;
      });
    }
  }

  _saveUserToCloudFirestore() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await _firestore.collection('user').add({
      'username': _nimController.text,
      'email': _emailController.text,
      'pass': _passController.text,
      'role': 3,
      'setup': true,
      'delete': false,
    }).then((value) async {
      preferences.setString('id', value.documentID);
      preferences.setString('email', _emailController.text);
      preferences.setInt('role', 3);
      await _firestore.collection('user').document(value.documentID).collection('biodata').document('data').setData({
        'name': _nameController.text,
        'nim': _nimController.text,
        'email': _emailController.text,
        'biodata': false,
        'carrer': false,
        'competency': false,
        'achievement': false,
        'search': false,
      });
      if(mounted){
        preferences.setString('name', _nameController.text);
        preferences.setString('nim', _nimController.text);
        preferences.setBool('biodata', false);
        preferences.setBool('carrer', false);
        preferences.setBool('competency', false);
        preferences.setBool('achievement', false);
        preferences.setBool('search', false);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
      }
    });
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
      child: WillPopScope(
        child: Scaffold(
          body: PageTransitionSwitcher(
            reverse: _reverse,
            duration: Duration(milliseconds: 400),
            transitionBuilder: (
              Widget child,
              Animation<double> primaryAnimation,
              Animation<double> secondaryAnimation,
            ) {
              return SharedAxisTransition(
                animation: primaryAnimation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.horizontal,
                fillColor: Theme.of(context).backgroundColor,
                child: child,
              );
            },
            child: Container(
              key: ValueKey<int>(_position),
              color: Theme.of(context).backgroundColor,
              child: _position == 0 ? _emailInput() : _profileInput()
            ),
          ),
        ),
        onWillPop: _onBackPressed,
      ),
    );
  }

  Future<bool> _onBackPressed() {
    if (_canVibrate) {
      Vibrate.feedback(FeedbackType.warning);
    }
    return _position == 0 ? showDialog(
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
                  'Batal buat akun?',
                  style: TextStyle(
                    fontFamily: 'Google',
                    fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 7.0,),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                  child: Text(
                    'Semua informasi yang Anda masukkan sejauh ini akan dihapus.',
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
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SigninPage()));
                    }, 
                    child: Text(
                      'Batalkan',
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
                      'Tutup',
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
    ) : showDialog(
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
                  'Akun hampir selesai',
                  style: TextStyle(
                    fontFamily: 'Google',
                    fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 7.0,),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                  child: Text(
                    'Apakah Anda yakin ingin kembali?',
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
                      setState(() {
                        _reverse = true;
                        _position = 0;
                        _readOnly = false;
                        _isLoading = false;
                        _passVisible = false;
                        _nimController.text = '';
                        _nameController.text = '';
                        _passController.text = '';
                        if(_emailController.text.length > 0){
                          _buttonActive = true;
                        }
                      });
                    }, 
                    child: Text(
                      'Kembali',
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
    ) ?? false;
  }

  Widget _emailInput(){
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Theme.of(context).backgroundColor,
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0, left: 25.0, right: 25.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(height: MediaQuery.of(context).size.width * 0.2),
                    Icon(
                      Icons.person_pin,
                      size: MediaQuery.of(context).size.width * 0.2,
                    ),
                    SizedBox(height: 30.0,),
                    Text(
                      'TRACER STUDI UPN',
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.headline5.fontSize,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Noto'
                      ),
                    ),
                    SizedBox(height: 30.0,),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.grey[50],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextFormField(
                            controller: _emailController,
                            readOnly: _readOnly,
                            onChanged: (value){
                              _enableButton(10);
                            },
                            decoration: InputDecoration(
                              hintText: 'Email',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0, bottom: 12.0),
                              counter: Offstage(),
                            ),
                            style: Theme.of(context).textTheme.bodyText1,
                            keyboardType: TextInputType.emailAddress,
                            maxLength: 30,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 50.0,
                      child: FlatButton(
                        onPressed: _buttonActive && !_isLoading ? (){
                          setState(() {
                            _isLoading = true;
                            _readOnly = true;
                          });
                          FocusScope.of(context).requestFocus(new FocusNode());
                          _checkEmail();
                        } : (){

                        },
                        child: _isLoading ? SizedBox(
                          width: 25.0,
                          height: 25.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ) : Text(
                          'Selanjutnya',
                        ),
                        color: _buttonActive ? Theme.of(context).buttonColor : Theme.of(context).buttonColor.withAlpha(50),
                        textColor: _buttonActive ? Colors.white : Colors.white60,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0)
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.35),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Theme.of(context).backgroundColor,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Divider(height: 0.0,),
                    GestureDetector(
                      onTap: (){
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SigninPage()));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Sudah punya akun? ', 
                                style: TextStyle(
                                  fontSize: Theme.of(context).textTheme.caption.fontSize,
                                  color: Theme.of(context).textTheme.caption.color
                                )
                              ),
                              TextSpan(
                                text: 'Masuk', 
                                style: TextStyle(
                                  fontSize: Theme.of(context).textTheme.caption.fontSize,
                                  color: Theme.of(context).textTheme.bodyText1.color,
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            ]
                          )
                        ),
                      )
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileInput(){
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Theme.of(context).backgroundColor,
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0, left: 25.0, right: 25.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(height: MediaQuery.of(context).size.width * 0.2),
                    Icon(
                      Icons.person_pin,
                      size: MediaQuery.of(context).size.width * 0.2,
                    ),
                    SizedBox(height: 30.0,),
                    Text(
                      'TRACER STUDI UPN',
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.headline5.fontSize,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Noto'
                      ),
                    ),
                    SizedBox(height: 30.0,),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.grey[50],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextFormField(
                            controller: _nimController,
                            readOnly: _readOnly,
                            onChanged: (value){
                              _enableButton(20);
                            },
                            decoration: InputDecoration(
                              hintText: 'NIM',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0, bottom: 12.0),
                              counter: Offstage(),
                            ),
                            style: Theme.of(context).textTheme.bodyText1,
                            keyboardType: TextInputType.number,
                            maxLength: 30,
                          ),
                          Divider(height: 0.5,),
                          TextFormField(
                            controller: _nameController,
                            readOnly: _readOnly,
                            onChanged: (value){
                              _enableButton(20);
                            },
                            decoration: InputDecoration(
                              hintText: 'Nama Lengkap',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0, bottom: 12.0),
                              counter: Offstage(),
                            ),
                            style: Theme.of(context).textTheme.bodyText1,
                            keyboardType: TextInputType.text,
                            maxLength: 30,
                          ),
                          Divider(height: 0.5,),
                          Stack(
                            children: <Widget>[
                              TextFormField(
                                controller: _passController,
                                readOnly: _readOnly,
                                onChanged: (value){
                                  _enableButton(20);
                                },
                                obscureText: !_passVisible,
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  border: InputBorder.none,
                                  counter: Offstage(),
                                  contentPadding: EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0, bottom: 12.0),
                                ),
                                style: Theme.of(context).textTheme.bodyText1,
                                maxLength: 20,
                              ),
                              Positioned(
                                right: 0,
                                top: 5.0,
                                child: IconButton(
                                  icon: Icon(
                                    _passVisible ? Icons.visibility : Icons.visibility_off,
                                    color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.grey[700] : Colors.grey[400],
                                  ), 
                                  onPressed: () {
                                    setState(() {
                                      _passVisible = !_passVisible;
                                    });
                                  },
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 50.0,
                      child: FlatButton(
                        onPressed: _buttonActive && !_isLoading ? (){
                          setState(() {
                            _isLoading = true;
                            _readOnly = true;
                          });
                          FocusScope.of(context).requestFocus(new FocusNode());
                          _checkNim();
                        } : (){

                        },
                        child: _isLoading ? SizedBox(
                          width: 25.0,
                          height: 25.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ) : Text(
                          'Buat akun',
                        ),
                        color: _buttonActive ? Theme.of(context).buttonColor : Theme.of(context).buttonColor.withAlpha(50),
                        textColor: _buttonActive ? Colors.white : Colors.white60,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0)
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.35),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Theme.of(context).backgroundColor,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Divider(height: 0.0,),
                    GestureDetector(
                      onTap: (){
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SigninPage()));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Sudah punya akun? ', 
                                style: TextStyle(
                                  fontSize: Theme.of(context).textTheme.caption.fontSize,
                                  color: Theme.of(context).textTheme.caption.color
                                )
                              ),
                              TextSpan(
                                text: 'Masuk', 
                                style: TextStyle(
                                  fontSize: Theme.of(context).textTheme.caption.fontSize,
                                  color: Theme.of(context).textTheme.bodyText1.color,
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            ]
                          )
                        ),
                      )
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}