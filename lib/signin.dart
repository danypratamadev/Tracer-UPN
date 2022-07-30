import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:tracer_upn/alumni/home.dart' as alumnus;
import 'package:tracer_upn/fakultas/home.dart' as faculty;
import 'package:tracer_upn/jurusan/departement.dart';
import 'package:tracer_upn/jurusan/home.dart' as departement;
import 'package:tracer_upn/signup.dart';

class SigninPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SigninState();
  }

}

class SigninState extends State {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _passVisible = false, _readOnly = false, _buttonActive = false, _isLoading = false, _setup = false;
  String _id;
  int _role;

  @override
  void initState() {
    super.initState();
  }

  _enableButton(){
    if(_emailController.text.length > 0 && _passController.text.length > 0){
      setState(() {
        _buttonActive = true;
      });
    } else {
      setState(() {
        _buttonActive = false;
      });
    }
  }

  _checkEmail() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _firestore.collection('user').where('email', isEqualTo: _emailController.text).getDocuments().then((user){
      if(user.documents.isNotEmpty){
        user.documents.forEach((f) {
          if(f.data['pass'] == _passController.text){
            String _email = f.data['email'];
            preferences.setString('id', f.documentID);
            preferences.setString('email', f.data['email']);
            preferences.setInt('role', f.data['role']);
            setState(() {
              _role = f.data['role'];
              _setup = f.data['setup'];
              _id = f.documentID;
            });
            _firestore.collection('user').document(_id).collection('biodata').getDocuments().then((bio){
              if(bio.documents.isNotEmpty){
                bio.documents.forEach((f) {
                  preferences.setString('name', f.data['name']);
                  if(f.data['faculty'] != null){
                    preferences.setString('faculty', f.data['faculty']);
                  }
                  if(_role == 3){
                    preferences.setString('nim', f.data['nim']);
                    if(f.data['gender'] != null){
                      preferences.setString('gender', f.data['gender']);
                    }
                    if(f.data['phone'] != null){
                      preferences.setString('phone', f.data['phone']);
                    }
                    if(f.data['address'] != null){
                      preferences.setString('address', f.data['address']);
                    }
                    if(f.data['birthplace'] != null){
                      preferences.setString('birthplace', f.data['birthplace']);
                    }
                    if(f.data['birthdate'] != null){
                      Timestamp dateBirth = f.data['birthdate'];
                      preferences.setString('birthdate', '${dateBirth.toDate().day}/${dateBirth.toDate().month}/${dateBirth.toDate().year}');
                    }
                    if(f.data['birthdatetext'] != null){
                      preferences.setString('birthdatetext', f.data['birthdatetext']);
                    }
                    if(f.data['departement'] != null){
                      preferences.setString('departement', f.data['departement']);
                    }
                    if(f.data['level'] != null){
                      preferences.setString('level', f.data['level']);
                    }
                    if(f.data['entryyear'] != null){
                      preferences.setString('entryyear', f.data['entryyear']);
                    }
                    if(f.data['graduationyear'] != null){
                      preferences.setString('graduationyear', f.data['graduationyear']);
                    }
                    if(f.data['biodata'] != null){
                      preferences.setBool('biodata', f.data['biodata']);
                    }
                    if(f.data['carrer'] != null){
                      preferences.setBool('carrer', f.data['carrer']);
                    }
                    if(f.data['competency'] != null){
                      preferences.setBool('competency', f.data['competency']);
                    }
                    if(f.data['achievement'] != null){
                      preferences.setBool('achievement', f.data['achievement']);
                    }
                    if(f.data['search'] != null){
                      preferences.setBool('search', f.data['search']);
                    }
                  }
                  if(_role == 2){
                    _firestore.collection('user').document(_id).collection('access').getDocuments().then((departement){
                      if(departement.documents.isNotEmpty){
                        if(departement.documents.length > 1){
                          preferences.setBool('isChoose', true);
                        } else {
                          departement.documents.forEach((j) {
                            preferences.setString('departement', j.data['departement']);
                          });
                        }
                        if(_setup){
                          _signIn(_email, departement.documents.length);
                        } else {
                          _firstSignIn(_email, departement.documents.length);
                        }
                      }
                    });
                  } else {
                    if(_setup){
                      _signIn(_email, 0);
                    } else {
                      _firstSignIn(_email, 0);
                    }
                  }
                });
              }
            });
          } else {
            Toast.show(
              'Password salah!', 
              context, 
              duration: Toast.LENGTH_SHORT, 
              gravity:  Toast.BOTTOM,
              backgroundColor: Colors.black87,
              backgroundRadius: 8.0
            );
            setState(() {
              _readOnly = false;
              _isLoading = false;
            });
          }
        });
      } else {
        _firestore.collection('user').where('username', isEqualTo: _emailController.text).getDocuments().then((user){
          if(user.documents.isNotEmpty){
            user.documents.forEach((f) {
              if(f.data['pass'] == _passController.text){
                String _email = f.data['email'];
                preferences.setString('id', f.documentID);
                preferences.setString('email', f.data['email']);
                preferences.setInt('role', f.data['role']);
                setState(() {
                  _role = f.data['role'];
                  _setup = f.data['setup'];
                  _id = f.documentID;
                });
                _firestore.collection('user').document(_id).collection('biodata').getDocuments().then((bio){
                  if(bio.documents.isNotEmpty){
                    bio.documents.forEach((f) {
                      preferences.setString('name', f.data['name']);
                      if(f.data['faculty'] != null){
                        preferences.setString('faculty', f.data['faculty']);
                      }
                      if(_role == 3){
                        preferences.setString('nim', f.data['nim']);
                        if(f.data['gender'] != null){
                          preferences.setString('gender', f.data['gender']);
                        }
                        if(f.data['phone'] != null){
                          preferences.setString('phone', f.data['phone']);
                        }
                        if(f.data['address'] != null){
                          preferences.setString('address', f.data['address']);
                        }
                        if(f.data['birthplace'] != null){
                          preferences.setString('birthplace', f.data['birthplace']);
                        }
                        if(f.data['birthdate'] != null){
                          Timestamp dateBirth = f.data['birthdate'];
                          preferences.setString('birthdate', '${dateBirth.toDate().day}/${dateBirth.toDate().month}/${dateBirth.toDate().year}');
                        }
                        if(f.data['birthdatetext'] != null){
                          preferences.setString('birthdatetext', f.data['birthdatetext']);
                        }
                        if(f.data['departement'] != null){
                          preferences.setString('departement', f.data['departement']);
                        }
                        if(f.data['level'] != null){
                          preferences.setString('level', f.data['level']);
                        }
                        if(f.data['entryyear'] != null){
                          preferences.setString('entryyear', f.data['entryyear']);
                        }
                        if(f.data['graduationyear'] != null){
                          preferences.setString('graduationyear', f.data['graduationyear']);
                        }
                        if(f.data['biodata'] != null){
                          preferences.setBool('biodata', f.data['biodata']);
                        }
                        if(f.data['carrer'] != null){
                          preferences.setBool('carrer', f.data['carrer']);
                        }
                        if(f.data['competency'] != null){
                          preferences.setBool('competency', f.data['competency']);
                        }
                        if(f.data['achievement'] != null){
                          preferences.setBool('achievement', f.data['achievement']);
                        }
                        if(f.data['search'] != null){
                          preferences.setBool('search', f.data['search']);
                        }
                      }
                      if(_role == 2){
                        _firestore.collection('user').document(_id).collection('access').getDocuments().then((departement){
                          if(departement.documents.isNotEmpty){
                            if(departement.documents.length > 1){
                              preferences.setBool('isChoose', true);
                            } else {
                              departement.documents.forEach((j) {
                                preferences.setString('departement', j.data['departement']);
                              });
                            }
                            if(_setup){
                              _signIn(_email, departement.documents.length);
                            } else {
                              _firstSignIn(_email, departement.documents.length);
                            }
                          }
                        });
                      } else {
                        if(_setup){
                          _signIn(_email, 0);
                        } else {
                          _firstSignIn(_email, 0);
                        }
                      }
                    });
                  }
                });
              } else {
                Toast.show(
                  'Password Anda salah!', 
                  context, 
                  duration: Toast.LENGTH_SHORT, 
                  gravity:  Toast.BOTTOM,
                  backgroundColor: Colors.black87,
                  backgroundRadius: 8.0
                );
                setState(() {
                  _readOnly = false;
                  _isLoading = false;
                });
              }
            });
          } else {
            Toast.show(
              'Email atau Username tidak terdaftar!', 
              context, 
              duration: Toast.LENGTH_SHORT, 
              gravity:  Toast.BOTTOM,
              backgroundColor: Colors.black87,
              backgroundRadius: 8.0
            );
            setState(() {
              _readOnly = false;
              _isLoading = false;
            });
          }
        });
      }
    });
  }

  _firstSignIn(String email, int depertement) async {
    try {
      FirebaseUser user = (await _auth.createUserWithEmailAndPassword(email: email, password: _passController.text)).user;
      assert(user != null);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      if (user.uid == currentUser.uid) {
        await _firestore.collection('user').document(_id).updateData({
          'setup': true,
        }).then((value) async {
          if(_role == 3){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => alumnus.HomePage()));
          } else if(_role == 2){
            if(depertement > 1){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DepartementPage()));
            } else {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => departement.HomePage()));
            }
          } else if(_role == 1){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => faculty.HomePage()));
          }
        });
      }
    } catch (e) {
      print('Error Login: $e');
      setState(() {
        _readOnly = false;
        _isLoading = false;
      });
    }
  }

  _signIn(String email, int depertement) async {
    try {
      FirebaseUser user = (await _auth.signInWithEmailAndPassword(email: email, password: _passController.text)).user;
      assert(user != null);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      if (user.uid == currentUser.uid) {
        if(_role == 3){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => alumnus.HomePage()));
        } else if(_role == 2){
          if(depertement > 1){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DepartementPage()));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => departement.HomePage()));
          }
        } else if(_role == 1){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => faculty.HomePage()));
        }
      }
    } catch (e){
      print('Error Login: $e');
      setState(() {
        _readOnly = false;
        _isLoading = false;
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
        body: GestureDetector(
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
                        Image.asset(
                          'assets/images/icon_trans.png',
                          width: MediaQuery.of(context).size.width * 0.4,
                        ),
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
                                  _enableButton();
                                },
                                decoration: InputDecoration(
                                  hintText: 'Email atau Username',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0, bottom: 12.0),
                                  counter: Offstage(),
                                ),
                                style: Theme.of(context).textTheme.bodyText1,
                                keyboardType: TextInputType.emailAddress,
                                maxLength: 30,
                              ),
                              Divider(height: 0.5,),
                              Stack(
                                children: <Widget>[
                                  TextFormField(
                                    controller: _passController,
                                    readOnly: _readOnly,
                                    onChanged: (value){
                                      _enableButton();
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
                              'Masuk',
                            ),
                            color: _buttonActive ? Theme.of(context).buttonColor : Theme.of(context).buttonColor.withAlpha(50),
                            textColor: _buttonActive ? Colors.white : Colors.white60,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Lupa detail informasi masuk Anda? ', 
                                style: TextStyle(
                                  fontSize: Theme.of(context).textTheme.caption.fontSize,
                                  color: Theme.of(context).textTheme.caption.color
                                )
                              ),
                              TextSpan(
                                text: 'Dapatkan bantuan', 
                                style: TextStyle(
                                  fontSize: Theme.of(context).textTheme.caption.fontSize,
                                  color: Theme.of(context).textTheme.bodyText1.color,
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            ]
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.width * 0.35,
                        ),
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
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignupPage()));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Tidak punya akun? ', 
                                    style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.caption.fontSize,
                                      color: Theme.of(context).textTheme.caption.color
                                    )
                                  ),
                                  TextSpan(
                                    text: 'Buat akun', 
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
        )
      ),
    );
  }

}