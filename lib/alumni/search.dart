import 'package:circular_check_box/circular_check_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SearchState();
  }

}

class Search {
  String id_question, id_response, title, subtitle, answer, answer2, answer3, hint, label;
  final int type, inputtype;
  List<Childs> child;
  List<Childs> subchild;
  bool filled;

  Search(this.id_question, this.id_response, this.title, this.subtitle, this.answer, this.answer2, this.answer3, this.hint, this.type, this.inputtype, this.child, this.subchild, this.filled, this.label);
}

class Childs {
  final String id_question, title;
  bool input, filled;

  Childs(this.id_question, this.title, this.input, this.filled);
}

class SearchState extends State {

  var _scaffoldkey = GlobalKey <ScaffoldState> ();
  final Firestore _firestore = Firestore.instance;
  final List<TextEditingController> _listController = new List<TextEditingController>();
  List<Search> _listSearchAlumnus = new List<Search>();
  bool _readOnly = true, _buttonActive = false, _canVibrate = false, _search = false, _allowBack = false;
  double _rightPosFA = 16.0, _bottomPosBtn = -200;
  String _id, _id_departement, _id_faculty;

  final _inputController = TextEditingController();
  final _inputController2 = TextEditingController();
  final _inputController3 = TextEditingController();
  final _inputController4 = TextEditingController();
  final _inputController5 = TextEditingController();
  final _inputController6 = TextEditingController();
  final _inputController7 = TextEditingController();
  final _inputController8 = TextEditingController();
  final _inputController9 = TextEditingController();
  final _inputController10 = TextEditingController();
  final _inputController11 = TextEditingController();
  final _inputController12 = TextEditingController();
  final _inputController13 = TextEditingController();
  final _inputController14 = TextEditingController();
  final _inputController15 = TextEditingController();
  final _inputController16 = TextEditingController();
  final _inputController17 = TextEditingController();
  final _inputController18 = TextEditingController();
  final _inputController19 = TextEditingController();
  final _inputController20 = TextEditingController();
  final _inputController21 = TextEditingController();
  final _inputController22 = TextEditingController();
  final _inputController23 = TextEditingController();
  final _inputController24 = TextEditingController();
  final _inputController25 = TextEditingController();
  final _inputController26 = TextEditingController();
  final _inputController27 = TextEditingController();
  final _inputController28 = TextEditingController();
  final _inputController29 = TextEditingController();
  final _inputController30 = TextEditingController();

  @override
  void initState() {
    _listController.add(_inputController);
    _listController.add(_inputController2);
    _listController.add(_inputController3);
    _listController.add(_inputController4);
    _listController.add(_inputController5);
    _listController.add(_inputController6);
    _listController.add(_inputController7);
    _listController.add(_inputController8);
    _listController.add(_inputController9);
    _listController.add(_inputController10);
    _listController.add(_inputController11);
    _listController.add(_inputController12);
    _listController.add(_inputController13);
    _listController.add(_inputController14);
    _listController.add(_inputController15);
    _listController.add(_inputController16);
    _listController.add(_inputController17);
    _listController.add(_inputController18);
    _listController.add(_inputController19);
    _listController.add(_inputController20);
    _listController.add(_inputController21);
    _listController.add(_inputController22);
    _listController.add(_inputController23);
    _listController.add(_inputController24);
    _listController.add(_inputController25);
    _listController.add(_inputController26);
    _listController.add(_inputController27);
    _listController.add(_inputController28);
    _listController.add(_inputController29);
    _listController.add(_inputController30);
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
    bool search = preferences.getBool('search');
    setState(() {
      _id = id;
      _id_departement = id_departement;
      _id_faculty = id_faculty;
      _search = search;
      if(!_search && !_allowBack){
        _readOnly = false;
        _rightPosFA = -200.0;
        _bottomPosBtn = 0.0;
      }
    });
  }

  _enableButton(){
    bool emptyFound = false;
    for(int i = 0; i < _listSearchAlumnus.length; i++){
      if(!_listSearchAlumnus[i].filled){
        emptyFound = true;
      }
    }
    if(emptyFound){
      _buttonActive = false;
    } else {
      _buttonActive = true;
    }
  }

  _getQuestionFromCloudFirestore() async {
    List<Search> _listTemp = new List<Search>();
    await _firestore.collection('questionnaire').document('question').collection('searchalumnus').orderBy('number').getDocuments().then((value){
      if(value.documents.isNotEmpty){
        String label = '-';
        value.documents.forEach((f) async {
          if(f.data['type'] == 5){
            label = f.data['label'];
          }
          Search search = new Search(f.documentID, null, f.data['title'], null, null, null, null, f.data['hint'], f.data['type'], f.data['inputtype'], null, null, false, label);
          _listTemp.add(search);
        });
      }
    });
    if(mounted){
      String child;
      for(int i = 0; i < _listTemp.length; i++){
        if(_listTemp[i].type == 10 || _listTemp[i].type == 30){
          child = 'dropdown';
        } else {
          child = 'checkbox';
        }
        List<Childs> _listChilds = new List<Childs>();
        await _firestore.collection('questionnaire').document('question').collection('searchalumnus').document(_listTemp[i].id_question).collection(child).orderBy('number').getDocuments().then((value){
          if(value.documents.isNotEmpty){
            value.documents.forEach((f) async {
              Childs child = new Childs(f.documentID, f.data['title'], f.data['input'], false);
              _listChilds.add(child);
            });
            _listTemp[i].child = _listChilds;
          }
        });
        if(mounted){
          print('BERHASIL AMBIL CHILD');
        }
        List<Childs> _listSubchild = new List<Childs>();
        if(_listTemp[i].type == 30){
          await _firestore.collection('questionnaire').document('question').collection('searchalumnus').document(_listTemp[i].id_question).collection('child').orderBy('number').getDocuments().then((value){
            if(value.documents.isNotEmpty){
              value.documents.forEach((f) async {
                _listTemp[i].subtitle = f.data['title'];
                _firestore.collection('questionnaire').document('question').collection('searchalumnus').document(_listTemp[i].id_question).collection('child').document(f.documentID).collection('dropdown').orderBy('number').getDocuments().then((value){
                  if(value.documents.isNotEmpty){
                    value.documents.forEach((f) async {
                      Childs child = new Childs(f.documentID, f.data['title'], f.data['input'], false);
                      _listSubchild.add(child);
                    });
                    _listTemp[i].subchild = _listSubchild;
                  }
                });
              });
            }
          });
          if(mounted){
            print('BERHASIL AMBIL SUBCHILD');
          }
        }
        await _firestore.collection('questionnaire').document('response').collection('searchalumnus').document(_id_faculty).collection(_id_departement).where('id_answer', isEqualTo: '${_listTemp[i].id_question}/$_id').getDocuments().then((answer){
          if(answer.documents.isNotEmpty){
            answer.documents.forEach((f) {
              _listTemp[i].id_response = f.documentID;
              _listTemp[i].answer = f.data['answer'];
              _listTemp[i].answer2 = f.data['answer2'];
              _listTemp[i].answer3 = f.data['answer3'];
            });
          }
        });
        if(mounted){
          print('BERHASIL AMBIL JAWABAN');
        }
        if(mounted){
          if(i == _listTemp.length - 1){
            setState(() {
              _listSearchAlumnus = _listTemp;
              if(_search){
                for(int y = 0; y < _listSearchAlumnus.length; y++){
                  _listSearchAlumnus[y].filled = true;
                  if(_listSearchAlumnus[y].type == 5){
                    _listController[y].text = _listSearchAlumnus[y].answer;
                  } else if(_listSearchAlumnus[y].type == 10){
                    for(int b = 0; b < _listSearchAlumnus[y].child.length; b++){
                      if(_listSearchAlumnus[y].child[b].id_question == _listSearchAlumnus[y].answer){
                        _listSearchAlumnus[y].child[b].filled = true;
                        if(_listSearchAlumnus[y].child[b].input){
                          _listController[y].text = _listSearchAlumnus[y].answer2;
                        } else {
                          _listController[y].text = _listSearchAlumnus[y].child[b].title;
                        }
                      }
                    }
                  } else if(_listSearchAlumnus[y].type == 20){
                    List splitAnswer = _listSearchAlumnus[y].answer.split(':');
                    for(int h = 0; h < splitAnswer.length; h++){
                      for(int g = 0; g < _listSearchAlumnus[y].child.length; g++){
                        if(_listSearchAlumnus[y].child[g].id_question == splitAnswer[h]){
                          _listSearchAlumnus[y].child[g].filled = true;
                          if(_listSearchAlumnus[y].child[g].input){
                            _listController[y].text = _listSearchAlumnus[y].answer2;
                          }
                        }
                      }
                    }
                  } else if(_listSearchAlumnus[y].type == 30){
                    for(int d = 0; d < _listSearchAlumnus[y].child.length; d++){
                      if(_listSearchAlumnus[y].child[d].id_question == _listSearchAlumnus[y].answer){
                        _listSearchAlumnus[y].child[d].filled = true;
                        if(_listSearchAlumnus[y].child[d].input){
                          for(int f = 0; f < _listSearchAlumnus[y].subchild.length; f++){
                            if(_listSearchAlumnus[y].subchild[f].id_question == _listSearchAlumnus[y].answer2){
                              _listSearchAlumnus[y].subchild[f].filled = true;
                              if(_listSearchAlumnus[y].subchild[f].input){
                                _listController[y].text = _listSearchAlumnus[y].answer3;
                              } else {
                                _listController[y].text = _listSearchAlumnus[y].subchild[f].title;
                              }
                            }
                          }
                        } else {
                          _listController[y].text = _listSearchAlumnus[y].child[d].title;
                        }
                      }
                    }
                  }
                }
              }
            });
          }
        }
      }
    }
  }

  _saveSearchAlumnusToCloudFirestore() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    for(int i = 0; i < _listSearchAlumnus.length; i++){
      await _firestore.collection('questionnaire').document('response').collection('searchalumnus').document(_id_faculty).collection(_id_departement).add({
        'id_answer': '${_listSearchAlumnus[i].id_question}/$_id',
        'id_question': _listSearchAlumnus[i].id_question,
        'id_user': _id,
        'answer': _listSearchAlumnus[i].answer,
        'answer2': _listSearchAlumnus[i].answer2 != null ? _listSearchAlumnus[i].answer2 : '-',
        'answer3': _listSearchAlumnus[i].answer3 != null ? _listSearchAlumnus[i].answer3 : '-',
      }).then((value){
        setState(() {
          _listSearchAlumnus[i].id_response = value.documentID;
          for(int y = 0; y < _listSearchAlumnus.length; y++){
            _listSearchAlumnus[y].filled = true;
            if(_listSearchAlumnus[y].type == 5){
              _listController[y].text = _listSearchAlumnus[y].answer;
            } else if(_listSearchAlumnus[y].type == 10){
              for(int b = 0; b < _listSearchAlumnus[y].child.length; b++){
                if(_listSearchAlumnus[y].child[b].id_question == _listSearchAlumnus[y].answer){
                  _listSearchAlumnus[y].child[b].filled = true;
                  if(_listSearchAlumnus[y].child[b].input){
                    _listController[y].text = _listSearchAlumnus[y].answer2;
                  } else {
                    _listController[y].text = _listSearchAlumnus[y].child[b].title;
                  }
                }
              }
            } else if(_listSearchAlumnus[y].type == 20){
              List splitAnswer = _listSearchAlumnus[y].answer.split(':');
              for(int h = 0; h < splitAnswer.length; h++){
                for(int g = 0; g < _listSearchAlumnus[y].child.length; g++){
                  if(_listSearchAlumnus[y].child[g].id_question == splitAnswer[h]){
                    _listSearchAlumnus[y].child[g].filled = true;
                    if(_listSearchAlumnus[y].child[g].input){
                      _listController[y].text = _listSearchAlumnus[y].answer2;
                    }
                  }
                }
              }
            } else if(_listSearchAlumnus[y].type == 30){
              for(int d = 0; d < _listSearchAlumnus[y].child.length; d++){
                if(_listSearchAlumnus[y].child[d].id_question == _listSearchAlumnus[y].answer){
                  _listSearchAlumnus[y].child[d].filled = true;
                  if(_listSearchAlumnus[y].child[d].input){
                    for(int f = 0; f < _listSearchAlumnus[y].subchild.length; f++){
                      if(_listSearchAlumnus[y].subchild[f].id_question == _listSearchAlumnus[y].answer2){
                        _listSearchAlumnus[y].subchild[f].filled = true;
                        if(_listSearchAlumnus[y].subchild[f].input){
                          _listController[y].text = _listSearchAlumnus[y].answer3;
                        } else {
                          _listController[y].text = _listSearchAlumnus[y].subchild[f].title;
                        }
                      }
                    }
                  } else {
                    _listController[y].text = _listSearchAlumnus[y].child[d].title;
                  }
                }
              }
            }
          }
        });
      });
      if(mounted){
        if(i == _listSearchAlumnus.length - 1){
          preferences.setBool('search', true);
          await _firestore.collection('user').document(_id).collection('biodata').document('data').setData({
            'search': true,
          }, merge: true);
          setState(() {
            _readOnly = true;
            _rightPosFA = 16.0;
            _bottomPosBtn = -200;
            _search = true;
          });
          Navigator.pop(context);
          _showSnackBar('Penelurusan berhasil disimpan.', Icons.verified_user, Colors.green[600]);
        }
      }
    }
  }

  _updateCompetencyPointToCloudFirestore() async {
    for(int i = 0; i < _listSearchAlumnus.length; i++){
      await _firestore.collection('questionnaire').document('response').collection('searchalumnus').document(_id_faculty).collection(_id_departement).document('${_listSearchAlumnus[i].id_response}').updateData({
        'answer': _listSearchAlumnus[i].answer,
        'answer2': _listSearchAlumnus[i].answer2,
        'answer3': _listSearchAlumnus[i].answer3,
      }).then((value){
        setState(() {
          for(int y = 0; y < _listSearchAlumnus.length; y++){
            _listSearchAlumnus[y].filled = true;
            if(_listSearchAlumnus[y].type == 5){
              _listController[y].text = _listSearchAlumnus[y].answer;
            } else if(_listSearchAlumnus[y].type == 10){
              for(int b = 0; b < _listSearchAlumnus[y].child.length; b++){
                if(_listSearchAlumnus[y].child[b].id_question == _listSearchAlumnus[y].answer){
                  _listSearchAlumnus[y].child[b].filled = true;
                  if(_listSearchAlumnus[y].child[b].input){
                    _listController[y].text = _listSearchAlumnus[y].answer2;
                  } else {
                    _listController[y].text = _listSearchAlumnus[y].child[b].title;
                  }
                }
              }
            } else if(_listSearchAlumnus[y].type == 20){
              List splitAnswer = _listSearchAlumnus[y].answer.split(':');
              for(int h = 0; h < splitAnswer.length; h++){
                for(int g = 0; g < _listSearchAlumnus[y].child.length; g++){
                  if(_listSearchAlumnus[y].child[g].id_question == splitAnswer[h]){
                    _listSearchAlumnus[y].child[g].filled = true;
                    if(_listSearchAlumnus[y].child[g].input){
                      _listController[y].text = _listSearchAlumnus[y].answer2;
                    }
                  }
                }
              }
            } else if(_listSearchAlumnus[y].type == 30){
              for(int d = 0; d < _listSearchAlumnus[y].child.length; d++){
                if(_listSearchAlumnus[y].child[d].id_question == _listSearchAlumnus[y].answer){
                  _listSearchAlumnus[y].child[d].filled = true;
                  if(_listSearchAlumnus[y].child[d].input){
                    for(int f = 0; f < _listSearchAlumnus[y].subchild.length; f++){
                      if(_listSearchAlumnus[y].subchild[f].id_question == _listSearchAlumnus[y].answer2){
                        _listSearchAlumnus[y].subchild[f].filled = true;
                        if(_listSearchAlumnus[y].subchild[f].input){
                          _listController[y].text = _listSearchAlumnus[y].answer3;
                        } else {
                          _listController[y].text = _listSearchAlumnus[y].subchild[f].title;
                        }
                      }
                    }
                  } else {
                    _listController[y].text = _listSearchAlumnus[y].child[d].title;
                  }
                }
              }
            }
          }
        });
      });
      if(mounted){
        if(i == _listSearchAlumnus.length - 1){
          Navigator.pop(context);
          setState(() {
            _readOnly = true;
            _rightPosFA = 16.0;
            _bottomPosBtn = -200;
          });
          _showSnackBar('Kompetensi berhasil diperbarui.', Icons.verified_user, Colors.green[600]);
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
              'Penelusuran Alumni'
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
                              color: Colors.blueGrey.withAlpha(30),
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
                                      Icons.search,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16.0,),
                                Text(
                                  'Penelusuran Alumni',
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
                                'PENELUSURAN',
                                style: TextStyle(
                                  fontFamily: 'Google',
                                  fontWeight: FontWeight.bold,
                                  fontSize: Theme.of(context).textTheme.caption.fontSize,
                                  color: Theme.of(context).textTheme.caption.color,
                                ),
                              ),
                              AnimatedOpacity(
                                duration: Duration(milliseconds: 500),
                                opacity: _readOnly ? 0.0 : _listSearchAlumnus.length == 0 ? 0.0 : 1.0,
                                curve: Curves.fastOutSlowIn,
                                child: Text(
                                  'Mode Edit Aktif',
                                  style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.caption.fontSize,
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                              ),
                              if(_listSearchAlumnus.length == 0)
                              CupertinoActivityIndicator(),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          if(_listSearchAlumnus.length > 0)
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
                              itemCount: _listSearchAlumnus.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, i){
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            _listSearchAlumnus[i].title,
                                          ),
                                          SizedBox(height: 10.0,),
                                          if(_listSearchAlumnus[i].type == 10)
                                            if(_readOnly)
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8.0),
                                              child: TextFormField(
                                                controller: _listController[i],
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  contentPadding: EdgeInsets.only(left: 12.0, top: 15.0),
                                                  hintText: _listSearchAlumnus[i].hint,
                                                  border: InputBorder.none,
                                                  filled: true,
                                                  suffixIcon: Icon(
                                                    Icons.keyboard_arrow_down,
                                                  ),
                                                ),
                                                style: Theme.of(context).textTheme.bodyText1,
                                                keyboardType: _listSearchAlumnus[i].inputtype == 1 ? TextInputType.text : TextInputType.number,
                                              ),
                                            )
                                            else
                                            Column(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                  child: DropdownButtonFormField(
                                                    value: _listSearchAlumnus[i].answer,
                                                    isExpanded: true,
                                                    icon: Icon(
                                                      Icons.keyboard_arrow_down,
                                                    ),
                                                    items: _listSearchAlumnus[i].child.map((child) {
                                                      return DropdownMenuItem(
                                                        value: child.id_question,
                                                        child: Text(
                                                          child.title,
                                                          style: TextStyle(
                                                            fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
                                                            fontFamily: 'Sans'
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        for(int j = 0; j < _listSearchAlumnus[i].child.length; j++){
                                                          if(_listSearchAlumnus[i].child[j].id_question == value){
                                                            _listSearchAlumnus[i].child[j].filled = true;
                                                            if(_listSearchAlumnus[i].child[j].filled && _listSearchAlumnus[i].child[j].input){
                                                              _listSearchAlumnus[i].filled = false;
                                                            } else {
                                                              _listSearchAlumnus[i].filled = true;
                                                            }
                                                          } else {
                                                            _listSearchAlumnus[i].child[j].filled = false;
                                                            if(!_listSearchAlumnus[i].child[j].filled && _listSearchAlumnus[i].child[j].input){
                                                              for(int x = 0; x < _listController.length; x++){
                                                                if(_listController[x].text != '' && _listSearchAlumnus[i].answer2 != null){
                                                                  if(_listController[x].text.toString().toLowerCase() == _listSearchAlumnus[i].answer2.toLowerCase()){
                                                                    _listController[x].text = '';
                                                                  }
                                                                }
                                                              }
                                                              _listSearchAlumnus[i].answer2 = '-';
                                                            }
                                                          }
                                                        }
                                                        _listSearchAlumnus[i].answer = value;
                                                      });
                                                      _enableButton();
                                                    },
                                                    onTap: (){
                                                      FocusScope.of(context).requestFocus(new FocusNode());
                                                    },
                                                    decoration: InputDecoration(
                                                      contentPadding: EdgeInsets.fromLTRB(15.0, 5.0, 10.0, 5.0),
                                                      hintText: _listSearchAlumnus[i].hint,
                                                      hintStyle: TextStyle(
                                                        fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
                                                        fontFamily: 'Sans'
                                                      ),
                                                      filled: true,
                                                      border: InputBorder.none,
                                                    ),
                                                    style: Theme.of(context).textTheme.bodyText1,
                                                  ),
                                                ),
                                                for(int j = 0; j < _listSearchAlumnus[i].child.length; j++)
                                                if(_listSearchAlumnus[i].child[j].filled && _listSearchAlumnus[i].child[j].input)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 10.0,),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(8.0),
                                                    child: TextFormField(
                                                      controller: _listController[i],
                                                      readOnly: _readOnly,
                                                      onChanged: (value){
                                                        setState(() {
                                                          if(value.length > 0){
                                                            _listSearchAlumnus[i].filled = true;
                                                          } else {
                                                            _listSearchAlumnus[i].filled = false;
                                                          }
                                                          _listSearchAlumnus[i].answer2 = value;
                                                        });
                                                        _enableButton();
                                                      },
                                                      decoration: InputDecoration(
                                                        hintText: 'Sebutkan disini',
                                                        border: InputBorder.none,
                                                        filled: true,
                                                      ),
                                                      maxLines: null,
                                                      style: Theme.of(context).textTheme.bodyText1,
                                                      keyboardType: _listSearchAlumnus[i].inputtype == 1 ? TextInputType.text : TextInputType.number,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          else if(_listSearchAlumnus[i].type == 20)
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics: NeverScrollableScrollPhysics(),
                                              itemCount: _listSearchAlumnus[i].child.length,
                                              itemBuilder: (context, j){
                                                return Padding(
                                                  padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                                                  child: Column(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius: BorderRadius.circular(8.0),
                                                        child: Material(
                                                          color: _listSearchAlumnus[i].child[j].filled ? Colors.green.withAlpha(30) : Theme.of(context).dividerColor.withAlpha(10),
                                                          child: InkWell(
                                                            onTap: _readOnly ? (){} : (){
                                                              setState(() {
                                                                _listSearchAlumnus[i].child[j].filled = !_listSearchAlumnus[i].child[j].filled;
                                                              });
                                                              String choose = ':';
                                                              for(int k = 0; k < _listSearchAlumnus[i].child.length; k++){
                                                                if(_listSearchAlumnus[i].child[k].filled){
                                                                  choose += '${_listSearchAlumnus[i].child[k].id_question}:';
                                                                  if(_listSearchAlumnus[i].child[k].filled && _listSearchAlumnus[i].child[k].input){
                                                                    _listSearchAlumnus[i].filled = false;
                                                                  }
                                                                }
                                                                if(!_listSearchAlumnus[i].child[k].filled && _listSearchAlumnus[i].child[k].input){
                                                                  for(int x = 0; x < _listController.length; x++){
                                                                    if(_listController[x].text != '' && _listSearchAlumnus[i].answer2 != null){
                                                                      if(_listController[x].text.toString().toLowerCase() == _listSearchAlumnus[i].answer2.toLowerCase()){
                                                                        _listController[x].text = '';
                                                                      }
                                                                    }
                                                                  }
                                                                  _listSearchAlumnus[i].filled = true;
                                                                  _listSearchAlumnus[i].answer2 = '-';
                                                                }
                                                              }
                                                              setState(() {
                                                                if(choose.length == 1){
                                                                  _listSearchAlumnus[i].answer = '-';
                                                                  _listSearchAlumnus[i].filled = false;
                                                                } else {
                                                                  _listSearchAlumnus[i].answer = choose;
                                                                }
                                                              });
                                                              _enableButton();
                                                            },
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(left: 5.0, top: 5.0, bottom: 5.0, right: 16.0),
                                                              child: Row(
                                                                children: <Widget>[
                                                                  CircularCheckBox(
                                                                    value: _listSearchAlumnus[i].child[j].filled,
                                                                    materialTapTargetSize: MaterialTapTargetSize.padded,
                                                                    onChanged: _readOnly ? (value){} : (value) {
                                                                      setState(() {
                                                                        _listSearchAlumnus[i].child[j].filled = value;
                                                                      });
                                                                      String choose = ':';
                                                                      for(int k = 0; k < _listSearchAlumnus[i].child.length; k++){
                                                                        if(_listSearchAlumnus[i].child[k].filled){
                                                                          choose += '${_listSearchAlumnus[i].child[k].id_question}:';
                                                                          if(_listSearchAlumnus[i].child[k].filled && _listSearchAlumnus[i].child[k].input){
                                                                            _listSearchAlumnus[i].filled = false;
                                                                          }
                                                                        }
                                                                        if(!_listSearchAlumnus[i].child[k].filled && _listSearchAlumnus[i].child[k].input){
                                                                          for(int x = 0; x < _listController.length; x++){
                                                                            if(_listController[x].text != '' && _listSearchAlumnus[i].answer2 != null){
                                                                              if(_listController[x].text.toString().toLowerCase() == _listSearchAlumnus[i].answer2.toLowerCase()){
                                                                                _listController[x].text = '';
                                                                              }
                                                                            }
                                                                          }
                                                                          _listSearchAlumnus[i].filled = true;
                                                                          _listSearchAlumnus[i].answer2 = '-';
                                                                        }
                                                                      }
                                                                      setState(() {
                                                                        if(choose.length == 1){
                                                                          _listSearchAlumnus[i].answer = '-';
                                                                          _listSearchAlumnus[i].filled = false;
                                                                        } else {
                                                                          _listSearchAlumnus[i].answer = choose;
                                                                        }
                                                                      });
                                                                      _enableButton();
                                                                    },
                                                                    activeColor: Colors.green,
                                                                    inactiveColor: Theme.of(context).disabledColor,
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      _listSearchAlumnus[i].child[j].title,
                                                                      style: Theme.of(context).textTheme.bodyText1,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        ),
                                                      ),
                                                      if(_listSearchAlumnus[i].child[j].filled && _listSearchAlumnus[i].child[j].input)
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 10.0,),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(8.0),
                                                          child: TextFormField(
                                                            controller: _listController[i],
                                                            readOnly: _readOnly,
                                                            onChanged: (value){
                                                              setState(() {
                                                                if(value.length > 0){
                                                                  _listSearchAlumnus[i].filled = true;
                                                                } else {
                                                                  _listSearchAlumnus[i].filled = false;
                                                                }
                                                                _listSearchAlumnus[i].answer2 = value;
                                                              });
                                                              _enableButton();
                                                            },
                                                            decoration: InputDecoration(
                                                              hintText: 'Sebutkan disini',
                                                              border: InputBorder.none,
                                                              filled: true,
                                                            ),
                                                            maxLines: null,
                                                            style: Theme.of(context).textTheme.bodyText1,
                                                            keyboardType: _listSearchAlumnus[i].inputtype == 1 ? TextInputType.text : TextInputType.number,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            )
                                          else if(_listSearchAlumnus[i].type == 30)
                                            if(_readOnly)
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8.0),
                                              child: TextFormField(
                                                controller: _listController[i],
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  contentPadding: EdgeInsets.only(left: 12.0, top: 15.0),
                                                  hintText: _listSearchAlumnus[i].hint,
                                                  border: InputBorder.none,
                                                  filled: true,
                                                  suffixIcon: Icon(
                                                    Icons.keyboard_arrow_down,
                                                  ),
                                                ),
                                                style: Theme.of(context).textTheme.bodyText1,
                                                keyboardType: _listSearchAlumnus[i].inputtype == 1 ? TextInputType.text : TextInputType.number,
                                              ),
                                            )
                                            else
                                            Column(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                  child: DropdownButtonFormField(
                                                    value: _listSearchAlumnus[i].answer,
                                                    icon: Icon(
                                                      Icons.keyboard_arrow_down,
                                                    ),
                                                    items: _listSearchAlumnus[i].child.map((child) {
                                                      return DropdownMenuItem(
                                                        value: child.id_question,
                                                        child: Text(
                                                          child.title,
                                                          style: TextStyle(
                                                            fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
                                                            fontFamily: 'Sans'
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        for(int j = 0; j < _listSearchAlumnus[i].child.length; j++){
                                                          if(_listSearchAlumnus[i].child[j].id_question == value){
                                                            _listSearchAlumnus[i].child[j].filled = true;
                                                            if(_listSearchAlumnus[i].child[j].filled && _listSearchAlumnus[i].child[j].input){
                                                              _listSearchAlumnus[i].filled = false;
                                                            } else {
                                                              _listSearchAlumnus[i].filled = true;
                                                            }
                                                          } else {
                                                            _listSearchAlumnus[i].child[j].filled = false;
                                                            if(!_listSearchAlumnus[i].child[j].filled && _listSearchAlumnus[i].child[j].input){
                                                              for(int x = 0; x < _listController.length; x++){
                                                                if(_listController[x].text != '' && _listSearchAlumnus[i].answer3 != null){
                                                                  if(_listController[x].text.toString().toLowerCase() == _listSearchAlumnus[i].answer3.toLowerCase()){
                                                                    _listController[x].text = '';
                                                                  }
                                                                }
                                                              }
                                                              _listSearchAlumnus[i].answer2 = '-';
                                                              _listSearchAlumnus[i].answer3 = '-';
                                                            }
                                                          }
                                                        }
                                                        _listSearchAlumnus[i].answer = value;
                                                      });
                                                      _enableButton();
                                                    },
                                                    onTap: (){
                                                      FocusScope.of(context).requestFocus(new FocusNode());
                                                    },
                                                    decoration: InputDecoration(
                                                      contentPadding: EdgeInsets.fromLTRB(15.0, 5.0, 10.0, 5.0),
                                                      hintText: _listSearchAlumnus[i].hint,
                                                      hintStyle: TextStyle(
                                                        fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
                                                        fontFamily: 'Sans'
                                                      ),
                                                      filled: true,
                                                      border: InputBorder.none,
                                                    ),
                                                    style: Theme.of(context).textTheme.bodyText1,
                                                  ),
                                                ),
                                                for(int j = 0; j < _listSearchAlumnus[i].child.length; j++)
                                                if(_listSearchAlumnus[i].child[j].filled && _listSearchAlumnus[i].child[j].input)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 10.0,),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        _listSearchAlumnus[i].subtitle,
                                                      ),
                                                      SizedBox(
                                                        height: 10.0,
                                                      ),
                                                      ClipRRect(
                                                        borderRadius: BorderRadius.circular(8.0),
                                                        child: DropdownButtonFormField(
                                                          value: _listSearchAlumnus[i].answer2 != '-' ? _listSearchAlumnus[i].answer2 : null,
                                                          icon: Icon(
                                                            Icons.keyboard_arrow_down,
                                                          ),
                                                          items: _listSearchAlumnus[i].subchild.map((subchild) {
                                                            return DropdownMenuItem(
                                                              value: subchild.id_question,
                                                              child: Text(
                                                                subchild.title,
                                                                style: TextStyle(
                                                                  fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
                                                                  fontFamily: 'Sans'
                                                                ),
                                                              ),
                                                            );
                                                          }).toList(),
                                                          onChanged: (value) {
                                                            setState(() {
                                                              for(int j = 0; j < _listSearchAlumnus[i].subchild.length; j++){
                                                                if(_listSearchAlumnus[i].subchild[j].id_question == value){
                                                                  _listSearchAlumnus[i].subchild[j].filled = true;
                                                                  if(_listSearchAlumnus[i].subchild[j].filled && _listSearchAlumnus[i].subchild[j].input){
                                                                    _listSearchAlumnus[i].filled = false;
                                                                  } else {
                                                                    _listSearchAlumnus[i].filled = true;
                                                                  }
                                                                } else {
                                                                  _listSearchAlumnus[i].subchild[j].filled = false;
                                                                  if(!_listSearchAlumnus[i].subchild[j].filled && _listSearchAlumnus[i].subchild[j].input){
                                                                    for(int x = 0; x < _listController.length; x++){
                                                                      if(_listController[x].text != '' && _listSearchAlumnus[i].answer3 != null){
                                                                        if(_listController[x].text.toString().toLowerCase() == _listSearchAlumnus[i].answer3.toLowerCase()){
                                                                          _listController[x].text = '';
                                                                        }
                                                                      }
                                                                    }
                                                                    _listSearchAlumnus[i].answer3 = '-';
                                                                  }
                                                                }
                                                              }
                                                              _listSearchAlumnus[i].answer2 = value;
                                                            });
                                                            _enableButton();
                                                          },
                                                          onTap: (){
                                                            FocusScope.of(context).requestFocus(new FocusNode());
                                                          },
                                                          decoration: InputDecoration(
                                                            contentPadding: EdgeInsets.fromLTRB(15.0, 5.0, 10.0, 5.0),
                                                            hintText: _listSearchAlumnus[i].hint,
                                                            hintStyle: TextStyle(
                                                              fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
                                                              fontFamily: 'Sans'
                                                            ),
                                                            filled: true,
                                                            border: InputBorder.none,
                                                          ),
                                                          style: Theme.of(context).textTheme.bodyText1,
                                                        ),
                                                      ),
                                                      for(int j = 0; j < _listSearchAlumnus[i].subchild.length; j++)
                                                      if(_listSearchAlumnus[i].subchild[j].filled && _listSearchAlumnus[i].subchild[j].input)
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 10.0,),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(8.0),
                                                          child: TextFormField(
                                                            controller: _listController[i],
                                                            readOnly: _readOnly,
                                                            onChanged: (value){
                                                              setState(() {
                                                                if(value.length > 0){
                                                                  _listSearchAlumnus[i].filled = true;
                                                                } else {
                                                                  _listSearchAlumnus[i].filled = false;
                                                                }
                                                                _listSearchAlumnus[i].answer3 = value;
                                                              });
                                                              _enableButton();
                                                            },
                                                            decoration: InputDecoration(
                                                              hintText: 'Sebutkan disini',
                                                              border: InputBorder.none,
                                                              filled: true,
                                                            ),
                                                            maxLines: null,
                                                            style: Theme.of(context).textTheme.bodyText1,
                                                            keyboardType: _listSearchAlumnus[i].inputtype == 1 ? TextInputType.text : TextInputType.number,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            )
                                          else
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8.0),
                                            child: TextFormField(
                                              controller: _listController[i],
                                              readOnly: _readOnly,
                                              onChanged: (value){
                                                setState(() {
                                                  if(value.length > 0){
                                                    _listSearchAlumnus[i].filled = true;
                                                  } else {
                                                    _listSearchAlumnus[i].filled = false;
                                                  }
                                                  _listSearchAlumnus[i].answer = value;
                                                });
                                                _enableButton();
                                              },
                                              decoration: InputDecoration(
                                                hintText: _listSearchAlumnus[i].hint,
                                                border: InputBorder.none,
                                                suffix: Text(
                                                  _listSearchAlumnus[i].label,
                                                  style: TextStyle(
                                                    color: Theme.of(context).accentColor,
                                                  )
                                                ),
                                                filled: true,
                                              ),
                                              style: Theme.of(context).textTheme.bodyText1,
                                              keyboardType: _listSearchAlumnus[i].inputtype == 1 ? TextInputType.text : TextInputType.number,
                                            ),
                                          ),
                                        ],
                                      )
                                    ),
                                    if(i < _listSearchAlumnus.length - 1)
                                    Divider(height: 0.5,),
                                  ]
                                );
                              }
                            )
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
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 400),
                    curve: Curves.fastOutSlowIn,
                    right: _rightPosFA,
                    bottom: 16.0,
                    child: FloatingActionButton.extended(
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
                        'Edit Penelusuran'
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
                            if(_search){
                              _updateCompetencyPointToCloudFirestore();
                            } else {
                              _saveSearchAlumnusToCloudFirestore();
                            }
                          } : (){
                            for(int i = 0; i < _listSearchAlumnus.length; i++){
                              if(!_listSearchAlumnus[i].filled){
                                print('NOMOR ${i + 1} BELUM DI ISI');
                              }
                            }
                          }, 
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
              )
            )
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
                        for(int y = 0; y < _listSearchAlumnus.length; y++){
                          _listSearchAlumnus[y].filled = true;
                          if(_listSearchAlumnus[y].type == 5){
                            _listController[y].text = _listSearchAlumnus[y].answer;
                          } else if(_listSearchAlumnus[y].type == 10){
                            for(int b = 0; b < _listSearchAlumnus[y].child.length; b++){
                              if(_listSearchAlumnus[y].child[b].id_question == _listSearchAlumnus[y].answer){
                                _listSearchAlumnus[y].child[b].filled = true;
                                if(_listSearchAlumnus[y].child[b].input){
                                  _listController[y].text = _listSearchAlumnus[y].answer2;
                                } else {
                                  _listController[y].text = _listSearchAlumnus[y].child[b].title;
                                }
                              }
                            }
                          } else if(_listSearchAlumnus[y].type == 20){
                            List splitAnswer = _listSearchAlumnus[y].answer.split(':');
                            for(int h = 0; h < splitAnswer.length; h++){
                              for(int g = 0; g < _listSearchAlumnus[y].child.length; g++){
                                if(_listSearchAlumnus[y].child[g].id_question == splitAnswer[h]){
                                  _listSearchAlumnus[y].child[g].filled = true;
                                  if(_listSearchAlumnus[y].child[g].input){
                                    _listController[y].text = _listSearchAlumnus[y].answer2;
                                  }
                                }
                              }
                            }
                          } else if(_listSearchAlumnus[y].type == 30){
                            for(int d = 0; d < _listSearchAlumnus[y].child.length; d++){
                              if(_listSearchAlumnus[y].child[d].id_question == _listSearchAlumnus[y].answer){
                                _listSearchAlumnus[y].child[d].filled = true;
                                if(_listSearchAlumnus[y].child[d].input){
                                  for(int f = 0; f < _listSearchAlumnus[y].subchild.length; f++){
                                    if(_listSearchAlumnus[y].subchild[f].id_question == _listSearchAlumnus[y].answer2){
                                      _listSearchAlumnus[y].subchild[f].filled = true;
                                      if(_listSearchAlumnus[y].subchild[f].input){
                                        _listController[y].text = _listSearchAlumnus[y].answer3;
                                      } else {
                                        _listController[y].text = _listSearchAlumnus[y].subchild[f].title;
                                      }
                                    }
                                  }
                                } else {
                                  _listController[y].text = _listSearchAlumnus[y].child[d].title;
                                }
                              }
                            }
                          }
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