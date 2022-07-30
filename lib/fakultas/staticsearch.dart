import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tracer_upn/jurusan/staticdetail.dart';

class StaticSearchPage extends StatefulWidget {

  final String id, name;

  const StaticSearchPage({Key key, @required this.id, @required this.name}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StaticSearchState();
  }

}

class Question {
  final String id, title, label;
  List<Response> listResponse;
  int respondent, type;
  bool empty;
  List<Childs> child;

  Question(this.id, this.title, this.label, this.type, this.listResponse, this.respondent, this.empty, this.child);
}

class Childs {
  final String id_question, title;
  double sumAnswer;

  Childs(this.id_question, this.title, this.sumAnswer);
}

class Response {
  final String title;
  final double point;

  Response(this.title, this.point);
}

class StaticSearchState extends State<StaticSearchPage> {

  final Firestore _firestore = Firestore.instance;
  List<Question> _listQuestion = new List<Question>();
  bool _isEmpty = false;
  String _id_faculty;
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  @override
  void initState() {
    _getDataSharedPref();
    super.initState();
  }

  _getDataSharedPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id_faculty = preferences.getString('faculty');
    setState(() {
      _id_faculty = id_faculty;
    });
    _getQuestionFromCloudFirestore();
  }

  _getQuestionFromCloudFirestore() async {
    await _firestore.collection('questionnaire').document('question').collection('searchalumnus').orderBy('number').getDocuments().then((value){
      if(value.documents.isNotEmpty){
        value.documents.forEach((f) async {
          if(mounted){
            Question question = new Question(f.documentID, f.data['title'], f.data['label'], f.data['type'], null, 0, false, null);
            setState(() {
              _listQuestion.add(question);
            });
          }
        });
      } else {
        setState(() {
          _isEmpty = true;
        });
      }
    });
    if(mounted){
      _getChildOfQuestion();
    }
  }

  _getChildOfQuestion() async {
    String child;
    for(int i = 0; i < _listQuestion.length; i++){
      if(_listQuestion[i].type == 10 || _listQuestion[i].type == 30){
        child = 'dropdown';
      } else {
        child = 'checkbox';
      }
      List<Childs> _listChilds = new List<Childs>();
      await _firestore.collection('questionnaire').document('question').collection('searchalumnus').document(_listQuestion[i].id).collection(child).orderBy('number').getDocuments().then((value){
        if(value.documents.isNotEmpty){
          value.documents.forEach((f) async {
            Childs child = new Childs(f.documentID, f.data['title'], 0);
            _listChilds.add(child);
          });
        }
      });
      if(mounted){
        setState(() {
          _listQuestion[i].child = _listChilds;
        });
        if(i == _listQuestion.length -1){
          _getResponseQuestionFromCloudFirestore();
        }
      }
    }
  }

  _getResponseQuestionFromCloudFirestore() async {
    for(int i = 0; i < _listQuestion.length; i++){
      if(_listQuestion[i].type == 5){
        List<Response> _listTemp = new List<Response>();
        await _firestore.collection('questionnaire').document('response').collection('searchalumnus').document(_id_faculty).collection(widget.id).where('id_question', isEqualTo: _listQuestion[i].id).getDocuments().then((value){
          if(value.documents.isNotEmpty){
            double one = 0, two = 0, three = 0, four = 0, five = 0, six = 0, seven = 0, eight = 0, nine = 0, teen = 0, more = 0;
            value.documents.forEach((f) {
              if(f.data['answer'] == '1'){
                one++;
              } else if(f.data['answer'] == '2') {
                two++;
              } else if(f.data['answer'] == '3') {
                three++;
              } else if(f.data['answer'] == '4') {
                four++;
              } else if(f.data['answer'] == '5') {
                five++;
              } else if(f.data['answer'] == '6') {
                six++;
              } else if(f.data['answer'] == '7') {
                seven++;
              } else if(f.data['answer'] == '8') {
                eight++;
              } else if(f.data['answer'] == '9') {
                nine++;
              } else if(f.data['answer'] == '10') {
                teen++;
              } else {
                more++;
              }
            });
            Response response = new Response('1 ${_listQuestion[i].label}', one);
            Response response2 = new Response('2 ${_listQuestion[i].label}', two);
            Response response3 = new Response('3 ${_listQuestion[i].label}', three);
            Response response4 = new Response('4 ${_listQuestion[i].label}', four);
            Response response5 = new Response('5 ${_listQuestion[i].label}', five);
            Response response6 = new Response('6 ${_listQuestion[i].label}', six);
            Response response7 = new Response('7 ${_listQuestion[i].label}', seven);
            Response response8 = new Response('8 ${_listQuestion[i].label}', eight);
            Response response9 = new Response('9 ${_listQuestion[i].label}', nine);
            Response response10 = new Response('10 ${_listQuestion[i].label}', teen);
            Response response11 = new Response('> 10 ${_listQuestion[i].label}', more);
            _listTemp.add(response);
            _listTemp.add(response2);
            _listTemp.add(response3);
            _listTemp.add(response4);
            _listTemp.add(response5);
            _listTemp.add(response6);
            _listTemp.add(response7);
            _listTemp.add(response8);
            _listTemp.add(response9);
            _listTemp.add(response10);
            _listTemp.add(response11);
            setState(() {
              _listQuestion[i].listResponse = _listTemp;
              _listQuestion[i].respondent = value.documents.length;
            });
          } else {
            setState(() {
              _listQuestion[i].empty = true;
            });
          }
        });
      } else if(_listQuestion[i].type == 10 || _listQuestion[i].type == 30){
        List<Response> _listTemp = new List<Response>();
        await _firestore.collection('questionnaire').document('response').collection('searchalumnus').document(_id_faculty).collection(widget.id).where('id_question', isEqualTo: _listQuestion[i].id).getDocuments().then((value){
          if(value.documents.isNotEmpty){
            value.documents.forEach((f) {
              for(int j = 0; j < _listQuestion[i].child.length; j++){
                if(_listQuestion[i].child[j].id_question == f.data['answer']){
                  _listQuestion[i].child[j].sumAnswer++;
                }
              }
            });
            for(int k = 0; k < _listQuestion[i].child.length; k++){
              Response response = new Response(_listQuestion[i].child[k].title, _listQuestion[i].child[k].sumAnswer);
              _listTemp.add(response);
            }
            setState(() {
              _listQuestion[i].listResponse = _listTemp;
              _listQuestion[i].respondent = value.documents.length;
            });
          } else {
            setState(() {
              _listQuestion[i].empty = true;
            });
          }
        });
      } else {
        List<Response> _listTemp = new List<Response>();
        await _firestore.collection('questionnaire').document('response').collection('searchalumnus').document(_id_faculty).collection(widget.id).where('id_question', isEqualTo: _listQuestion[i].id).getDocuments().then((value){
          if(value.documents.isNotEmpty){
            value.documents.forEach((f) {
              List splitAnswer = f.data['answer'].toString().split(':');
              for(int j = 0; j < _listQuestion[i].child.length; j++){
                for(int x = 0; x < splitAnswer.length; x++){
                  if(_listQuestion[i].child[j].id_question == splitAnswer[x]){
                    _listQuestion[i].child[j].sumAnswer++;
                  }
                }
              }
            });
            for(int k = 0; k < _listQuestion[i].child.length; k++){
              Response response = new Response(_listQuestion[i].child[k].title, _listQuestion[i].child[k].sumAnswer);
              _listTemp.add(response);
            }
            setState(() {
              _listQuestion[i].listResponse = _listTemp;
              _listQuestion[i].respondent = value.documents.length;
            });
          } else {
            setState(() {
              _listQuestion[i].empty = true;
            });
          }
        });
      }
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
                      'Statik Penelusuran Alumni',
                    ),
                  )
                ),
                SizedBox(width: 8.0,),
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
                        'Jurusan ${widget.name}',
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
                        'Berikut daftar statik penelusuran alumni untuk jurusan ${widget.name}',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              if(_listQuestion.length > 0)
              ListView.builder(
                itemCount: _listQuestion.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index){
                  return Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _listQuestion[index].title,
                                style: TextStyle(
                                  fontFamily: 'Google',
                                  fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Text(
                                '${_listQuestion[index].respondent} Alumni yang Menjawab',
                                style: TextStyle(
                                  fontSize: Theme.of(context).textTheme.caption.fontSize
                                ),
                              ),
                            ],
                          ),
                        ),
                        if(_listQuestion[index].listResponse != null)
                        BarChart(
                          data: _listQuestion[index].listResponse,
                          height: 220.0,
                          line: 4,
                          maxValue: _listQuestion[index].respondent,
                          barWidth: _listQuestion[index].type == 5 ? 40.0 : 70.0,
                          labelVisible: _listQuestion[index].type == 5 ? 5 : 3,
                          animDuration: Duration(milliseconds: 500),
                          barColor: Colors.blueGrey,
                          barRadius: BorderRadius.circular(10.0),
                          headerAlign: Alignment.centerLeft,
                          margin: EdgeInsets.zero,
                          padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 5.0),
                          titleStyle: TextStyle(
                            fontFamily: 'Google',
                            fontWeight: FontWeight.bold,
                            fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
                          ),
                          subtitleStyle: TextStyle(
                            fontFamily: 'Sans-Pro',
                            fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
                          ),
                        )
                        else if(_listQuestion[index].empty)
                        Padding(
                          padding: const EdgeInsets.only(top: 30.0, bottom: 50.0),
                          child: Center(
                            child: Column(
                              children: [
                                SizedBox(height: 50.0,),
                                Icon(
                                  Icons.insert_chart,
                                  color: Theme.of(context).dividerColor,
                                  size: MediaQuery.of(context).size.width * 0.15,
                                ),
                                SizedBox(height: 16.0,),
                                Text(
                                  'Data Belum Tersedia.',
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
                          padding: const EdgeInsets.all(16.0),
                          child: Shimmer.fromColors(
                            baseColor: Theme.of(context).disabledColor,
                            highlightColor: Theme.of(context).dividerColor,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 220.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(11.0),
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 15.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: FlatButton(
                              onPressed: (){
                                // Navigator.push(context, MaterialPageRoute(builder: (context) => StaticDetailsPage(action: 30, id: _listQuestion[index].id, title: _listQuestion[index].title, number: index,)));
                              }, 
                              child: Text(
                                'Lihat Detail'
                              ),
                              textColor: Theme.of(context).buttonColor,
                              padding: EdgeInsets.only(left: 10.0, right: 10.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)
                              ),
                            ),
                          ),
                        ),
                        Divider(),
                      ],
                    )
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
                        Icons.insert_chart,
                        color: Theme.of(context).dividerColor,
                        size: MediaQuery.of(context).size.width * 0.15,
                      ),
                      SizedBox(height: 16.0,),
                      Text(
                        'Data Belum Tersedia.',
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
            ]
          )
        )
      ),
    );
  }

}

class BarChart extends StatelessWidget {
  final List<Response> data;
  final double height;
  final double barWidth;
  final int labelVisible;
  final int line;
  final int maxValue;
  final Color barColor;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final BorderRadius barRadius;
  final Alignment headerAlign;
  final Duration animDuration;
  final String title;
  final String subtitle;
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;
  const BarChart({Key key, this.data, this.height, this.barColor, this.margin, this.padding, this.barRadius, this.headerAlign, this.titleStyle, this.subtitleStyle, this.title, this.subtitle, this.line, this.barWidth, this.labelVisible, this.animDuration, this.maxValue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: margin != null ? margin : EdgeInsets.all(16.0),
      padding: padding != null ? padding : EdgeInsets.all(16.0),
      child: Column(
        children: [
          if(title != null)
          Align(
            alignment: headerAlign != null ? headerAlign : Alignment.center,
            child: Text(
              title,
              style: titleStyle != null ? titleStyle : TextStyle(
                fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if(subtitle != null)
          SizedBox(height: 3.0,),
          if(subtitle != null)
          Align(
            alignment: headerAlign != null ? headerAlign : Alignment.center,
            child: Text(
              subtitle,
              style: subtitleStyle != null ? subtitleStyle : TextStyle(
                fontSize: Theme.of(context).textTheme.subtitle2.fontSize,
              ),
            ),
          ),
          SizedBox(height: 16.0,),
          Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: height != null ? height : 200.0,
                margin: EdgeInsets.only(left: maxValue.toString().length > 2 ? 26.0 : 16.0, top: 5.5),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: data.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, i){
                    return Padding(
                      padding: i == data.length - 1 ? EdgeInsets.only(right: 16.0) : EdgeInsets.zero,
                      child: Stack(
                        children: [
                          for(int j = 0; j < line; j++)
                          Positioned(
                            top: ((height - 35.0) / line).toDouble() * j,
                            child: Container(
                              width: MediaQuery.of(context).size.width / labelVisible,
                              height: 0.5,
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: barWidth,
                                    height: height != null ? height - 35.0 : 165.0,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).dividerColor,
                                      borderRadius: barRadius,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0.0,
                                    child: BouncingWidget(
                                      duration: Duration(milliseconds: 100),
                                      scaleFactor: 0.5,
                                      onPressed: (){},
                                      child: AnimatedContainer(
                                        duration: animDuration,
                                        width: barWidth,
                                        height: (data[i].point * (height - 35.0)) / maxValue,
                                        // ((height - 35.0) / line).toDouble() * data[i].chart,
                                        decoration: BoxDecoration(
                                          color: barColor,
                                          borderRadius: barRadius,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: ((data[i].point * (height - 35.0)) / maxValue) == (height - 35.0) ? ((data[i].point * (height - 35.0)) / maxValue) - 20.0 : (data[i].point * (height - 35.0)) / maxValue,
                                    left: 0.0,
                                    right: 0.0,
                                    child: Center(
                                      child: Text(
                                        '${data[i].point.round()}',
                                        style: TextStyle(
                                          fontSize: Theme.of(context).textTheme.overline.fontSize,
                                          color: ((data[i].point * (height - 35.0)) / maxValue) == (height - 35.0) ? Colors.white : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 1.0,
                                    height: 5.0,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                  Container(
                                    width: maxValue.toString().length > 2 ? (MediaQuery.of(context).size.width - 58.0) / labelVisible : (MediaQuery.of(context).size.width - 48.0) / labelVisible,
                                    height: 0.5,
                                    color: Theme.of(context).dividerColor,
                                  ),
                                  if(i == data.length - 1)
                                  Container(
                                    width: 1.0,
                                    height: 5.0,
                                    color: Theme.of(context).disabledColor,
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: maxValue.toString().length > 2 ? (MediaQuery.of(context).size.width - 58.0) / labelVisible : (MediaQuery.of(context).size.width - 48.0) / labelVisible,
                                child: Text(
                                  data[i].title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.caption.fontSize,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                ),
              ),
              for(int j = 0; j <= maxValue; j+=(maxValue / line).round())
              Positioned(
                top: ((height - 35.0) / maxValue).toDouble() * j,
                child: SizedBox(
                  width: maxValue.toString().length > 2 ? 22.0 : 12.0,
                  child: Text(
                    '${maxValue - j}',
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.overline.fontSize,
                    ),
                    textAlign: TextAlign.right,
                  ),
                )
              ),
            ],
          )
        ],
      ),
    );
  }

}