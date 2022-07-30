import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';

class ProfilePage extends StatefulWidget {

  final String id, initial, email, username, pass, name, gender, phone, address;

  const ProfilePage({Key key, @required this.id, @required this.initial, @required this.email, @required this.username, @required this.pass, @required this.name, @required this.gender, @required this.phone, @required this.address,}) : super(key: key);
  
  @override
  State<StatefulWidget> createState() {
    return ProfileState();
  }

}

class Access{
  final String initial, id_access, id_departement, name;

  Access(this.initial, this.id_access, this.id_departement, this.name);
}

class ProfileState extends State<ProfilePage> {

  Firestore _firestore = Firestore.instance;
  List<Access> _listAccess = new List<Access>();
  List _splitName;

  @override
  void initState() {
    _getAccessDepartement();
    _splitName = widget.name.split(' ');
    super.initState();
  }

  _getAccessDepartement() async {
    _firestore.collection('user').document(widget.id).collection('access').getDocuments().then((value){
      if(value.documents.isNotEmpty){
        value.documents.forEach((f) {
          _firestore.collection('departement').document(f.data['departement']).get().then((data){
            if(data.exists){
              List splitName = data.data['name'].toString().split(' ');
              String initial;
              if(splitName.length > 1){
                initial = '${splitName[0].toString().substring(0, 1)}${splitName[1].toString().substring(0, 1)}';
              } else {
                initial = splitName[0].toString().substring(0, 2);
              }
              Access access = new Access(initial, f.documentID, f.data['departement'], data.data['name']);
              setState(() {
                _listAccess.add(access);
              });
            }
          });
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
                      'Profil Admin Jurusan',
                    ),
                  )
                ),
                SizedBox(width: 8.0,),
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
                widget.email,
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
                    'AKSES PRODI',
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
              ListView.builder(
                itemCount: _listAccess.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index){
                  return Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.lock,
                          color: Colors.transparent,
                        ),
                        title: Text(
                          _listAccess[index].name,
                          style: Theme.of(context).textTheme.bodyText1
                        ),
                      ),
                      if(index < _listAccess.length - 1)
                      Divider(
                        height: 0.0,
                        indent: 70.0,
                        endIndent: 16.0,
                      ),
                    ],
                  );
                }
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
                  'Hapus ${_splitName[0]} ${_splitName[1]}',
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