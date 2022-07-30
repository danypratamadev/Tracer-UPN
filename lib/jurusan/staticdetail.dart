import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StaticDetailsPage extends StatefulWidget {

  final String id, title;
  final int action, number;

  const StaticDetailsPage({Key key, @required this.action, @required this.id, @required this.title, @required this.number}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StaticDetailsState();
  }

}

class ResponseDetail {
  final String id_response, id_user;
  String initial, name, nim, level, level_name;
  final double score;

  ResponseDetail(this.id_response, this.id_user, this.initial, this.name, this.nim, this.level, this.level_name, this.score);
}

class StaticDetailsState extends State<StaticDetailsPage> {

  final Firestore _firestore = Firestore.instance;
  List<ResponseDetail> _listTemp = new List<ResponseDetail>();
  List<ResponseDetail> _listDetails = new List<ResponseDetail>();
  String _id_faculty, _id_departement, _name_departement;
  bool _isEmpty = false;

  @override
  void initState() {
    _getDataSharedPref();
    super.initState();
  }

  _getDataSharedPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id_faculty = preferences.getString('faculty');
    String id_departement = preferences.getString('departement');
    String name_departement = preferences.getString('departementName');
    setState(() {
      _id_faculty = id_faculty;
      _id_departement = id_departement;
      _name_departement = name_departement;
    });
    _getResponseQuestionFromCloudFirestore();
  }

  _getResponseQuestionFromCloudFirestore() async {
    String category;
    if(widget.action == 10){
      category = 'competency';
    } else if(widget.action == 20) {
      category = 'achievement';
    } else {
      category = 'searchalumnus';
    }
    if(widget.action == 10 || widget.action == 20){
      await _firestore.collection('questionnaire').document('response').collection(category).document(_id_faculty).collection(_id_departement).where('id_question', isEqualTo: widget.id).getDocuments().then((value){
        if(value.documents.isNotEmpty){
          value.documents.forEach((f) {
            ResponseDetail responseDetail = new ResponseDetail(f.documentID, f.data['id_user'], '-', '-', '-', '-', '-', f.data['score']);
            setState(() {
              _listTemp.add(responseDetail);
            });
          });
        } else {
          setState(() {
            _isEmpty = true;
          });
        }
      });
      if(mounted){
        _getDataUserFromCloudFirestore();
      }
    } else {
      await _firestore.collection('questionnaire').document('response').collection(category).document(_id_faculty).collection(_id_departement).where('id_question', isEqualTo: widget.id).getDocuments().then((value){
        if(value.documents.isNotEmpty){
          value.documents.forEach((f) {
            ResponseDetail responseDetail = new ResponseDetail(f.documentID, f.data['id_user'], '-', '-', '-', '-', '-', f.data['score']);
            setState(() {
              _listTemp.add(responseDetail);
            });
          });
        } else {
          setState(() {
            _isEmpty = true;
          });
        }
      });
      if(mounted){
        _getDataUserFromCloudFirestore();
      }
    }
  }

  _getDataUserFromCloudFirestore() async {
    for(int i = 0; i < _listTemp.length; i++){
      _firestore.collection('user').document(_listTemp[i].id_user).collection('biodata').document('data').get().then((value){
        if(value.exists){
          String initial;
          List splitName = value.data['name'].split(' ');
          if(splitName.length > 1){
            initial = '${splitName[0].toString().substring(0, 1)}${splitName[1].toString().substring(0, 1)}';
          } else {
            initial = splitName[0].toString().substring(0, 2);
          }
          _firestore.collection('departement').document(_id_departement).collection('level').document(value.data['level']).get().then((level){
            if(level.exists){
              _firestore.collection('level').document(level.data['id_level']).get().then((values){
                if(values.exists){
                  ResponseDetail responseDetail = new ResponseDetail(_listTemp[i].id_response, _listTemp[i].id_user, initial, value.data['name'], value.data['nim'], values.data['name'], level.data['name'], _listTemp[i].score);
                  setState(() {
                    _listDetails.add(responseDetail);
                  });
                }
              });
            }
          });
        }
      });
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
                      'Detail Statik',
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
                            Icons.show_chart,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0,),
                      Text(
                        '${widget.number + 1}. ${widget.title}',
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
                        'Berikut daftar alumni yang menjawab pertanyaan.',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              if(_listDetails.length > 0)
              ListView.builder(
                itemCount: _listDetails.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index){
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
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
                                    _listDetails[index].initial.toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Google',
                                      fontWeight: FontWeight.bold
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              ),
                            ),
                            SizedBox(width: 24.0,),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.45,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    _listDetails[index].name,
                                    style: TextStyle(
                                      fontFamily: 'Noto',
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${_listDetails[index].nim}',
                                    style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.caption.fontSize,
                                    ),
                                  ),
                                  Text(
                                    '${_listDetails[index].level} ${_listDetails[index].level_name}',
                                    style: TextStyle(
                                      fontSize: Theme.of(context).textTheme.caption.fontSize,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Penilaian',
                                  style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.caption.fontSize,
                                  ),
                                ),
                                SizedBox(height: 5.0,),
                                RatingBar(
                                  initialRating: _listDetails[index].score,
                                  itemSize: 15.0,
                                  minRating: 1,
                                  maxRating: 3,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 3,
                                  itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: null
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        indent: 70.0,
                        endIndent: 16.0,
                        height: 0.0,
                      )
                    ],
                  );
                },
              )
              else if(_isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 150.0, bottom: 10.0),
                child: Text(
                  'Tidak ada data tersedia'
                )
              )
              else
              Padding(
                padding: const EdgeInsets.only(top: 150.0, bottom: 10.0),
                child: SizedBox(
                  width: 30.0,
                  height: 30.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
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