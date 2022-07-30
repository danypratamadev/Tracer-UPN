import 'package:circular_check_box/circular_check_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracer_upn/jurusan/home.dart' as departement;

class DepartementPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DepartementState();
  }

}

class Access{
  final String initial, id_access, id_departement, name;
  bool active;

  Access(this.initial, this.id_access, this.id_departement, this.name, this.active);
}

class DepartementState extends State {

  Firestore _firestore = Firestore.instance;
  List<Access> _listAccess = new List<Access>();
  String _id;
  bool _buttonActive = false;

  @override
  void initState() {
    _getCurrentUser();
    super.initState();
  }

  _getCurrentUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('id');
    setState(() {
      _id = id;
    });
    _getAccessDepartement();
  }

  _getAccessDepartement() async {
    _firestore.collection('user').document(_id).collection('access').getDocuments().then((value){
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
              Access access = new Access(initial, f.documentID, f.data['departement'], data.data['name'], false);
              setState(() {
                _listAccess.add(access);
              });
            }
          });
        });
      }
    });
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
          leading: IconButton(
            icon: Icon(
              Icons.close
            ), 
            onPressed: (){
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            }
          ),
          title: Text(
            'Akses Jurusan Saya'
          ),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    if(_listAccess.length > 0)
                    ListView.builder(
                      itemCount: _listAccess.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index){
                        return Column(
                          children: [
                            InkWell(
                              onTap: (){
                                setState(() {
                                  for(int i = 0; i < _listAccess.length; i++){
                                    if(i == index){
                                      _listAccess[i].active = true;
                                      if(!_buttonActive){
                                        _buttonActive = true;
                                      }
                                    } else {
                                      _listAccess[i].active = false;
                                    }
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 20.0),
                                child: Row(
                                  children: <Widget>[
                                    CircularCheckBox(
                                      value: _listAccess[index].active, 
                                      onChanged: (value){
                                        setState(() {
                                          for(int i = 0; i < _listAccess.length; i++){
                                            if(i == index){
                                              _listAccess[i].active = true;
                                              if(!_buttonActive){
                                                _buttonActive = true;
                                              }
                                            } else {
                                              _listAccess[i].active = false;
                                            }
                                          }
                                        });
                                      }
                                    ),
                                    SizedBox(width: 24.0,),
                                    Flexible(
                                      child: Text(
                                        _listAccess[index].name,
                                        style: TextStyle(
                                          fontFamily: 'Noto',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              height: 0.0,
                              indent: 16.0,
                              endIndent: 16.0,
                            )
                          ],
                        );
                      },
                    )
                    else
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.5 - 120.0),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 40.0,
                            height: 40.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 3.0,
                            ),
                          ),
                        ],
                      )
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.15,
                    )
                  ],
                ),
              ),
              Positioned(
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
                      onPressed: _buttonActive ? () async {
                        SharedPreferences preferences = await SharedPreferences.getInstance();
                        String name;
                        for(int i = 0; i < _listAccess.length; i++){
                          if(_listAccess[i].active){
                            name = _listAccess[i].name;
                            preferences.setString('departement', _listAccess[i].id_departement);
                            preferences.setString('departementName', _listAccess[i].name);
                          }
                        }
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => departement.HomePage(title: name,)));
                      } : (){}, 
                      child: Text(
                        'Kelola Jurusan'
                      ),
                      textColor: _buttonActive ? Colors.white : Theme.of(context).disabledColor,
                      color: _buttonActive ? Theme.of(context).buttonColor : Theme.of(context).disabledColor.withAlpha(30),
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
    );
  }

}