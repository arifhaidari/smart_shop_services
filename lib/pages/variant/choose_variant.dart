import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/variant_model.dart';
import 'package:pos/db/variant_option_price.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/home/placeholder.dart';
import 'package:pos/pages/variant/variant_options.dart';

class ChooseVariant extends StatefulWidget {
  final objectMap;

  const ChooseVariant({Key key, this.objectMap}) : super(key: key);
  @override
  _ChooseVariantState createState() => _ChooseVariantState();
}

class _ChooseVariantState extends State<ChooseVariant> {
  final PosDatabase dbmanager = new PosDatabase();
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  //
  Map<int, List<VariantOptionPrice>> variantOptionMap = Map();
  List<int> variantsId = List();
  Map<int, Variant> selectedVariantsMap = Map();
  List<Variant> variantsList = List();

  bool isLoading = false;

  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(milliseconds: 50));

    return null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.objectMap != null) {
      setState(() {
        finalMap = widget.objectMap;
      });
      setVariant();
    }
    refreshList();
  }

  void setVariant() async {
    int counter = 1;

    for (var key in finalMap.keys) {
      if (counter == 1) {
        //variant_list
        setState(() {
          selectedVariantsMap = finalMap[key];
        });
        counter++;
      } else {
        //option_list
        setState(() {
          variantOptionMap = finalMap[key];
        });
      }
    }
    setState(() {
      //variantsId
      for (var key in selectedVariantsMap.keys) {
        variantsId.add(key);
      }
    });
  }

  void myOnPressed(int id) {
    if (variantsId.contains(id)) {
      variantsId.remove(id);
      refreshList();
    } else {
      variantsId.add(id);
      refreshList();
    }
  }

  void myOnPressedVariantMap(int variantIdObject) async {
    if (selectedVariantsMap == null) {
      await dbmanager.getSingleVariant(variantIdObject).then((variantObjectTemp) {
        setState(() {
          selectedVariantsMap[variantIdObject] = variantObjectTemp;
        });
      });
    } else {
      if (selectedVariantsMap.containsKey(variantIdObject)) {
        setState(() {
          selectedVariantsMap.remove(variantIdObject);
        });
      } else {
        await dbmanager.getSingleVariant(variantIdObject).then((variantObjectTemp) {
          setState(() {
            selectedVariantsMap[variantIdObject] = variantObjectTemp;
          });
        });
      }
    }
  }

  void myOnPressedMap(List<VariantOptionPrice> variantObjectList, int variantId) {
    if (variantOptionMap == null) {
      variantOptionMap[variantId] = variantObjectList;
    } else {
      if (variantOptionMap.containsKey(variantId)) {
        setState(() {
          variantOptionMap.remove(variantId);
        });
      } else {
        setState(() {
          variantOptionMap[variantId] = variantObjectList;
        });
      }
    }
  }

  Map<String, dynamic> finalMap = Map();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          elevation: 0.1,
          backgroundColor: Colors.blue[900],
          title: Text(getTranslated(context, "variant_select")),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.done, color: Colors.white),
                onPressed: () {
                  setState(() {
                    if (selectedVariantsMap.length > 0 && variantOptionMap.length > 0) {
                      finalMap['variant_list'] = selectedVariantsMap;
                      finalMap['option_list'] = variantOptionMap;
                    } else {
                      finalMap['variant_list'] = "variant_list_empty";
                      finalMap['option_list'] = "option_list_empty";
                    }
                  });
                  Navigator.pop(context, finalMap);
                }),
          ],
        ),
        body: Builder(
          builder: (context) {
            if (isLoading) {
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return RefreshIndicator(
              key: refreshKey,
              onRefresh: refreshList,
              child: Column(
                children: <Widget>[
                  Expanded(
                      child: FutureBuilder(
                    future: dbmanager.getVariantList(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        variantsList = snapshot.data;
                        if (variantsList.length == 0) {
                          return Container(
                            child: Center(child: PlaceHolderContent()),
                          );
                        }
                        return ListView.builder(
                            itemCount: variantsList == null ? 0 : variantsList.length,
                            itemBuilder: (context, index) {
                              Variant v = variantsList[index];
                              return Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Container(
                                  color: Colors.white,
                                  child: ListTile(
                                    title: Row(
                                      children: <Widget>[
                                        Text(
                                          "${v.name}",
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      if (variantsId.contains(v.id)) {
                                        myOnPressed(v.id);
                                        myOnPressedVariantMap(v.id);
                                        myOnPressedMap(null, v.id);
                                      } else {
                                        if (variantsId.length < 3) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => ChooseVariantOptions(
                                                        variantId: v.id,
                                                      ))).then((onValue) async {
                                            if (onValue != null) {
                                              Map<int, VariantOptionPrice> optionPriceMap = Map();
                                              List<VariantOptionPrice> vopTemplist = List();
                                              int variantId;
                                              setState(() {
                                                optionPriceMap = onValue;
                                                for (var key in optionPriceMap.keys) {
                                                  variantId = optionPriceMap[key].variant_id;
                                                  vopTemplist.add(optionPriceMap[key]);
                                                }
                                              });
                                              myOnPressed(variantId);
                                              myOnPressedVariantMap(variantId);
                                              myOnPressedMap(vopTemplist, variantId);
                                            }
                                          });
                                        } else {
                                          _showToastMessage(
                                              getTranslated(context, "variant_three_allowed"));
                                        }
                                      }
                                    },
                                    trailing: variantsId.contains(v.id)
                                        ? Icon(
                                            Icons.done,
                                            color: Colors.blue[900],
                                          )
                                        : Icon(
                                            Icons.done,
                                            color: Colors.yellow[600],
                                          ),
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
            );
          },
        ));
  }

  void _showToastMessage(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
