import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracer_upn/fakultas/addadmin.dart';
import 'package:tracer_upn/fakultas/profile.dart';

class ListadminPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ListadminState();
  }

}

class User{
  final String id, initial, email, username, pass, name, gender, phone, address;

  User(this.id, this.initial, this.email, this.username, this.pass, this.name, this.gender, this.phone, this.address);

}

class ListadminState extends State {

  final Firestore _firestore = Firestore.instance;
  List<User> _listUser = new List<User>();
  String _id_faculty;
  bool _isEmpty = false;

  @override
  void initState() {
    _getDataFromSharedPref();
    super.initState();
  }

  _getDataFromSharedPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id_faculty = preferences.getString('faculty');
    setState(() {
      _id_faculty = id_faculty;
    });
    _getUserFromCloudFirestore();
  }

  _getUserFromCloudFirestore() {
    _firestore.collection('user').where('role', isEqualTo: 2).getDocuments().then((user){
      if(user.documents.isNotEmpty){
        int i = 0;
        user.documents.forEach((f) {
          _firestore.collection('user').document(f.documentID).collection('biodata').document('data').get().then((value){
            if(value.exists){
              if(value.data['faculty'] == _id_faculty && !f.data['delete']){
                String initial;
                List splitName = value.data['name'].split(' ');
                if(splitName.length > 1){
                  initial = '${splitName[0].toString().substring(0, 1)}${splitName[1].toString().substring(0, 1)}';
                } else {
                  initial = splitName[0].toString().substring(0, 2);
                }
                User user = new User(f.documentID, initial, f.data['email'], f.data['username'], f.data['pass'], value.data['name'], value.data['gender'], value.data['phone'], value.data['address'],);
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
        });
      } else {
        setState(() {
          _isEmpty = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      'Daftar Admin Jurusan',
                    ),
                  )
                ),
                SizedBox(width: 8.0,),
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
                    color: Colors.indigo.withAlpha(30),
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
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0,),
                      Text(
                        'Admin Jurusan',
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
                        'Lihat atau Tambahkan Admin Jurusan Baru.',
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
                      'DAFTAR ADMIN JURUSAN',
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
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddadminPage()));
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
                              'Tambah Admin',
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
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(15.0),
                        onTap: () async {
                          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(id: _listUser[i].id, initial: _listUser[i].initial, email: _listUser[i].email, username: _listUser[i].username, pass: _listUser[i].pass, name: _listUser[i].name, gender: _listUser[i].gender, phone: _listUser[i].phone, address: _listUser[i].address,)));
                          if(result != null){
                            if(result){
                              _listUser.clear();
                              _getUserFromCloudFirestore();
                            }
                          }
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
                                      _listUser[i].initial.toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white,
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
                                    ),
                                    SizedBox(height: 3.0,),
                                    Text(
                                      _listUser[i].email,
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
                        'Admin Jurusan Belum Tersedia.',
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
    );
  }

}