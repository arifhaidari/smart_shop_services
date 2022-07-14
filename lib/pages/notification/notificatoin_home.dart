import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/notification_model.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/home/placeholder.dart';
import 'package:pos/pages/notification/update_by_notification.dart';

import 'invoice_due_detail.dart';

class NotificationHome extends StatefulWidget {
  @override
  _NotificationHomeState createState() => _NotificationHomeState();
}

class _NotificationHomeState extends State<NotificationHome> {
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  final PosDatabase dbmanager = new PosDatabase();

  List<NotificationModel> notificationList = List();

  @override
  void initState() {
    super.initState();
    refreshList();
    getDataList();
  }

  void getDataList() async {
    await dbmanager.getNotificationList().then((value) {
      setState(() {
        notificationList = value;
      });
    });
  }

  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 1));

    return null;
  }

  Widget _noteListTile(
      NotificationModel noteObject, List<NotificationModel> noteList, int myIndex) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      key: Key(noteObject.subject),
      actionExtentRatio: 0.25,
      dismissal: SlidableDismissal(
        child: SlidableDrawerDismissal(),
        onWillDismiss: (actionType) {
          return showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(getTranslated(context, "delete")),
                content: Text(getTranslated(context, "notification_delete_one"),
                    style: TextStyle(color: Colors.red[800])),
                actions: <Widget>[
                  MaterialButton(
                    color: Colors.blue[800],
                    child: Text(
                      getTranslated(context, "no"),
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  MaterialButton(
                    color: Colors.blue[800],
                    child: Text(
                      getTranslated(context, "yes"),
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      dbmanager.clearNotification(noteObject.id).then((onValue) {});
                      setState(() {
                        noteList.removeAt(myIndex);
                      });
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
      actions: <Widget>[
        IconSlideAction(
          // closeOnTap: true,
          caption: getTranslated(context, "delete"),
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            dbmanager.clearNotification(noteObject.id).then((onValue) {});
            setState(() {
              noteList.removeAt(myIndex);
            });
          },
          // onTap: () => _showSnackBar('Archive'),
        ),
      ],
      child: Card(
        color: Colors.white,
        elevation: 4.0,
        child: ListTile(
          leading: CircleAvatar(
            radius: 20.0,
            backgroundColor: Colors.blue[800],
            child: Icon(
              Icons.notifications_active,
              size: 25.0,
              color: noteObject.seen_status == false ? Colors.yellow[600] : Colors.white,
            ),
          ),
          title: Text(
            noteObject.subject,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(DateFormat.yMMMMd().add_jm().format(DateTime.parse(noteObject.timestamp))),
          onTap: () async {
            if (noteObject.note_type == "invoice") {
              await dbmanager.getSingleInvoice(int.parse(noteObject.detail_id)).then((onValue) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => InvoiceDueDetail(
                              invoiceObject: onValue,
                            ))).then((value) => getDataList());
              });
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UpdateByNotification(
                            noteId: noteObject.id,
                            noteType: noteObject.note_type,
                            productId: noteObject.detail_id,
                          ))).then((value) => getDataList());
            }
          },
          // subtitle: Text("subs"),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.blue[900],
        title: Text(getTranslated(context, "more_notification")),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.delete_sweep, color: Colors.white),
              onPressed: () {
                showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(getTranslated(context, "delete")),
                      content: Text(getTranslated(context, "notification_delete_all"),
                          style: TextStyle(color: Colors.red[800])),
                      actions: <Widget>[
                        MaterialButton(
                          color: Colors.blue[800],
                          child: Text(
                            getTranslated(context, "no"),
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        MaterialButton(
                          color: Colors.blue[800],
                          child: Text(
                            getTranslated(context, "yes"),
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            dbmanager.clearAllNotification().then((onValue) {});
                            setState(() {
                              refreshList();
                            });
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                );
              }),
        ],
      ),

      //List of orders
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: refreshList,
        child: FutureBuilder(
          future: dbmanager.getNotificationList(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              notificationList = snapshot.data;
              if (notificationList.length == 0) {
                return Container(
                  child: Center(child: PlaceHolderContent()),
                );
              }

              return ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: notificationList == null ? 0 : notificationList.length,
                  itemBuilder: (context, index) {
                    NotificationModel nl = notificationList[index];
                    return _noteListTile(nl, notificationList, index);
                  });
            }
            return Container(child: Center(child: new CircularProgressIndicator()));
          },
        ),
      ),
    );
  }
}

/// in daily and weekly notification delete the notificaiton when the day is not equal to the current day
