import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CarrerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CarrerState();
  }

}

class Optional{
  String title;
  bool check;

  Optional(this.title, this.check);
}

class CarrerState extends State<CarrerPage> {

  var _scaffoldkey = GlobalKey <ScaffoldState> ();
  final Firestore _firestore = Firestore.instance;
  final _companyController = TextEditingController();
  final _leadernameController = TextEditingController();
  final _leaderemailController = TextEditingController();
  final _companyaddressController = TextEditingController();
  final _positionController = TextEditingController();
  final _scaleController = TextEditingController();
  final _compatibilityController = TextEditingController();
  String _id, _id_depertement, _id_faculty, _position, _scale, _compatibility;
  bool _readOnly = true, _buttonActive = false, _canVibrate = false, _carrer = false, _allowBack = false;
  double _rightPosFA = 16.0, _bottomPosBtn = -200;
  List<Optional> _listPosition = new List<Optional>();
  List<Optional> _listScale = new List<Optional>();
  List<Optional> _listCompatibility = new List<Optional>();

  Optional optional = new Optional('Direksi', false);
  Optional optional2 = new Optional('Top Manager', false);
  Optional optional3 = new Optional('Middle Manager', false);
  Optional optional4 = new Optional('Low Manager', false);
  Optional optional5 = new Optional('Supervisor', false);
  Optional optional6 = new Optional('Staff', false);
  Optional optional7 = new Optional('Lainnya', false);

  Optional optional8 = new Optional('Lokal', false);
  Optional optional9 = new Optional('Nasional', false);
  Optional optional10 = new Optional('Internasional', false);

  Optional optional11 = new Optional('Sangat Sesuai', false);
  Optional optional12 = new Optional('Sesuai', false);
  Optional optional13 = new Optional('Cukup', false);
  Optional optional14 = new Optional('Tidak Sesuai', false);
  Optional optional15 = new Optional('Sangat Tidak Sesuai', false);

  @override
  void initState() {
    _checkDeviceVibrate();
    _getCarrer();
    _listPosition.add(optional);
    _listPosition.add(optional2);
    _listPosition.add(optional3);
    _listPosition.add(optional4);
    _listPosition.add(optional5);
    _listPosition.add(optional6);
    _listPosition.add(optional7);
    _listScale.add(optional8);
    _listScale.add(optional9);
    _listScale.add(optional10);
    _listCompatibility.add(optional11);
    _listCompatibility.add(optional12);
    _listCompatibility.add(optional13);
    _listCompatibility.add(optional14);
    _listCompatibility.add(optional15);
    _positionController.addListener(() {
      _enableButton();
    });
    _scaleController.addListener(() {
      _enableButton();
    });
    _compatibilityController.addListener(() {
      _enableButton();
    });
    super.initState();
  }

  _checkDeviceVibrate() async {
    bool canVibrate = await Vibrate.canVibrate;
    setState(() {
      _canVibrate = canVibrate;
    });
  }

  _enableButton() {
    if(_companyController.text.length > 0 && _leadernameController.text.length > 0 && _leaderemailController.text.length > 0 && _companyaddressController.text.length > 0 && _position != '' && _scale != '' && _compatibility != ''){
      setState(() {
        _buttonActive = true;
      });
    } else {
      setState(() {
        _buttonActive = false;
      });
    }
  }

  _getCarrer() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('id');
    String id_departement = preferences.getString('departement');
    String id_faculty = preferences.getString('faculty');
    String company = preferences.getString('company');
    String leader_name = preferences.getString('leader_name');
    String leader_email = preferences.getString('leader_email');
    String company_address = preferences.getString('company_address');
    String position = preferences.getString('position');
    String scale = preferences.getString('scale');
    String compatibility = preferences.getString('compatibility');
    bool carrer = preferences.getBool('carrer');
    setState(() {
      _id = id;
      _id_depertement = id_departement;
      _id_faculty = id_faculty;
      _carrer = carrer;
      if(!_carrer && !_allowBack){
        _readOnly = false;
        _rightPosFA = -200.0;
        _bottomPosBtn = 0.0;
      }
      if(company != null){
        _companyController.text = company;
      }
      if(leader_name != null){
        _leadernameController.text = leader_name;
      }
      if(leader_email != null){
        _leaderemailController.text = leader_email;
      }
      if(company_address != null){
        _companyaddressController.text = company_address;
      }
      if(position != null){
        _position = position;
        _positionController.text = position;
      }
      if(scale != null){
        _scale = scale;
        _scaleController.text = scale;
      }
      if(compatibility != null){
        _compatibility = compatibility;
        _compatibilityController.text = compatibility;
      }
    });
  }

  _saveWorksDataToCloudFirestor() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await _firestore.collection('questionnaire').document('response').collection('carrer').document(_id_faculty).collection(_id_depertement).document(_id).setData({
      'company': _companyController.text,
      'leader_name': _leadernameController.text,
      'leader_email': _leaderemailController.text,
      'company_address': _companyaddressController.text,
      'position': _positionController.text,
      'scale': _scaleController.text,
      'compatibility': _compatibilityController.text,
    });
    if(mounted){
      if(_carrer){
        Navigator.pop(context);
        preferences.setString('company', _companyController.text);
        preferences.setString('leader_name', _leadernameController.text);
        preferences.setString('leader_email', _leaderemailController.text);
        preferences.setString('company_address', _companyaddressController.text);
        preferences.setString('position', _positionController.text);
        preferences.setString('scale', _scaleController.text);
        preferences.setString('compatibility', _compatibilityController.text);
        setState(() {
          _readOnly = true;
          _rightPosFA = 16.0;
          _bottomPosBtn = -200;
        });
        _getCarrer();
        _showSnackBar('Pekerjaan berhasil disimpan.', Icons.verified_user, Colors.green[600]);
      } else {
        _updateDataUser();
      }
    }
  }

  _updateDataUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await _firestore.collection('user').document(_id).collection('biodata').document('data').setData({
      'carrer': true,
    }, merge: true);
    if(mounted){
      Navigator.pop(context);
      preferences.setString('company', _companyController.text);
      preferences.setString('leader_name', _leadernameController.text);
      preferences.setString('leader_email', _leaderemailController.text);
      preferences.setString('company_address', _companyaddressController.text);
      preferences.setString('position', _positionController.text);
      preferences.setString('scale', _scaleController.text);
      preferences.setString('compatibility', _compatibilityController.text);
      preferences.setBool('carrer', true);
      setState(() {
        _readOnly = true;
        _rightPosFA = 16.0;
        _bottomPosBtn = -200;
      });
      _getCarrer();
      _showSnackBar('Pekerjaan berhasil disimpan.', Icons.verified_user, Colors.green[600]);
    }
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
                  "Menyimpan data...",
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
          appBar: AppBar(
            title: Text(
              'Pekerjaan Saya'
            ),
            elevation: 0.0,
          ),
          body: GestureDetector(
            onTap: (){
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Theme.of(context).backgroundColor,
              child: Stack(
                children: <Widget>[
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.deepPurple.withAlpha(30),
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
                                      Icons.work,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16.0,),
                                Text(
                                  'Pekerjaan',
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
                                  'Data Pekerjaan yang sementara ditekuni oleh Lulusan.',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 32.0,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'DATA PEKERJAAN',
                                style: TextStyle(
                                  fontFamily: 'Google',
                                  fontWeight: FontWeight.bold,
                                  fontSize: Theme.of(context).textTheme.caption.fontSize,
                                  color: Theme.of(context).textTheme.caption.color,
                                ),
                              ),
                              AnimatedOpacity(
                                duration: Duration(milliseconds: 500),
                                opacity: _readOnly ? 0.0 : 1.0,
                                curve: Curves.fastOutSlowIn,
                                child: Text(
                                  'Mode Edit Aktif',
                                  style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.caption.fontSize,
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                              color: Colors.grey[50],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Posisi/Jabatan',
                                      ),
                                      SizedBox(height: 10.0,),
                                      if(_readOnly)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: TextFormField(
                                          controller: _positionController,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.only(left: 12.0, top: 15.0),
                                            hintText: 'Pilih Posisi/Jabatan',
                                            border: InputBorder.none,
                                            filled: true,
                                            suffixIcon: Icon(
                                              Icons.keyboard_arrow_down,
                                            ),
                                          ),
                                          style: Theme.of(context).textTheme.bodyText1,
                                          keyboardType: TextInputType.text,
                                        ),
                                      )
                                      else
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: DropdownButtonFormField(
                                          isExpanded: true,
                                          value: _position,
                                          icon: Icon(
                                            Icons.keyboard_arrow_down,
                                          ),
                                          items: _listPosition.map((position) {
                                            return DropdownMenuItem(
                                              value: position.title,
                                              child: Text(
                                                position.title,
                                                style: Theme.of(context).textTheme.bodyText1,
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              _position = value;
                                              _positionController.text = value;
                                            });
                                            _enableButton();
                                          },
                                          onTap: (){
                                            FocusScope.of(context).requestFocus(new FocusNode());
                                          },
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.fromLTRB(12.0, 5.0, 10.0, 5.0),
                                            hintText: 'Pilih Posisi/Jabatan',
                                            hintStyle: Theme.of(context).textTheme.bodyText1,
                                            filled: true,
                                            border: InputBorder.none,
                                          ),
                                          style: Theme.of(context).textTheme.bodyText1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(height: 0.5,),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Nama Perusahaan/Instansi',
                                      ),
                                      SizedBox(height: 10.0,),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: TextFormField(
                                          controller: _companyController,
                                          readOnly: _readOnly,
                                          onChanged: (value){
                                            _enableButton();
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Masukkan Nama Perusahaan/Instansi',
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
                                Divider(height: 0.5,),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Skala Perusahaan/Instansi',
                                      ),
                                      SizedBox(height: 10.0,),
                                      if(_readOnly)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: TextFormField(
                                          controller: _scaleController,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.only(left: 12.0, top: 15.0),
                                            hintText: 'Pilih Skala Perusahaan/Instansi',
                                            border: InputBorder.none,
                                            filled: true,
                                            suffixIcon: Icon(
                                              Icons.keyboard_arrow_down,
                                            ),
                                          ),
                                          style: Theme.of(context).textTheme.bodyText1,
                                          keyboardType: TextInputType.text,
                                        ),
                                      )
                                      else
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: DropdownButtonFormField(
                                          isExpanded: true,
                                          value: _scale,
                                          icon: Icon(
                                            Icons.keyboard_arrow_down,
                                          ),
                                          items: _listScale.map((scale) {
                                            return DropdownMenuItem(
                                              value: scale.title,
                                              child: Text(
                                                scale.title,
                                                style: Theme.of(context).textTheme.bodyText1,
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              _scale = value;
                                              _scaleController.text = value;
                                            });
                                            _enableButton();
                                          },
                                          onTap: (){
                                            FocusScope.of(context).requestFocus(new FocusNode());
                                          },
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.fromLTRB(12.0, 5.0, 10.0, 5.0),
                                            hintText: 'Pilih Skala Perusahaan/Instansi',
                                            hintStyle: Theme.of(context).textTheme.bodyText1,
                                            filled: true,
                                            border: InputBorder.none,
                                          ),
                                          style: Theme.of(context).textTheme.bodyText1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(height: 0.5,),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Nama Atasan',
                                      ),
                                      SizedBox(height: 10.0,),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: TextFormField(
                                          controller: _leadernameController,
                                          readOnly: _readOnly,
                                          onChanged: (value){
                                            _enableButton();
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Masukkan Nama Atasan',
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
                                Divider(height: 0.5,),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Email Atasan',
                                      ),
                                      SizedBox(height: 10.0,),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: TextFormField(
                                          controller: _leaderemailController,
                                          readOnly: _readOnly,
                                          onChanged: (value){
                                            _enableButton();
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Masukkan Email Atasan',
                                            border: InputBorder.none,
                                            filled: true,
                                          ),
                                          style: Theme.of(context).textTheme.bodyText1,
                                          keyboardType: TextInputType.emailAddress,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(height: 0.5,),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Alamat Perusahaan/Instansi',
                                      ),
                                      SizedBox(height: 10.0,),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: TextFormField(
                                          controller: _companyaddressController,
                                          readOnly: _readOnly,
                                          onChanged: (value){
                                            _enableButton();
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Masukkan Alamat Perusahaan/Instansi',
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
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 32.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'KESESUAIAN BIDANG PEKERJAAN',
                                style: TextStyle(
                                  fontFamily: 'Google',
                                  fontWeight: FontWeight.bold,
                                  fontSize: Theme.of(context).textTheme.caption.fontSize,
                                  color: Theme.of(context).textTheme.caption.color,
                                ),
                              ),
                              AnimatedOpacity(
                                duration: Duration(milliseconds: 500),
                                opacity: _readOnly ? 0.0 : 1.0,
                                curve: Curves.fastOutSlowIn,
                                child: Text(
                                  'Mode Edit Aktif',
                                  style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.caption.fontSize,
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                              color: Colors.grey[50],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Kesesuaian bidang pekerjaan terhadap bidang keilmuan selama kuliah',
                                  ),
                                  SizedBox(height: 10.0,),
                                  if(_readOnly)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: TextFormField(
                                      controller: _compatibilityController,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.only(left: 12.0, top: 15.0),
                                        hintText: 'Pilih salah satu',
                                        border: InputBorder.none,
                                        filled: true,
                                        suffixIcon: Icon(
                                          Icons.keyboard_arrow_down,
                                        ),
                                      ),
                                      style: Theme.of(context).textTheme.bodyText1,
                                      keyboardType: TextInputType.text,
                                    ),
                                  )
                                  else
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: DropdownButtonFormField(
                                      isExpanded: true,
                                      value: _compatibility,
                                      icon: Icon(
                                        Icons.keyboard_arrow_down,
                                      ),
                                      items: _listCompatibility.map((compatibility) {
                                        return DropdownMenuItem(
                                          value: compatibility.title,
                                          child: Text(
                                            compatibility.title,
                                            style: Theme.of(context).textTheme.bodyText1,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _compatibility = value;
                                          _compatibilityController.text = value;
                                        });
                                        _enableButton();
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
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.15,
                          ),
                        ]
                      ),
                    )
                  ),
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 400),
                    curve: Curves.fastOutSlowIn,
                    right: _rightPosFA,
                    bottom: 16.0,
                    child: FloatingActionButton.extended(
                      backgroundColor: Colors.deepPurple,
                      onPressed: (){
                        setState(() {
                          _readOnly = false;
                          _rightPosFA = -200.0;
                          _bottomPosBtn = 0.0;
                        });
                      },
                      icon: Icon(
                        Icons.edit
                      ),
                      label: Text(
                        'Edit Pekerjaan'
                      ),
                    )
                  ),
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 700),
                    curve: Curves.fastOutSlowIn,
                    right: 0.0,
                    left: 0.0,
                    bottom: _bottomPosBtn,
                    child: Container(
                      color: Theme.of(context).backgroundColor,
                      padding: EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 50.0,
                        child: FlatButton(
                          onPressed: _buttonActive ? (){
                            FocusScope.of(context).requestFocus(new FocusNode());
                            _showProgressDialog();
                            _saveWorksDataToCloudFirestor();
                          } : (){}, 
                          child: Text(
                            'Simpan'
                          ),
                          textColor: _buttonActive ? Theme.of(context).buttonColor : Theme.of(context).disabledColor,
                          color: _buttonActive ? Theme.of(context).buttonColor.withAlpha(30) : Theme.of(context).disabledColor.withAlpha(30),
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
          )
        ),
        onWillPop: _readOnly ? null : _onBackPressed,
      )
    );
  }

  Future<bool> _onBackPressed() {
    if (_canVibrate) {
      Vibrate.feedback(FeedbackType.warning);
    }
    return showDialog(
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
                Padding(
                  padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                  child: Text(
                    'Apakah Anda yakin ingin kembali?',
                    style: TextStyle(
                      fontFamily: 'Google',
                      fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 7.0,),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                  child: Text(
                    'Semua perubahan yang Anda masukkan tidak akan disimpan.',
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
                      setState(() {
                        _readOnly = true;
                        _rightPosFA = 16.0;
                        _bottomPosBtn = -200;
                        _allowBack = true;
                      });
                      _getCarrer();
                    }, 
                    child: Text(
                      'Kembali',
                    ),
                    textColor: Theme.of(context).accentColor,
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
    ) ?? false;
  }

}