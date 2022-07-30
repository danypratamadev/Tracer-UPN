import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracer_upn/fakultas/report2.dart';
import 'package:tracer_upn/fakultas/static.dart';

class DepartementPage extends StatefulWidget {

  final int action;

  const DepartementPage({Key key, @required this.action}) : super(key: key); 

  @override
  State<StatefulWidget> createState() {
    return DepartementState();
  }

}

class Departement {
  final String id, initial, name;

  Departement(this.id, this.initial, this.name);
}

class DepartementState extends State<DepartementPage> {

  final Firestore _firestore = Firestore.instance;
  List<Departement> _listDepartement = new List<Departement>();
  String _id_faculty, _name;
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
    _getDepartementFromCloudFirestore();
  }

  _getDepartementFromCloudFirestore() {
    _firestore.collection('departement').where('faculty', isEqualTo: _id_faculty).getDocuments().then((departement){
      if(departement.documents.isNotEmpty){
        _listDepartement.clear();
        departement.documents.forEach((value) {
          if(!value.data['delete']){
            String initial;
            List splitName = value.data['name'].split(' ');
            if(splitName.length > 1){
              initial = '${splitName[0].toString().substring(0, 1)}${splitName[1].toString().substring(0, 1)}';
            } else {
              initial = splitName[0].toString().substring(0, 2);
            }
            Departement departement = new Departement(value.documentID, initial, value.data['name']);
            setState(() {
              _listDepartement.add(departement);
            });
          }
        });
      } else {
        setState(() {
          _isEmpty = true;
        });
      }
    });
  }
  
  _checkPermission(String id, String name) async {
    if(await Permission.storage.request().isGranted){
      Navigator.push(context, MaterialPageRoute(builder: (context) => ReportPage(id: id, name: name,)));
    } else {
      _checkPermission(id, name);
    }
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
                      'Pilih Jurusan',
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
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.grey.withAlpha(30),
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
                            Icons.local_library,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0,),
                      Text(
                        'Jurusan',
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
                        widget.action == 10 ? 'Silakan pilih jurusan untuk melihat statik angket setiap jurusan.' : 'Silakan pilih jurusan untuk melihat laporan setiap jurusan.',
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
                      'DAFTAR JURUSAN',
                      style: TextStyle(
                        fontFamily: 'Google',
                        fontWeight: FontWeight.bold,
                        fontSize: Theme.of(context).textTheme.caption.fontSize,
                        color: Theme.of(context).textTheme.caption.color,
                      ),
                    ),
                    
                  ],
                ),
              ),
              if(_listDepartement.length > 0)
              ListView.builder(
                itemCount: _listDepartement.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, i){
                  return Column(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(15.0),
                        onTap: () {
                          if(widget.action == 10){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => StaticPage(id_departement: _listDepartement[i].id, name: _listDepartement[i].name,)));
                          } else {
                            _checkPermission(_listDepartement[i].id, _listDepartement[i].name);
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
                                      _listDepartement[i].initial.toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                ),
                              ),
                              SizedBox(width: 24.0,),
                              Text(
                                _listDepartement[i].name,
                                style: TextStyle(
                                  fontFamily: 'Noto',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              )
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
                        Icons.local_library,
                        color: Theme.of(context).dividerColor,
                        size: MediaQuery.of(context).size.width * 0.15,
                      ),
                      SizedBox(height: 16.0,),
                      Text(
                        'Jurusan Belum Tersedia.',
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