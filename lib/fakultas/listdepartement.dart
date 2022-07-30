import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class ListdepartementPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ListdepartementState();
  }

}

class Departement {
  final String id, initial, name;

  Departement(this.id, this.initial, this.name);
}

class ListdepartementState extends State {

  var _scaffoldkey = GlobalKey <ScaffoldState> ();
  final _nameController = TextEditingController();
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
    String name = preferences.getString('name');
    setState(() {
      _id_faculty = id_faculty;
      _name = name;
    });
    _getDepartementFromCloudFirestore();
  }

  _getDepartementFromCloudFirestore() async {
    List<Departement> _listTemp = new List<Departement>();
    await _firestore.collection('departement').where('faculty', isEqualTo: _id_faculty).getDocuments().then((departement){
      if(departement.documents.isNotEmpty){
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
            _listTemp.add(departement);
          }
        });
      }
    });
    if(mounted){
      if(_listTemp.length > 0){
        setState(() {
          _listDepartement = _listTemp;
        });
      } else {
        setState(() {
          _isEmpty = true;
        });
      }
    }
  }

  _saveNewDepartementToCloudFirestore() async {
    await _firestore.collection('departement').add({
      'name': _nameController.text,
      'faculty': _id_faculty,
      'delete': false
    });
    if(mounted){
      _getDepartementFromCloudFirestore();
      Navigator.pop(context);
      _showSnackBar('Jurusan berhasil disimpan.', Icons.verified_user, Colors.green[600]);
    }
  }

  _updateDepartementFromCloudFirestore(String id) async {
    await _firestore.collection('departement').document(id).updateData({
      'name': _nameController.text,
    });
    if(mounted){
      _getDepartementFromCloudFirestore();
      Navigator.pop(context);
      _showSnackBar('Jurusan berhasil diperbarui.', Icons.verified_user, Colors.green[600]);
    }
  }

  _deleteDepartementFromCloudFirestore(String id) async {
    await _firestore.collection('departement').document(id).updateData({
      'delete': true,
    });
    if(mounted){
      _getDepartementFromCloudFirestore();
      Navigator.pop(context);
      _showSnackBar('Jurusan berhasil dihapus.', Icons.verified_user, Colors.green[600]);
    }
  }

  _showAddDepartementDialog(int action, String id) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Wrap(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 30.0, bottom: 30.0),
              child: Center(
                child: Text(
                  'Tambah Jurusan',
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
                children: [
                  Text(
                    'Nama Jurusan'
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Masukkan Nama Jurusan',
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
                onPressed: () {
                  if(_nameController.text.length > 0){
                    Navigator.pop(context);
                    FocusScope.of(context).requestFocus(new FocusNode());
                    if(action == 10){
                      _showProgressDialog('Menyimpan jurusan...');
                      _saveNewDepartementToCloudFirestore();
                    } else {
                      _showProgressDialog('Memperbarui jurusan...');
                      _updateDepartementFromCloudFirestore(id);
                    }
                  } else {
                    Toast.show(
                      'Nama jurusan tidak boleh kosong!', 
                      context, 
                      duration: Toast.LENGTH_SHORT, 
                      gravity:  Toast.BOTTOM,
                      backgroundColor: Colors.black87,
                      backgroundRadius: 8.0
                    );
                  }
                },
                child: Text(
                  action == 10 ? 'Simpan' : 'Perbarui',
                ),
                textColor: Theme.of(context).buttonColor,
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
                },
                child: Text(
                  'Batal',
                ),
              ),
            )
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

  _showAlertDialog(String id, String name){
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
                    'Apakah Anda yakin ingin menghapus jurusan $name?',
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
                      _showProgressDialog('Menghapus jurusan...');
                      _deleteDepartementFromCloudFirestore(id);
                    }, 
                    child: Text(
                      'Hapus',
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
    return SafeArea(
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
                      'Daftar Jurusan',
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
                            Icons.local_library,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0,),
                      Text(
                        'Kelola Jurusan',
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
                        'Lihat atau Menambah Jurusan Baru.',
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
                    InkWell(
                      borderRadius: BorderRadius.circular(8.0),
                      onTap: () async {
                        _nameController.text = '';
                        _showAddDepartementDialog(10, '-');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'Tambah Jurusan',
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
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
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
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.65,
                                child: Text(
                                  _listDepartement[i].name,
                                  style: TextStyle(
                                    fontFamily: 'Noto',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Spacer(),
                              PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                onSelected: (value){
                                  if(value == '10'){
                                    _nameController.text = _listDepartement[i].name;
                                    _showAddDepartementDialog(20, _listDepartement[i].id);
                                  } else {
                                    _showAlertDialog(_listDepartement[i].id, _listDepartement[i].name);
                                  }
                                },
                                itemBuilder: (context) {
                                  return <PopupMenuItem<String>>[
                                    PopupMenuItem<String>(
                                      value: '10',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.mode_edit,
                                            size: 18.0,
                                            color: Colors.grey[800],
                                          ),
                                          SizedBox(
                                            width: 16.0,
                                          ),
                                          Text(
                                            'Edit'
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: '20',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            size: 18.0,
                                            color: Colors.red[600],
                                          ),
                                          SizedBox(
                                            width: 16.0,
                                          ),
                                          Text(
                                            'Hapus'
                                          ),
                                        ],
                                      ),
                                    ),
                                  ];
                                },
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
            ]
          )
        )
      ),
    );
  }

}