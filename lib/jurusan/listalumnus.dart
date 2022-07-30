import 'dart:async';
import 'package:circular_check_box/circular_check_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracer_upn/jurusan/profile.dart';
import 'package:tracer_upn/jurusan/addalumnus.dart';

class ListalumnusPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ListalumnusState();
  }

}

class User{
  final String id, initial, email, username, pass, name, nim, gender, phone, address, birthplace, birthdatetext, departement, entryyear, graduationyear, faculty, level;
  final DateTime birthdate;
  bool selected;

  User(this.id, this.initial, this.email, this.username, this.pass, this.name, this.nim, this.gender, this.phone, this.address, this.birthplace, this.birthdate, this.birthdatetext, this.departement, this.entryyear, this.graduationyear, this.faculty, this.level, this.selected);

}

class ListalumnusState extends State {

  var _scaffoldkey = GlobalKey <ScaffoldState> ();
  final Firestore _firestore = Firestore.instance;
  List<User> _listUser = new List<User>();
  bool _isEmpty = false, _isSelected = false;
  int _isSelectedCount = 0;
  String _id_departement, _name_departement;

  @override
  void initState() {
    _getDataSharedPref();
    super.initState();
  }

  _getDataSharedPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id_departement = preferences.getString('departement');
    String name_departement = preferences.getString('departementName');
    setState(() {
      _id_departement = id_departement;
      _name_departement = name_departement;
    });
    _getUserFromCloudFirestore();
  }

  _getUserFromCloudFirestore() {
    _firestore.collection('user').where('role', isEqualTo: 3).getDocuments().then((user){
      if(user.documents.isNotEmpty){
        int i = 0;
        _listUser.clear();
        user.documents.forEach((f) {
          _firestore.collection('user').document(f.documentID).collection('biodata').document('data').get().then((value){
            if(value.exists){
              if(value.data['departement'] == _id_departement && !f.data['delete']){
                String initial;
                List splitName = value.data['name'].split(' ');
                if(splitName.length > 1){
                  initial = '${splitName[0].toString().substring(0, 1)}${splitName[1].toString().substring(0, 1)}';
                } else {
                  initial = splitName[0].toString().substring(0, 1);
                }
                Timestamp dateBirth = value.data['birthdate'];
                User user = new User(f.documentID, initial, f.data['email'], f.data['username'], f.data['pass'], value.data['name'], value.data['nim'], value.data['gender'], value.data['phone'], value.data['address'], value.data['birthplace'], dateBirth.toDate(), value.data['birthdatetext'], value.data['departement'], value.data['entryyear'], value.data['graduationyear'], value.data['faculty'], value.data['level'], false);
                setState(() {
                  _listUser.add(user);
                });
              } else {
                if(i == user.documents.length){
                  if(_listUser.length == 0){
                    setState(() {
                      _isEmpty = true;
                    });
                  }
                }
              }
            }
          });
          i++;
        });
      } else {
        setState(() {
          _isEmpty = true;
        });
      }
    });
    
  }

  _deleteAlumnus() {
    for(int i = 0; i < _listUser.length; i++){
      if(_listUser[i].selected){
        _firestore.collection('user').document(_listUser[i].id).updateData({
          'delete': true,
        });
      }
      if(i == _listUser.length - 1){
        Timer(Duration(seconds: 2), (){
          Navigator.pop(context);
          _getUserFromCloudFirestore();
          setState(() {
            _isSelected = false;
            _isSelectedCount = 0;
          });
          _showSnackBar('Berhasil menghapus alumni.', Icons.verified_user, Colors.green[600]);
        });
      }
    }
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
                  'Hapus Alumni',
                  style: TextStyle(
                    fontFamily: 'Google',
                    fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 5.0,),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Text(
                    'Apakah Anda yakin ingin menghapus Alumni dari Tracer Studi UPN?',
                    style: TextStyle(
                      fontFamily: 'Sans-Pro',
                      fontSize: Theme.of(context).textTheme.bodyText2.fontSize,
                    ),
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
                      _deleteAlumnus();
                    }, 
                    child: Text(
                      'Hapus',
                    ),
                    textColor: Colors.red[700],
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
                width: 16.0,
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text(
                  'Menghapus alumni...',
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

  _showSnackBar(String message, IconData icon, Color colors){
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            icon,
            color: colors,
          ),
          SizedBox(
            width: 16.0,
          ),
          Text(
            message
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0)
      ),
      duration: Duration(seconds: 1),
    );
    _scaffoldkey.currentState.showSnackBar(snackBar);
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
          key: _scaffoldkey,
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 0.7,
                )
              ),
              child: Row(
                children: <Widget>[
                  ClipOval(
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back
                        ),
                        onPressed: (){
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0,),
                  Flexible(
                    fit: FlexFit.tight,
                    child: GestureDetector(
                      onTap: (){

                      },
                      child: Text(
                        _isSelected ? '$_isSelectedCount' : 'Kelola Alumni',
                      ),
                    )
                  ),
                  SizedBox(width: 8.0,),
                  if(_isSelected)
                  ClipOval(
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red[400],
                        ),
                        onPressed: (){
                          _showAlertDialog();
                        },
                      ),
                    ),
                  )
                  else
                  ClipOval(
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: Icon(
                          Icons.search
                        ),
                        onPressed: (){

                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            elevation: 0.0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.blueGrey.withAlpha(30),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.group_add,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0,),
                        Text(
                          'Jurusan $_name_departement',
                          style: TextStyle(
                            fontFamily: 'Google',
                            fontSize: Theme.of(context).textTheme.headline6.fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          'Melihat Data Alumni atau Daftarkan Alumni Baru pada Jurusan $_name_departement.',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'DAFTAR ALUMNI',
                        style: TextStyle(
                          fontFamily: 'Google',
                          fontWeight: FontWeight.bold,
                          fontSize: Theme.of(context).textTheme.caption.fontSize,
                          color: Theme.of(context).textTheme.caption.color,
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(8.0),
                        onTap: () async {
                          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddalumnusPage(action: 10,)));
                          if(result != null){
                            if(result){
                              _listUser.clear();
                              _getUserFromCloudFirestore();
                            }
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'Tambah Alumni',
                                style: TextStyle(
                                  fontFamily: 'Google',
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                              SizedBox(width: 5.0,),
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).accentColor,
                                  shape: BoxShape.circle
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 18.0,
                                  color: Colors.white
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if(_listUser.length > 0)
                ListView.builder(
                  itemCount: _listUser.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, i){
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Material(
                          color: _listUser[i].selected ? Theme.of(context).dividerColor.withAlpha(10) : Theme.of(context).backgroundColor,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15.0),
                            onTap: () async {
                              if(_isSelected){
                                if(_listUser[i].selected){
                                  setState(() {
                                    _listUser[i].selected = false;
                                    _isSelectedCount--;
                                    if(_isSelectedCount == 0){
                                      _isSelected = false;
                                    }
                                  });
                                } else {
                                  setState(() {
                                    _listUser[i].selected = true;
                                    _isSelectedCount++;
                                  });
                                }
                              } else {
                                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(id: _listUser[i].id, initial: _listUser[i].initial, email: _listUser[i].email, username: _listUser[i].username, pass: _listUser[i].pass, name: _listUser[i].name, nim: _listUser[i].nim, gender: _listUser[i].gender, phone: _listUser[i].phone, address: _listUser[i].address, birthplace: _listUser[i].birthplace, birthdate: _listUser[i].birthdate, birthdatetext: _listUser[i].birthdatetext,  departement: _listUser[i].departement, entryyear: _listUser[i].entryyear, graduationyear: _listUser[i].graduationyear, faculty: _listUser[i].faculty, level: _listUser[i].level,)));
                                if(result != null){
                                  if(result){
                                    _listUser.clear();
                                    _getUserFromCloudFirestore();
                                  }
                                }
                              }
                            },
                            onLongPress: (){
                              if(_isSelected){
                                if(_listUser[i].selected){
                                  setState(() {
                                    _listUser[i].selected = false;
                                    _isSelectedCount--;
                                    if(_isSelectedCount == 0){
                                      _isSelected = false;
                                    }
                                  });
                                } else {
                                  setState(() {
                                    _listUser[i].selected = true;
                                    _isSelectedCount++;
                                  });
                                }
                              } else {
                                setState(() {
                                  _isSelected = true;
                                  _listUser[i].selected = true;
                                  _isSelectedCount++;
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 20.0),
                              child: Row(
                                children: <Widget>[
                                  if(_isSelected)
                                  CircularCheckBox(
                                    value: _listUser[i].selected, 
                                    onChanged: (value){
                                      if(_isSelected){
                                        if(_listUser[i].selected){
                                          setState(() {
                                            _listUser[i].selected = value;
                                            _isSelectedCount--;
                                            if(_isSelectedCount == 0){
                                              _isSelected = false;
                                            }
                                          });
                                        } else {
                                          setState(() {
                                            _listUser[i].selected = value;
                                            _isSelectedCount++;
                                          });
                                        }
                                      }
                                    }
                                  )
                                  else
                                  ClipOval(
                                    child: Container(
                                      width: 35.0,
                                      height: 35.0,
                                      color: Theme.of(context).accentColor,
                                      child: Center(
                                        child: Text(
                                          _listUser[i].initial.toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Google',
                                            fontWeight: FontWeight.bold
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    ),
                                  ),
                                  SizedBox(width: 24.0,),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.65,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          _listUser[i].name,
                                          style: TextStyle(
                                            fontFamily: 'Noto',
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 3.0,),
                                        Text(
                                          _listUser[i].nim,
                                          style: TextStyle(
                                            fontSize: Theme.of(context).textTheme.caption.fontSize,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.keyboard_arrow_right,
                                    color: Colors.black26,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Divider(
                          height: 0.5,
                        )
                      ],
                    );
                  }
                )
                else if(_isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 50.0, bottom: 10.0),
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(height: 50.0,),
                        Icon(
                          Icons.person,
                          color: Theme.of(context).dividerColor,
                          size: MediaQuery.of(context).size.width * 0.15,
                        ),
                        SizedBox(height: 16.0,),
                        Text(
                          'Alumni Belum Tersedia.',
                          style: TextStyle(
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                else
                Padding(
                  padding: const EdgeInsets.only(top: 150.0, bottom: 10.0),
                  child: SizedBox(
                    width: 40.0,
                    height: 40.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.0,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15,
                )
              ],
            ),
          ),
        ),
        onWillPop: _isSelected ? (){
          setState(() {
            _isSelected = false;
            _isSelectedCount = 0;
            for(int i = 0; i < _listUser.length; i++){
              setState(() {
                _listUser[i].selected = false;
              });
            }
          });
        } : null,
      ), 
    );
  }

}