import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracer_upn/alumni/biodata.dart';
import 'package:tracer_upn/alumni/profile.dart';
import 'package:tracer_upn/alumni/carrer.dart';
import 'package:tracer_upn/alumni/questionnaire.dart';
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

class HomeState extends State {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;
  List<Menu> listMenu = new List<Menu>();
  String _id, _name, _id_departement, _id_faculty, _initial = '-', _email;
  bool _bio = false, _carrer = false, _competency = false, _achievement = false, _search = false;

  Menu menu = new Menu(10, Icons.person_pin, 'Data Diri', 'Data diri lulusan', Colors.red);
  Menu menu2 = new Menu(20, Icons.work, 'Pekerjaan', 'Data pekerjaan yang sementara ditekuni lulusan', Colors.deepPurple);
  Menu menu3 = new Menu(30, Icons.folder_special, 'Angket Alumni', 'Angket penelusuran terkait waktu tunggu pekerjaan', Colors.green);

  @override
  void initState() {
    listMenu.add(menu);
    listMenu.add(menu2);
    listMenu.add(menu3);
    _getCurrentUser();
    super.initState();
  }

  _getCurrentUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('id');
    String id_departement = preferences.getString('departement');
    String id_faculty = preferences.getString('faculty');
    String name = preferences.getString('name');
    String email = preferences.getString('email');
    List initial = preferences.getString('name').split(' ');
    bool bio = preferences.getBool('biodata');
    bool carrer = preferences.getBool('carrer');
    bool competency = preferences.getBool('competency');
    bool achievement = preferences.getBool('achievement');
    bool search = preferences.getBool('search');
    print('BIODATA => $bio');
    setState(() {
      _id = id;
      _name = name;
      _id_departement = id_departement;
      _id_faculty = id_faculty;
      _bio = bio;
      _carrer = carrer;
      _competency = competency;
      _achievement = achievement;
      _search = search;
      _email = email;
      if(initial.length > 1){
        _initial = '${initial[0].toString().substring(0, 1)}${initial[1].toString().substring(0, 1)}';
      } else {
        _initial = initial[0].substring(0, 1);
      }
    });
    if(_carrer){
      _getCarrerFromCloudFirestor();
    }
  }

  _getCarrerFromCloudFirestor() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _firestore.collection('questionnaire').document('response').collection('carrer').document(_id_faculty).collection(_id_departement).document(_id).get().then((carrer){
      if(carrer.exists){
        preferences.setString('company', carrer.data['company']);
        preferences.setString('leader_name', carrer.data['leader_name']);
        preferences.setString('leader_email', carrer.data['leader_email']);
        preferences.setString('company_address', carrer.data['company_address']);
        preferences.setString('position', carrer.data['position']);
        preferences.setString('scale', carrer.data['scale']);
        preferences.setString('compatibility', carrer.data['compatibility']);
      }
    });
  }

  _onclickMenu(int id){
    switch(id){
      case 10:
        Navigator.push(context, MaterialPageRoute(builder: (context) => BiodataPage()));
      break;
      case 20:
        Navigator.push(context, MaterialPageRoute(builder: (context) => CarrerPage()));
      break;
      case 30:
        Navigator.push(context, MaterialPageRoute(builder: (context) => QuestionnairePage()));
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                if(_bio)
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'TRACER STUDI UPN',
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Universitas Pembangunan Nasional 'Veteran' Yogyakarta",
                        style: TextStyle(
                          fontFamily: 'Sans',
                          fontSize: Theme.of(context).textTheme.caption.fontSize,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                )
                else
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Selamat Datang',
                        style: TextStyle(
                          fontFamily: 'Sans',
                          fontSize: Theme.of(context).textTheme.caption.fontSize,
                        ),
                      ),
                      Text(
                        _name,
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    _showAccountDialog();
                    // if(_bio){
                    //   Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
                    // } else {
                    //   SharedPreferences preferences = await SharedPreferences.getInstance();
                    //   final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
                    //   bool bio = preferences.getBool('biodata');
                    //   if(bio){
                    //     setState(() {
                    //       _bio = bio;
                    //     });
                    //   }
                    // }
                  },
                  child: ClipOval(
                    child: Container(
                      width: 36.0,
                      height: 36.0,
                      color: Theme.of(context).accentColor,
                      child: Center(
                        child: Text(
                          _initial,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Theme.of(context).textTheme.subtitle2.fontSize,
                            fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
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
                  padding: _bio ? EdgeInsets.all(10.0) : EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 5.0),
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
                              _bio ? LineIcons.star : Icons.notifications_active,
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
                              _bio ? 'Halo, $_name' : 'HIMBAUAN',
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
                              _bio ? 'Terima kasih telah mengisi Biodata Anda sebelum mengisi Kuisioner.' : 'Lengkapi Biodata Anda sebelum mengisi Kuisioner.',
                              style: TextStyle(
                                fontSize: Theme.of(context).textTheme.caption.fontSize,
                              ),
                            ),
                            if(!_bio)
                            SizedBox(
                              height: 32.0,
                            ),
                            if(!_bio)
                            FlatButton.icon(
                              onPressed: () async {
                                SharedPreferences preferences = await SharedPreferences.getInstance();
                                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => BiodataPage()));
                                bool bio = preferences.getBool('biodata');
                                if(bio){
                                  setState(() {
                                    _bio = bio;
                                  });
                                }
                              }, 
                              icon: ClipOval(
                                child: Container(
                                  color: Theme.of(context).accentColor,
                                  child: Icon(
                                    Icons.keyboard_arrow_right,
                                    color: Colors.white,
                                    size: 18.0,
                                  ),
                                ),
                              ),
                              label: Text(
                                'Lengkapi Biodata',
                              ),
                              textColor: Theme.of(context).accentColor,
                              padding: EdgeInsets.zero,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                            )
                            else
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
                  'DASHBOARD ALUMNI',
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
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: MediaQuery.of(context).size.width * 0.03,
                  mainAxisSpacing: MediaQuery.of(context).size.width * 0.03,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: listMenu.map((menu){
                    return Material(
                      color: _bio ? menu.color.withAlpha(30) : Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(20.0),
                      child: InkWell(
                        onTap: _bio ? (){
                          _onclickMenu(menu.id);
                        } : null,
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
                                    color: _bio ? Colors.white : Theme.of(context).disabledColor.withAlpha(30),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      menu.icon,
                                      color: _bio ? menu.color : Theme.of(context).dividerColor,
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
                                        color: _bio ? null : Theme.of(context).disabledColor.withAlpha(50)
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Text(
                                      menu.desc,
                                      style: TextStyle(
                                        fontSize: Theme.of(context).textTheme.caption.fontSize,
                                        color: _bio ? null : Theme.of(context).disabledColor.withAlpha(50)
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
                  height: MediaQuery.of(context).size.height * 0.15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}