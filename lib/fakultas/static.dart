import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracer_upn/fakultas/staticachievement.dart';
import 'package:tracer_upn/fakultas/staticcompetency.dart';
import 'package:tracer_upn/fakultas/staticsearch.dart';

class StaticPage extends StatefulWidget {

  final String id_departement, name;

  const StaticPage({Key key, @required this.id_departement, @required this.name}) : super(key: key);
  
  @override
  State<StatefulWidget> createState() {
    return StaticState();
  }

}

class Menu {
  final int id;
  final IconData icon;
  final String name, desc;
  final Color color;

  Menu(this.id, this.icon, this.name, this.desc, this.color);
}

class Category {
  final String id, initial, name, description;

  Category(this.id, this.initial, this.name, this.description);
}

class StaticState extends State<StaticPage> {

  List<Menu> listMenu = new List<Menu>();
  final Firestore _firestore = Firestore.instance;
  List<Category> _listCategory = new List<Category>();
  bool _isEmpty = false;
  String _id_faculty;

  Menu menu = new Menu(10, Icons.search, 'Statik Angket Penelusuran Alumni', 'Data diri lulusan', Colors.blueGrey);
  Menu menu2 = new Menu(20, Icons.show_chart, 'Statik Tingkat Kompetensi', 'Data pekerjaan yang sementara ditekuni lulusan', Colors.blue);
  Menu menu3 = new Menu(30, Icons.timeline, 'Statik Capaian Kompetensi', 'Angket penelusuran terkait waktu tunggu pekerjaan', Colors.pink);

  @override
  void initState() {
    listMenu.add(menu);
    listMenu.add(menu2);
    listMenu.add(menu3);
    _getDataFromSharedPref();
    super.initState();
  }

  _getDataFromSharedPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id_faculty = preferences.getString('faculty');
    setState(() {
      _id_faculty = id_faculty;
    });
    _getCategoryFromCloudFirestore();
  }

  _getCategoryFromCloudFirestore() async {
    List<Category> _listTemp = new List<Category>();
    await _firestore.collection('questionnaire').document('category').collection(_id_faculty).document(widget.id_departement).collection('list_category').orderBy('name').getDocuments().then((value){
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

  _onclickMenu(int id){
    switch(id){
      case 10:
        Navigator.push(context, MaterialPageRoute(builder: (context) => StaticSearchPage(id: widget.id_departement, name: widget.name,)));
      break;
      case 20:
        Navigator.push(context, MaterialPageRoute(builder: (context) => StaticCompetencyPage(id: widget.id_departement, name: widget.name,)));
      break;
      case 30:
        Navigator.push(context, MaterialPageRoute(builder: (context) => StaticAchievementPage(id: widget.id_departement, name: widget.name,)));
      break;
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
                      // showSearch(context: context, delegate: DataSearch());
                    },
                    child: Text(
                      widget.name,
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
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
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
                            Icons.graphic_eq,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0,),
                      Text(
                        'Statik Angket',
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
                        'Lihat statik angket untuk jurusan ${widget.name}.',
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
                    
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: MediaQuery.of(context).size.width * 0.03,
                  mainAxisSpacing: MediaQuery.of(context).size.width * 0.03,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: listMenu.map((menu){
                    return Material(
                      color: menu.color.withAlpha(30),
                      borderRadius: BorderRadius.circular(20.0),
                      child: InkWell(
                        onTap: (){
                          _onclickMenu(menu.id);
                        },
                        borderRadius: BorderRadius.circular(15.0),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          padding: EdgeInsets.all(16.0),
                          child: Stack(
                            children: <Widget>[
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      menu.icon,
                                      color: menu.color,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      menu.name,
                                      style: TextStyle(
                                        fontFamily: 'Google',
                                        fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Text(
                                      menu.desc,
                                      style: TextStyle(
                                        fontSize: Theme.of(context).textTheme.caption.fontSize,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // if(_listCategory.length > 0)
              // ListView.builder(
              //   itemCount: _listCategory.length,
              //   shrinkWrap: true,
              //   physics: NeverScrollableScrollPhysics(),
              //   itemBuilder: (context, i){
              //     return Column(
              //       children: [
              //         InkWell(
              //           borderRadius: BorderRadius.circular(15.0),
              //           onTap: () async {
                          
              //           },
              //           child: Padding(
              //             padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 20.0),
              //             child: Row(
              //               children: <Widget>[
              //                 ClipOval(
              //                   child: Container(
              //                     width: 35.0,
              //                     height: 35.0,
              //                     color: Theme.of(context).accentColor,
              //                     child: Center(
              //                       child: Text(
              //                         _listCategory[i].initial.toUpperCase(),
              //                         style: TextStyle(
              //                           color: Colors.white,
              //                           fontWeight: FontWeight.bold
              //                         ),
              //                         textAlign: TextAlign.center,
              //                       ),
              //                     )
              //                   ),
              //                 ),
              //                 SizedBox(width: 24.0,),
              //                 SizedBox(
              //                   width: MediaQuery.of(context).size.width * 0.65,
              //                   child: Column(
              //                     crossAxisAlignment: CrossAxisAlignment.start,
              //                     children: <Widget>[
              //                       Text(
              //                         'Statik ${_listCategory[i].name}',
              //                         style: TextStyle(
              //                           fontFamily: 'Noto',
              //                           fontWeight: FontWeight.bold,
              //                         ),
              //                       ),
              //                       SizedBox(height: 3.0,),
              //                       Text(
              //                         _listCategory[i].description,
              //                         style: TextStyle(
              //                           fontSize: Theme.of(context).textTheme.caption.fontSize,
              //                         ),
              //                       ),
              //                     ],
              //                   ),
              //                 ),
              //                 Spacer(),
              //                 Icon(
              //                   Icons.keyboard_arrow_right,
              //                   color: Colors.black26,
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ),
              //         Divider(
              //           height: 0.5,
              //         )
              //       ],
              //     );
              //   }
              // )
              // else if(_isEmpty)
              // Padding(
              //   padding: const EdgeInsets.only(top: 50.0, bottom: 10.0),
              //   child: Center(
              //     child: Column(
              //       children: [
              //         SizedBox(height: 50.0,),
              //         Icon(
              //           Icons.library_books,
              //           color: Theme.of(context).dividerColor,
              //           size: MediaQuery.of(context).size.width * 0.15,
              //         ),
              //         SizedBox(height: 16.0,),
              //         Text(
              //           'Kategori Angket Belum Tersedia.',
              //           style: TextStyle(
              //             color: Theme.of(context).disabledColor,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // )
              // else
              // Padding(
              //   padding: const EdgeInsets.only(top: 150.0, bottom: 10.0),
              //   child: SizedBox(
              //     width: 40.0,
              //     height: 40.0,
              //     child: CircularProgressIndicator(
              //       strokeWidth: 3.0,
              //     ),
              //   ),
              // ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
            ]
          )
        ),
      )
    );
  }

}