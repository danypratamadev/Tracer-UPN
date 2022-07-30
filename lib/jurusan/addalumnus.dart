import 'dart:io';
import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:line_icons/line_icons.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:random_string/random_string.dart';

class AddalumnusPage extends StatefulWidget {

  final int action;
  final String id, name, gender, phone, address, birthplace, birthdatetext, level, entryyear, graduationyear;
  final DateTime birthdate;

  const AddalumnusPage({Key key, @required this.action, this.id, this.name, this.gender, this.phone, this.address, this.birthplace, this.birthdate, this.birthdatetext, this.level, this.entryyear, this.graduationyear, }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddalumnusState();
  }

}

class Level{
  final String id, id_level, level, name;

  Level(this.id, this.id_level, this.level, this.name);
}

class Excels {
  final String nim, name, nameexsist, email, emailexsist;
  bool registered, activated, saved, failedemail;

  Excels(this.nim, this.name, this.nameexsist, this.email, this.emailexsist, this.registered, this.activated, this.saved, this.failedemail);
}

class AddalumnusState extends State<AddalumnusPage> {

  var _scaffoldkey = GlobalKey <ScaffoldState> ();
  final Firestore _firestore = Firestore.instance;
  final _emailController = TextEditingController();
  final _nimController = TextEditingController();
  final _nameController = TextEditingController();
  final _passController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthplaceController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _entryyearController = TextEditingController();
  final _graduationyearController = TextEditingController();
  String _id_faculty, _gender, _id_departement, _name_departement, _id_level, _file_name;
  bool _buttonActive = false, _obsecurePass = true, _sendEmail = true, _canVibrate = false;
  List _listGender = ['Laki-Laki', 'Perempuan'];
  DateTime _birthdate = DateTime.now();
  List<Level> _listLevel = new List<Level>();
  List<Excels> _listAlumnus = new List<Excels>();
  int _position = 0;
  double _bottomPos = 0.0;
  bool _reverse = false, _saveing = false;

  @override
  void initState() {
    if(widget.action == 20){
      _nameController.text = widget.name;
      _gender = widget.gender;
      _phoneController.text = widget.phone;
      _addressController.text = widget.address;
      _birthplaceController.text = widget.birthplace;
      _birthdateController.text = widget.birthdatetext;
      _id_level = widget.level;
      _entryyearController.text = widget.entryyear;
      _graduationyearController.text = widget.graduationyear;
      _birthdate = widget.birthdate;
      _buttonActive = true;
    }
    _checkDeviceVibrate();
    _getDataSharedPref();
    super.initState();
  }

  _checkDeviceVibrate() async {
    bool canVibrate = await Vibrate.canVibrate;
    setState(() {
      _canVibrate = canVibrate;
    });
  }

  _getDataSharedPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id_faculty = preferences.getString('faculty');
    String id_departement = preferences.getString('departement');
    String name_departement = preferences.getString('departementName');
    setState(() {
      _id_faculty = id_faculty;
      _id_departement = id_departement;
      _name_departement = name_departement;
      _passController.text = randomAlphaNumeric(10).toUpperCase();
    });
    _getLevelDepartementFromCloudFirestore();
  }

  _getLevelDepartementFromCloudFirestore() async {
    await _firestore.collection('departement').document(_id_departement).collection('level').getDocuments().then((value){
      if(value.documents.isNotEmpty){
        value.documents.forEach((f) {
          _firestore.collection('level').document(f.data['id_level']).get().then((values){
            if(values.exists){
              Level level = new Level(f.documentID, f.data['id_level'], values.data['name'], f.data['name']);
              setState(() {
                _listLevel.add(level);
              });
            }
          });
        });
      }
    });
  }

  _enableButton(){
    if(widget.action == 10){
      if(_emailController.text.length > 0 && _passController.text.length > 0 && _nimController.text.length > 0 && _nameController.text.length > 0 && _gender != null && _phoneController.text.length > 0 && _addressController.text.length > 0 && _birthplaceController.text.length > 0 && _birthdateController.text.length > 0 && _id_level != null && _entryyearController.text.length > 0 && _graduationyearController.text.length > 0){
        setState(() {
          _buttonActive = true;
        });
      } else {
        setState(() {
          _buttonActive = false;
        });
      }
    } else {
      if(_nameController.text.length > 0 && _gender != null && _phoneController.text.length > 0 && _addressController.text.length > 0 && _birthplaceController.text.length > 0 && _birthdateController.text.length > 0 && _id_level != null && _entryyearController.text.length > 0 && _graduationyearController.text.length > 0){
        setState(() {
          _buttonActive = true;
        });
      } else {
        setState(() {
          _buttonActive = false;
        });
      }
    }
  }

  _checkUsername(int index) {
    _firestore.collection('user').where('username', isEqualTo: _position == 0 ? _nimController.text : _listAlumnus[index].nim).getDocuments().then((value){
      if(value.documents.isNotEmpty){
        value.documents.forEach((f) async {
          if(f.data['delete']){
            String name;
            await _firestore.collection('user').document(f.documentID).collection('biodata').document('data').get().then((bio){
              if(bio.exists){
                name = bio.data['name'];
              }
            });
            if(_position == 0){
              Navigator.pop(context);
              _showActivatedDialog(f.documentID, name, f.data['username'], f.data['email'], f.data['password']);
            } else {
              setState(() {
                _listAlumnus[index].activated = true;
              });
            }
          } else {
            if(_position == 0){
              Navigator.pop(context);
              _showSnackBar('NIM telah terdaftar!', Icons.warning, Colors.orange[600]);
            } else {
              setState(() {
                _listAlumnus[index].registered = true;
              });
            }
          }
        });
      } else {
        _checkEmail(index);
      }
    });
  }

  _checkEmail(int index) {
    _firestore.collection('user').where('email', isEqualTo: _position == 0 ? _emailController.text : _listAlumnus[index].email).getDocuments().then((value){
      if(value.documents.isEmpty){
        if(_position == 0){
          _saveAlumnusToCloudFirestore();
        } else {
          _saveAlumnusToCloudFirestore2(index);
        }
      } else {
        if(_position == 0){
          Navigator.pop(context);
          _showSnackBar('Email telah terdaftar!', Icons.warning, Colors.orange[600]);
        } else {
          setState(() {
            _listAlumnus[index].registered = true;
          });
        }
      }
    });
  }

  _activatedAlumnus(String idUser, String emailUser, String nimUser, String passwordUser) async {
    await _firestore.collection('user').document(idUser).updateData({
      'delete': false,
    });
    if(mounted){
      String email = 'dev.ifupn@gmail.com';
      String password = 'Dev.ifUPN#';

      final smtpServer = gmail(email, password); 
      final message = Message()
        ..from = Address(email, 'TRACER STUDI UPN VETERAN YOGYAKARTA')
        ..recipients.add(_emailController.text)
        ..subject = "Pemulihan Akun Tracer Studi UPN Veteran Yogyakarta"
        ..html = """<div 
        style="border: 0.5px solid #EEEEEE;
          border-radius: 8px;">

          <table width="100%" 
              align="center" 
              border="0" 
              cellpadding="0" 
              cellspacing="0" 
              style="border-collapse: collapse; 
                  border-spacing: 0; 
                  margin: 0; 
                  padding: 0; 
                  width: 100%;" 
              class="background">

              <tr>
                  <td align="center" 
                      valign="top" 
                      style="border-collapse: collapse; 
                          border-spacing: 0; 
                          margin: 0; 
                          padding: 0;">

                      <table  border="0" 
                          cellpadding="0" 
                          cellspacing="0" 
                          align="center"
                          style="border-collapse: collapse; 
                              border-spacing: 0; 
                              padding: 0; 
                              width: inherit;
                              max-width: 95%;" 
                          class="wrapper">

                          <tr>
                              <td align="center" 
                                  valign="top" 
                                  style="border-collapse: collapse; 
                                      border-spacing: 0; 
                                      margin: 0; 
                                      padding: 0;
                                      padding-top: 40px;" 
                                  class="hero">

                                      <img border="0" 
                                              vspace="0" 
                                              hspace="0"
                                              src="https://upnyk.ac.id/asset/images/logo_upn.png"
                                              alt="Universitas Pembangunan Nasional 'Veteran' Yogyakarta"title="UPN"
                                              width="150" 
                                              style="
                                                width: inherit;
                                                  height: 60px;
                                                  color: #FFFFFF; 
                                                  font-size: 13px; 
                                                  margin: 0; 
                                                  padding: 0; 
                                                  outline: none; 
                                                  text-decoration: none; 
                                                  -ms-interpolation-mode: bicubic; 
                                                  border: none; 
                                                  display: block;"/>
                              </td>
                          </tr>

                          <tr>
                              <td align="center" 
                                  valign="top" 
                                  style="border-collapse: collapse; 
                                      border-spacing: 0; 
                                      margin: 0; 
                                      padding: 0;  
                                      padding-left: 4%; 
                                      padding-right: 4%; 
                                      padding-top: 30px;
                                      width: 87.5%; 
                                      font-size: 16px; 
                                      font-weight: normal; 
                                      line-height: 130%;
                                      color: #000000;
                                      font-family: sans-serif;" 
                                  class="header">
                                      Akun Alumni Tracer UPN 'Veteran' Yogyakarta
                              </td>
                          </tr>

                          <tr>
                              <td align="center" 
                                  valign="top" 
                                  style="border-collapse: collapse; 
                                      border-spacing: 0; 
                                      margin: 0; 
                                      padding: 0;  
                                      padding-left: 4%; 
                                      padding-right: 4%;
                                      padding-top: 5px;
                                      width: 87.5%; 
                                      font-size: 12px; 
                                      font-weight: normal; 
                                      line-height: 130%;
                                      color: #424242;
                                      font-family: sans-serif;" 
                                  class="header">
                                      Akun Anda telah dipulihan kembali dan Jangan berikan Akses Akun Anda kepada orang lain!
                              </td>
                          </tr>

                          <tr>
                              <td align="left" 
                                  valign="top" 
                                  style="border-collapse: collapse; 
                                      border-spacing: 0; 
                                      margin: 0; 
                                      padding: 0;  
                                      padding-left: 4%; 
                                      padding-right: 4%; 
                                      padding-top: 50px;
                                      width: 87.5%; 
                                      font-size: 12px; 
                                      font-weight: normal; 
                                      line-height: 130%;
                                      color: #424242;
                                      font-family: sans-serif;" 
                                  class="header">
                                      <div style="padding-left: 8px;">Email</div>
                              </td>
                          </tr>
                          
                          <tr>
                              <td align="left" 
                                  valign="top" 
                                  style="border-collapse: collapse; 
                                      border-spacing: 0; 
                                      margin: 0; 
                                      padding: 0;  
                                      padding-left: 4%; 
                                      padding-right: 4%; 
                                      padding-top: 5px;
                                      width: 87.5%; 
                                      font-size: 14px; 
                                      font-weight: normal; 
                                      line-height: 130%;
                                      color: #000000;
                                      font-family: sans-serif;" 
                                  class="header">
                                      <div style="border: 0.5px solid #EEEEEE;
                                        border-radius: 8px;
                                        padding: 15px;">$emailUser</div>
                              </td>
                          </tr>

                          <tr>
                              <td align="left" 
                                  valign="top" 
                                  style="border-collapse: collapse; 
                                      border-spacing: 0; 
                                      margin: 0; 
                                      padding: 0;  
                                      padding-left: 4%; 
                                      padding-right: 4%; 
                                      padding-top: 20px;
                                      width: 87.5%; 
                                      font-size: 12px; 
                                      font-weight: normal; 
                                      line-height: 130%;
                                      color: #424242;
                                      font-family: sans-serif;" 
                                  class="header">
                                      <div style="padding-left: 8px;">Username</div>
                              </td>
                          </tr>

                          <tr>
                              <td align="left" 
                                  valign="top" 
                                  style="border-collapse: collapse; 
                                      border-spacing: 0; 
                                      margin: 0; 
                                      padding: 0;  
                                      padding-left: 4%; 
                                      padding-right: 4%; 
                                      padding-top: 5px;
                                      width: 87.5%; 
                                      font-size: 14px; 
                                      font-weight: normal; 
                                      line-height: 130%;
                                      color: #000000;
                                      font-family: sans-serif;" 
                                  class="header">
                                      <div style="border: 0.5px solid #EEEEEE;
                                        border-radius: 8px;
                                        padding: 15px;">$nimUser</div>
                              </td>
                          </tr>

                          <tr>
                              <td align="left" 
                                  valign="top" 
                                  style="border-collapse: collapse; 
                                      border-spacing: 0; 
                                      margin: 0; 
                                      padding: 0;  
                                      padding-left: 4%; 
                                      padding-right: 4%; 
                                      padding-top: 20px;
                                      width: 87.5%; 
                                      font-size: 12px; 
                                      font-weight: normal; 
                                      line-height: 130%;
                                      color: #424242;
                                      font-family: sans-serif;" 
                                  class="header">
                                      <div style="padding-left: 8px;">Password</div>
                              </td>
                          </tr>

                          <tr>
                              <td align="left" 
                                  valign="top" 
                                  style="border-collapse: collapse; 
                                      border-spacing: 0; 
                                      margin: 0; 
                                      padding: 0;  
                                      padding-left: 4%; 
                                      padding-right: 4%; 
                                      padding-top: 5px;
                                      padding-bottom: 50px;
                                      width: 87.5%; 
                                      font-size: 14px; 
                                      font-weight: normal; 
                                      line-height: 130%;
                                      color: #000000;
                                      font-family: sans-serif;" 
                                  class="header">
                                      <div style="border: 0.5px solid #EEEEEE;
                                        border-radius: 8px;
                                        padding: 15px;">$passwordUser</div>
                              </td>
                          </tr>

                          <tr>
                              <td align="center" 
                                  valign="top" 
                                  style="border-collapse: collapse; 
                                      border-spacing: 0; 
                                      margin: 0; 
                                      padding: 0;  
                                      padding-left: 4%; 
                                      padding-right: 4%;
                                      padding-bottom: 50px;
                                      width: 87.5%; 
                                      font-size: 12px; 
                                      font-weight: normal; 
                                      line-height: 130%;
                                      color: #424242;
                                      font-family: sans-serif;" 
                                  class="header">
                                      Copyright &copy;2020 Tracer Studi UPN 'Veteran' Yogyakarta
                              </td>
                          </tr>

                      </table>

                  </td>
              </tr>

          </table>

      </div>""";

      try {
        final sendReport = await send(message, smtpServer);
        print('Message sent: ' + sendReport.toString());
        Navigator.pop(context);
        _showSnackBar('Berhasil mengaktifkan alumni.', Icons.verified_user, Colors.green[600]);
        Navigator.pop(context, true);
      } on MailerException catch (e) {
        Navigator.pop(context);
        _showSnackBar('Terjadi kesalahan!', Icons.warning, Colors.red[600]);
        for (var p in e.problems) {
          print('Problem: ${p.code}: ${p.msg}');
        }
      }
    }
  }

  _saveAlumnusToCloudFirestore() async {
    await _firestore.collection('user').add({
      'email': _emailController.text,
      'pass': _passController.text,
      'role': 3,
      'username': _nimController.text,
      'setup': false,
      'delete': false,
    }).then((value) => {
      _firestore.collection('user').document(value.documentID).collection('biodata').document('data').setData({
        'nim': _nimController.text,
        'name': _nameController.text,
        'email': _emailController.text,
        'gender': _gender,
        'faculty': _id_faculty,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'birthdate': _birthdate,
        'birthdatetext': _birthdateController.text,
        'birthplace': _birthplaceController.text,
        'departement': _id_departement,
        'level': _id_level,
        'entryyear': _entryyearController.text,
        'graduationyear': _graduationyearController.text,
        'biodata': true,
        'carrer': false,
        'competency': false,
        'achievement': false,
        'search': false
      })
    });
    if(mounted){
      if(_sendEmail){
        _sendCodeAuthEmail();
      } else {
        Navigator.pop(context);
        _showSnackBar('Berhasil menambah alumni.', Icons.verified_user, Colors.green[600]);
        Navigator.pop(context, true);
      }
    }
  }

  _saveAlumnusToCloudFirestore2(int index) async {
    String passwordRandom = randomAlphaNumeric(10).toUpperCase();
    await _firestore.collection('user').add({
      'email': _listAlumnus[index].email,
      'pass': passwordRandom,
      'role': 3,
      'username': _listAlumnus[index].nim,
      'setup': false,
      'delete': false,
    }).then((value) => {
      _firestore.collection('user').document(value.documentID).collection('biodata').document('data').setData({
        'name': _listAlumnus[index].name,
        'nim': _listAlumnus[index].nim,
        'email': _listAlumnus[index].email,
        'biodata': false,
        'carrer': false,
        'competency': false,
        'achievement': false,
        'search': false,
      })
    });
    if(mounted){
      if(_sendEmail){
        _sendEmailToUser(index, passwordRandom);
      } else {
        setState(() {
          _listAlumnus[index].saved = true;
        });
        if((index + 1) < _listAlumnus.length){
          _checkUsername((index + 1));
        } else {
          setState(() {
            _saveing = false;
          });
          _showSnackBar('Berhasil menambah alumni.', Icons.verified_user, Colors.green[600]);
          Navigator.pop(context, true);
          print('SELESAI MENAMBAH ALUMNI');
        }
      }
    }
  }

  _sendEmailToUser(int index, String passwordRandom) async {
    String email = 'dev.ifupn@gmail.com';
    String password = 'Dev.ifUPN#';

    final smtpServer = gmail(email, password); 
    final message = Message()
      ..from = Address(email, 'TRACER STUDI UPN VETERAN YOGYAKARTA')
      ..recipients.add(_listAlumnus[index].email)
      ..subject = "Akun Tracer Studi UPN Veteran Yogyakarta"
      ..html = """<div 
      style="border: 0.5px solid #EEEEEE;
        border-radius: 8px;">

        <table width="100%" 
            align="center" 
            border="0" 
            cellpadding="0" 
            cellspacing="0" 
            style="border-collapse: collapse; 
                border-spacing: 0; 
                margin: 0; 
                padding: 0; 
                width: 100%;" 
            class="background">

            <tr>
                <td align="center" 
                    valign="top" 
                    style="border-collapse: collapse; 
                        border-spacing: 0; 
                        margin: 0; 
                        padding: 0;">

                    <table  border="0" 
                        cellpadding="0" 
                        cellspacing="0" 
                        align="center"
                        style="border-collapse: collapse; 
                            border-spacing: 0; 
                            padding: 0; 
                            width: inherit;
                            max-width: 95%;" 
                        class="wrapper">

                        <tr>
                            <td align="center" 
                                valign="top" 
                                style="border-collapse: collapse; 
                                    border-spacing: 0; 
                                    margin: 0; 
                                    padding: 0;
                                    padding-top: 40px;" 
                                class="hero">

                                    <img border="0" 
                                            vspace="0" 
                                            hspace="0"
                                            src="https://upnyk.ac.id/asset/images/logo_upn.png"
                                            alt="Universitas Pembangunan Nasional 'Veteran' Yogyakarta"title="UPN"
                                            width="150" 
                                            style="
                                              width: inherit;
                                                height: 60px;
                                                color: #FFFFFF; 
                                                font-size: 13px; 
                                                margin: 0; 
                                                padding: 0; 
                                                outline: none; 
                                                text-decoration: none; 
                                                -ms-interpolation-mode: bicubic; 
                                                border: none; 
                                                display: block;"/>
                            </td>
                        </tr>

                        <tr>
                            <td align="center" 
                                valign="top" 
                                style="border-collapse: collapse; 
                                    border-spacing: 0; 
                                    margin: 0; 
                                    padding: 0;  
                                    padding-left: 4%; 
                                    padding-right: 4%; 
                                    padding-top: 30px;
                                    width: 87.5%; 
                                    font-size: 16px; 
                                    font-weight: normal; 
                                    line-height: 130%;
                                    color: #000000;
                                    font-family: sans-serif;" 
                                class="header">
                                    Akun Alumni Tracer UPN 'Veteran' Yogyakarta
                            </td>
                        </tr>

                        <tr>
                            <td align="center" 
                                valign="top" 
                                style="border-collapse: collapse; 
                                    border-spacing: 0; 
                                    margin: 0; 
                                    padding: 0;  
                                    padding-left: 4%; 
                                    padding-right: 4%;
                                    padding-top: 5px;
                                    width: 87.5%; 
                                    font-size: 12px; 
                                    font-weight: normal; 
                                    line-height: 130%;
                                    color: #424242;
                                    font-family: sans-serif;" 
                                class="header">
                                    Jangan berikan Akses Akun Anda kepada orang lain!
                            </td>
                        </tr>

                        <tr>
                            <td align="left" 
                                valign="top" 
                                style="border-collapse: collapse; 
                                    border-spacing: 0; 
                                    margin: 0; 
                                    padding: 0;  
                                    padding-left: 4%; 
                                    padding-right: 4%; 
                                    padding-top: 50px;
                                    width: 87.5%; 
                                    font-size: 12px; 
                                    font-weight: normal; 
                                    line-height: 130%;
                                    color: #424242;
                                    font-family: sans-serif;" 
                                class="header">
                                    <div style="padding-left: 8px;">Email</div>
                            </td>
                        </tr>
                        
                        <tr>
                            <td align="left" 
                                valign="top" 
                                style="border-collapse: collapse; 
                                    border-spacing: 0; 
                                    margin: 0; 
                                    padding: 0;  
                                    padding-left: 4%; 
                                    padding-right: 4%; 
                                    padding-top: 5px;
                                    width: 87.5%; 
                                    font-size: 14px; 
                                    font-weight: normal; 
                                    line-height: 130%;
                                    color: #000000;
                                    font-family: sans-serif;" 
                                class="header">
                                    <div style="border: 0.5px solid #EEEEEE;
                                      border-radius: 8px;
                                      padding: 15px;">${_listAlumnus[index].email}</div>
                            </td>
                        </tr>

                        <tr>
                            <td align="left" 
                                valign="top" 
                                style="border-collapse: collapse; 
                                    border-spacing: 0; 
                                    margin: 0; 
                                    padding: 0;  
                                    padding-left: 4%; 
                                    padding-right: 4%; 
                                    padding-top: 20px;
                                    width: 87.5%; 
                                    font-size: 12px; 
                                    font-weight: normal; 
                                    line-height: 130%;
                                    color: #424242;
                                    font-family: sans-serif;" 
                                class="header">
                                    <div style="padding-left: 8px;">Username</div>
                            </td>
                        </tr>

                        <tr>
                            <td align="left" 
                                valign="top" 
                                style="border-collapse: collapse; 
                                    border-spacing: 0; 
                                    margin: 0; 
                                    padding: 0;  
                                    padding-left: 4%; 
                                    padding-right: 4%; 
                                    padding-top: 5px;
                                    width: 87.5%; 
                                    font-size: 14px; 
                                    font-weight: normal; 
                                    line-height: 130%;
                                    color: #000000;
                                    font-family: sans-serif;" 
                                class="header">
                                    <div style="border: 0.5px solid #EEEEEE;
                                      border-radius: 8px;
                                      padding: 15px;">${_listAlumnus[index].nim}</div>
                            </td>
                        </tr>

                        <tr>
                            <td align="left" 
                                valign="top" 
                                style="border-collapse: collapse; 
                                    border-spacing: 0; 
                                    margin: 0; 
                                    padding: 0;  
                                    padding-left: 4%; 
                                    padding-right: 4%; 
                                    padding-top: 20px;
                                    width: 87.5%; 
                                    font-size: 12px; 
                                    font-weight: normal; 
                                    line-height: 130%;
                                    color: #424242;
                                    font-family: sans-serif;" 
                                class="header">
                                    <div style="padding-left: 8px;">Password</div>
                            </td>
                        </tr>

                        <tr>
                            <td align="left" 
                                valign="top" 
                                style="border-collapse: collapse; 
                                    border-spacing: 0; 
                                    margin: 0; 
                                    padding: 0;  
                                    padding-left: 4%; 
                                    padding-right: 4%; 
                                    padding-top: 5px;
                                    padding-bottom: 50px;
                                    width: 87.5%; 
                                    font-size: 14px; 
                                    font-weight: normal; 
                                    line-height: 130%;
                                    color: #000000;
                                    font-family: sans-serif;" 
                                class="header">
                                    <div style="border: 0.5px solid #EEEEEE;
                                      border-radius: 8px;
                                      padding: 15px;">$passwordRandom</div>
                            </td>
                        </tr>

                        <tr>
                            <td align="center" 
                                valign="top" 
                                style="border-collapse: collapse; 
                                    border-spacing: 0; 
                                    margin: 0; 
                                    padding: 0;  
                                    padding-left: 4%; 
                                    padding-right: 4%;
                                    padding-bottom: 50px;
                                    width: 87.5%; 
                                    font-size: 12px; 
                                    font-weight: normal; 
                                    line-height: 130%;
                                    color: #424242;
                                    font-family: sans-serif;" 
                                class="header">
                                    Copyright &copy;2020 Tracer Studi UPN 'Veteran' Yogyakarta
                            </td>
                        </tr>

                    </table>

                </td>
            </tr>

        </table>

    </div>""";

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      setState(() {
        _listAlumnus[index].saved = true;
      });
    } on MailerException catch (e) {
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      setState(() {
        _listAlumnus[index].saved = true;
        _listAlumnus[index].failedemail = true;
      });
    }
    if((index + 1) < _listAlumnus.length){
      _checkUsername((index + 1));
    } else {
      setState(() {
        _saveing = false;
      });
      _showSnackBar('Berhasil menambah alumni.', Icons.verified_user, Colors.green[600]);
      Navigator.pop(context, true);
    }
  }

  _updateDataAlumni() async {
    await _firestore.collection('user').document(widget.id).collection('biodata').document('data').updateData({
      'name': _nameController.text,
      'gender': _gender,
      'phone': _phoneController.text,
      'address': _addressController.text,
      'birthdate': _birthdate,
      'birthdatetext': _birthdateController.text,
      'birthplace': _birthplaceController.text,
      'departement': _id_departement,
      'level': _id_level,
      'entryyear': _entryyearController.text,
      'graduationyear': _graduationyearController.text,
    });
    if(mounted){
      Navigator.pop(context);
      _showSnackBar('Berhasil memperbarui data alumni.', Icons.verified_user, Colors.green[600]);
      Navigator.pop(context, true);
    }
  }

  _sendCodeAuthEmail() async {
    String email = 'dev.ifupn@gmail.com';
    String password = 'Dev.ifUPN#';

    final smtpServer = gmail(email, password); 
    final message = Message()
      ..from = Address(email, 'TRACER STUDI UPN VETERAN YOGYAKARTA')
      ..recipients.add(_emailController.text)
      ..subject = "Akun Tracer Studi UPN Veteran Yogyakarta"
      ..html = """<div 
      style="border: 0.5px solid #EEEEEE;
        border-radius: 8px;">

        <table width="100%" 
            align="center" 
            border="0" 
            cellpadding="0" 
            cellspacing="0" 
            style="border-collapse: collapse; 
                border-spacing: 0; 
                margin: 0; 
                padding: 0; 
                width: 100%;" 
            class="background">

            <tr>
                <td align="center" 
                    valign="top" 
                    style="border-collapse: collapse; 
                        border-spacing: 0; 
                        margin: 0; 
                        padding: 0;">

                    <table  border="0" 
                        cellpadding="0" 
                        cellspacing="0" 
                        align="center"
                        style="border-collapse: collapse; 
                            border-spacing: 0; 
                            padding: 0; 
                            width: inherit;
                            max-width: 95%;" 
                        class="wrapper">

                        <tr>
                            <td align="center" 
                                valign="top" 
                                style="border-collapse: collapse; 
                                    border-spacing: 0; 
                                    margin: 0; 
                                    padding: 0;
                                    padding-top: 40px;" 
                                class="hero">

                                    <img border="0" 
                                            vspace="0" 
                                            hspace="0"
                                            src="https://upnyk.ac.id/asset/images/logo_upn.png"
                                            alt="Universitas Pembangunan Nasional 'Veteran' Yogyakarta"title="UPN"
                                            width="150" 
                                            style="
                                              width: inherit;
                                                height: 60px;
                                                color: #FFFFFF; 
                                                font-size: 13px; 
                                                margin: 0; 
                                                padding: 0; 
                                                outline: none; 
                                                text-decoration: none; 
                                                -ms-interpolation-mode: bicubic; 
                                                border: none; 
                                                display: block;"/>
                            </td>
                        </tr>

                        <tr>
                            <td align="center" 
                                valign="top" 
                                style="border-collapse: collapse; 
                                    border-spacing: 0; 
                                    margin: 0; 
                                    padding: 0;  
                                    padding-left: 4%; 
                                    padding-right: 4%; 
                                    padding-top: 30px;
                                    width: 87.5%; 
                                    font-size: 16px; 
                                    font-weight: normal; 
                                    line-height: 130%;
                                    color: #000000;
                                    font-family: sans-serif;" 
                                class="header">
                                    Akun Alumni Tracer UPN 'Veteran' Yogyakarta
                            </td>
                        </tr>

                        <tr>
                            <td align="center" 
                                valign="top" 
                                style="border-collapse: collapse; 
                                    border-spacing: 0; 
                                    margin: 0; 
                                    padding: 0;  
                                    padding-left: 4%; 
                                    padding-right: 4%;
                                    padding-top: 5px;
                                    width: 87.5%; 
                                    font-size: 12px; 
                                    font-weight: normal; 
                                    line-height: 130%;
                                    color: #424242;
                                    font-family: sans-serif;" 
                                class="header">
                                    Jangan berikan Akses Akun Anda kepada orang lain!
                            </td>
                        </tr>

                        <tr>
                            <td align="left" 
                                valign="top" 
                                style="border-collapse: collapse; 
                                    border-spacing: 0; 
                                    margin: 0; 
                                    padding: 0;  
                                    padding-left: 4%; 
                                    padding-right: 4%; 
                                    padding-top: 50px;
                                    width: 87.5%; 
                                    font-size: 12px; 
                                    font-weight: normal; 
                                    line-height: 130%;
                                    color: #424242;
                                    font-family: sans-serif;" 
                                class="header">
                                    <div style="padding-left: 8px;">Email</div>
                            </td>
                        </tr>
                        
                        <tr>
                            <td align="left" 
                                valign="top" 
                                style="border-collapse: collapse; 
                                    border-spacing: 0; 
                                    margin: 0; 
                                    padding: 0;  
                                    padding-left: 4%; 
                                    padding-right: 4%; 
                                    padding-top: 5px;
                                    width: 87.5%; 
                                    font-size: 14px; 
                                    font-weight: normal; 
                                    line-height: 130%;
                                    color: #000000;
                                    font-family: sans-serif;" 
                                class="header">
                                    <div style="border: 0.5px solid #EEEEEE;
                                      border-radius: 8px;
                                      padding: 15px;">${_emailController.text}</div>
                            </td>
                        </tr>

                        <tr>
                            <td align="left" 
                                valign="top" 
                                style="border-collapse: collapse; 
                                    border-spacing: 0; 
                                    margin: 0; 
                                    padding: 0;  
                                    padding-left: 4%; 
                                    padding-right: 4%; 
                                    padding-top: 20px;
                                    width: 87.5%; 
                                    font-size: 12px; 
                                    font-weight: normal; 
                                    line-height: 130%;
                                    color: #424242;
                                    font-family: sans-serif;" 
                                class="header">
                                    <div style="padding-left: 8px;">Username</div>
                            </td>
                        </tr>

                        <tr>
                            <td align="left" 
                                valign="top" 
                                style="border-collapse: collapse; 
                                    border-spacing: 0; 
                                    margin: 0; 
                                    padding: 0;  
                                    padding-left: 4%; 
                                    padding-right: 4%; 
                                    padding-top: 5px;
                                    width: 87.5%; 
                                    font-size: 14px; 
                                    font-weight: normal; 
                                    line-height: 130%;
                                    color: #000000;
                                    font-family: sans-serif;" 
                                class="header">
                                    <div style="border: 0.5px solid #EEEEEE;
                                      border-radius: 8px;
                                      padding: 15px;">${_nimController.text}</div>
                            </td>
                        </tr>

                        <tr>
                            <td align="left" 
                                valign="top" 
                                style="border-collapse: collapse; 
                                    border-spacing: 0; 
                                    margin: 0; 
                                    padding: 0;  
                                    padding-left: 4%; 
                                    padding-right: 4%; 
                                    padding-top: 20px;
                                    width: 87.5%; 
                                    font-size: 12px; 
                                    font-weight: normal; 
                                    line-height: 130%;
                                    color: #424242;
                                    font-family: sans-serif;" 
                                class="header">
                                    <div style="padding-left: 8px;">Password</div>
                            </td>
                        </tr>

                        <tr>
                            <td align="left" 
                                valign="top" 
                                style="border-collapse: collapse; 
                                    border-spacing: 0; 
                                    margin: 0; 
                                    padding: 0;  
                                    padding-left: 4%; 
                                    padding-right: 4%; 
                                    padding-top: 5px;
                                    padding-bottom: 50px;
                                    width: 87.5%; 
                                    font-size: 14px; 
                                    font-weight: normal; 
                                    line-height: 130%;
                                    color: #000000;
                                    font-family: sans-serif;" 
                                class="header">
                                    <div style="border: 0.5px solid #EEEEEE;
                                      border-radius: 8px;
                                      padding: 15px;">${_passController.text}</div>
                            </td>
                        </tr>

                        <tr>
                            <td align="center" 
                                valign="top" 
                                style="border-collapse: collapse; 
                                    border-spacing: 0; 
                                    margin: 0; 
                                    padding: 0;  
                                    padding-left: 4%; 
                                    padding-right: 4%;
                                    padding-bottom: 50px;
                                    width: 87.5%; 
                                    font-size: 12px; 
                                    font-weight: normal; 
                                    line-height: 130%;
                                    color: #424242;
                                    font-family: sans-serif;" 
                                class="header">
                                    Copyright &copy;2020 Tracer Studi UPN 'Veteran' Yogyakarta
                            </td>
                        </tr>

                    </table>

                </td>
            </tr>

        </table>

    </div>""";

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      Navigator.pop(context);
      _showSnackBar('Berhasil menambah alumni.', Icons.verified_user, Colors.green[600]);
      Navigator.pop(context, true);
    } on MailerException catch (e) {
      Navigator.pop(context);
      _showSnackBar('Terjadi kesalahan!', Icons.warning, Colors.red[600]);
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
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

  _showProgressDialog(String title) {
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
                  title,
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

  _showActivatedDialog(String idUser, String name, String nim, String email, String password){
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
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0, bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Alumni ini sebelumnya telah terdaftar dan kemudian dihapus.',
                        style: TextStyle(
                          fontFamily: 'Google',
                          fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.0,),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(20),
                          borderRadius: BorderRadius.circular(10.0)
                        ),
                        child: Row(
                          children: [
                            ClipOval(
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.1,
                                height: MediaQuery.of(context).size.width * 0.1,
                                color: Colors.orange,
                                child: Center(
                                  child: Icon(
                                    Icons.cached,
                                    color: Colors.white,
                                  )
                                )
                              ),
                            ),
                            SizedBox(width: 15.0,),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontFamily: 'Google',
                                      fontSize: Theme.of(context).textTheme.subtitle1.fontSize - 2,
                                      fontWeight: FontWeight.bold
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 3.0,),
                                  Text(
                                    nim,
                                    style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.caption.fontSize,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 3.0,),
                                  Text(
                                    email,
                                    style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.caption.fontSize,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 0.0,),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: FlatButton(
                    onPressed: (){
                     Navigator.pop(context);
                     _showProgressDialog('Mengaktifkan alumni...');
                     _activatedAlumnus(idUser, email, nim, password);
                    }, 
                    child: Text(
                      'Aktifkan Kembali',
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
                Padding(
                  padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                  child: Text(
                    'Perhatian',
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
                    widget.action == 10 ? 'Apakah Anda yakin ingin membatalkan tambah alumni?' : 'Apakah Anda yakin ingin membatalkan edit alumni?',
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
                     Navigator.pop(context);
                    }, 
                    child: Text(
                      'Ya',
                    ),
                    textColor: Colors.red[600],
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
                      'Tidak',
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
                          _showAlertDialog();
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0,),
                  Flexible(
                    fit: FlexFit.tight,
                    child: GestureDetector(
                      onTap: (){
                        // showSearch(context: context, delegate: DataSearch());
                      },
                      child: Text(
                        widget.action == 20 ? 'Edit Data Alumni' : 'Tambah Alumni',
                      ),
                    )
                  ),
                  SizedBox(width: 8.0,),
                ],
              ),
            ),
            elevation: 0.0,
          ),
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
              child: _position == 0 ? _manualInput() : _excelInput()
            ),
          ),
        ), 
        onWillPop: _position == 1 ? (){
          setState(() {
            _reverse = true;
            _position = 0;
            _file_name = null;
            _listAlumnus = new List<Excels>();
            _buttonActive = false;
          });
        } : _onBackPressed,
      )
    );
  }

  Widget _excelInput() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Theme.of(context).backgroundColor,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      FlatButton(
                        onPressed: (){
                          setState(() {
                            _reverse = true;
                            _position = 0;
                            _file_name = null;
                            _listAlumnus = new List<Excels>();
                            _buttonActive = false;
                          });
                        }, 
                        child: Text(
                          'Tambah Manual'
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)
                        ),
                        color: _position == 0 ? Colors.blue : Colors.grey[100],
                        textColor: _position == 0 ? Colors.white : null,
                      ),
                      SizedBox(
                        width: 16.0,
                      ),
                      FlatButton(
                        onPressed: (){
                          setState(() {
                            _reverse = false;
                            _position = 1;
                          });
                        }, 
                        child: Text(
                          'Tambah dari .xlsx'
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        color: _position == 1 ? Colors.blue : Colors.grey[100],
                        textColor: _position == 1 ? Colors.white : null,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10.0),
                      onTap: () async {
                        FilePickerResult result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['xlsx',],
                        );
                        if(result != null) {
                          PlatformFile file = result.files.first;
                          print('PATH => ${file.path}');
                          var path = file.path;
                          var bytes = File(path).readAsBytesSync();
                          var excel = Excel.decodeBytes(bytes);
                          List<Excels> _listTemp = new List<Excels>();
                          int i = 0;
                          for (var table in excel.tables.keys) {
                            for (var row in excel.tables[table].rows) {
                              if(i != 0){
                                Excels excels = new Excels(row[0].toString(), row[1].toString(), '', row[2].toString(), '', false, false, false, false);
                                _listTemp.add(excels);
                              }
                              i++;
                            }
                          }
                          setState(() {
                            _file_name = file.name;
                            _listAlumnus = _listTemp;
                            _buttonActive = true;
                          });
                        }
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 400),
                        curve: Curves.fastOutSlowIn,
                        width: double.infinity,
                        height: _listAlumnus.length > 0 ? MediaQuery.of(context).size.height * 0.2 : MediaQuery.of(context).size.height * 0.5,
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                            width: 0.5
                          )
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                FontAwesome.folder_open,
                                color: _file_name != null ? Colors.blue[200] : Theme.of(context).dividerColor,
                                size: MediaQuery.of(context).size.width * 0.15,
                              ),
                              SizedBox(
                                height: 10.0
                              ),
                              Text(
                                _file_name != null ? _file_name : 'Cari File .xlsx'
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if(_listAlumnus.length > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.grey[50],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(5.0),
                        onTap: (){
                          setState(() {
                            _sendEmail = !_sendEmail;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 8.0, bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  _sendEmail ? 'Kirim Password Akun melalui Email: YA' : 'Kirim Password Akun melalui Email: TIDAK'
                                ),
                              ),
                              Switch(
                                value: _sendEmail, 
                                onChanged: (value){
                                  setState(() {
                                    _sendEmail = value;
                                  });
                                }
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if(_listAlumnus.length > 0)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text(
                        'DAFTAR ALUMNI',
                        style: TextStyle(
                          fontFamily: 'Google',
                          fontWeight: FontWeight.bold,
                          fontSize: Theme.of(context).textTheme.caption.fontSize,
                          color: Theme.of(context).textTheme.caption.color,
                        ),
                      ),
                      Spacer(),
                      if(!_saveing)
                      Text(
                        '${_listAlumnus.length} Alumni',
                        style: TextStyle(
                          fontFamily: 'Google',
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      if(_saveing)
                      CupertinoActivityIndicator(),
                      if(_saveing)
                      SizedBox(
                        width: 8.0,
                      ),
                      if(_saveing)
                      Text(
                        'Menyimpan...',
                        style: TextStyle(
                          fontFamily: 'Google',
                          color: Theme.of(context).accentColor,
                        ),
                      )
                    ],
                  ),
                ),
                if(_listAlumnus.length > 0)
                ListView.builder(
                  itemCount: _listAlumnus.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, i){
                    List splitName = _listAlumnus[i].name.split(' ');
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Material(
                          color: Theme.of(context).backgroundColor,
                          child: InkWell(
                            onTap: () async {
                              
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 20.0),
                              child: Row(
                                children: <Widget>[
                                  ClipOval(
                                    child: Container(
                                      width: 35.0,
                                      height: 35.0,
                                      color: Theme.of(context).accentColor,
                                      child: Center(
                                        child: Text(
                                          splitName.length > 1 ? '${splitName[0].toString().substring(0,1)}${splitName[0].toString().substring(0,1)}' : '${splitName[0].toString().substring(0,1)}',
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
                                    width: MediaQuery.of(context).size.width * 0.6,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          _listAlumnus[i].name,
                                          style: TextStyle(
                                            fontFamily: 'Noto',
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          _listAlumnus[i].nim,
                                          style: TextStyle(
                                            fontSize: Theme.of(context).textTheme.caption.fontSize,
                                          ),
                                        ),
                                        Text(
                                          _listAlumnus[i].email,
                                          style: TextStyle(
                                            fontSize: Theme.of(context).textTheme.caption.fontSize,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  if(_saveing && !_listAlumnus[i].saved && !_listAlumnus[i].registered && !_listAlumnus[i].activated)
                                  CupertinoActivityIndicator(),
                                  if(_listAlumnus[i].saved && !_listAlumnus[i].failedemail)
                                  Icon(
                                    Icons.verified_user,
                                    color: Colors.green,
                                  ),
                                  if(_listAlumnus[i].saved && _listAlumnus[i].failedemail)
                                  Icon(
                                    Icons.mail,
                                    color: Colors.red,
                                  ),
                                  if(_listAlumnus[i].registered)
                                  Icon(
                                    Icons.info,
                                    color: Colors.orange,
                                  ),
                                  if(_listAlumnus[i].activated)
                                  Icon(
                                    Icons.info,
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Divider(
                          height: 0.5,
                          indent: 70.0,
                          endIndent: 16.0,
                        )
                      ],
                    );
                  }
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15,
                ),
              ],
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 700),
            curve: Curves.fastOutSlowIn,
            right: 0.0,
            left: 0.0,
            bottom: _bottomPos,
            child: Container(
              color: Theme.of(context).backgroundColor,
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50.0,
                child: FlatButton(
                  onPressed: _buttonActive ? () async {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    // _showProgressDialog('Menyimpan alumni...');
                    setState(() {
                      _saveing = true;
                      _bottomPos = -200;
                    });
                    _checkUsername(0);
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
      )
    );
  }

  Widget _manualInput() {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Theme.of(context).backgroundColor,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if(widget.action == 10)
                    Row(
                      children: [
                        FlatButton(
                          onPressed: (){
                            setState(() {
                              _reverse = true;
                              _position = 0;
                            });
                          }, 
                          child: Text(
                            'Tambah Manual'
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)
                          ),
                          color: _position == 0 ? Colors.blue : Colors.grey[100],
                          textColor: _position == 0 ? Colors.white : null,
                        ),
                        SizedBox(
                          width: 16.0,
                        ),
                        FlatButton(
                          onPressed: (){
                            setState(() {
                              _reverse = false;
                              _position = 1;
                            });
                          }, 
                          child: Text(
                            'Tambah dari .xlsx'
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          color: _position == 1 ? Colors.blue : Colors.grey[100],
                          textColor: _position == 1 ? Colors.white : null,
                        ),
                      ],
                    ),
                    if(widget.action == 10)
                    SizedBox(
                      height: 16.0,
                    ),
                    if(widget.action == 10)
                    Text(
                      'AKSES MASUK',
                      style: TextStyle(
                        fontFamily: 'Google',
                        fontWeight: FontWeight.bold,
                        fontSize: Theme.of(context).textTheme.caption.fontSize,
                        color: Theme.of(context).textTheme.caption.color,
                      ),
                    ),
                    if(widget.action == 10)
                    SizedBox(
                      height: 10.0,
                    ),
                    if(widget.action == 10)
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
                                  'Email',
                                ),
                                SizedBox(height: 10.0,),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: TextFormField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      hintText: 'Masukkan Alamat Email',
                                      border: InputBorder.none,
                                      filled: true,
                                    ),
                                    onChanged: (value){
                                      _enableButton();
                                    },
                                    style: Theme.of(context).textTheme.bodyText1,
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
                                  'Password',
                                ),
                                SizedBox(height: 10.0,),
                                Row(
                                  children: [
                                    Flexible(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: TextFormField(
                                          controller: _passController,
                                          obscureText: _obsecurePass,
                                          onChanged: (value){
                                            _enableButton();
                                          },
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.only(left: 12.0, top: 15.0),
                                            hintText: 'Acak password otomatis',
                                            border: InputBorder.none,
                                            filled: true,
                                            suffixIcon: IconButton(
                                              onPressed: (){
                                                setState(() {
                                                  _obsecurePass = !_obsecurePass;
                                                  // _passController.text = randomAlphaNumeric(10);
                                                });
                                              },
                                              icon: Icon(
                                                _obsecurePass ? Icons.visibility_off : Icons.visibility,
                                              ),
                                            )
                                          ),
                                          style: Theme.of(context).textTheme.bodyText1,
                                          keyboardType: TextInputType.text,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 5.0,),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Material(
                                        color: Theme.of(context).dividerColor.withAlpha(10),
                                        child: IconButton(
                                          onPressed: (){
                                            setState(() {
                                              _passController.text = randomAlphaNumeric(10).toUpperCase();
                                            });
                                          },
                                          icon: Icon(
                                            Icons.refresh,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if(widget.action == 10)
                    SizedBox(
                      height: 32.0,
                    ),
                    Text(
                      'PROFIL',
                      style: TextStyle(
                        fontFamily: 'Google',
                        fontWeight: FontWeight.bold,
                        fontSize: Theme.of(context).textTheme.caption.fontSize,
                        color: Theme.of(context).textTheme.caption.color,
                      ),
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
                        children: [
                          if(widget.action == 10)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Nim',
                                ),
                                SizedBox(height: 10.0,),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: TextFormField(
                                    controller: _nimController,
                                    decoration: InputDecoration(
                                      hintText: 'Masukkan Nim',
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
                          if(widget.action == 10)
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
                                Text(
                                  'Nomor Telepon',
                                ),
                                SizedBox(height: 10.0,),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: TextFormField(
                                    controller: _phoneController,
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
                    Text(
                      'DATA KELAHIRAN',
                      style: TextStyle(
                        fontFamily: 'Google',
                        fontWeight: FontWeight.bold,
                        fontSize: Theme.of(context).textTheme.caption.fontSize,
                        color: Theme.of(context).textTheme.caption.color,
                      ),
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
                                    onTap: (){
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
                    Text(
                      'DATA AKADEMIK',
                      style: TextStyle(
                        fontFamily: 'Google',
                        fontWeight: FontWeight.bold,
                        fontSize: Theme.of(context).textTheme.caption.fontSize,
                        color: Theme.of(context).textTheme.caption.color,
                      ),
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
                                if(_listLevel.length > 0)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: DropdownButtonFormField(
                                    isExpanded: true,
                                    value: _id_level,
                                    icon: Icon(
                                      Icons.keyboard_arrow_down,
                                    ),
                                    items: _listLevel.map((level) {
                                      return DropdownMenuItem(
                                        value: level.id,
                                        child: Text(
                                          '${level.level} ${level.name}',
                                          style: Theme.of(context).textTheme.bodyText1,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        for(int i = 0; i < _listLevel.length; i++){
                                          if(_listLevel[i].id == value){
                                            _id_level = _listLevel[i].id;
                                          }
                                        }
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
                                )
                                else
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: TextFormField(
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      hintText: 'Prodi belum ditambahkan!',
                                      hintStyle: TextStyle(
                                        color: Colors.red[700]
                                      ),
                                      border: InputBorder.none,
                                      filled: true,
                                      fillColor: Colors.red[50]
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
                                  'Tahun Masuk',
                                ),
                                SizedBox(height: 10.0,),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: TextFormField(
                                    controller: _entryyearController,
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
                    if(widget.action == 10)
                    SizedBox(
                      height: 32.0,
                    ),
                    if(widget.action == 10)
                    Text(
                      'LAINNYA',
                      style: TextStyle(
                        fontFamily: 'Google',
                        fontWeight: FontWeight.bold,
                        fontSize: Theme.of(context).textTheme.caption.fontSize,
                        color: Theme.of(context).textTheme.caption.color,
                      ),
                    ),
                    if(widget.action == 10)
                    SizedBox(
                      height: 10.0,
                    ),
                    if(widget.action == 10)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.grey[50],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(5.0),
                          onTap: (){
                            setState(() {
                              _sendEmail = !_sendEmail;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 8.0, bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _sendEmail ? 'Kirim Password Akun melalui Email: YA' : 'Kirim Password Akun melalui Email: TIDAK'
                                ),
                                Switch(
                                  value: _sendEmail, 
                                  onChanged: (value){
                                    setState(() {
                                      _sendEmail = value;
                                    });
                                  }
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.15,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 700),
              curve: Curves.fastOutSlowIn,
              right: 0.0,
              left: 0.0,
              bottom: 0.0,
              child: Container(
                color: Theme.of(context).backgroundColor,
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50.0,
                  child: FlatButton(
                    onPressed: _buttonActive ? (){
                      FocusScope.of(context).requestFocus(new FocusNode());
                      _showProgressDialog('Menyimpan alumni...');
                      if(widget.action == 10){
                        _checkUsername(0);
                      } else {
                        _updateDataAlumni();
                      }
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
                    'Perhatian',
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
                    widget.action == 10 ? 'Apakah Anda yakin ingin membatalkan tambah alumni?' : 'Apakah Anda yakin ingin membatalkan edit alumni?',
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
                     Navigator.of(context).pop(true);
                    }, 
                    child: Text(
                      'Ya',
                    ),
                    textColor: Colors.red[600],
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
                      'Tidak',
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

}