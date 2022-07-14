import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/session_model.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/home/placeholder.dart';
import 'package:pos/pages/session/session_detail.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class SessionList extends StatefulWidget {
  @override
  _SessionListState createState() => _SessionListState();
}

class _SessionListState extends State<SessionList> {
  final PosDatabase dbmanager = new PosDatabase();
  List<SessionModel> sessionList = List();
  String _dateMonthObject;

  @override
  void initState() {
    super.initState();
    setState(() {
      _dateMonthObject = DateTime.now().toString().substring(0, 7);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          elevation: 0.1,
          backgroundColor: Colors.blue[900],
          title: Text(getTranslated(context, "more_session")),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.date_range, color: Colors.white),
                onPressed: () {
                  showMonthPicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2019),
                          lastDate: DateTime(2030))
                      .then((date) {
                    setState(() {
                      if (date == null) {
                        // do nonthing
                      } else {
                        _dateMonthObject = date.toString().substring(0, 7);
                        print(_dateMonthObject);
                      }
                    });
                  });
                }),
          ],
        ),

        //List of orders
        body: Column(
          children: <Widget>[
            Expanded(
                child: FutureBuilder(
              future: dbmanager.getSessionListByMonth(_dateMonthObject),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  sessionList = snapshot.data;
                  if (sessionList.length == 0) {
                    return Container(
                      child: Center(child: PlaceHolderContent()),
                    );
                  }
                  return ListView.builder(
                      itemCount: sessionList == null ? 0 : sessionList.length,
                      itemBuilder: (context, index) {
                        SessionModel sl = sessionList[index];
                        if (sessionList.length != 0) {
                          return Card(
                            elevation: 5,
                            child: ListTile(
                              trailing: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  FontAwesomeIcons.coins,
                                  color: sl.drawer_status ? Colors.blue[900] : Colors.green[900],
                                  size: 40,
                                ),
                              ),
                              // trailing: Icon(Icons.attach_money),
                              title: Text(
                                "Session-#${sl.id}",
                                style: TextStyle(
                                    color: sl.drawer_status ? Colors.black : Colors.green[900],
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              leading: CircleAvatar(
                                radius: 20.0,
                                backgroundColor: Colors.blue[800],
                                child: Icon(
                                  Icons.branding_watermark,
                                  size: 28.0,
                                  color: sl.drawer_status ? Colors.white : Colors.yellow[900],
                                ),
                              ),
                              contentPadding: EdgeInsets.all(5.0),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SessionDetail(
                                      sessionObject: sl,
                                    ),
                                  ),
                                );
                              },
                              subtitle: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Text(
                                            sl.drawer_status
                                                ? getTranslated(context, 'session_smooth')
                                                : getTranslated(context, 'session_low'),
                                            style: TextStyle(
                                                color: sl.drawer_status
                                                    ? Colors.blue[900]
                                                    : Colors.green[900],
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Text(
                                            sl.close_status
                                                ? DateFormat.yMMMMd()
                                                    .add_jm()
                                                    .format(DateTime.parse(sl.opening_time))
                                                : getTranslated(context, 'session_current_session'),
                                            style: TextStyle(
                                                color: sl.drawer_status
                                                    ? Colors.blue[900]
                                                    : Colors.green[900],
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return PlaceHolderContent();
                        }
                      });
                }
                return Container(child: Center(child: new CircularProgressIndicator()));
              },
            )),
          ],
        ));
  }
}
