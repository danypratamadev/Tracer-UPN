import 'dart:async';
import 'package:circular_check_box/circular_check_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiodataPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BiodataState();
  }

}

class Departement{
  final String id_departement, id_level, level, name, faculty;
  bool check;

  Departement(this.id_departement, this.id_level, this.level, this.name, this.faculty, this.check);
}

class Temp {
  final String id, name, faculty;

  Temp(this.id, this.name, this.faculty);
}

class BiodataState extends State {

  var _scaffoldkey = GlobalKey <ScaffoldState> ();
  final Firestore _firestore = Firestore.instance;
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _genderController = TextEditingController();
  final _nimController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthplaceController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _departementController = TextEditingController();
  final _entryyearController = TextEditingController();
  final _graduationyearController = TextEditingController();
  final List _listGender = ['Laki-Laki', 'Perempuan'];
  String _id, _id_level, _id_departement, _id_faculty, _gender;
  bool _readOnly = true, _buttonActive = false, _canVibrate = false, _biodata = false, _allowBack = false, _buttonVisible = false;
  double _rightPosFA = 16.0, _bottomPosBtn = -200;
  DateTime _birthdate = DateTime.now();
  List<Departement> _listDepartement = new List<Departement>();

  @override
  void initState() {
    _getDepartementFromCloudFirestor();
    _checkDeviceVibrate();
    _birthdateController.addListener(() {
      _enableButton();
    });
    super.initState();
  }

  _checkDeviceVibrate() async {
    bool canVibrate = await Vibrate.canVibrate;
    setState(() {
      _canVibrate = canVibrate;
    });
  }

  _enableButton() {
    if(_nameController.text.length > 0 && _genderController.text.length > 0 && _phoneController.text.length > 0 && _addressController.text.length > 0 && _birthplaceController.text.length > 0 && _birthdateController.text.length > 0 && _departementController.text.length > 0 && _entryyearController.text.length > 0 && _graduationyearController.text.length > 0){
      setState(() {
        _buttonActive = true;
      });
    } else {
      setState(() {
        _buttonActive = false;
      });
    }
  }

  _getBiodata() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool bio = preferences.getBool('biodata');
    String id = preferences.getString('id');
    String email = preferences.getString('email');
    String name = preferences.getString('name');
    String nim = preferences.getString('nim');
    String gender = preferences.getString('gender');
    String phone = preferences.getString('phone');
    String address = preferences.getString('address');
    String birthplace = preferences.getString('birthplace');
    String birthdate = preferences.getString('birthdate');
    String birthdatetext = preferences.getString('birthdatetext');
    String departement = preferences.getString('departement');
    String level = preferences.getString('level');
    String entryyear = preferences.getString('entryyear');
    String graduationyear = preferences.getString('graduationyear');
    setState(() {
      _biodata = bio;
      if(!_biodata && !_allowBack){
        _readOnly = false;
        _rightPosFA = -200.0;
        _bottomPosBtn = 0.0;
      }
      _id = id;
      _emailController.text = email;
      _nameController.text = name;
      _nimController.text = nim;
      if(gender != null){
        _gender = gender;
        _genderController.text = gender;
      } else {
        _genderController.text = '';
      }
      if(phone != null){
        _phoneController.text = phone;
      } else {
        _phoneController.text = '';
      }
      if(address != null){
        _addressController.text = address;
      } else {
        _addressController.text = '';
      }
      if(birthplace != null){
        _birthplaceController.text = birthplace;
      } else {
        _birthplaceController.text = '';
      }
      if(birthdate != null){
        _birthdate = DateFormat('dd/MM/yyyy').parse(birthdate);
      }
      if(birthdatetext != null){
        _birthdateController.text = birthdatetext;
      } else {
        _birthdateController.text = '';
      }
      if(departement != null && _listDepartement.length > 0){
        for(int i = 0; i < _listDepartement.length; i++){
          if(_listDepartement[i].id_departement == departement && _listDepartement[i].id_level == level){
            _id_departement = _listDepartement[i].id_departement;
            _id_faculty = _listDepartement[i].faculty;
            _id_level = _listDepartement[i].level;
            _listDepartement[i].check = true;
            _departementController.text = '${_listDepartement[i].level} ${_listDepartement[i].name}';
          } else {
            _listDepartement[i].check = false;
          }
        }
      } else {
        for(int i = 0; i < _listDepartement.length; i++){
          setState(() {
            _listDepartement[i].check = false;
          });
        }
        _departementController.text = '';
      }
      if(entryyear != null){
        _entryyearController.text = entryyear;
      } else {
        _entryyearController.text = '';
      }
      if(graduationyear != null){
        _graduationyearController.text = graduationyear;
      } else {
        _graduationyearController.text = '';
      }
    });
  }

  _getDepartementFromCloudFirestor() async {
    List<Temp> listTemp = new List<Temp>();
    await _firestore.collection('departement').getDocuments().then((value){
      if(value.documents.isNotEmpty){
        value.documents.forEach((f) async {
          Temp temp = new Temp(f.documentID, f.data['name'], f.data['faculty']);
          listTemp.add(temp);
        });
      }
    });
    if(mounted){
      _getLevelDepartementFromCloudFirestore(listTemp);
    }
  }

  _getLevelDepartementFromCloudFirestore(List<Temp> listTemp) async {
    for(int i = 0; i < listTemp.length; i++){
      await _firestore.collection('departement').document(listTemp[i].id).collection('level').getDocuments().then((value){
        if(value.documents.isNotEmpty){
          value.documents.forEach((f) {
            _firestore.collection('level').document(f.data['id_level']).get().then((values){
              if(values.exists){
                Departement departement = new Departement(listTemp[i].id, f.documentID, values.data['name'], f.data['name'], listTemp[i].faculty, false);
                _listDepartement.add(departement);
              }
            });
          });
        }
      }).then((value){
        if(i == listTemp.length - 1){
          setState(() {
            _buttonVisible = true;
          });
          _getBiodata();
        }
      });
    }
  }

  _saveBiodataToCloudFirestore() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await _firestore.collection('user').document(_id).collection('biodata').document('data').setData({
      'nim': _nimController.text,
      'name': _nameController.text,
      'email': _emailController.text,
      'gender': _gender,
      'phone': _phoneController.text,
      'address': _addressController.text,
      'birthplace': _birthplaceController.text,
      'birthdate': _birthdate,
      'birthdatetext': _birthdateController.text,
      'departement': _id_departement,
      'faculty': _id_faculty,
      'level': _id_level,
      'entryyear': _entryyearController.text,
      'graduationyear': _graduationyearController.text,
      'biodata': true,
    }, merge: true);
    if(mounted){
      Navigator.pop(context);
      preferences.setString('nim', _nimController.text);
      preferences.setString('name', _nameController.text);
      preferences.setString('email', _emailController.text);
      preferences.setString('gender', _gender);
      preferences.setString('phone', _phoneController.text);
      preferences.setString('address', _addressController.text);
      preferences.setString('birthplace', _birthplaceController.text);
      preferences.setString('birthdate', '${_birthdate.day}/${_birthdate.month}/${_birthdate.year}');
      preferences.setString('birthdatetext', _birthdateController.text);
      preferences.setString('departement', _id_departement);
      preferences.setString('faculty', _id_faculty);
      preferences.setString('level', _id_level);
      preferences.setString('entryyear', _entryyearController.text);
      preferences.setString('graduationyear', _graduationyearController.text);
      preferences.setBool('biodata', true);
      setState(() {
        _readOnly = true;
        _rightPosFA = 16.0;
        _bottomPosBtn = -200;
      });
      _getBiodata();
      _showSnackBar('Biodata berhasil disimpan.', Icons.verified_user, Colors.green[600]);
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
                width: 16.0,
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text(
                  "Menyimpan biodata...",
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

  String _getMonth(int number) {
    String month;
    switch(number){
      case 1:
        month = 'Januari';
      break;
      case 2:
        month = 'Februari';
      break;
      case 3:
        month = 'Maret';
      break;
      case 4:
        month = 'April';
      break;
      case 5:
        month = 'Mei';
      break;
      case 6:
        month = 'Juni';
      break;
      case 7:
        month = 'Juli';
      break;
      case 8:
        month = 'Agustus';
      break;
      case 9:
        month = 'September';
      break;
      case 10:
        month = 'Oktober';
      break;
      case 11:
        month = 'November';
      break;
      case 12:
        month = 'Desember';
      break;
    }
    return month;
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
          appBar: AppBar(
            title: Text(
              'Biodata Saya'
            ),
            elevation: 0.0,
          ),
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
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.red.withAlpha(30),
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
                                      Icons.person_pin,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16.0,),
                                Text(
                                  'Data Diri',
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
                                  'Data Diri Lulusan/Alumni',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 32.0,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'DATA UMUM',
                                style: TextStyle(
                                  fontFamily: 'Google',
                                  fontWeight: FontWeight.bold,
                                  fontSize: Theme.of(context).textTheme.caption.fontSize,
                                  color: Theme.of(context).textTheme.caption.color,
                                ),
                              ),
                              AnimatedOpacity(
                                duration: Duration(milliseconds: 500),
                                opacity: _readOnly ? 0.0 : 1.0,
                                curve: Curves.fastOutSlowIn,
                                child: Text(
                                  'Mode Edit Aktif',
                                  style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.caption.fontSize,
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                              ),
                              if(_listDepartement.length == 0)
                              CupertinoActivityIndicator(),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
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
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            'Nim',
                                          ),
                                          Icon(
                                            LineIcons.lock,
                                            size: 18.0,
                                            color: _readOnly ? Theme.of(context).disabledColor : Theme.of(context).accentColor,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10.0,),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: TextFormField(
                                          controller: _nimController,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            hintText: 'Nim',
                                            border: InputBorder.none,
                                            filled: true,
                                            fillColor: _readOnly ? null : Theme.of(context).disabledColor.withAlpha(5),
                                          ),
                                          style: _readOnly ? Theme.of(context).textTheme.bodyText1 : TextStyle(
                                            fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
                                            color: Theme.of(context).disabledColor,
                                          ),
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(height: 0.5,),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Nama Lengkap',
                                      ),
                                      SizedBox(height: 10.0,),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: TextFormField(
                                          controller: _nameController,
                                          readOnly: _readOnly,
                                          onChanged: (value){
                                            _enableButton();
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Masukkan Nama Lengkap',
                                            border: InputBorder.none,
                                            filled: true,
                                          ),
                                          style: Theme.of(context).textTheme.bodyText1,
                                          keyboardType: TextInputType.text,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(height: 0.5,),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Jenis Kelamin',
                                      ),
                                      SizedBox(height: 10.0,),
                                      if(_readOnly)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: TextFormField(
                                          controller: _genderController,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.only(left: 12.0, top: 15.0),
                                            hintText: 'Pilih salah satu',
                                            border: InputBorder.none,
                                            filled: true,
                                            suffixIcon: Icon(
                                              Icons.keyboard_arrow_down,
                                            ),
                                          ),
                                          style: Theme.of(context).textTheme.bodyText1,
                                          keyboardType: TextInputType.number,
                                        ),
                                      )
                                      else
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: DropdownButtonFormField(
                                          isExpanded: true,
                                          value: _gender,
                                          icon: Icon(
                                            Icons.keyboard_arrow_down,
                                          ),
                                          items: _listGender.map((gender) {
                                            return DropdownMenuItem(
                                              value: gender,
                                              child: Text(
                                                gender,
                                                style: Theme.of(context).textTheme.bodyText1,
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              _gender = value;
                                              _genderController.text = value;
                                            });
                                            _enableButton();
                                          },
                                          onTap: (){
                                            FocusScope.of(context).requestFocus(new FocusNode());
                                          },
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.fromLTRB(12.0, 5.0, 10.0, 5.0),
                                            hintText: 'Pilih salah satu',
                                            hintStyle: Theme.of(context).textTheme.bodyText1,
                                            filled: true,
                                            border: InputBorder.none,
                                          ),
                                          style: Theme.of(context).textTheme.bodyText1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(height: 0.5,),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            'Email',
                                          ),
                                          Icon(
                                            LineIcons.lock,
                                            size: 18.0,
                                            color: _readOnly ? Theme.of(context).disabledColor : Theme.of(context).accentColor,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10.0,),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: TextFormField(
                                          controller: _emailController,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            hintText: 'Email',
                                            border: InputBorder.none,
                                            filled: true,
                                            fillColor: _readOnly ? null : Theme.of(context).disabledColor.withAlpha(5),
                                          ),
                                          style: _readOnly ? Theme.of(context).textTheme.bodyText1 : TextStyle(
                                            fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
                                            color: Theme.of(context).disabledColor,
                                          ),
                                          keyboardType: TextInputType.emailAddress,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(height: 0.5,),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Nomor Telepon',
                                      ),
                                      SizedBox(height: 10.0,),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: TextFormField(
                                          controller: _phoneController,
                                          readOnly: _readOnly,
                                          onChanged: (value){
                                            _enableButton();
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Masukkan Nomor Telepon',
                                            border: InputBorder.none,
                                            filled: true
                                          ),
                                          style: Theme.of(context).textTheme.bodyText1,
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(height: 0.5,),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Alamat',
                                      ),
                                      SizedBox(height: 10.0,),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: TextFormField(
                                          controller: _addressController,
                                          readOnly: _readOnly,
                                          onChanged: (value){
                                            _enableButton();
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Masukkan Alamat',
                                            border: InputBorder.none,
                                            filled: true,
                                          ),
                                          style: Theme.of(context).textTheme.bodyText1,
                                          keyboardType: TextInputType.text,
                                          maxLines: null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 32.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'DATA KELAHIRAN',
                                style: TextStyle(
                                  fontFamily: 'Google',
                                  fontWeight: FontWeight.bold,
                                  fontSize: Theme.of(context).textTheme.caption.fontSize,
                                  color: Theme.of(context).textTheme.caption.color,
                                ),
                              ),
                              AnimatedOpacity(
                                duration: Duration(milliseconds: 500),
                                opacity: _readOnly ? 0.0 : 1.0,
                                curve: Curves.fastOutSlowIn,
                                child: Text(
                                  'Mode Edit Aktif',
                                  style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.caption.fontSize,
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
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
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Tempat Lahir',
                                      ),
                                      SizedBox(height: 10.0,),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: TextFormField(
                                          controller: _birthplaceController,
                                          readOnly: _readOnly,
                                          onChanged: (value){
                                            _enableButton();
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Masukkan Tempat Lahir',
                                            border: InputBorder.none,
                                            filled: true,
                                          ),
                                          style: Theme.of(context).textTheme.bodyText1,
                                          keyboardType: TextInputType.text,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(height: 0.5,),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Tanggal Lahir',
                                      ),
                                      SizedBox(height: 10.0,),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: TextFormField(
                                          controller: _birthdateController,
                                          readOnly: true,
                                          onChanged: (value){
                                            _enableButton();
                                          },
                                          onTap: _readOnly ? (){} : (){
                                            FocusScope.of(context).requestFocus(new FocusNode());
                                            DatePicker.showDatePicker(context,
                                              showTitleActions: true,
                                              minTime: DateTime(1990, 1, 1),
                                              maxTime: DateTime.now(), 
                                              currentTime: _birthdate, 
                                              locale: LocaleType.id,
                                              onChanged: (date) {
                                                print('change $date');
                                              }, 
                                              onConfirm: (date) {
                                                setState(() {
                                                  _birthdate = date;
                                                  _birthdateController.text = '${date.day} ${_getMonth(date.month)} ${date.year}';
                                                });
                                              }, 
                                            );
                                          },
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.only(left: 12.0, top: 15.0),
                                            hintText: 'Pilih Tanggal Lahir',
                                            border: InputBorder.none,
                                            suffixIcon: Icon(
                                              LineIcons.calendar,
                                            ),
                                            filled: true,
                                          ),
                                          style: Theme.of(context).textTheme.bodyText1,
                                          keyboardType: TextInputType.text,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 32.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'DATA AKADEMIK',
                                style: TextStyle(
                                  fontFamily: 'Google',
                                  fontWeight: FontWeight.bold,
                                  fontSize: Theme.of(context).textTheme.caption.fontSize,
                                  color: Theme.of(context).textTheme.caption.color,
                                ),
                              ),
                              AnimatedOpacity(
                                duration: Duration(milliseconds: 500),
                                opacity: _readOnly ? 0.0 : 1.0,
                                curve: Curves.fastOutSlowIn,
                                child: Text(
                                  'Mode Edit Aktif',
                                  style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.caption.fontSize,
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
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
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Jurusan',
                                      ),
                                      SizedBox(height: 10.0,),
                                      // if(_readOnly)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: TextFormField(
                                          controller: _departementController,
                                          readOnly: true,
                                          onChanged: (value){
                                            _enableButton();
                                          },
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.only(left: 12.0, top: 15.0),
                                            hintText: 'Pilih Jurusan',
                                            border: InputBorder.none,
                                            filled: true,
                                            suffixIcon: Icon(
                                              Icons.compare_arrows,
                                            ),
                                          ),
                                          onTap: _readOnly ? (){} : (){
                                            _showDepartementDialog();
                                          },
                                          style: Theme.of(context).textTheme.bodyText1,
                                          keyboardType: TextInputType.number,
                                        ),
                                      )
                                      // else
                                      // ClipRRect(
                                      //   borderRadius: BorderRadius.circular(8.0),
                                      //   child: DropdownButtonFormField(
                                      //     isExpanded: true,
                                      //     value: '',
                                      //     icon: Icon(
                                      //       Icons.keyboard_arrow_down,
                                      //     ),
                                      //     items: _listDepartement.map((departemen) {
                                      //       return DropdownMenuItem(
                                      //         value: departemen.id_departement,
                                      //         child: Text(
                                      //           '${departemen.name}',
                                      //           style: Theme.of(context).textTheme.bodyText1,
                                      //         ),
                                      //       );
                                      //     }).toList(),
                                      //     onChanged: (value) {
                                      //       setState(() {
                                      //         for(int i = 0; i < _listDepartement.length; i++){
                                      //           if(_listDepartement[i].id_level == value){
                                      //             _id_departement = _listDepartement[i].id_departement;
                                      //             _id_faculty = _listDepartement[i].faculty;
                                      //             _id_level = _listDepartement[i].id_level;
                                      //             _departementController.text = '${_listDepartement[i].level} ${_listDepartement[i].name}';
                                      //           }
                                      //         }
                                      //       });
                                      //       _enableButton();
                                      //     },
                                      //     onTap: (){
                                      //       FocusScope.of(context).requestFocus(new FocusNode());
                                      //     },
                                      //     decoration: InputDecoration(
                                      //       contentPadding: EdgeInsets.fromLTRB(12.0, 5.0, 10.0, 5.0),
                                      //       hintText: 'Pilih salah satu',
                                      //       hintStyle: Theme.of(context).textTheme.bodyText1,
                                      //       filled: true,
                                      //       border: InputBorder.none,
                                      //     ),
                                      //     style: Theme.of(context).textTheme.bodyText1,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                                Divider(height: 0.5,),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Tahun Masuk',
                                      ),
                                      SizedBox(height: 10.0,),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: TextFormField(
                                          controller: _entryyearController,
                                          readOnly: _readOnly,
                                          onChanged: (value){
                                            _enableButton();
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Masukkan Tahun Masuk Kuliah',
                                            border: InputBorder.none,
                                            filled: true,
                                          ),
                                          style: Theme.of(context).textTheme.bodyText1,
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(height: 0.5,),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Tahun Keluar',
                                      ),
                                      SizedBox(height: 10.0,),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: TextFormField(
                                          controller: _graduationyearController,
                                          readOnly: _readOnly,
                                          onChanged: (value){
                                            _enableButton();
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Masukkan Tahun Keluar Kuliah',
                                            border: InputBorder.none,
                                            filled: true,
                                          ),
                                          style: Theme.of(context).textTheme.bodyText1,
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.15,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if(_buttonVisible)
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 400),
                    curve: Curves.fastOutSlowIn,
                    right: _rightPosFA,
                    bottom: 16.0,
                    child: FloatingActionButton.extended(
                      backgroundColor: Colors.red,
                      onPressed: (){
                        setState(() {
                          _readOnly = false;
                          _rightPosFA = -200.0;
                          _bottomPosBtn = 0.0;
                        });
                      },
                      icon: Icon(
                        Icons.edit
                      ),
                      label: Text(
                        'Edit Biodata'
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 700),
                    curve: Curves.fastOutSlowIn,
                    right: 0.0,
                    left: 0.0,
                    bottom: _bottomPosBtn,
                    child: Container(
                      color: Theme.of(context).backgroundColor,
                      padding: EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 50.0,
                        child: FlatButton(
                          onPressed: _buttonActive ? (){
                            FocusScope.of(context).requestFocus(new FocusNode());
                            _showProgressDialog();
                            _saveBiodataToCloudFirestore();
                          } : (){}, 
                          child: Text(
                            'Simpan'
                          ),
                          textColor: _buttonActive ? Theme.of(context).buttonColor : Theme.of(context).disabledColor,
                          color: _buttonActive ? Theme.of(context).buttonColor.withAlpha(30) : Theme.of(context).disabledColor.withAlpha(30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      )
                    )
                  )
                ],
              ),
            ),
          )
          // PageTransitionSwitcher(
          //   reverse: _reverse,
          //   duration: Duration(milliseconds: 400),
          //   transitionBuilder: (
          //     Widget child,
          //     Animation<double> primaryAnimation,
          //     Animation<double> secondaryAnimation,
          //   ) {
          //     return SharedAxisTransition(
          //       animation: primaryAnimation,
          //       secondaryAnimation: secondaryAnimation,
          //       transitionType: SharedAxisTransitionType.horizontal,
          //       fillColor: Theme.of(context).backgroundColor,
          //       child: child,
          //     );
          //   },
          //   child: Container(
          //     key: ValueKey<int>(_position),
          //     color: Theme.of(context).backgroundColor,
          //     child: _position == 0 ? _inputLayout() : _departementLayout()
          //   ),
          // ),
        ),
        onWillPop: _readOnly ? null : _onBackPressed,
      ),
    );
  }

  Future<bool> _onBackPressed() {
    if (_canVibrate) {
      Vibrate.feedback(FeedbackType.warning);
    }
    return showDialog(
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
                Padding(
                  padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                  child: Text(
                    'Apakah Anda yakin ingin kembali?',
                    style: TextStyle(
                      fontFamily: 'Google',
                      fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 7.0,),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                  child: Text(
                    'Semua perubahan yang Anda masukkan tidak akan disimpan.',
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
                        _readOnly = true;
                        _rightPosFA = 16.0;
                        _bottomPosBtn = -200;
                        _allowBack = true;
                      });
                      _getBiodata();
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

  _showDepartementDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Wrap(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 30.0, bottom: 30.0),
              child: Center(
                child: Text(
                  'Pilih Jurusan',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                    fontFamily: 'Google',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ),
            Divider(
              height: 0.0,
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _listDepartement.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: <Widget>[
                      Material(
                        color: Colors.transparent,
                        child: ListTile(
                          enabled: _listDepartement[index].check ? false : true,
                          onTap: () {
                            for(int i = 0; i < _listDepartement.length; i++){
                              if(i == index){
                                _listDepartement[i].check= true;
                                _id_departement = _listDepartement[i].id_departement;
                                _id_faculty = _listDepartement[i].faculty;
                                _id_level = _listDepartement[i].id_level;
                                _departementController.text = '${_listDepartement[i].level} ${_listDepartement[i].name}';
                              } else {
                                _listDepartement[i].check = false;
                              }
                            }
                            Navigator.pop(context);
                            _enableButton();
                          },
                          leading: CircularCheckBox(
                            value: _listDepartement[index].check, 
                            onChanged: _listDepartement[index].check ? (value){} : (value){
                              setState(() {
                                for(int i = 0; i < _listDepartement.length; i++){
                                  if(i == index){
                                    _listDepartement[i].check= true;
                                    _id_departement = _listDepartement[i].id_departement;
                                    _id_faculty = _listDepartement[i].faculty;
                                    _id_level = _listDepartement[i].id_level;
                                    _departementController.text = '${_listDepartement[i].level} ${_listDepartement[i].name}';
                                  } else {
                                    _listDepartement[i].check = false;
                                  }
                                }
                                Navigator.pop(context);
                                _enableButton();
                              });
                            }
                          ),
                          title: Text(
                            '${_listDepartement[index].level} ${_listDepartement[index].name}',
                            style: TextStyle(
                              fontFamily: 'Noto',
                              fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
                              color: _listDepartement[index].check ? Theme.of(context).disabledColor : null,
                            ),
                          ),
                        ),
                      ),
                      if (index != _listDepartement.length - 1)
                      Divider(
                        indent: 70.0,
                        endIndent: 16.0,
                        height: 0.5,
                      )
                    ],
                  );
                }
              ),
            ),
            Divider(
              height: 0.0,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Batal',
                  style: TextStyle(
                    fontFamily: 'Google',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        )
      )
    );
  }

}