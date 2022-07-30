import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracer_upn/fakultas/departement.dart';
import 'package:tracer_upn/fakultas/listadmin.dart';
import 'package:tracer_upn/fakultas/listdepartement.dart';
import 'package:tracer_upn/signin.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }

}

class Menu {
  final int id;
  final IconData icon;
  final String name, desc;
  final Color color;

  Menu(this.id, this.icon, this.name, this.desc, this.color);
}

class Departement {
  final String id, name;

  Departement(this.id, this.name);
}

class HomeState extends State {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;
  List<Menu> listMenu = new List<Menu>();
  List<Departement> _listDepartement = new List<Departement>();
  String _id, _name, _initial = '-', _email;

  Menu menu = new Menu(10, Icons.local_library, 'Kelola Jurusan', 'Lihat atau Menambah Jurusan', Colors.red);
  Menu menu2 = new Menu(20, Icons.group_add, 'Kelola Admin Jurusan', 'Lihat atau Menambah Admin Jurusan', Colors.indigo);
  Menu menu3 = new Menu(30, Icons.graphic_eq, 'Statik Angket', 'Lihat Statik Angket Alumni', Colors.deepPurple);
  Menu menu4 = new Menu(40, Icons.date_range, 'Laporan Angket', 'Export Statik Angket Alumni', Colors.green);

  @override
  void initState() {
    listMenu.add(menu);
    listMenu.add(menu2);
    listMenu.add(menu3);
    listMenu.add(menu4);
    _getCurrentUser();
    super.initState();
  }

  _getCurrentUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('id');
    String name = preferences.getString('name');
    String email = preferences.getString('email');
    List initial = preferences.getString('name').split(' ');
    setState(() {
      _id = id;
      _name = name;
      _email = email;
      if(initial.length > 1){
        _initial = '${initial[0].toString().substring(0, 1)}${initial[1].toString().substring(0, 1)}';
      } else {
        _initial = initial[0].substring(0, 1);
      }
    });
    _getDepartementFromCloudFirestore();
  }

  _getDepartementFromCloudFirestore() async {
    List<Departement> listTemp = new List<Departement>();
    await _firestore.collection('departement').getDocuments().then((value){
      if(value.documents.isNotEmpty){
        value.documents.forEach((f) async {
          Departement departement = new Departement(f.documentID, f.data['name']);
          listTemp.add(departement);
        });
      }
    });
    if(mounted){
      setState(() {
        _listDepartement = listTemp;
      });
    }
  }

  _onclickMenu(int id){
    switch(id){
      case 10:
        Navigator.push(context, MaterialPageRoute(builder: (context) => ListdepartementPage()));
      break;
      case 20:
        Navigator.push(context, MaterialPageRoute(builder: (context) => ListadminPage()));
      break;
      case 30:
        Navigator.push(context, MaterialPageRoute(builder: (context) => DepartementPage(action: 10,)));
      break;
      case 40:
        Navigator.push(context, MaterialPageRoute(builder: (context) => DepartementPage(action: 20,)));
      break;
    }
  }

  _showAccountDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Wrap(
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 30.0, bottom: 30.0),
              child: Column(
                children: <Widget>[
                  ClipOval(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: MediaQuery.of(context).size.width * 0.2,
                      color: Theme.of(context).accentColor,
                      child: Center(
                        child: Text(
                          _initial,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Theme.of(context).textTheme.headline5.fontSize,
                            fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ),
                  ),
                  SizedBox(height: 16.0,),
                  Text(
                    _name,
                    style: TextStyle(
                      fontFamily: 'Google',
                      fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                      fontWeight: FontWeight.bold
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.0,),
                  Text(
                    _email,
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.caption.fontSize,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
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
                  _showAlertDialog();
                },
                child: Text(
                  'Keluar Akun',
                  style: TextStyle(
                    fontFamily: 'Google',
                    fontWeight: FontWeight.bold,
                    color: Colors.red[600]
                  ),
                ),
              ),
            )
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
                SizedBox(width: 16.0,),
                Flexible(
                  fit: FlexFit.tight,
                  child: GestureDetector(
                    onTap: (){

                    },
                    child: Text(
                      'Tracer Studi UPN',
                    ),
                  )
                ),
                SizedBox(width: 8.0,),
                ClipOval(
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _initial.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Theme.of(context).textTheme.subtitle2.fontSize,
                              fontWeight: FontWeight.bold
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ),
                      onPressed: (){
                        _showAccountDialog();
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
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ClipOval(
                        child: Material(
                          color: Theme.of(context).backgroundColor,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Icon(
                              LineIcons.star,
                              color: Colors.orange[400],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 16.0,
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              'Halo, $_name',
                              style: TextStyle(
                                fontFamily: 'Noto',
                                fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              "Selamat datang di dashboard Admin Fakultas Universitas Pembangunan Nasional 'Veteran' Yogyakarta.",
                              style: TextStyle(
                                fontSize: Theme.of(context).textTheme.caption.fontSize,
                              ),
                            ),
                            SizedBox(
                              height: 5.0,
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
                  'DASHBOARD FAKULTAS',
                  style: TextStyle(
                    fontFamily: 'Google',
                    fontWeight: FontWeight.bold,
                    fontSize: Theme.of(context).textTheme.caption.fontSize,
                    color: Theme.of(context).textTheme.caption.color,
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: MediaQuery.of(context).size.width * 0.03,
                  mainAxisSpacing: MediaQuery.of(context).size.width * 0.03,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: listMenu.map((menu){
                    return Material(
                      color: menu.color.withAlpha(30),
                      borderRadius: BorderRadius.circular(20.0),
                      child: InkWell(
                        onTap: (){
                          _onclickMenu(menu.id);
                        },
                        borderRadius: BorderRadius.circular(15.0),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          padding: EdgeInsets.all(16.0),
                          child: Stack(
                            children: <Widget>[
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      menu.icon,
                                      color: menu.color,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      menu.name,
                                      style: TextStyle(
                                        fontFamily: 'Google',
                                        fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Text(
                                      menu.desc,
                                      style: TextStyle(
                                        fontSize: Theme.of(context).textTheme.caption.fontSize,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
              ]
            )
          )
        )
      )
    );
  }

}