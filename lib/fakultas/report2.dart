import 'dart:async';
import 'dart:io';
import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportPage extends StatefulWidget {

  final String id, name;

  const ReportPage({Key key, @required this.id, @required this.name}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ReportState();
  }

}

class Level {
  final String id, id_level, level, name;

  Level(this.id, this.id_level, this.level, this.name);
}

class User {
  final String id, initial, email, username, pass, name, nim, gender, phone, address, birthplace, birthdatetext, departement, entryyear, graduationyear, faculty, level;
  final DateTime birthdate;
  bool selected;

  User(this.id, this.initial, this.email, this.username, this.pass, this.name, this.nim, this.gender, this.phone, this.address, this.birthplace, this.birthdate, this.birthdatetext, this.departement, this.entryyear, this.graduationyear, this.faculty, this.level, this.selected);

}

class Question {
  final String id_question, title;

  Question(this.id_question, this.title);
}

class Response {
  String id_question, id_response, title, grade;
  double score;

  Response(this.id_question, this.id_response, this.title, this.score, this.grade);
}

class Carrer {
  final String position, name_company, scale_company, leader_company, email_company, address_company, compatibility;

  Carrer(this.position, this.name_company, this.scale_company, this.leader_company, this.email_company, this.address_company, this.compatibility);
}

class Search {
  String id_question, id_response, title, subtitle, answer, answer2, answer3, hint, label;
  final int type, inputtype;
  List<Childs> child;
  List<Childs> subchild;
  bool filled;

  Search(this.id_question, this.id_response, this.title, this.subtitle, this.answer, this.answer2, this.answer3, this.hint, this.type, this.inputtype, this.child, this.subchild, this.filled, this.label);
}

class PdfFiles {
  String filename, path;
  bool check;

  PdfFiles(this.filename, this.path, this.check);
}

class Childs {
  final String id_question, title;
  bool input, filled;

  Childs(this.id_question, this.title, this.input, this.filled);
}

class ReportState extends State<ReportPage> {

  final _searchController = TextEditingController();
  final Firestore _firestore = Firestore.instance;
  List<PdfFiles> _pdfFiles = new List<PdfFiles>();
  List<PdfFiles> _pdfSearch = new List<PdfFiles>();
  List<User> _listUser = new List<User>();
  List<User> _listSearch = new List<User>();
  List<Level> _listLevel = new List<Level>();
  List<Carrer> _listCarrer = new List<Carrer>();
  List<Search> _listSearchAlumnus = new List<Search>();
  List<Question> _listQuestionCompetency = new List<Question>();
  List<Question> _listQuestionAchievement = new List<Question>();
  List<Response> _listLearningExperience = new List<Response>();
  List<Response> _listAchievementCompetence = new List<Response>();
  bool _isEmpty = false, _reverse = false, _isUserEmpty = false, _isSearch = false, _selected = false;
  int _position = 0, _positionList = 0, _count = 0;
  double _height = 0.0;
  String _id_level, _level_departement, _name_departement;
  List _carrerQuestion = [
    'Posisi/Jabatan',
    'Nama Perusahaan/Instansi',
    'Skala Perusahaan/Instansi',
    'Nama Atasan',
    'Email Atasan',
    'Alamat Perusahaan/Instansi',
    'Kesesuaian bidang pekerjaan terhadap bidang keilmuan selama kuliah'
  ];

  @override
  void initState() {
    _getCompetencyQuestionFromCloudFirestore();
    _getAchievementQuestionFromCloudFirestore();
    _getAllLevelDepartement();
    super.initState();
  }

  _getAllLevelDepartement() async {
    _firestore.collection('departement').document(widget.id).collection('level').getDocuments().then((value){
      if(value.documents.isNotEmpty){
        value.documents.forEach((f) async {
          _firestore.collection('level').document(f.data['id_level']).get().then((values){
            if(values.exists){
              Level level = new Level(f.documentID, f.data['id_level'], values.data['name'], f.data['name']);
              setState(() {
                _listLevel.add(level);
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
  }

  _getAllFiles(String level) async {
    _pdfFiles.clear();
    List<PdfFiles> _listTempPdf = new List<PdfFiles>();
    List<FileSystemEntity> _listTemp;
    final directory = new Directory('/storage/emulated/0/Tracer Studi UPN/$level $_name_departement');
    if((await directory.exists())){
      _listTemp = directory.listSync(recursive: true, followLinks: false);
      for(int i = 0; i < _listTemp.length; i++){
        PdfFiles file = new PdfFiles(_listTemp[i].path.split('/').last, _listTemp[i].path, false);
        _listTempPdf.add(file);
      }
      setState(() {
        _pdfFiles = _listTempPdf;
      });
    }
  }

  _getUserFromCloudFirestore() {
    _firestore.collection('user').where('role', isEqualTo: 3).getDocuments().then((user){
      if(user.documents.isNotEmpty){
        int i = 0;
        user.documents.forEach((f) {
          _firestore.collection('user').document(f.documentID).collection('biodata').document('data').get().then((value){
            if(value.exists){
              if(value.data['departement'] == widget.id && !f.data['delete'] && value.data['level'] == _id_level && value.data['competency'] && value.data['achievement']){
                String initial;
                List splitName = value.data['name'].split(' ');
                if(splitName.length > 1){
                  initial = '${splitName[0].toString().substring(0, 1)}${splitName[1].toString().substring(0, 1)}';
                } else {
                  initial = splitName[0].toString().substring(0, 1);
                }
                Timestamp dateBirth = value.data['birthdate'];
                String level_departement, name_departement;
                _firestore.collection('departement').document(value.data['departement']).collection('level').document(value.data['level']).get().then((values){
                  if(values.exists){
                    name_departement = values.data['name'];
                    _firestore.collection('level').document(values.data['id_level']).get().then((valuess){
                      if(valuess.exists){
                        level_departement = valuess.data['name'];
                        User user = new User(f.documentID, initial, f.data['email'], f.data['username'], f.data['pass'], value.data['name'], value.data['nim'], value.data['gender'], value.data['phone'], value.data['address'], value.data['birthplace'], dateBirth.toDate(), value.data['birthdatetext'], name_departement, value.data['entryyear'], value.data['graduationyear'], value.data['faculty'], level_departement, false);
                        setState(() {
                          _listUser.add(user);
                        });
                      }
                    });
                  }
                });
              } else {
                if(i == user.documents.length){
                  if(_listUser.length == 0){
                    setState(() {
                      _isUserEmpty = true;
                    });
                  }
                }
              }
            }
          });
          i++;
        });
      } else {
        setState(() {
          _isUserEmpty = true;
        });
      }
    });
    
  }

  _getCarrerResponseFromCloudFirestore(List<User> list, int index) async {
    List<Carrer> _listTemp = new List<Carrer>();
    await _firestore.collection('questionnaire').document('response').collection('carrer').document(list[index].faculty).collection(widget.id).document(list[index].id).get().then((value){
      if(value.exists){
        Carrer carrer = new Carrer(value.data['position'], value.data['company'], value.data['scale'], value.data['leader_name'], value.data['leader_email'], value.data['company_address'], value.data['compatibility']);
        _listTemp.add(carrer);
      }
    });
    if(mounted){
      setState(() {
        _listCarrer = _listTemp;
      });
    }
  }

  _getSearchAlumnusResponseFromCloudFirestore(List<User> list, int index) async {
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
        await _firestore.collection('questionnaire').document('response').collection('searchalumnus').document(list[index].faculty).collection(widget.id).where('id_answer', isEqualTo: '${_listTemp[i].id_question}/${list[index].id}').getDocuments().then((answer){
          if(answer.documents.isNotEmpty){
            answer.documents.forEach((f) {
              if(_listTemp[i].type == 5){
                _listTemp[i].id_response = f.documentID;
                _listTemp[i].answer = f.data['answer'];
              } else if(_listTemp[i].type == 10){
                for(int j = 0; j < _listTemp[i].child.length; j++){
                  if(_listTemp[i].child[j].id_question == f.data['answer']){
                    if(_listTemp[i].child[j].input){
                      _listTemp[i].id_response = f.documentID;
                      _listTemp[i].answer = '${_listTemp[i].child[j].title} (${f.data['answer2']})';
                    } else {
                      _listTemp[i].id_response = f.documentID;
                      _listTemp[i].answer = _listTemp[i].child[j].title;
                    }
                  }
                }
              } else if(_listTemp[i].type == 20){
                String answer = '';
                List split = f.data['answer'].toString().split(':');
                for(int j = 0; j < _listTemp[i].child.length; j++) {
                  for(int k = 0; k < split.length; k++){
                    if(_listTemp[i].child[j].id_question == split[k]){
                      if(_listTemp[i].child[j].input){
                        answer += '${_listTemp[i].child[j].title} (${f.data['answer2']}), ';
                      } else {
                        answer += '${_listTemp[i].child[j].title}, ';
                      }
                    }
                  }
                }
                _listTemp[i].id_response = f.documentID;
                _listTemp[i].answer = answer;
              } else {
                for(int j = 0; j < _listTemp[i].child.length; j++){
                  if(_listTemp[i].child[j].id_question == f.data['answer']){
                    if(_listTemp[i].child[j].input){
                      for(int k = 0; k < _listTemp[i].subchild.length; k++){
                        if(_listTemp[i].subchild[k].id_question == f.data['answer2']){
                          if(_listTemp[i].child[j].input){
                            _listTemp[i].id_response = f.documentID;
                            _listTemp[i].answer = '${_listTemp[i].child[j].title}, ${_listTemp[i].subchild[k].title} (${f.data['answer3']})';
                          }
                          else {
                            _listTemp[i].id_response = f.documentID;
                            _listTemp[i].answer = '${_listTemp[i].child[j].title} (${_listTemp[i].subchild[k].title})';
                          }
                        }
                      }
                    } else {
                      _listTemp[i].id_response = f.documentID;
                      _listTemp[i].answer = _listTemp[i].child[j].title;
                    }
                  }
                }
              }
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
            });
          }
        }
      }
    }
  }

  _getCompetencyQuestionFromCloudFirestore() async {
    List<Question> _listTemp = new List<Question>();
    await _firestore.collection('questionnaire').document('question').collection('competency').orderBy('number').getDocuments().then((value){
      if(value.documents.isNotEmpty){
        value.documents.forEach((f) async {
          Question question = new Question(f.documentID, f.data['title']);
          _listTemp.add(question);
        });
      }
    });
    if(mounted){
      setState(() {
        _listQuestionCompetency.addAll(_listTemp);
      });
      print('KOMPETENSI SELESAI => ${_listQuestionCompetency.length}');
    }
  }

  _getCompetencyResponseFromCloudFirestore(List<User> list, int index) async {
    List<Response> _listTemp = new List<Response>();
    for(int i = 0; i < _listQuestionCompetency.length; i++){
      await _firestore.collection('questionnaire').document('response').collection('competency').document(list[index].faculty).collection(widget.id).where('id_answer', isEqualTo: '${_listQuestionCompetency[i].id_question}/${list[index].id}').getDocuments().then((answer){
        if(answer.documents.isNotEmpty){
          String grade;
          answer.documents.forEach((f) {
            if(f.data['score'] == 1){
              grade = 'Tidak Penting';
            } else if(f.data['score'] == 2){
              grade = 'Penting';
            } else {
              grade = 'Sangat Penting';
            }
            Response response = new Response(_listQuestionCompetency[i].id_question, f.documentID, _listQuestionCompetency[i].title, f.data['score'], grade);
            _listTemp.add(response);
          });
        }
      }).then((value){
        if(i == _listQuestionCompetency.length - 1){
          setState(() {
            _listLearningExperience = _listTemp;
          });
        }
      });
    }
  }

  _getAchievementQuestionFromCloudFirestore() async {
    List<Question> _listTemp = new List<Question>();
    await _firestore.collection('questionnaire').document('question').collection('achievement').orderBy('number').getDocuments().then((value){
      if(value.documents.isNotEmpty){
        value.documents.forEach((f) {
          Question question = new Question(f.documentID, f.data['title']);
          _listTemp.add(question);
        });
      }
    });
    if(mounted){
      setState(() {
        _listQuestionAchievement.addAll(_listTemp);
      });
      print('CAPAIAN KOMPETENSI SELESAI => ${_listQuestionAchievement.length}');
    }
  }

  _getAchievementResponseFromCloudFirestore(List<User> list, int index) async {
    List<Response> _listTemp = new List<Response>();
    for(int i = 0; i < _listQuestionAchievement.length; i++){
      await _firestore.collection('questionnaire').document('response').collection('achievement').document(list[index].faculty).collection(widget.id).where('id_answer', isEqualTo: '${_listQuestionAchievement[i].id_question}/${list[index].id}').getDocuments().then((answer){
        if(answer.documents.isNotEmpty){
          String grade;
          answer.documents.forEach((f) {
            if(f.data['score'] == 1){
              grade = 'Tidak Penting';
            } else if(f.data['score'] == 2){
              grade = 'Penting';
            } else {
              grade = 'Sangat Penting';
            }
            Response response = new Response(_listQuestionAchievement[i].id_question, f.documentID, _listQuestionAchievement[i].title, f.data['score'], grade);
            _listTemp.add(response);
          });
        }
      }).then((value){
        if(i == _listQuestionAchievement.length - 1){
          setState(() {
            _listAchievementCompetence = _listTemp;
          });
        }
      });
    }
  }

  _exportToPdfFile(List<User> list, int index) async {
    if(await Permission.storage.request().isGranted){
      final pdf = pw.Document();
      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Laporan Tracer Studi Mahasiswa UPN',
              textScaleFactor: 1.7,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold
              )
            )
          ),
          pw.Padding(
            padding: pw.EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: pw.Text(
              'Biodata Mahasiswa',
              style: pw.TextStyle(
                fontSize: 12.0,
                fontWeight: pw.FontWeight.bold
              )
            ),
          ),
          pw.Row(
            children: [
              pw.SizedBox(
                width: PdfPageFormat.cm * 3.5,
                child: pw.Text(
                  'NIM'
                ),
              ),
              pw.Text(
                ': ${list[index].nim}'
              )
            ]
          ),
          pw.Row(
            children: [
              pw.SizedBox(
                width: PdfPageFormat.cm * 3.5,
                child: pw.Text(
                  'Nama Lengkap'
                ),
              ),
              pw.Text(
                ': ${list[index].name}'
              )
            ]
          ),
          pw.Row(
            children: [
              pw.SizedBox(
                width: PdfPageFormat.cm * 3.5,
                child: pw.Text(
                  'Program Studi'
                ),
              ),
              pw.Text(
                ': ${list[index].level} ${list[index].departement}'
              )
            ]
          ),
          pw.Row(
            children: [
              pw.SizedBox(
                width: PdfPageFormat.cm * 3.5,
                child: pw.Text(
                  'Email'
                ),
              ),
              pw.Text(
                ': ${list[index].email}'
              )
            ]
          ),
          pw.Row(
            children: [
              pw.SizedBox(
                width: PdfPageFormat.cm * 3.5,
                child: pw.Text(
                  'TTL'
                ),
              ),
              pw.Text(
                ': ${list[index].birthplace}, ${list[index].birthdatetext}'
              )
            ]
          ),
          pw.Row(
            children: [
              pw.SizedBox(
                width: PdfPageFormat.cm * 3.5,
                child: pw.Text(
                  'Telepon'
                ),
              ),
              pw.Text(
                ': ${list[index].phone}'
              )
            ]
          ),
          pw.Row(
            children: [
              pw.SizedBox(
                width: PdfPageFormat.cm * 3.5,
                child: pw.Text(
                  'Alamat'
                ),
              ),
              pw.Text(
                ': ${list[index].address}'
              )
            ]
          ),
          pw.Padding(
            padding: pw.EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: pw.Text(
              'Pekerjaan',
              style: pw.TextStyle(
                fontSize: 12.0,
                fontWeight: pw.FontWeight.bold
              )
            ),
          ),
          pw.Table.fromTextArray(
            context: context, 
            data: <List<String>>[
              <String>['Pertanyaan', 'Jawaban'],
              for(int i = 0; i < _carrerQuestion.length; i++)
              if(i == 0)
              <String>['${_carrerQuestion[i]}', '${_listCarrer[0].position}']
              else if(i == 1)
              <String>['${_carrerQuestion[i]}', '${_listCarrer[0].name_company}']
              else if(i == 2)
              <String>['${_carrerQuestion[i]}', '${_listCarrer[0].scale_company}']
              else if(i == 3)
              <String>['${_carrerQuestion[i]}', '${_listCarrer[0].leader_company}']
              else if(i == 4)
              <String>['${_carrerQuestion[i]}', '${_listCarrer[0].email_company}']
              else if(i == 5)
              <String>['${_carrerQuestion[i]}', '${_listCarrer[0].address_company}']
              else
              <String>['${_carrerQuestion[i]}', '${_listCarrer[0].compatibility}']
            ]
          ),
          pw.Padding(
            padding: pw.EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: pw.Text(
              'Angket Penelusuran',
              style: pw.TextStyle(
                fontSize: 12.0,
                fontWeight: pw.FontWeight.bold
              )
            ),
          ),
          pw.Table.fromTextArray(
            context: context,
            data: <List<String>>[
              <String>['Pertanyaan', 'Jawaban'],
              for(int i = 0; i < _listSearchAlumnus.length; i++)
              <String>['${_listSearchAlumnus[i].title}', '${_listSearchAlumnus[i].answer}'],
            ]
          ),
          pw.Padding(
            padding: pw.EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: pw.Text(
              'Angket Kompetensi',
              style: pw.TextStyle(
                fontSize: 12.0,
                fontWeight: pw.FontWeight.bold
              )
            ),
          ),
          pw.Table.fromTextArray(
            context: context, 
            data: <List<String>>[
              <String>['Pertanyaan', 'Jawaban'],
              for(int i = 0; i < _listLearningExperience.length; i++)
              <String>['${_listLearningExperience[i].title}', '${_listLearningExperience[i].grade}'],
            ]
          ),
          pw.Padding(
            padding: pw.EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: pw.Text(
              'Angket Capaian Kompetensi',
              style: pw.TextStyle(
                fontSize: 12.0,
                fontWeight: pw.FontWeight.bold
              )
            ),
          ),
          pw.Table.fromTextArray(
            context: context, 
            data: <List<String>>[
              <String>['Pertanyaan', 'Jawaban'],
              for(int i = 0; i < _listAchievementCompetence.length; i++)
              <String>['${_listAchievementCompetence[i].title}', '${_listAchievementCompetence[i].grade}'],
            ]
          ),
        ]
      ));
      // final directory = (await getExternalStorageDirectory()).path;
      final directory = new Directory('/storage/emulated/0/Tracer Studi UPN/$_level_departement $_name_departement');
      if((await directory.exists())){
        print('SUDAH ADA');
        final String path = '${directory.path}/Laporan_${list[index].nim}.pdf';
        final file = File(path);
        await file.writeAsBytes(pdf.save());
        Navigator.pop(context);
        setState(() {
          _reverse = true;
          if(_position == 2){
            _position = 1;
            if(_height > 0){
              _height = 0.0;
            }
            if(_isSearch){
              _searchController.text = '';
              _isSearch = false;
              FocusScope.of(context).requestFocus(new FocusNode());
            }
          }
          _getAllFiles(_level_departement);
        });
        print('PATH => $path');
      } else {
        await directory.create(recursive: true);
        final String path = '${directory.path}/Laporan_${list[index].nim}.pdf';
        final file = File(path);
        await file.writeAsBytes(pdf.save());
        Navigator.pop(context);
        setState(() {
          _reverse = true;
          if(_position == 2){
            _position = 1;
            if(_height > 0){
              _height = 0.0;
            }
            if(_isSearch){
              _searchController.text = '';
              _isSearch = false;
              FocusScope.of(context).requestFocus(new FocusNode());
            }
          }
          _getAllFiles(_level_departement);
        });
        print('PATH => $path');
      }
      // Navigator.of(context).push(MaterialPageRoute(builder: (_) => PdfViewerPage(path: path),));
    } else {
      _exportToPdfFile(list, index);
    }
  }

  Future<void> openFile(String path) async {
    final result = await OpenFile.open(path);
    print("BUKA FILE PDF => ${result.message}");
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
                  'Hapus Laporan',
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
                    'Apakah Anda yakin ingin menghapus $_count Laporan dari Tracer Studi UPN?',
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
                    onPressed: () async {
                      Navigator.pop(context);
                      for(int i = 0; i < _pdfFiles.length; i++){
                        if(_pdfFiles[i].check){
                          final file = File(_pdfFiles[i].path);
                          await file.delete();
                        }
                      }
                      setState(() {
                        _selected = false;
                        _count = 0;
                      });
                      _getAllFiles(_level_departement);
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
                  "Mengunduh laporan...",
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
                          if(_position == 0){
                            Navigator.pop(context);
                          } else {
                            setState(() {
                              _reverse = true;
                              if(_position == 2){
                                _position = 1;
                              } else if(_position == 1){
                                if(_selected){
                                  for(int i = 0; i < _pdfFiles.length; i++){
                                    _pdfFiles[i].check = false;
                                  }
                                  _selected = false;
                                  _count = 0;
                                } else {
                                  _position = 0;
                                }
                              }
                            });
                          }
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
                        _selected ? '$_count' : 'Laporan Angket',
                      ),
                    )
                  ),
                  SizedBox(width: 8.0,),
                  if(_selected)
                  ClipOval(
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red[400],
                        ),
                        onPressed: () {
                          _showAlertDialog();
                        },
                      ),
                    ),
                  ),
                  if(_selected)
                  ClipOval(
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: Icon(
                          Icons.share,
                        ),
                        onPressed: (){
                          List<String> _listPath = new List<String>();
                          for(int i = 0; i < _pdfFiles.length; i++){
                            if(_pdfFiles[i].check){
                              _listPath.add(_pdfFiles[i].path);
                            }
                          }
                          Share.shareFiles(_listPath, text: 'Laporan $_level_departement $_name_departement Tracer Studi UPN');
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
            elevation: 0.0,
          ),
          floatingActionButton: _position == 1 ? FloatingActionButton(
            child: Icon(
              Icons.add
            ),
            onPressed: (){
              setState(() {
                _reverse = false;
                _position = 2;
                _isUserEmpty = false;
              });
              _listUser.clear();
              _getUserFromCloudFirestore();
            }
          ) : null,
          body: GestureDetector(
            onTap: (){
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Theme.of(context).backgroundColor,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.green.withAlpha(30),
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
                                  Icons.date_range,
                                  color: Colors.green,
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
                              'Mengelola Laporan atau Membuat Laporan Baru pada Jurusan ${widget.name}.',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                      child: Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: (){
                                setState(() {
                                  _reverse = true;
                                  if(_selected){
                                    for(int i = 0; i < _pdfFiles.length; i++){
                                      _pdfFiles[i].check = false;
                                    }
                                    _selected = false;
                                    _count = 0;
                                  } else {
                                    _position = 0;
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  'Semua Prodi',
                                  style: TextStyle(
                                    fontFamily: 'Google',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if(_position == 1 || _position == 2)
                          Icon(
                            Feather.chevron_right,
                            size: 18.0,
                          ),
                          if(_position == 1)
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: Text(
                              '$_level_departement $_name_departement',
                              style: TextStyle(
                                fontFamily: 'Google',
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).accentColor,
                              ),
                            ),
                          ),
                          if(_position == 2)
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: Text(
                              'Alumni $_level_departement $_name_departement',
                              style: TextStyle(
                                fontFamily: 'Google',
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).accentColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Spacer(),
                          if(_position == 1 && !_selected)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: (){
                                setState(() {
                                  if(_positionList == 0){
                                    _positionList = 1;
                                  } else {
                                    _positionList = 0;
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Icon(
                                  _positionList == 1 ? Icons.view_module : Icons.view_list
                                ),
                              ),
                            ),
                          ),
                          if(_position == 1 && _selected)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: (){
                                  if(_count != _pdfFiles.length){
                                    for(int i = 0; i < _pdfFiles.length; i++){
                                      setState(() {
                                        _pdfFiles[i].check = true;
                                      });
                                    }
                                    setState(() {
                                      _count = _pdfFiles.length;
                                    });
                                  } else {
                                    for(int i = 0; i < _pdfFiles.length; i++){
                                      setState(() {
                                        _pdfFiles[i].check = false;
                                      });
                                    }
                                    setState(() {
                                      _count = 0;
                                      _selected = false;
                                    });
                                  }
                                },
                                borderRadius: BorderRadius.circular(8.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Icon(
                                    _count == _pdfFiles.length ? Icons.check_box : Icons.check_box_outline_blank
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if(_position == 1 && _height == 0.0 || _position == 2 && _height == 0.0)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: (){
                                  setState(() {
                                    _height = 60.0;
                                    _isSearch = true;
                                    if(_position == 1){
                                      _pdfSearch = _pdfFiles;
                                    } else if(_position == 2){
                                      _listSearch = _listUser;
                                    }
                                  });
                                },
                                borderRadius: BorderRadius.circular(8.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Icon(
                                    Icons.search,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ),
                    AnimatedContainer(
                      width: double.infinity,
                      height: _height,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.fastOutSlowIn,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0,),
                          child: Row(
                            children: [
                              Flexible(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: TextFormField(
                                    controller: _searchController,
                                    readOnly: false,
                                    decoration: InputDecoration(
                                      hintText: 'Nomor Induk Mahasiswa',
                                      border: InputBorder.none,
                                      filled: true,
                                    ),
                                    onChanged: (query){
                                      setState(() {
                                        if(_position == 1){
                                          _pdfSearch = _pdfFiles.where((p) => p.filename.contains(query)).toList();
                                        } else if(_position == 2){
                                          _listSearch = _listUser.where((p) => p.nim.contains(query)).toList();
                                        }
                                      });
                                    },
                                    style: Theme.of(context).textTheme.bodyText1,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ),
                              SizedBox(width: 5.0,),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Material(
                                  color: Theme.of(context).dividerColor.withAlpha(10),
                                  child: IconButton(
                                    onPressed: (){
                                      setState(() {
                                        if(_searchController.text.length > 0){
                                          _searchController.text = '';
                                        } else {
                                          _height = 0.0;
                                          _isSearch = false;
                                          FocusScope.of(context).requestFocus(new FocusNode());
                                        }
                                      });
                                      print('USER => ${_listUser.length}');
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 20.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if(_listLevel.length > 0)
                    PageTransitionSwitcher(
                      reverse: _reverse,
                      duration: Duration(milliseconds: 400),
                      transitionBuilder: (
                        Widget child,
                        Animation<double> primaryAnimation,
                        Animation<double> secondaryAnimation,
                      ) {
                        return SharedAxisTransition(
                          animation: primaryAnimation,
                          secondaryAnimation: secondaryAnimation,
                          transitionType: SharedAxisTransitionType.horizontal,
                          fillColor: Theme.of(context).backgroundColor,
                          child: child,
                        );
                      },
                      child: Container(
                        key: ValueKey<int>(_position),
                        color: Theme.of(context).backgroundColor,
                        child: _position == 0 ? _folderView() : _position == 1 ? _pdfView() : _userView(),
                      ),
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
                  ]
                )
              ),
            ),
          )
        ),
        onWillPop: _position != 0 ? (){
          setState(() {
            _reverse = true;
            if(_position == 2){
              _position = 1;
              if(_height > 0){
                _height = 0.0;
              }
              if(_isSearch){
                _searchController.text = '';
                _isSearch = false;
              }
            } else if(_position == 1){
              if(_height > 0){
                _height = 0.0;
              }
              if(_isSearch){
                _searchController.text = '';
                _isSearch = false;
              }
              if(_selected){
                for(int i = 0; i < _pdfFiles.length; i++){
                  _pdfFiles[i].check = false;
                }
                _selected = false;
                _count = 0;
              } else {
                _position = 0;
              }
            }
          });
        } : null,
      )
    );
  }

  Widget _folderView(){
    return PageTransitionSwitcher(
      duration: Duration(milliseconds: 400),
      transitionBuilder: (
        Widget child,
        Animation<double> primaryAnimation,
        Animation<double> secondaryAnimation,
      ) {
        return SharedAxisTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.vertical,
          fillColor: Theme.of(context).backgroundColor,
          child: child,
        );
      },
      child: Container(
        key: ValueKey<int>(_positionList),
        color: Theme.of(context).backgroundColor,
        child: _positionList == 0 ? _folderViewGrid() : _folderViewList()
      ),
    );
  }

  Widget _folderViewGrid(){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: MediaQuery.of(context).size.width * 0.03,
        mainAxisSpacing: MediaQuery.of(context).size.width * 0.03,
        shrinkWrap: true,
        childAspectRatio: 1/1.15,
        physics: NeverScrollableScrollPhysics(),
        children: _listLevel.map((folder){
          return Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: (){
                  setState(() {
                    _reverse = false;
                    _position = 1;
                    _name_departement = folder.name;
                    _level_departement = folder.level;
                    _id_level = folder.id;
                  });
                  _getAllFiles(folder.level);
                },
                borderRadius: BorderRadius.circular(15.0),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 5.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder,
                        color: Colors.blue[400],
                        size: MediaQuery.of(context).size.width * 0.2,
                      ),
                      Flexible(
                        child: Text(
                          '${folder.level} ${folder.name}',
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.caption.fontSize,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _folderViewList(){
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _listLevel.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, i){
        return Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: (){
                  setState(() {
                    _reverse = false;
                    _position = 1;
                    _name_departement = _listLevel[i].name;
                    _level_departement = _listLevel[i].level;
                    _id_level = _listLevel[i].id;
                  });
                  _getAllFiles(_listLevel[i].level);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.folder,
                        color: Colors.blue[400],
                        size: MediaQuery.of(context).size.width * 0.11,
                      ),
                      SizedBox(width: 16.0,),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.55,
                        child: Text(
                          '${_listLevel[i].level} ${_listLevel[i].name}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
            ),
            Divider(
              indent: 16.0,
              endIndent: 16.0,
              height: 0.5,
            )
          ],
        );
      }
    );
  }

  Widget _pdfView(){
    return PageTransitionSwitcher(
      duration: Duration(milliseconds: 400),
      transitionBuilder: (
        Widget child,
        Animation<double> primaryAnimation,
        Animation<double> secondaryAnimation,
      ) {
        return SharedAxisTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.vertical,
          fillColor: Theme.of(context).backgroundColor,
          child: child,
        );
      },
      child: Container(
        key: ValueKey<int>(_positionList),
        color: Theme.of(context).backgroundColor,
        child: _positionList == 0 ? _pdfViewGrid() : _pdfViewList()
      ),
    );
  }

  Widget _pdfViewGrid(){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child:  _isSearch ? _pdfSearch.length > 0 ? GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: MediaQuery.of(context).size.width * 0.03,
        mainAxisSpacing: MediaQuery.of(context).size.width * 0.03,
        shrinkWrap: true,
        childAspectRatio: 1/1.1,
        physics: NeverScrollableScrollPhysics(),
        children: _pdfSearch.map((pdf){
          return Material(
            color: pdf.check ? Theme.of(context).dividerColor.withAlpha(20) : Colors.transparent,
            borderRadius: BorderRadius.circular(15.0),
            child: InkWell(
              onTap: (){
                if(_selected){
                  if(pdf.check){
                    if(_count == 1){
                      setState(() {
                        pdf.check = !pdf.check;
                        _count--;
                        _selected = false;
                      });
                    } else {
                      setState(() {
                        pdf.check = !pdf.check;
                        _count--;
                      });
                    }
                  } else {
                    setState(() {
                      pdf.check = !pdf.check;
                      _count++;
                    });
                  }
                } else {
                  openFile(pdf.path);
                }
              },
              onLongPress: (){
                if(_selected){
                  if(pdf.check){
                    if(_count == 1){
                      setState(() {
                        pdf.check = !pdf.check;
                        _count--;
                        _selected = false;
                      });
                    } else {
                      setState(() {
                        pdf.check = !pdf.check;
                        _count--;
                      });
                    }
                  } else {
                    setState(() {
                      pdf.check = !pdf.check;
                      _count++;
                    });
                  }
                } else {
                  setState(() {
                    _selected = true;
                    pdf.check = !pdf.check;
                    _count++;
                  });
                }
                // Share.shareFiles([pdf.path], text: 'Laporan $_level_departement $_name_departement Tracer Studi UPN');
              },
              borderRadius: BorderRadius.circular(15.0),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      FontAwesome.file_pdf_o,
                      color: Colors.blue[400],
                      size: MediaQuery.of(context).size.width * 0.15,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Flexible(
                      child: Text(
                        '${pdf.filename}',
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.caption.fontSize,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ) :  Center(
      child: Column(
        children: [
          SizedBox(height: 50.0,),
          Icon(
            Icons.search,
            color: Theme.of(context).dividerColor,
            size: MediaQuery.of(context).size.width * 0.15,
          ),
          SizedBox(height: 16.0,),
          Text(
            'Oops.. hasil pencarian tidak ditemukan.',
            style: TextStyle(
              color: Theme.of(context).disabledColor,
            ),
          ),
        ],
      ),
    ) : _pdfFiles.length > 0 ? GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: MediaQuery.of(context).size.width * 0.03,
        mainAxisSpacing: MediaQuery.of(context).size.width * 0.03,
        shrinkWrap: true,
        childAspectRatio: 1/1.1,
        physics: NeverScrollableScrollPhysics(),
        children: _pdfFiles.map((pdf){
          return Material(
            color: pdf.check ? Theme.of(context).dividerColor.withAlpha(20) : Colors.transparent,
            borderRadius: BorderRadius.circular(15.0),
            child: InkWell(
              onTap: (){
                if(_selected){
                  if(pdf.check){
                    if(_count == 1){
                      setState(() {
                        pdf.check = !pdf.check;
                        _count--;
                        _selected = false;
                      });
                    } else {
                      setState(() {
                        pdf.check = !pdf.check;
                        _count--;
                      });
                    }
                  } else {
                    setState(() {
                      pdf.check = !pdf.check;
                      _count++;
                    });
                  }
                } else {
                  openFile(pdf.path);
                }
              },
              onLongPress: (){
                if(_selected){
                  if(pdf.check){
                    if(_count == 1){
                      setState(() {
                        pdf.check = !pdf.check;
                        _count--;
                        _selected = false;
                      });
                    } else {
                      setState(() {
                        pdf.check = !pdf.check;
                        _count--;
                      });
                    }
                  } else {
                    setState(() {
                      pdf.check = !pdf.check;
                      _count++;
                    });
                  }
                } else {
                  setState(() {
                    _selected = true;
                    pdf.check = !pdf.check;
                    _count++;
                  });
                }
                // Share.shareFiles([pdf.path], text: 'Laporan $_level_departement $_name_departement Tracer Studi UPN');
              },
              borderRadius: BorderRadius.circular(15.0),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      FontAwesome.file_pdf_o,
                      color: Colors.blue[400],
                      size: MediaQuery.of(context).size.width * 0.15,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Flexible(
                      child: Text(
                        '${pdf.filename}',
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.caption.fontSize,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ) : Center(
        child: Column(
          children: [
            SizedBox(height: 50.0,),
            Icon(
              FontAwesome.file_pdf_o,
              color: Theme.of(context).dividerColor,
              size: MediaQuery.of(context).size.width * 0.15,
            ),
            SizedBox(height: 16.0,),
            Text(
              'Laporan Belum Tersedia.',
              style: TextStyle(
                color: Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pdfViewList(){
    return _isSearch ? _pdfSearch.length > 0 ? ListView.builder(
      shrinkWrap: true,
      itemCount: _pdfSearch.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, i){
        return Column(
          children: [
            Material(
              color: _pdfSearch[i].check ? Theme.of(context).dividerColor.withAlpha(20) : Colors.transparent,
              child: InkWell(
                onTap: (){
                  if(_selected){
                    if(_pdfSearch[i].check){
                      if(_count == 1){
                        setState(() {
                          _pdfSearch[i].check = !_pdfSearch[i].check;
                          _count--;
                          _selected = false;
                        });
                      } else {
                        setState(() {
                          _pdfSearch[i].check = !_pdfSearch[i].check;
                          _count--;
                        });
                      }
                    } else {
                      setState(() {
                        _pdfSearch[i].check = !_pdfSearch[i].check;
                        _count++;
                      });
                    }
                  } else {
                    openFile(_pdfSearch[i].path);
                  }
                },
                onLongPress: (){
                  if(_selected){
                    if(_pdfSearch[i].check){
                      if(_count == 1){
                        setState(() {
                          _pdfSearch[i].check = !_pdfSearch[i].check;
                          _count--;
                          _selected = false;
                        });
                      } else {
                        setState(() {
                          _pdfSearch[i].check = !_pdfSearch[i].check;
                          _count--;
                        });
                      }
                    } else {
                      setState(() {
                        _pdfSearch[i].check = !_pdfSearch[i].check;
                        _count++;
                      });
                    }
                  } else {
                    setState(() {
                      _selected = true;
                      _pdfSearch[i].check = !_pdfSearch[i].check;
                      _count++;
                    });
                  }
                  // Share.shareFiles([pdf.path], text: 'Laporan $_level_departement $_name_departement Tracer Studi UPN');
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        FontAwesome.file_pdf_o,
                        color: Colors.blue[400],
                        size: MediaQuery.of(context).size.width * 0.11,
                      ),
                      SizedBox(width: 16.0,),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.55,
                        child: Text(
                          '${_pdfSearch[i].filename}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
            ),
            Divider(
              indent: 16.0,
              endIndent: 16.0,
              height: 0.5,
            )
          ],
        );
      }
    ) : Center(
      child: Column(
        children: [
          SizedBox(height: 50.0,),
          Icon(
            Icons.search,
            color: Theme.of(context).dividerColor,
            size: MediaQuery.of(context).size.width * 0.15,
          ),
          SizedBox(height: 16.0,),
          Text(
            'Oops.. hasil pencarian tidak ditemukan.',
            style: TextStyle(
              color: Theme.of(context).disabledColor,
            ),
          ),
        ],
      ),
    ) :  _pdfFiles.length > 0 ? ListView.builder(
      shrinkWrap: true,
      itemCount: _pdfFiles.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, i){
        return Column(
          children: [
            Material(
              color: _pdfFiles[i].check ? Theme.of(context).dividerColor.withAlpha(20) : Colors.transparent,
              child: InkWell(
                onTap: (){
                  if(_selected){
                    if(_pdfFiles[i].check){
                      if(_count == 1){
                        setState(() {
                          _pdfFiles[i].check = !_pdfFiles[i].check;
                          _count--;
                          _selected = false;
                        });
                      } else {
                        setState(() {
                          _pdfFiles[i].check = !_pdfFiles[i].check;
                          _count--;
                        });
                      }
                    } else {
                      setState(() {
                        _pdfFiles[i].check = !_pdfFiles[i].check;
                        _count++;
                      });
                    }
                  } else {
                    openFile(_pdfFiles[i].path);
                  }
                },
                onLongPress: (){
                  if(_selected){
                    if(_pdfFiles[i].check){
                      if(_count == 1){
                        setState(() {
                          _pdfFiles[i].check = !_pdfFiles[i].check;
                          _count--;
                          _selected = false;
                        });
                      } else {
                        setState(() {
                          _pdfFiles[i].check = !_pdfFiles[i].check;
                          _count--;
                        });
                      }
                    } else {
                      setState(() {
                        _pdfFiles[i].check = !_pdfFiles[i].check;
                        _count++;
                      });
                    }
                  } else {
                    setState(() {
                      _selected = true;
                      _pdfFiles[i].check = !_pdfFiles[i].check;
                      _count++;
                    });
                  }
                  // Share.shareFiles([pdf.path], text: 'Laporan $_level_departement $_name_departement Tracer Studi UPN');
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        FontAwesome.file_pdf_o,
                        color: Colors.blue[400],
                        size: MediaQuery.of(context).size.width * 0.11,
                      ),
                      SizedBox(width: 16.0,),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.55,
                        child: Text(
                          '${_pdfFiles[i].filename}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
            ),
            Divider(
              indent: 16.0,
              endIndent: 16.0,
              height: 0.5,
            )
          ],
        );
      }
    ) : Center(
      child: Column(
        children: [
          SizedBox(height: 50.0,),
          Icon(
            FontAwesome.file_pdf_o,
            color: Theme.of(context).dividerColor,
            size: MediaQuery.of(context).size.width * 0.15,
          ),
          SizedBox(height: 16.0,),
          Text(
            'Laporan Belum Tersedia.',
            style: TextStyle(
              color: Theme.of(context).disabledColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _userView() {
    return _isSearch ? _listSearch.length > 0 ? ListView.builder(
      itemCount: _listSearch.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, i){
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Theme.of(context).backgroundColor,
              child: InkWell(
                onTap: () async {
                  _showProgressDialog();
                  await _getCarrerResponseFromCloudFirestore(_listSearch, i);
                  await _getSearchAlumnusResponseFromCloudFirestore(_listSearch, i);
                  await _getCompetencyResponseFromCloudFirestore(_listSearch, i);
                  await _getAchievementResponseFromCloudFirestore(_listSearch, i);
                  _exportToPdfFile(_listSearch, i);
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
                              _listSearch[i].initial.toUpperCase(),
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
                        width: MediaQuery.of(context).size.width * 0.65,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _listSearch[i].name,
                              style: TextStyle(
                                fontFamily: 'Noto',
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _listSearch[i].nim,
                              style: TextStyle(
                                fontSize: Theme.of(context).textTheme.caption.fontSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.file_download,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(
              height: 0.5,
              indent: 70.0,
              endIndent: 16.0,
            )
          ],
        );
      }
    ) : Center(
      child: Column(
        children: [
          SizedBox(height: 50.0,),
          Icon(
            Icons.search,
            color: Theme.of(context).dividerColor,
            size: MediaQuery.of(context).size.width * 0.15,
          ),
          SizedBox(height: 16.0,),
          Text(
            'Oops.. hasil pencarian tidak ditemukan.',
            style: TextStyle(
              color: Theme.of(context).disabledColor,
            ),
          ),
        ],
      ),
    ) : _listUser.length > 0 ? ListView.builder(
      itemCount: _listUser.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, i){
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Theme.of(context).backgroundColor,
              child: InkWell(
                onTap: () async {
                  _showProgressDialog();
                  await _getCarrerResponseFromCloudFirestore(_listUser, i);
                  await _getSearchAlumnusResponseFromCloudFirestore(_listUser, i);
                  await _getCompetencyResponseFromCloudFirestore(_listUser, i);
                  await _getAchievementResponseFromCloudFirestore(_listUser, i);
                  _exportToPdfFile(_listUser, i);
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
                              _listUser[i].initial.toUpperCase(),
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
                        width: MediaQuery.of(context).size.width * 0.65,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _listUser[i].name,
                              style: TextStyle(
                                fontFamily: 'Noto',
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _listUser[i].nim,
                              style: TextStyle(
                                fontSize: Theme.of(context).textTheme.caption.fontSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.file_download,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(
              height: 0.5,
              indent: 70.0,
              endIndent: 16.0,
            )
          ],
        );
      }
    ) : _isUserEmpty ? Center(
      child: Column(
        children: [
          SizedBox(height: 50.0,),
          Icon(
            Icons.person,
            color: Theme.of(context).dividerColor,
            size: MediaQuery.of(context).size.width * 0.15,
          ),
          SizedBox(height: 16.0,),
          Text(
            'Belum tersedia Alumni yang telah mengisi Angket.',
            style: TextStyle(
              color: Theme.of(context).disabledColor,
            ),
          ),
        ],
      ),
    ) : Padding(
      padding: const EdgeInsets.only(top: 150.0, bottom: 10.0),
      child: SizedBox(
        width: 40.0,
        height: 40.0,
        child: CircularProgressIndicator(
          strokeWidth: 3.0,
        ),
      ),
    );
  }

}