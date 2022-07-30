import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tracer_upn/jurusan/staticachievement.dart';
import 'package:tracer_upn/jurusan/staticcompetency.dart';
import 'package:tracer_upn/jurusan/staticsearch.dart';

class StaticPage extends StatefulWidget {
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

class StaticState extends State {

  List<Menu> listMenu = new List<Menu>();
  String _id_departement, _name_departement;

  Menu menu = new Menu(10, Icons.search, 'Statik Angket Penelusuran Alumni', 'Data diri lulusan', Colors.blueGrey);
  Menu menu2 = new Menu(20, Icons.show_chart, 'Statik Tingkat Kompetensi', 'Data pekerjaan yang sementara ditekuni lulusan', Colors.blue);
  Menu menu3 = new Menu(30, Icons.timeline, 'Statik Capaian Kompetensi', 'Angket penelusuran terkait waktu tunggu pekerjaan', Colors.pink);

  @override
  void initState() {
    listMenu.add(menu);
    listMenu.add(menu2);
    listMenu.add(menu3);
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
  }

  _onclickMenu(int id){
    switch(id){
      case 10:
        Navigator.push(context, MaterialPageRoute(builder: (context) => StaticSearchPage()));
      break;
      case 20:
        Navigator.push(context, MaterialPageRoute(builder: (context) => StaticCompetencyPage()));
      break;
      case 30:
        Navigator.push(context, MaterialPageRoute(builder: (context) => StaticAchievementPage()));
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
                      'Statik Angket',
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        'Lihat statik angket untuk jurusan $_name_departement.',
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