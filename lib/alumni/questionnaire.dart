import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tracer_upn/alumni/achievement.dart';
import 'package:tracer_upn/alumni/competency.dart';
import 'package:tracer_upn/alumni/search.dart';

class QuestionnairePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return QuestionnaireState();
  }

}

class Menu {
  final int id;
  final IconData icon;
  final String name, desc;
  final Color color;

  Menu(this.id, this.icon, this.name, this.desc, this.color);
}

class QuestionnaireState extends State {

  List<Menu> listMenu = new List<Menu>();

  Menu menu = new Menu(10, Icons.search, 'Angket Penelusuran Alumni', 'Data diri lulusan', Colors.blueGrey);
  Menu menu2 = new Menu(20, Icons.show_chart, 'Tingkat Kompetensi', 'Data pekerjaan yang sementara ditekuni lulusan', Colors.blue);
  Menu menu3 = new Menu(30, Icons.timeline, 'Capaian Kompetensi', 'Angket penelusuran terkait waktu tunggu pekerjaan', Colors.pink);

  @override
  void initState() {
    listMenu.add(menu);
    listMenu.add(menu2);
    listMenu.add(menu3);
    super.initState();
  }

  _onclickMenu(int id){
    switch(id){
      case 10:
        Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()));
      break;
      case 20:
        Navigator.push(context, MaterialPageRoute(builder: (context) => CompetencyPage()));
      break;
      case 30:
        Navigator.push(context, MaterialPageRoute(builder: (context) => AchievementPage()));
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
          title: Text(
            'Angket Alumni'
          ),
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
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
                            Icons.folder_special,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0,),
                      Text(
                        'Angket Alumni',
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
                        'Angket penelusuran terkait waktu tunggu pekerjaan',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.0,),
                Text(
                  'DAFTAR ANGKET',
                  style: TextStyle(
                    fontFamily: 'Google',
                    fontWeight: FontWeight.bold,
                    fontSize: Theme.of(context).textTheme.caption.fontSize,
                    color: Theme.of(context).textTheme.caption.color,
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                GridView.count(
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
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
              ]
            )
          )
        )
      ),
    );
  }

}