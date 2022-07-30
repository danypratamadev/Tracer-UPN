import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class CategoryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CategoryState();
  }

}

class Category {
  final String id, initial, name, description;

  Category(this.id, this.initial, this.name, this.description);
}

class CategoryState extends State {

  var _scaffoldkey = GlobalKey <ScaffoldState> ();
  final Firestore _firestore = Firestore.instance;
  List<Category> _listCategory = new List<Category>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _id_faculty, _id_departement, _name_departement;
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
    String id_faculty = preferences.getString('faculty');
    String name_departement = preferences.getString('departementName');
    setState(() {
      _id_departement = id_departement;
      _name_departement = name_departement;
      _id_faculty = id_faculty;
    });
    _getCategoryFromCloudFirestore();
  }

  _getCategoryFromCloudFirestore() async {
    List<Category> _listTemp = new List<Category>();
    await _firestore.collection('questionnaire').document('category').collection(_id_faculty).document(_id_departement).collection('list_category').orderBy('name').getDocuments().then((value){
      if(value.documents.isNotEmpty){
        value.documents.forEach((f) {
          if(!f.data['delete']){
            String initial;
            List splitName = f.data['name'].split(' ');
            if(splitName.length > 1){
              initial = '${splitName[0].toString().substring(0, 1)}${splitName[1].toString().substring(0, 1)}';
            } else {
              initial = splitName[0].toString().substring(0, 2);
            }
            Category category = new Category(f.documentID, initial, f.data['name'], f.data['description']);
            _listTemp.add(category);
          }
        });
      }
    });
    if(mounted){
      if(_listTemp.length > 0){
        setState(() {
          _listCategory = _listTemp;
        });
      } else {
        setState(() {
          _isEmpty = true;
        });
      }
    }
  }

  _saveCategoryToCloudFirestore() async {
    _firestore.collection('questionnaire').document('category').collection(_id_faculty).document(_id_departement).collection('list_category').where('name', isEqualTo: _nameController.text).getDocuments().then((value) async {
      if(value.documents.isEmpty){
        await _firestore.collection('questionnaire').document('category').collection(_id_faculty).document(_id_departement).collection('list_category').add({
          'name': _nameController.text,
          'description': _descController.text,
          'delete': false,
        });
        if(mounted){
          await _getCategoryFromCloudFirestore();
          Navigator.pop(context);
          _showSnackBar('Kategori berhasil disimpan.', Icons.verified_user, Colors.green[600]);
        }
      } else {
        Navigator.pop(context);
        _showSnackBar('Kategori sudah tersedia', Icons.warning, Colors.orange[600]);
      }
    });
  }

  _showAddCategoryDialog() {
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
                  'Tambah Kategori',
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
                    'Nama Kategori',
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
                  SizedBox(height: 20.0,),
                  Text(
                    'Deskripsi Kategori',
                  ),
                  SizedBox(height: 10.0,),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: TextFormField(
                      controller: _descController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan Deskripsi Kategori',
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
            Divider(
              height: 0.0,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: FlatButton(
                onPressed:() {
                  if(_nameController.text.length > 0 && _descController.text.length > 0){
                    Navigator.pop(context);
                    _showProgressDialog('Menyimpan kategori...');
                    _saveCategoryToCloudFirestore();
                  } else {
                    if(_nameController.text.length == 0 && _descController.text.length == 0){
                      Toast.show(
                        'Masukkan nama dan deskripsi kategori!', 
                        context, 
                        duration: Toast.LENGTH_SHORT, 
                        gravity:  Toast.BOTTOM,
                        backgroundColor: Colors.black87,
                        backgroundRadius: 8.0
                      );
                    } else if(_nameController.text.length == 0){
                      Toast.show(
                        'Masukkan nama kategori!', 
                        context, 
                        duration: Toast.LENGTH_SHORT, 
                        gravity:  Toast.BOTTOM,
                        backgroundColor: Colors.black87,
                        backgroundRadius: 8.0
                      );
                    } else {
                      Toast.show(
                        'Masukkan deskripsi kategori!', 
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
                  'Tambahkan Kategori',
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
                      // showSearch(context: context, delegate: DataSearch());
                    },
                    child: Text(
                      _isSelected ? '$_isSelectedCount' : 'Kelola Angket',
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
                        // _showAlertDialog();
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
                    color: Colors.blue.withAlpha(30),
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
                            Icons.library_books,
                            color: Colors.blue,
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
                        "Menambah atau Menghapus Kategori Angket Tracer Studi UPN 'Veteran' Yogyakarta",
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
                      'DAFTAR KATEGORI ANGKET',
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
                        _nameController.text = '';
                        _descController.text = '';
                        _showAddCategoryDialog();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'Tambah Kategori',
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
              if(_listCategory.length > 0)
              ListView.builder(
                itemCount: _listCategory.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, i){
                  return Column(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(15.0),
                        onTap: () async {
                          
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
                                      _listCategory[i].initial.toUpperCase(),
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
                                      _listCategory[i].name,
                                      style: TextStyle(
                                        fontFamily: 'Noto',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 3.0,),
                                    Text(
                                      _listCategory[i].description,
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
                        Icons.library_books,
                        color: Theme.of(context).dividerColor,
                        size: MediaQuery.of(context).size.width * 0.15,
                      ),
                      SizedBox(height: 16.0,),
                      Text(
                        'Kategori Angket Belum Tersedia.',
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
                height: MediaQuery.of(context).size.height * 0.1,
              ),
            ],
          ),
        ),
      )
    );
  }

}