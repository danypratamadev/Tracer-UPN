import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class AchievementPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AchievementState();
  }

}

class Competence {
  String id_question, id_response, title;
  double score;

  Competence(this.id_question, this.id_response, this.title, this.score);
}

class Competence2 {
  String id_question, id_response, title;
  double score;

  Competence2(this.id_question, this.id_response, this.title, this.score);
}

class AchievementState extends State {

  var _scaffoldkey = GlobalKey <ScaffoldState> ();
  final Firestore _firestore = Firestore.instance;
  List<Competence> _listAchievementCompetence = new List<Competence>();
  List<Competence2> _listAchievementCompetenceTemp = new List<Competence2>();
  bool _readOnly = true, _buttonActive = false, _canVibrate = false, _achievement = false, _allowBack = false, _buttonVisible = false;
  double _rightPosFA = 16.0, _bottomPosBtn = -200;
  String _id, _id_departement, _id_faculty;

  @override
  void initState() {
    _checkDeviceVibrate();
    _getCurrentUser();
    _getQuestionFromCloudFirestore();
    super.initState();
  }

  _getCurrentUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('id');
    String id_departement = preferences.getString('departement');
    String id_faculty = preferences.getString('faculty');
    bool achievement = preferences.getBool('achievement');
    setState(() {
      _id = id;
      _id_departement = id_departement;
      _id_faculty = id_faculty;
      _achievement = achievement;
      if(!_achievement && !_allowBack){
        _readOnly = false;
        _rightPosFA = -200.0;
        _bottomPosBtn = 0.0;
      }
    });
  }

  _getQuestionFromCloudFirestore() async {
    List<Competence> _listTemp = new List<Competence>();
    List<Competence2> _listTemp2 = new List<Competence2>();
    await _firestore.collection('questionnaire').document('question').collection('achievement').orderBy('number').getDocuments().then((value){
      if(value.documents.isNotEmpty){
        value.documents.forEach((f) {
          Competence learning = new Competence(f.documentID, '-', f.data['title'], 0);
          Competence2 learning2 = new Competence2(f.documentID, '-', f.data['title'], 0);
          _listTemp.add(learning);
          _listTemp2.add(learning2);
        });
      }
    });
    if(mounted){
      for(int i = 0; i < _listTemp.length; i++){
        await _firestore.collection('questionnaire').document('response').collection('achievement').document(_id_faculty).collection(_id_departement).where('id_answer', isEqualTo: '${_listTemp[i].id_question}/$_id').getDocuments().then((answer){
          if(answer.documents.isNotEmpty){
            answer.documents.forEach((f) {
              _listTemp[i].id_response = f.documentID;
              _listTemp[i].score = f.data['score'] - 1;
              _listTemp2[i].id_response = f.documentID;
              _listTemp2[i].score = f.data['score'] - 1;
            });
          }
        }).then((value){
          if(i == _listTemp.length - 1){
            setState(() {
              _listAchievementCompetence.addAll(_listTemp);
              _listAchievementCompetenceTemp.addAll(_listTemp2);
              _buttonVisible = true;
            });
          }
        });
      }
    }
  }

  _saveAchievementPointToCloudFirestore() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    for(int i = 0; i < _listAchievementCompetence.length; i++){
      await _firestore.collection('questionnaire').document('response').collection('achievement').document(_id_faculty).collection(_id_departement).add({
        'id_answer': '${_listAchievementCompetence[i].id_question}/$_id',
        'score': _listAchievementCompetence[i].score + 1,
        'id_question': _listAchievementCompetence[i].id_question,
        'id_user': _id
      }).then((value){
        setState(() {
          _listAchievementCompetence[i].id_response = value.documentID;
          _listAchievementCompetenceTemp[i].score = _listAchievementCompetence[i].score;
        });
      });
      if(mounted){
        if(i == _listAchievementCompetence.length - 1){
          preferences.setBool('achievement', true);
          await _firestore.collection('user').document(_id).collection('biodata').document('data').setData({
            'achievement': true,
          }, merge: true);
          setState(() {
            _readOnly = true;
            _rightPosFA = 16.0;
            _bottomPosBtn = -200;
            _achievement = true;
          });
          Navigator.pop(context);
          _showSnackBar('Capaian berhasil disimpan.', Icons.verified_user, Colors.green[600]);
        }
      }
    }
  }

  _updateAchievementPointToCloudFirestore() async {
    for(int i = 0; i < _listAchievementCompetence.length; i++){
      await _firestore.collection('questionnaire').document('response').collection('achievement').document(_id_faculty).collection(_id_departement).document('${_listAchievementCompetence[i].id_response}').updateData({
        'score': _listAchievementCompetence[i].score + 1,
      }).then((value){
        setState(() {
          _listAchievementCompetenceTemp[i].score = _listAchievementCompetence[i].score;
        });
      });
      if(mounted){
        if(i == _listAchievementCompetence.length - 1){
          Navigator.pop(context);
          setState(() {
            _readOnly = true;
            _rightPosFA = 16.0;
            _bottomPosBtn = -200;
          });
          _showSnackBar('Capaian berhasil diperbarui.', Icons.verified_user, Colors.green[600]);
        }
      }
    }
  }

  _checkDeviceVibrate() async {
    bool canVibrate = await Vibrate.canVibrate;
    setState(() {
      _canVibrate = canVibrate;
    });
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
                  "Menyimpan kompetensi...",
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
      child: WillPopScope(
        child: Scaffold(
          key: _scaffoldkey,
          appBar: AppBar(
            title: Text(
              'Capaian Kompetensi'
            ),
            elevation: 0.0,
          ),
          body: GestureDetector(
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
                              color: Colors.pink.withAlpha(30),
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
                                      Icons.timeline,
                                      color: Colors.pink,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16.0,),
                                Text(
                                  'Capaian Kompetensi',
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
                                  'Saat anda lulus kuliah, seberapa baik kompetensi berikut anda capai?',
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
                                'CAPAIAN KOMPETENSI',
                                style: TextStyle(
                                  fontFamily: 'Google',
                                  fontWeight: FontWeight.bold,
                                  fontSize: Theme.of(context).textTheme.caption.fontSize,
                                  color: Theme.of(context).textTheme.caption.color,
                                ),
                              ),
                              AnimatedOpacity(
                                duration: Duration(milliseconds: 500),
                                opacity: _readOnly  ? 0.0 : _listAchievementCompetence.length == 0 ? 0.0 : 1.0,
                                curve: Curves.fastOutSlowIn,
                                child: Text(
                                  'Mode Edit Aktif',
                                  style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.caption.fontSize,
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                              ),
                              if(_listAchievementCompetence.length == 0)
                              CupertinoActivityIndicator(),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          if(_listAchievementCompetence.length > 0)
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                              color: Colors.grey[50],
                            ),
                            child: ListView.builder(
                              itemCount: _listAchievementCompetence.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, i){
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Flexible(
                                            child: Text(
                                              _listAchievementCompetence[i].title,
                                            ),
                                          ),
                                          Text(
                                            _listAchievementCompetence[i].score.round() == 0 ? 'Tidak Baik' : _listAchievementCompetence[i].score.round() == 1 ? 'Baik' : 'Sangat Baik',
                                            style: TextStyle(
                                              color: _listAchievementCompetence[i].score == 0 ? Colors.red[400] : _listAchievementCompetence[i].score == 1 ? Colors.blue[400] : Colors.green[400],
                                              fontSize: Theme.of(context).textTheme.caption.fontSize,
                                              fontFamily: 'Google'
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 16.0,),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 10.0),
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 500),
                                        decoration: BoxDecoration(
                                          color: _listAchievementCompetence[i].score == 0 ? Colors.red[400].withAlpha(30) : _listAchievementCompetence[i].score == 1 ? Colors.blue[400].withAlpha(30) : Colors.green[400].withAlpha(30),
                                          borderRadius: BorderRadius.circular(8.0)
                                        ),
                                        child: SliderTheme(
                                          data: SliderTheme.of(context).copyWith(
                                            trackShape: RoundedRectSliderTrackShape(),
                                            trackHeight: 4.0,
                                          ),
                                          child: Slider(
                                            value: _listAchievementCompetence[i].score,
                                            min: 0,
                                            max: 2,
                                            divisions: 2,
                                            label: _listAchievementCompetence[i].score == 0 ? 'Tidak Baik' : _listAchievementCompetence[i].score == 1 ? 'Baik' : 'Sangat Baik',
                                            activeColor: _listAchievementCompetence[i].score == 0 ? Colors.red[400] :  _listAchievementCompetence[i].score == 1 ? Colors.blue[400] : Colors.green[400],
                                            inactiveColor: Theme.of(context).dividerColor,
                                            onChanged: _readOnly ? null : (value){
                                              setState(() {
                                                _listAchievementCompetence[i].score = value;
                                                if(!_buttonActive){
                                                  _buttonActive = true;
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10.0,),
                                    if(i < _listAchievementCompetence.length - 1)
                                    Divider(height: 0.5,),
                                  ]
                                );
                              }
                            ),
                          )
                          else
                          Shimmer.fromColors(
                            baseColor: Theme.of(context).disabledColor,
                            highlightColor: Theme.of(context).dividerColor,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height * 0.7,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(11.0),
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.15,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if(_buttonVisible)
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 400),
                    curve: Curves.fastOutSlowIn,
                    right: _rightPosFA,
                    bottom: 16.0,
                    child: FloatingActionButton.extended(
                      backgroundColor: Colors.pink,
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
                        'Edit Capaian'
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
                            if(_achievement){
                              _updateAchievementPointToCloudFirestore();
                            } else {
                              _saveAchievementPointToCloudFirestore();
                            }
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
          ),
        ),
        onWillPop: _readOnly ? null : _onBackPressed,
      ),
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
                        for(int i = 0; i < _listAchievementCompetenceTemp.length; i++){
                          _listAchievementCompetence[i].score = _listAchievementCompetenceTemp[i].score;
                        }
                      });
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