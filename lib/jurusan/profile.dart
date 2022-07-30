import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:tracer_upn/jurusan/addalumnus.dart';

class ProfilePage extends StatefulWidget {

  final String id, initial, email, username, pass, name, nim, gender, phone, address, birthplace, birthdatetext, departement, entryyear, graduationyear, faculty, level;
  final DateTime birthdate;

  const ProfilePage({Key key, @required this.id, @required this.initial, @required this.email, @required this.username, @required this.pass, @required this.name, @required this.nim, @required this.gender, @required this.phone, @required this.address, @required this.birthplace, @required this.birthdate, @required this.birthdatetext, @required this.departement, @required this.entryyear, @required this.graduationyear, @required this.faculty, @required this.level}) : super(key: key);
  
  @override
  State<StatefulWidget> createState() {
    return ProfileState();
  }

}

class ProfileState extends State<ProfilePage> {

  Firestore _firestore = Firestore.instance;
  String _depatementName, _levelName = '-', _prodiName = '-';
  List _splitName;

  @override
  void initState() {
    _getDataFromSharedPref();
    _getLevelDepartementFromCloudFirestore();
    _splitName = widget.name.split(' ');
    super.initState();
  }

  _getDataFromSharedPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String depatementName = preferences.getString('departementName');
    setState(() {
      _depatementName = depatementName;
    });
  }

  _getLevelDepartementFromCloudFirestore() {
    _firestore.collection('departement').document(widget.departement).collection('level').document(widget.level).get().then((value){
      if(value.exists){
        _firestore.collection('level').document(value.data['id_level']).get().then((values){
          if(values.exists){
            setState(() {
              _levelName = values.data['name'];
              _prodiName = value.data['name'];
            });
          }
        });
      }
    });
  }

  _deleteAlumnusFromCloudFirestore() async {
    _firestore.collection('user').document(widget.id).updateData({
      'delete': true
    });
    if(mounted){
      Timer(Duration(seconds: 2), (){
        Navigator.pop(context);
        Toast.show(
          'Berhasil menghapus ${_splitName[0]}.', 
          context, 
          duration: Toast.LENGTH_SHORT, 
          gravity:  Toast.BOTTOM,
          backgroundColor: Colors.black87,
          backgroundRadius: 8.0
        );
        Navigator.pop(context, true);
      });
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
                  'Hapus ${widget.name}',
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
                    'Apakah Anda yakin ingin menghapus ${_splitName[0]} dari Tracer Studi UPN?',
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
                      _deleteAlumnusFromCloudFirestore();
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
                  "Menghapus ${_splitName[0]}...",
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
                      'Profil Alumni',
                    ),
                  )
                ),
                SizedBox(width: 8.0,),
                ClipOval(
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: Icon(
                        Icons.edit
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddalumnusPage(action: 20, id: widget.id, name: widget.name, gender: widget.gender, phone: widget.phone, address: widget.address, birthplace: widget.birthplace, birthdate: widget.birthdate, birthdatetext: widget.birthdatetext, level: widget.level, entryyear: widget.entryyear, graduationyear: widget.graduationyear)));
                        if(result != null){
                          if(result){
                            
                          }
                        }
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
            children: [
              SizedBox(
                height: 32.0,
              ),
              ClipOval(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  height: MediaQuery.of(context).size.width * 0.2,
                  color: Theme.of(context).accentColor,
                  child: Center(
                    child: Text(
                      widget.initial.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Google',
                        fontWeight: FontWeight.bold,
                        fontSize: Theme.of(context).textTheme.headline6.fontSize,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                ),
              ),
              SizedBox(
                height: 16.0,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Text(
                  widget.name,
                  style: TextStyle(
                    fontFamily: 'Google',
                    fontWeight: FontWeight.bold,
                    fontSize: Theme.of(context).textTheme.headline6.fontSize,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              Text(
                widget.nim,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 32.0,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'AKSES MASUK',
                    style: TextStyle(
                      fontFamily: 'Google',
                      fontWeight: FontWeight.bold,
                      fontSize: Theme.of(context).textTheme.overline.fontSize,
                      color: Theme.of(context).textTheme.caption.color,
                    ),
                  ),
                ),
              ),
              Divider(
                height: 0.0,
              ),
              ListTile(
                leading: Icon(
                  Icons.mail,
                  color: Colors.transparent,
                ),
                title: Text(
                  'Email',
                  style: Theme.of(context).textTheme.caption
                ),
                subtitle: Text(
                  widget.email,
                  style: Theme.of(context).textTheme.bodyText1
                ),
              ),
              Divider(
                height: 0.0,
                indent: 70.0,
                endIndent: 16.0,
              ),
              ListTile(
                leading: Icon(
                  Icons.person,
                  color: Colors.transparent,
                ),
                title: Text(
                  'Username',
                  style: Theme.of(context).textTheme.caption
                ),
                subtitle: Text(
                  widget.username,
                  style: Theme.of(context).textTheme.bodyText1
                ),
              ),
              Divider(
                height: 0.0,
                indent: 70.0,
                endIndent: 16.0,
              ),
              ListTile(
                leading: Icon(
                  Icons.lock,
                  color: Colors.transparent,
                ),
                title: Text(
                  'Password',
                  style: Theme.of(context).textTheme.caption
                ),
                subtitle: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for(int i = 0; i < widget.pass.length; i++)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7.0,
                          height: 7.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(
                          width: 2.0,
                        )
                      ],
                    )
                  ],
                ),
                // trailing: IconButton(
                //   icon: Icon(
                //     Icons.send
                //   ),
                //   onPressed: (){
                    
                //   },
                // ),
              ),
              Divider(
                height: 0.0,
              ),
              SizedBox(
                height: 16.0,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'BIODATA',
                    style: TextStyle(
                      fontFamily: 'Google',
                      fontWeight: FontWeight.bold,
                      fontSize: Theme.of(context).textTheme.overline.fontSize,
                      color: Theme.of(context).textTheme.caption.color,
                    ),
                  ),
                ),
              ),
              Divider(
                height: 0.0,
              ),
              ListTile(
                leading: Icon(
                  Icons.mail,
                  color: Colors.transparent,
                ),
                title: Text(
                  'Nama Lengkap',
                  style: Theme.of(context).textTheme.caption
                ),
                subtitle: Text(
                  widget.name,
                  style: Theme.of(context).textTheme.bodyText1
                ),
              ),
              Divider(
                height: 0.0,
                indent: 70.0,
                endIndent: 16.0,
              ),
              ListTile(
                leading: Icon(
                  Icons.person,
                  color: Colors.transparent,
                ),
                title: Text(
                  'Nomor Induk Mahasiswa',
                  style: Theme.of(context).textTheme.caption
                ),
                subtitle: Text(
                  widget.nim,
                  style: Theme.of(context).textTheme.bodyText1
                ),
              ),
              Divider(
                height: 0.0,
                indent: 70.0,
                endIndent: 16.0,
              ),
              ListTile(
                leading: Icon(
                  Icons.lock,
                  color: Colors.transparent,
                ),
                title: Text(
                  'Tempat Tanggal Lahir',
                  style: Theme.of(context).textTheme.caption
                ),
                subtitle: Text(
                  '${widget.birthplace}, ${widget.birthdatetext}',
                  style: Theme.of(context).textTheme.bodyText1
                ),
              ),
              Divider(
                height: 0.0,
                indent: 70.0,
                endIndent: 16.0,
              ),
              ListTile(
                leading: Icon(
                  Icons.lock,
                  color: Colors.transparent,
                ),
                title: Text(
                  'Jenis Kelamin',
                  style: Theme.of(context).textTheme.caption
                ),
                subtitle: Text(
                  widget.gender,
                  style: Theme.of(context).textTheme.bodyText1
                ),
              ),
              Divider(
                height: 0.0,
                indent: 70.0,
                endIndent: 16.0,
              ),
              ListTile(
                leading: Icon(
                  Icons.lock,
                  color: Colors.transparent,
                ),
                title: Text(
                  'Nomor Telepon',
                  style: Theme.of(context).textTheme.caption
                ),
                subtitle: Text(
                  widget.phone,
                  style: Theme.of(context).textTheme.bodyText1
                ),
              ),
              Divider(
                height: 0.0,
                indent: 70.0,
                endIndent: 16.0,
              ),
              ListTile(
                leading: Icon(
                  Icons.lock,
                  color: Colors.transparent,
                ),
                title: Text(
                  'Alamat',
                  style: Theme.of(context).textTheme.caption
                ),
                subtitle: Text(
                  widget.address,
                  style: Theme.of(context).textTheme.bodyText1
                ),
              ),
              Divider(
                height: 0.0,
              ),
              SizedBox(
                height: 16.0,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'AKADEMIK',
                    style: TextStyle(
                      fontFamily: 'Google',
                      fontWeight: FontWeight.bold,
                      fontSize: Theme.of(context).textTheme.overline.fontSize,
                      color: Theme.of(context).textTheme.caption.color,
                    ),
                  ),
                ),
              ),
              Divider(
                height: 0.0,
              ),
              ListTile(
                leading: Icon(
                  Icons.lock,
                  color: Colors.transparent,
                ),
                title: Text(
                  'Program Studi',
                  style: Theme.of(context).textTheme.caption
                ),
                subtitle: Text(
                  _levelName != '-' && _prodiName != '-' ? '$_levelName $_prodiName' : '$_depatementName',
                  style: Theme.of(context).textTheme.bodyText1
                ),
              ),
              Divider(
                height: 0.0,
                indent: 70.0,
                endIndent: 16.0,
              ),
              ListTile(
                leading: Icon(
                  Icons.lock,
                  color: Colors.transparent,
                ),
                title: Text(
                  'Tahun Masuk',
                  style: Theme.of(context).textTheme.caption
                ),
                subtitle: Text(
                  widget.entryyear,
                  style: Theme.of(context).textTheme.bodyText1
                ),
              ),
              Divider(
                height: 0.0,
                indent: 70.0,
                endIndent: 16.0,
              ),
              ListTile(
                leading: Icon(
                  Icons.lock,
                  color: Colors.transparent,
                ),
                title: Text(
                  'Tahun Lulus',
                  style: Theme.of(context).textTheme.caption
                ),
                subtitle: Text(
                  widget.graduationyear,
                  style: Theme.of(context).textTheme.bodyText1
                ),
              ),
              Divider(
                height: 0.0,
              ),
              SizedBox(
                height: 48.0,
              ),
              FlatButton(
                onPressed: (){
                  _showAlertDialog();
                }, 
                child: Text(
                  _splitName.length > 1 ? 'Hapus ${_splitName[0]} ${_splitName[1]}' : 'Hapus ${_splitName[0]}',
                ),
                textColor: Colors.red[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.15,
              )
            ],
          ),
        ),
      ),
    );
  }

}