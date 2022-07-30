import 'package:circular_check_box/circular_check_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:random_string/random_string.dart';
import 'package:toast/toast.dart';

class AddadminPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddadminState();
  }

}

class Departement{
  final String id, name;
  bool check;

  Departement(this.id, this.name, this.check);
}

class AddadminState extends State {

  final Firestore _firestore = Firestore.instance;
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _id_faculty, _gender, _username;
  bool _buttonActive = false, _obsecurePass = true, _sendEmail = true;
  List _listGender = ['Laki-Laki', 'Perempuan'];
  List<Departement> _listDepartement = new List<Departement>();
  List<Departement> _listDepartementTemp = new List<Departement>();

  @override
  void initState() {
    _getBiodata();
    super.initState();
  }

  _getBiodata() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id_faculty = preferences.getString('faculty');
    setState(() {
      _id_faculty = id_faculty;
      _passController.text = randomAlphaNumeric(10).toUpperCase();
    });
    _getDepartementFromCloudFirestore();
  }

  _getDepartementFromCloudFirestore() async {
    List<Departement> _listTemp = new List<Departement>();
    _firestore.collection('departement').where('faculty', isEqualTo: _id_faculty).getDocuments().then((value){
      if(value.documents.isNotEmpty){
        value.documents.forEach((f) {
          if(!f.data['delete']){
            Departement departement = new Departement(f.documentID, f.data['name'], false);
            _listTemp.add(departement);
          }
        });
      }
    });
    if(mounted){
      setState(() {
        _listDepartement = _listTemp;
      });
    }
  }

  _enableButton() {
    if(_emailController.text.length > 0 &&  _passController.text.length > 0 && _nameController.text.length > 0 && _gender != null && _phoneController.text.length > 0 && _addressController.text.length > 0){
      setState(() {
        _buttonActive = true;
      });
    } else {
      setState(() {
        _buttonActive = false;
      });
    }
  }

  _getUsername() {
    int subIndex;
    for(int i = 0; i < _emailController.text.length; i++){
      if(_emailController.text[i] == '@'){
        subIndex = i;
      }
    }
    String username = _emailController.text.substring(0, subIndex);
    setState(() {
      _username = username;
    });
    _checkEmail();
  }

  _checkEmail() {
    _firestore.collection('user').where('email', isEqualTo: _emailController.text).getDocuments().then((value){
      if(value.documents.isNotEmpty){
        value.documents.forEach((f) async {
          if(f.data['delete']){
            String name;
            await _firestore.collection('user').document(f.documentID).collection('biodata').document('data').get().then((bio){
              if(bio.exists){
                name = bio.data['name'];
              }
            });
            Navigator.pop(context);
            _showActivatedDialog(f.documentID, name, f.data['username'], f.data['email'], f.data['password']);
          } else {
            Navigator.pop(context);
            Toast.show(
              'Email telah terdaftar!', 
              context, 
              duration: Toast.LENGTH_SHORT, 
              gravity:  Toast.BOTTOM,
              backgroundColor: Colors.black87,
              backgroundRadius: 8.0
            );
          }
        });
      } else {
        _saveAdminToCloudFirestore();
      }
    });
  }

  _saveAdminToCloudFirestore() async {
    await _firestore.collection('user').add({
      'email': _emailController.text,
      'pass': _passController.text,
      'role': 2,
      'setup': false,
      'username': _username,
      'delete': false,
    }).then((value) async => {
      _firestore.collection('user').document(value.documentID).collection('biodata').document('data').setData({
        'name': _nameController.text,
        'email': _emailController.text,
        'gender': _gender,
        'faculty': _id_faculty,
        'phone': _phoneController.text,
        'address': _addressController.text,
      }),
      for(int i = 0; i < _listDepartementTemp.length; i++){
        await _firestore.collection('user').document(value.documentID).collection('access').add({
          'departement': _listDepartementTemp[i].id,
        })
      }
    });
    if(mounted){
      if(_sendEmail){
        _sendCodeAuthEmail();
      } else {
        Navigator.pop(context);
        Toast.show(
          'Berhasil menambah admin jurusan.', 
          context, 
          duration: Toast.LENGTH_SHORT, 
          gravity:  Toast.BOTTOM,
          backgroundColor: Colors.black87,
          backgroundRadius: 8.0
        );
        Navigator.pop(context, true);
      }
    }
  }

  _activatedAdmin(String idUser, String emailUser, String nimUser, String passwordUser) async {
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
                                      Akun Admin Jurusan Tracer UPN 'Veteran' Yogyakarta
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
        Toast.show(
          'Berhasil mengaktifkan alumni.', 
          context, 
          duration: Toast.LENGTH_SHORT, 
          gravity:  Toast.BOTTOM,
          backgroundColor: Colors.black87,
          backgroundRadius: 8.0
        );
        Navigator.pop(context, true);
      } on MailerException catch (e) {
        Navigator.pop(context);
        Toast.show(
          'Terjadi kesalahan!', 
          context, 
          duration: Toast.LENGTH_SHORT, 
          gravity:  Toast.BOTTOM,
          backgroundColor: Colors.black87,
          backgroundRadius: 8.0
        );
        print('Message not sent.');
        for (var p in e.problems) {
          print('Problem: ${p.code}: ${p.msg}');
        }
      }
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
                                    Akun Admin Jurusan Tracer UPN 'Veteran' Yogyakarta
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
                                      padding: 15px;">$_username</div>
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
      Toast.show(
        'Berhasil menambah admin jurusan.', 
        context, 
        duration: Toast.LENGTH_SHORT, 
        gravity:  Toast.BOTTOM,
        backgroundColor: Colors.black87,
        backgroundRadius: 8.0
      );
      Navigator.pop(context, true);
    } on MailerException catch (e) {
      Navigator.pop(context);
      Toast.show(
        'Terjadi kesalahan!', 
        context, 
        duration: Toast.LENGTH_SHORT, 
        gravity:  Toast.BOTTOM,
        backgroundColor: Colors.black87,
        backgroundRadius: 8.0
      );
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  _showActivatedDialog(String idUser, String name, String username, String email, String password){
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
                     _showProgressDialog('Mengaktifkan admin...');
                     _activatedAdmin(idUser, email, username, password);
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

  _showDepartementDialog(){
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Wrap(
          children: [
            Padding(padding: EdgeInsets.only(top: 35.0, bottom: 35.0, left: 16.0, right: 16.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Daftar Prodi',
                  style: TextStyle(
                    fontFamily: 'Google',
                    fontSize: Theme.of(context).textTheme.headline6.fontSize,
                  ),
                ),
              )
            ),
            Divider(height: 0.0,),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _listDepartement.length,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    Material(
                      color: Colors.transparent,
                      child: ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            if(!_listDepartement[index].check){
                              Departement departement = new Departement(_listDepartement[index].id, _listDepartement[index].name, _listDepartement[index].check);
                              _listDepartementTemp.add(departement);
                              _listDepartement[index].check = true;
                            } else {
                              _listDepartementTemp.removeWhere((item) => item.id == _listDepartement[index].id);
                              _listDepartement[index].check = false;
                            }
                          });
                        },
                        leading: CircularCheckBox(
                          value: _listDepartement[index].check, 
                          onChanged: (value){
                            Navigator.pop(context);
                            setState(() {
                              if(!_listDepartement[index].check){
                                Departement departement = new Departement(_listDepartement[index].id, _listDepartement[index].name, _listDepartement[index].check);
                                _listDepartementTemp.add(departement);
                                _listDepartement[index].check = true;
                              } else {
                                _listDepartementTemp.removeWhere((item) => item.id == _listDepartement[index].id);
                                _listDepartement[index].check = false;
                              }
                            });
                          }
                        ),
                        title: Text(
                          _listDepartement[index].name,
                        ),
                      ),
                    ),
                    if (index != _listDepartement.length - 1)
                    Divider(
                      indent: 70.0,
                      endIndent: 16.0,
                      height: 0.0
                    )
                  ],
                );
              }
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
                  'Close',
                ),
                textColor: Theme.of(context).buttonColor,
              ),
            )
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
      child: WillPopScope(
        child: Scaffold(
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
                        // showSearch(context: context, delegate: DataSearch());
                      },
                      child: Text(
                        'Tambah Admin',
                      ),
                    )
                  ),
                  SizedBox(width: 8.0,),
                ],
              ),
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
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'AKSES MASUK',
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
                            'AKSES PRODI',
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
                              children: [
                                if(_listDepartementTemp.length> 0)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: _listDepartementTemp.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Theme.of(context).dividerColor,
                                            width: 0.5,
                                          ),
                                          borderRadius: BorderRadius.circular(10.0)
                                        ),
                                        margin: index == 0 ? EdgeInsets.only(bottom: 5.0) : EdgeInsets.only(top: 5.0, bottom: 5.0),
                                        padding: EdgeInsets.all(12.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _listDepartementTemp[index].name
                                            ),
                                            ClipOval(
                                              child: Material(
                                                color: Colors.red[50],
                                                child: InkWell(
                                                  onTap: (){
                                                    setState(() {
                                                      for(int i = 0; i < _listDepartement.length; i++){
                                                        if(_listDepartement[i].id == _listDepartementTemp[index].id){
                                                          _listDepartement[i].check = false;
                                                        }
                                                      }
                                                      _listDepartementTemp.removeWhere((item) => item.id == _listDepartementTemp[index].id);
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(5.0),
                                                    child: Icon(
                                                      Icons.close,
                                                      size: 15.0,
                                                      color: Colors.red[800],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    }
                                  ),
                                ),
                                // if(_counter == 0)
                                Padding(
                                  padding: _listDepartementTemp.length == 0 ? const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 10.0) : const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 10.0),
                                  child: Row(
                                    mainAxisAlignment: _listDepartementTemp.length == 0 ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end, 
                                    children: [
                                      if(_listDepartementTemp.length == 0)
                                      Text(
                                        'Tambahkan Akses ke Prodi'
                                      ),
                                      FlatButton.icon(
                                        icon: Icon(
                                          Icons.add,
                                          size: 18.0,
                                        ),
                                        label: Text(
                                          'Tambah'
                                        ),
                                        onPressed: (){
                                          FocusScope.of(context).requestFocus(new FocusNode());
                                          _showDepartementDialog();
                                        },
                                        color: Theme.of(context).buttonColor,
                                        textColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0)
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            )
                          ),
                          SizedBox(
                            height: 32.0,
                          ),
                          Text(
                            'LAINNYA',
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
                            _showProgressDialog("Menyimpan admin...");
                            _getUsername();
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
          ),
        ), 
        onWillPop: null
      )
    );
  }

}