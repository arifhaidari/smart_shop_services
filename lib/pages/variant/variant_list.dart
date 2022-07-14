import 'package:flutter/material.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/home/home_page.dart';
import 'package:pos/pages/home/placeholder.dart';
import 'package:pos/pages/variant/add_variant.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/variant_model.dart';
import 'package:pos/pages/variant/variant_option_list.dart';

class VariantList extends StatefulWidget {
  @override
  _VariantListState createState() => _VariantListState();
}

class _VariantListState extends State<VariantList> {
  final PosDatabase dbmanager = new PosDatabase();

  List<Variant> variantList = List();

  var refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    variantList = [];
  }

  void getDataList() async {
    await dbmanager.getVariantList().then((value) {
      setState(() {
        variantList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(
                              sentIndex: 3,
                            )));
              },
            ),
            elevation: 0.1,
            backgroundColor: Colors.blue[900],
            title: Text(getTranslated(context, "variant")),
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddVariant()))
                        .then((value) => getDataList());
                  }),
            ],
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                  child: FutureBuilder(
                future: dbmanager.getVariantList(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    variantList = snapshot.data;
                    if (variantList.length == 0) {
                      return Container(
                        child: Center(child: PlaceHolderContent()),
                      );
                    }
                    return ListView.builder(
                        itemCount: variantList == null ? 0 : variantList.length,
                        itemBuilder: (context, index) {
                          Variant vl = variantList[index];
                          return Card(
                            elevation: 5.0,
                            child: ListTile(
                              title: Text(
                                "${vl.name}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              trailing: Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => VariantOptionList(
                                              varObject: vl,
                                              varList: variantList,
                                            ))).then((value) => getDataList());
                              },
                            ),
                          );
                        });
                  }
                  return Container(child: Center(child: new CircularProgressIndicator()));
                },
              )),
            ],
          )),
    );
  }
}
