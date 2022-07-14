import 'package:flutter/material.dart';
import 'package:pos/components/log_activity.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/variant_option_model.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/variant/edit_variant.dart';
import 'package:pos/pages/variant/variant_list.dart';

class VariantOptionList extends StatefulWidget {
  final varObject;
  final varList;

  VariantOptionList({
    this.varObject,
    this.varList,
  });

  @override
  _VariantOptionListState createState() => _VariantOptionListState();
}

class _VariantOptionListState extends State<VariantOptionList> {
  final PosDatabase dbmanager = new PosDatabase();

  List<VariantOption> variantOptionList = List();

  var refreshKey = GlobalKey<RefreshIndicatorState>();
  final LogAcitvity logActivity = new LogAcitvity();
  bool log = false;
  bool backup = false;

  @override
  void initState() {
    super.initState();
    variantOptionList = [];
    refreshList();
    logActivity.logActivation().then((value) {
      if (value != null) {
        log = value.log_activate;
        backup = value.backup_activation;
      }
    });
  }

  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      variantOptionList = [];
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.blue[900],
        title: Text(getTranslated(context, "variant_option")),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.delete, color: Colors.white),
              onPressed: () async {
                await dbmanager.deleteVariant(widget.varObject.id).then((value) {
                  if (log) {
                    logActivity.recordLog(
                        "${widget.varObject.name} ${getTranslated(context, 'category_deleted')}",
                        'delete_variant',
                        widget.varObject.id,
                        "Variant",
                        null);
                  }
                  if (backup) {
                    logActivity.recordBackupHistory("Variant", widget.varObject.id, 'Delete');
                  }
                });

                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => VariantList()));
              }),
          IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                _editVariantOptionDialogue(context);
              }),
        ],
      ),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: refreshList,
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListTile(
                  title: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "${widget.varObject.name}",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                    ),
                  ),
                  onTap: () {},
                  subtitle: Column(
                    children: <Widget>[
                      Expanded(
                          child: FutureBuilder(
                        future: dbmanager.getVariantOptionList(widget.varObject.id),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            variantOptionList = snapshot.data;
                            return ListView.builder(
                                itemCount: variantOptionList == null ? 0 : variantOptionList.length,
                                itemBuilder: (context, index) {
                                  VariantOption vol = variantOptionList[index];

                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Column(
                                        children: <Widget>[
                                          // Divider(color: Colors.blue[900]),
                                          Text(
                                            "${vol.option_name}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue[900],
                                                fontSize: 15.0),
                                          ),
                                          Divider(color: Colors.blue[900]),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          }
                          return Container(child: Center(child: new CircularProgressIndicator()));
                        },
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editVariantOptionDialogue(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(getTranslated(context, "variant_edit_message")),
            elevation: 8,
            content: Text(getTranslated(context, "variant_edit_alert")),
            actions: <Widget>[
              MaterialButton(
                elevation: 3,
                child: Text(
                  getTranslated(context, "no"),
                  style:
                      TextStyle(color: Colors.blue[800], fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              MaterialButton(
                elevation: 3,
                child: Text(
                  getTranslated(context, "yes"),
                  style:
                      TextStyle(color: Colors.blue[800], fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditVariant(
                                varObject: widget.varObject,
                              )));
                },
              ),
            ],
          );
        });
  }
}
