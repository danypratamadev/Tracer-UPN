import 'package:circular_check_box/circular_check_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class LevelPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LevelState();
  }

}

class DepartementLevel {
  final String id_departement, id_level, level, name;
  bool selected;

  DepartementLevel(this.id_departement, this.id_level, this.level, this.name, this.selected);
}

class Level {
  final String id, name;

  Level(this.id, this.name);
}

class LevelState extends State {

  var _scaffoldkey = GlobalKey <ScaffoldState> ();
  final Firestore _firestore = Firestore.instance;
  final _nameController = TextEditingController();
  List<DepartementLevel> _listDepartementLevel = new List<DepartementLevel>();
  List<Level> _listLevel = new List<Level>();
  String _id_departement, _name_departement, _id_level_selected;
  bool _isEmpty = false, _isSelected = false;
  int _isSelectedCount = 0;

  @override
  void initState() {
    _getDataSharedPref();
    super.initState();
  }

  _getDataSharedPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id_departement = preferences.getString('departement');
    String name_departement = preferences.getString('departementName');
    setState(() {
      _id_departement = id_departement;
      _name_departement = name_departement;
    });
    _getLevelDepartementFromCloudFirestore();
  }

  _getLevelDepartementFromCloudFirestore() async {
    await _firestore.collection('departement').document(_id_departement).collection('level').getDocuments().then((value){
      if(value.documents.isNotEmpty){
        _listDepartementLevel.clear();
        value.documents.forEach((f) {
          _firestore.collection('level').document(f.data['id_level']).get().then((values){
            if(values.exists){
              DepartementLevel level = new DepartementLevel(f.documentID, f.data['id_level'], values.data['name'], f.data['name'], false);
              setState(() {
                _listDepartementLevel.add(level);
              });
            }
          });
        });
      } else {
        setState(() {
          _isEmpty = true;
        });
      }
    });
    if(mounted){
      _getAllLevelFromCloudFirestore();
    }
  }

  _getAllLevelFromCloudFirestore() {
    _firestore.collection('level').getDocuments().then((value){
      if(value.documents.isNotEmpty){
        _listLevel.clear();
        value.documents.forEach((f) {
          Level level = new Level(f.documentID, f.data['name']);
          setState(() {
            _listLevel.add(level);
          });
        });
      }
    });
  }

  _checkLevelDepartement() async {
    bool already = false;
    await _firestore.collection('departement').document(_id_departement).collection('level').getDocuments().then((value){
      if(value.documents.isNotEmpty){
        value.documents.forEach((f) {
          if(f.data['id_level'].toString().toLowerCase() == _id_level_selected.toLowerCase() && f.data['name'].toString().toLowerCase() == _nameController.text.toLowerCase()){
            already = true;
          }
        });
      }
    });
    if(mounted){
      if(already){
        Navigator.pop(context);
        _showSnackBar('Program studi sudah tersedia!', Icons.warning, Colors.orange[600]);
      } else {
        _saveLevelDepartement();
      }
    }
  }

  _saveLevelDepartement() async {
    await _firestore.collection('departement').document(_id_departement).collection('level').add({
      'id_level': _id_level_selected,
      'name': _nameController.text,
    });
    if(mounted){
      Navigator.pop(context);
      _getLevelDepartementFromCloudFirestore();
      _showSnackBar('Berhasil menambah program studi.', Icons.verified_user, Colors.green[600]);
    }
  }

  _deleteLevelDepartement() async {
    for(int i = 0; i < _listDepartementLevel.length; i++){
      if(_listDepartementLevel[i].selected){
        await _firestore.collection('departement').document(_id_departement).collection('level').document(_listDepartementLevel[i].id_departement).delete().then((value){
          if(i == _listDepartementLevel.length - 1){
            Navigator.pop(context);
            _getLevelDepartementFromCloudFirestore();
            setState(() {
              _isSelected = false;
              _isSelectedCount = 0;
            });
            _showSnackBar('Berhasil menghapus program studi.', Icons.verified_user, Colors.green[600]);
          }
        });
      }
    }
  }

  _showAddProdiDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Wrap(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 30.0, bottom: 30.0),
              child: Center(
                child: Text(
                  'Tambah Program Studi',
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
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Jenjang',
                  ),
                  SizedBox(height: 10.0,),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: DropdownButtonFormField(
                      isExpanded: true,
                      value: _id_level_selected,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                      ),
                      items: _listLevel.map((level) {
                        return DropdownMenuItem(
                          value: level.id,
                          child: Text(
                            level.name,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _id_level_selected = value;
                        });
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
                  SizedBox(height: 20.0,),
                  Text(
                    'Nama Program Studi',
                  ),
                  SizedBox(height: 10.0,),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan Nama Kategori',
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
            Divider(
              height: 0.0,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: FlatButton(
                onPressed:() {
                  if(_id_level_selected != null && _nameController.text.length > 0){
                    Navigator.pop(context);
                    FocusScope.of(context).requestFocus(new FocusNode());
                    _showProgressDialog('Menyimpan prodi...');
                    _checkLevelDepartement();
                  } else {
                    if(_id_level_selected == null && _nameController.text.length == 0){
                      Toast.show(
                        'Jenjang dan nama prodi tidak boleh kosong!', 
                        context, 
                        duration: Toast.LENGTH_SHORT, 
                        gravity:  Toast.BOTTOM,
                        backgroundColor: Colors.black87,
                        backgroundRadius: 8.0
                      );
                    } else if(_nameController.text.length == 0){
                      Toast.show(
                        'Nama prodi tidak boleh kosong!', 
                        context, 
                        duration: Toast.LENGTH_SHORT, 
                        gravity:  Toast.BOTTOM,
                        backgroundColor: Colors.black87,
                        backgroundRadius: 8.0
                      );
                    } else {
                      Toast.show(
                        'Jenjang tidak boleh kosong!', 
                        context, 
                        duration: Toast.LENGTH_SHORT, 
                        gravity:  Toast.BOTTOM,
                        backgroundColor: Colors.black87,
                        backgroundRadius: 8.0
                      );
                    }
                  }
                },
                child: Text(
                  'Tambahkan Prodi',
                  style: TextStyle(
                    fontFamily: 'Google',
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).accentColor,
                  ),
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
                  'Hapus Program Studi',
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
                    'Apakah kamu yakin ingin menghapus Program Studi dari Tracer Studi UPN?',
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
                      _showProgressDialog('Menghapus prodi...');
                      _deleteLevelDepartement();
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

                      },
                      child: Text(
                        _isSelected ? '$_isSelectedCount' : 'Kelola Program Studi',
                      ),
                    )
                  ),
                  SizedBox(width: 8.0,),
                  if(_isSelected)
                  ClipOval(
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red[400],
                        ),
                        onPressed: (){
                          _showAlertDialog();
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
                              Icons.school,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0,),
                        Text(
                          'Jurusan $_name_departement',
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
                          'Menambah atau Menghapus Program Studi pada Jurusan $_name_departement.',
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
                        'DAFTAR PROGRAM STUDI',
                        style: TextStyle(
                          fontFamily: 'Google',
                          fontWeight: FontWeight.bold,
                          fontSize: Theme.of(context).textTheme.caption.fontSize,
                          color: Theme.of(context).textTheme.caption.color,
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(8.0),
                        onTap: () {
                          _nameController.text = _name_departement;
                          _id_level_selected = null;
                          _showAddProdiDialog();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'Tambah Prodi',
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
                if(_listDepartementLevel.length > 0)
                ListView.builder(
                  itemCount: _listDepartementLevel.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, i){
                    return Column(
                      children: [
                        Material(
                          color: _listDepartementLevel[i].selected ? Theme.of(context).dividerColor.withAlpha(10) : Theme.of(context).backgroundColor,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15.0),
                            onTap: (){
                              if(_isSelected){
                                if(_listDepartementLevel[i].selected){
                                  setState(() {
                                    _listDepartementLevel[i].selected = false;
                                    _isSelectedCount--;
                                    if(_isSelectedCount == 0){
                                      _isSelected = false;
                                    }
                                  });
                                } else {
                                  setState(() {
                                    _listDepartementLevel[i].selected = true;
                                    _isSelectedCount++;
                                  });
                                }
                              }
                            },
                            onLongPress: (){
                              if(_isSelected){
                                if(_listDepartementLevel[i].selected){
                                  setState(() {
                                    _listDepartementLevel[i].selected = false;
                                    _isSelectedCount--;
                                    if(_isSelectedCount == 0){
                                      _isSelected = false;
                                    }
                                  });
                                } else {
                                  setState(() {
                                    _listDepartementLevel[i].selected = true;
                                    _isSelectedCount++;
                                  });
                                }
                              } else {
                                setState(() {
                                  _isSelected = true;
                                  _listDepartementLevel[i].selected = true;
                                  _isSelectedCount++;
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 20.0),
                              child: Row(
                                children: <Widget>[
                                  if(_isSelected)
                                  CircularCheckBox(
                                    value: _listDepartementLevel[i].selected, 
                                    onChanged: (value){
                                      if(_isSelected){
                                        if(_listDepartementLevel[i].selected){
                                          setState(() {
                                            _listDepartementLevel[i].selected = value;
                                            _isSelectedCount--;
                                            if(_isSelectedCount == 0){
                                              _isSelected = false;
                                            }
                                          });
                                        } else {
                                          setState(() {
                                            _listDepartementLevel[i].selected = value;
                                            _isSelectedCount++;
                                          });
                                        }
                                      }
                                    }
                                  )
                                  else
                                  ClipOval(
                                    child: Container(
                                      width: 35.0,
                                      height: 35.0,
                                      color: Theme.of(context).accentColor,
                                      child: Center(
                                        child: Text(
                                          _listDepartementLevel[i].level,
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
                                    child: Text(
                                      '${_listDepartementLevel[i].level} ${_listDepartementLevel[i].name}',
                                      style: TextStyle(
                                        fontFamily: 'Noto',
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Divider(
                          height: 0.0,
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
                        Icon(
                          FontAwesome.folder,
                          color: Theme.of(context).dividerColor,
                          size: MediaQuery.of(context).size.width * 0.15,
                        ),
                        SizedBox(height: 16.0,),
                        Text(
                          'Program Studi Belum Tersedia.',
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
        onWillPop: _isSelected ? (){
          setState(() {
            _isSelected = false;
            _isSelectedCount = 0;
            for(int i = 0; i < _listDepartementLevel.length; i++){
              setState(() {
                _listDepartementLevel[i].selected = false;
              });
            }
          });
        } : null,
      ),
    );
  }

}