import 'dart:math';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/home/placeholder.dart';
import 'package:pos/pages/others/qr_barcode/barcode_printing.dart';
import 'package:random_color/random_color.dart';
import 'package:flutter/material.dart';
import 'package:pos/db/barcode_model.dart';
import 'package:pos/db/db_helper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:barcode_flutter/barcode_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

//Ticket Printing
import 'dart:ui';
import 'package:flutter/material.dart' hide Image;

class BarcodeTab extends StatefulWidget {
  @override
  _BarcodeTabState createState() => _BarcodeTabState();
}

class _BarcodeTabState extends State<BarcodeTab> {
  final PosDatabase dbmanager = PosDatabase();
  String scanResult = "";
  String functionMode = "else_mode";
  BarcodeModel barcodeModelObject;

  Widget _myBarcodeImage(String barcodeImageMode) {
    double width = MediaQuery.of(context).size.width;
    if (barcodeImageMode == "generate") {
      // String startString = "AC";
      // String endString = "B";
      Random rnd = Random();
      int min = 111111111;
      int max = 999999999;
      int r = min + rnd.nextInt(max - min);
      // String barcodeString = startString + r.toString() + endString;
      String barcodeString = 351.toString() + r.toString();

      /// after creating the random text then check if database has it already or not then create new one
      _isSameBarcode(barcodeString);
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.fromLTRB(0, 15, 0, 8),
            child: Center(
              child: BarCodeImage(
                // params: CodabarBarCodeParams(
                params: Code128BarCodeParams(
                  barcodeString, //this text will come through function
                  withText: true,
                ),
                onError: (error) {
                  _showToastMessage("$error ${getTranslated(context, "other_barcode_error")}");
                  _modeChanger("else_mode");
                },
              ),
            ),
            width: width * 0.8,
            height: 110,
          ),
          Text(
            barcodeString,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue[900]),
          ),
          Container(
            height: 75.0,
            width: width,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                      child: FlatButton.icon(
                          color: Colors.blue[900],
                          onPressed: () {
                            _modeChanger("else_mode");
                          },
                          icon: FittedBox(
                            child: Icon(
                              FontAwesomeIcons.eraser,
                              color: Colors.white,
                            ),
                          ),
                          label: FittedBox(
                            child: Text(
                              getTranslated(context, "cancel"),
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ))),
                ),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                      child: FlatButton.icon(
                          color: Colors.blue[900],
                          onPressed: () {
                            _saveBarcodeDialogue(context, barcodeString);
                          },
                          icon: FittedBox(
                            child: Icon(
                              FontAwesomeIcons.save,
                              color: Colors.white,
                            ),
                          ),
                          label: FittedBox(
                            child: Text(
                              getTranslated(context, "save"),
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ))),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (barcodeImageMode == "regenerate") {
      Random rnd = Random();
      int min = 111111111;
      int max = 999999999;
      int r = min + rnd.nextInt(max - min);
      // String barcodeString = startString + r.toString() + endString;
      String barcodeString = 351.toString() + r.toString();

      /// after creating the random text then check if database has it already or not then create new one
      _isSameBarcode(barcodeString);
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.fromLTRB(0, 15, 0, 8),
            child: Center(
              child: BarCodeImage(
                // params: CodabarBarCodeParams(
                params: Code128BarCodeParams(
                  barcodeString, //this text will come through function
                  withText: true,
                ),
                onError: (error) {
                  _showToastMessage("$error ${getTranslated(context, "other_barcode_error")}");
                  _modeChanger("else_mode");
                },
              ),
            ),
            width: width * 0.8,
            height: 110,
          ),
          Text(
            barcodeModelObject.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue[900]),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            height: 75.0,
            width: width,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                      child: FlatButton.icon(
                          color: Colors.blue[900],
                          onPressed: () {
                            setState(() {
                              barcodeModelObject = null;
                            });
                            _modeChanger("else_mode");
                          },
                          icon: FittedBox(
                            child: Icon(
                              FontAwesomeIcons.eraser,
                              color: Colors.white,
                            ),
                          ),
                          label: FittedBox(
                            child: Text(
                              getTranslated(context, "cancel"),
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ))),
                ),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                      child: FlatButton.icon(
                          color: Colors.blue[900],
                          onPressed: () {
                            _saveBarcodeDialogue(context, barcodeString);
                          },
                          icon: FittedBox(
                            child: Icon(
                              FontAwesomeIcons.save,
                              color: Colors.white,
                            ),
                          ),
                          label: FittedBox(
                            child: Text(
                              getTranslated(context, "save"),
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ))),
                ),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                      child: FlatButton.icon(
                          color: Colors.blue[900],
                          onPressed: () {
                            _printingBarcodeDialogue(context, barcodeString);
                          },
                          icon: FittedBox(
                            child: Icon(
                              FontAwesomeIcons.print,
                              color: Colors.white,
                            ),
                          ),
                          label: FittedBox(
                            child: Text(
                              getTranslated(context, "other_print_button"),
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ))),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (barcodeImageMode == "list_tile_mode") {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.fromLTRB(0, 15, 0, 8),
            child: Center(
              child: BarCodeImage(
                // params: CodabarBarCodeParams(
                params: Code128BarCodeParams(
                  // params: EAN13BarCodeParams(
                  barcodeModelObject.barcode_text, //this text will come through function
                  withText: true,
                ),
                onError: (error) {
                  _showToastMessage("$error ${getTranslated(context, "other_barcode_error")}");
                  _modeChanger("else_mode");
                },
              ),
            ),
            width: width * 0.8,
            height: 110,
          ),
          Text(
            barcodeModelObject.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue[900]),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            height: 75.0,
            width: width,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                      child: FlatButton.icon(
                          color: Colors.blue[900],
                          onPressed: () {
                            _modeChanger("else_mode");
                            setState(() {
                              barcodeModelObject = null;
                            });
                          },
                          icon: FittedBox(
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                          label: FittedBox(
                            child: Text(
                              getTranslated(context, "back"),
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ))),
                ),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                      child: FlatButton.icon(
                          color: Colors.blue[900],
                          onPressed: () {
                            if (barcodeModelObject.product_id == null) {
                              _editBarcodeDialogue(context);
                            } else {
                              _showToastMessage(getTranslated(context, "other_associated_barcode"));
                            }
                            //back, generate, scan, save
                          },
                          icon: FittedBox(
                            child: Icon(
                              FontAwesomeIcons.edit,
                              color: Colors.white,
                            ),
                          ),
                          label: FittedBox(
                            child: Text(
                              getTranslated(context, "other_edit_button"),
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ))),
                ),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                      child: FlatButton.icon(
                          color: Colors.blue[900],
                          onPressed: () {
                            if (barcodeModelObject != null) {
                              _printingBarcodeDialogue(context, barcodeModelObject.barcode_text);
                            }
                          },
                          icon: FittedBox(
                            child: Icon(
                              FontAwesomeIcons.print,
                              color: Colors.white,
                            ),
                          ),
                          label: FittedBox(
                            child: Text(
                              getTranslated(context, "other_print_button"),
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ))),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      //re_scan_mode
      _isSameBarcode(barcodeImageMode);
      if (barcodeModelObject != null) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.fromLTRB(0, 15, 0, 8),
              child: Center(
                child: BarCodeImage(
                  // params: CodabarBarCodeParams(
                  params: Code128BarCodeParams(
                    scanResult, //this text will come through function
                    withText: true,
                  ),
                  onError: (error) {
                    setState(() {
                      scanResult = "";
                    });
                    _showToastMessage("$error ${getTranslated(context, "other_barcode_error")}");
                    _modeChanger("else_mode");
                  },
                ),
              ),
              width: width * 0.8,
              height: 110,
            ),
            Text(
              barcodeModelObject.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue[900]),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              height: 75.0,
              width: width,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                        child: FlatButton.icon(
                            color: Colors.blue[900],
                            onPressed: () {
                              setState(() {
                                barcodeModelObject = null;
                                scanResult = "";
                              });
                              _modeChanger("else_mode");
                            },
                            icon: FittedBox(
                              child: Icon(
                                FontAwesomeIcons.eraser,
                                color: Colors.white,
                              ),
                            ),
                            label: FittedBox(
                              child: Text(
                                getTranslated(context, "cancel"),
                                style: TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ))),
                  ),
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                        child: FlatButton.icon(
                            color: Colors.blue[900],
                            onPressed: () {
                              _saveBarcodeDialogue(context, scanResult);
                            },
                            icon: FittedBox(
                              child: Icon(
                                FontAwesomeIcons.save,
                                color: Colors.white,
                              ),
                            ),
                            label: FittedBox(
                              child: Text(
                                getTranslated(context, "save"),
                                style: TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ))),
                  ),
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                        child: FlatButton.icon(
                            color: Colors.blue[900],
                            onPressed: () {
                              _printingBarcodeDialogue(context, scanResult);
                            },
                            icon: FittedBox(
                              child: Icon(
                                FontAwesomeIcons.print,
                                color: Colors.white,
                              ),
                            ),
                            label: FittedBox(
                              child: Text(
                                getTranslated(context, "other_print_button"),
                                style: TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ))),
                  ),
                ],
              ),
            ),
          ],
        );
      } else {
        //scan_mode
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.fromLTRB(0, 15, 0, 8),
              child: Center(
                child: BarCodeImage(
                  params: Code128BarCodeParams(
                    barcodeImageMode, //this text will come through function
                    withText: true,
                  ),
                  onError: (error) {
                    setState(() {
                      scanResult = "";
                    });
                    _showToastMessage("$error ${getTranslated(context, "other_barcode_error")}");
                    _modeChanger("else_mode");
                  },
                ),
              ),
              width: width * 0.8,
              height: 110,
            ),
            Text(
              barcodeImageMode,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue[900]),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              height: 75.0,
              width: width,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                        child: FlatButton.icon(
                            color: Colors.blue[900],
                            onPressed: () {
                              setState(() {
                                barcodeModelObject = null;
                                scanResult = "";
                              });
                              _modeChanger("else_mode");
                            },
                            icon: FittedBox(
                              child: Icon(
                                FontAwesomeIcons.eraser,
                                color: Colors.white,
                              ),
                            ),
                            label: FittedBox(
                              child: Text(
                                getTranslated(context, "cancel"),
                                style: TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ))),
                  ),
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                        child: FlatButton.icon(
                            color: Colors.blue[900],
                            onPressed: () {
                              _saveBarcodeDialogue(context, scanResult);
                            },
                            icon: FittedBox(
                              child: Icon(
                                FontAwesomeIcons.save,
                                color: Colors.white,
                              ),
                            ),
                            label: FittedBox(
                              child: Text(
                                getTranslated(context, "save"),
                                style: TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ))),
                  ),
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                        child: FlatButton.icon(
                            color: Colors.blue[900],
                            onPressed: () {
                              _printingBarcodeDialogue(context, scanResult);
                            },
                            icon: FittedBox(
                              child: Icon(
                                FontAwesomeIcons.print,
                                color: Colors.white,
                              ),
                            ),
                            label: FittedBox(
                              child: Text(
                                getTranslated(context, "other_print_button"),
                                style: TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ))),
                  ),
                ],
              ),
            ),
          ],
        );
      }
    }
  }

  /////////////////////////// _silverBackground starts //////////////////

  Widget _silverBackground(String barcodeImage) {
    if (functionMode == "regenerate_mode") {
      //after pressing  on Listtile and scanned the barcode
      return SliverAppBar(
        backgroundColor: Colors.white,
        // pinned: true,
        floating: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        expandedHeight: 240.0,
        flexibleSpace: FlexibleSpaceBar(
          background: _myBarcodeImage("regenerate"), // it associated with edit button
        ),
      );
    } else if (functionMode == "list_tile_mode") {
      //after pressing  on Listtile
      return SliverAppBar(
        backgroundColor: Colors.white,
        // pinned: true,
        floating: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        expandedHeight: 240.0,
        flexibleSpace: FlexibleSpaceBar(
          background: _myBarcodeImage("list_tile_mode"),
        ),
      );
    } else if (functionMode == "generate_mode") {
      // after pressing generate button
      return SliverAppBar(
        backgroundColor: Colors.white,
        // pinned: true,
        // stretch: true,
        floating: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        expandedHeight: 240.0,
        flexibleSpace: FlexibleSpaceBar(
          background: _myBarcodeImage("generate"),
        ),
      );
    } else if (functionMode == "scan_mode") {
      // after pressing generate button and scan button
      return SliverAppBar(
        backgroundColor: Colors.white,
        // pinned: true,
        floating: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        expandedHeight: 240.0,
        flexibleSpace: FlexibleSpaceBar(
          background: _myBarcodeImage("scan_mode"), // it associated with edit button
        ),
      );
    } else if (functionMode == "re_scan_mode") {
      // after pressing generate button and scan button
      return SliverAppBar(
        backgroundColor: Colors.white,
        // pinned: true,
        floating: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        expandedHeight: 240.0,
        flexibleSpace: FlexibleSpaceBar(
          background: _myBarcodeImage("re_scan_mode"), // it associated with edit button
        ),
      );
    } else {
      //when we open first
      return SliverAppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {},
        ),
        // title: MyAppBar(),
        // pinned: true,
        floating: true,
        expandedHeight: 80.0,
        flexibleSpace: FlexibleSpaceBar(
          background: Column(
            children: <Widget>[
              Container(
                // margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                height: 77.0,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                          // padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                          padding: const EdgeInsets.all(8),
                          child: FlatButton.icon(
                              color: Colors.white,
                              onPressed: () {
                                _modeChanger("generate_mode");
                              },
                              icon: Icon(
                                FontAwesomeIcons.barcode,
                                color: Colors.blue[900],
                              ),
                              label: Text(
                                getTranslated(context, "other_generate_button"),
                                style: TextStyle(
                                    color: Colors.blue[900],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ))),
                    ),
                    Expanded(
                      child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: FlatButton.icon(
                              color: Colors.white,
                              onPressed: () {
                                _scanBarcode();
                              },
                              icon: Icon(
                                FontAwesomeIcons.cameraRetro,
                                color: Colors.blue[900],
                              ),
                              label: Text(
                                getTranslated(context, "other_scan_button"),
                                style: TextStyle(
                                    color: Colors.blue[900],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _modeChanger(String modeName) {
    setState(() {
      functionMode = modeName;
    });
  }

  Future _scanBarcode() async {
    try {
      var qrResult = await BarcodeScanner.scan();
      if (barcodeModelObject == null) {
        setState(() {
          scanResult = qrResult.rawContent.toString();
        });
        _modeChanger("scan_mode");
      } else {
        setState(() {
          scanResult = qrResult.rawContent.toString();
        });
        _modeChanger("re_scan_mode");
      }
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.cameraAccessDenied) {
        _showToastMessage(getTranslated(context, "home_camera_denied"));
        _modeChanger("else_mode");
      } else {
        _showToastMessage("${getTranslated(context, "home_unknown_error")} $ex");
        _modeChanger("else_mode");
      }
    } on FormatException {
      _showToastMessage(getTranslated(context, "home_press_back_button"));
      _modeChanger("else_mode");
    } catch (ex) {
      _showToastMessage("${getTranslated(context, "home_unknown_error")} $ex");
      _modeChanger("else_mode");
    }
  }

  ////////////// List part starts//////////////////

  List<BarcodeModel> barcodeList = List();
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 1));

    return null;
  }

  Widget _barcodeListTile(
      BarcodeModel barcodeObject, List<BarcodeModel> myBarcodeList, int myIndex) {
    RandomColor _randomColor = RandomColor();
    Color _color = _randomColor.randomColor(colorSaturation: ColorSaturation.highSaturation);

    var nameInitial = barcodeObject.name[0].toUpperCase();

    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      // closeOnScroll: false,
      key: Key(barcodeObject.name),
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
                      dbmanager.deleteBarcode(barcodeObject.id).then((onValue) {});
                      setState(() {
                        myBarcodeList.removeAt(myIndex);
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
            showDialog<bool>(
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
                        'No',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    MaterialButton(
                      color: Colors.blue[800],
                      child: Text(
                        'Yes',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        dbmanager.deleteBarcode(barcodeObject.id).then((onValue) {});
                        setState(() {
                          myBarcodeList.removeAt(myIndex);
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
        IconSlideAction(
          caption: getTranslated(context, "other_view_button"),
          color: Colors.blue[800],
          icon: FontAwesomeIcons.barcode,
          onTap: () {
            setState(() {
              barcodeModelObject = barcodeObject;
            });
            _modeChanger("list_tile_mode");
            _silverBackground("list_tile_mode");
          },
          // onTap: () => _showSnackBar('Share'),
        ),
      ],
      child: Card(
        elevation: 5,
        child: ListTile(
          leading: CircleAvatar(
              radius: 35.0,
              backgroundColor: _color,
              foregroundColor: Colors.black,
              // backgroundImage: NetworkImage(img),
              child: Text(
                nameInitial,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              )),
          title: Text(
            barcodeObject.name,
            style: TextStyle(color: Colors.black, fontSize: 17.0, fontWeight: FontWeight.bold),
          ),
          contentPadding: EdgeInsets.all(0.0),
          subtitle: Row(
            children: <Widget>[
              Text(
                barcodeObject.barcode_text,
                style:
                    TextStyle(color: Colors.blue[900], fontSize: 15.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /////////////// List part ends ////////////////
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        _silverBackground("else_mode"),
        //generate
        SliverList(
          delegate: SliverChildListDelegate(
            <Widget>[
              RefreshIndicator(
                key: refreshKey,
                onRefresh: refreshList,
                child: FutureBuilder(
                  future: dbmanager.getBarcodeList(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      barcodeList = snapshot.data;
                      if (barcodeList.length == 0) {
                        return Container(
                          child: Center(child: PlaceHolderContent()),
                        );
                      }

                      return ListView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: barcodeList == null ? 0 : barcodeList.length,
                          itemBuilder: (context, index) {
                            BarcodeModel iml = barcodeList[index];
                            return _barcodeListTile(iml, barcodeList, index);
                          });
                    }
                    return Container(child: Center(child: new CircularProgressIndicator()));
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _isSameBarcode(String barcodeText) async {
    await dbmanager.getSingleBarcode(barcodeText).then((value) {
      if (value == null) {
      } else {
        _showToastMessage(getTranslated(context, "other_barcode_exist"));
        _modeChanger("else_mode");
      }
    });
  }

  Future<void> _saveBarcodeDialogue(BuildContext context, String barcodeString) async {
    double width = MediaQuery.of(context).size.width;
    final _barcodeNameController = TextEditingController();
    final _formKey = new GlobalKey<FormState>();
    if (barcodeModelObject != null) {
      _barcodeNameController.text = barcodeModelObject.name;
    }
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  BarCodeImage(
                    params: Code128BarCodeParams(
                      barcodeString, //this text will come through function
                      withText: true,
                    ),
                    onError: (error) {
                      setState(() {
                        scanResult = "";
                      });
                      _showToastMessage("$error ${getTranslated(context, "other_barcode_error")}");
                      _modeChanger("else_mode");
                    },
                  ),
                ],
              ),
            ),
            elevation: 15,
            // backgroundColor: Colors.deepOrange,
            content: Form(
              key: _formKey,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: getTranslated(context, "other_barcode_name"),
                ),
                controller: _barcodeNameController,
                // maxLength: 10,
                validator: (String value) {
                  if (value.isEmpty) {
                    return getTranslated(context, "other_barcode_required");
                  }

                  return null;
                },
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                color: Colors.blue[800],
                elevation: 3,
                child: Text(
                  getTranslated(context, "cancel"),
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  setState(() {
                    barcodeModelObject = null;
                    scanResult = "";
                  });
                  _barcodeNameController.clear();
                  Navigator.of(context).pop();
                },
              ),
              MaterialButton(
                color: Colors.blue[800],
                elevation: 3,
                child: Text(
                  getTranslated(context, "submit"),
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _saveBarcode(barcodeString, _barcodeNameController.text);
                  }
                },
              ),
            ],
          );
        });
  }

  void _saveBarcode(String barcodeString, String barcodeName) async {
    if (barcodeModelObject != null) {
      barcodeModelObject.name = barcodeName;
      barcodeModelObject.barcode_text = barcodeString;
      await dbmanager.updateBarcode(barcodeModelObject).then((updateValue) {
        _modeChanger("else_mode");
      });
      setState(() {
        barcodeModelObject = null;
        scanResult = "";
      });

      Navigator.of(context).pop();
    } else {
      BarcodeModel b = new BarcodeModel(name: barcodeName, barcode_text: barcodeString);
      await dbmanager.insertBarcode(b).then((id) => {
            _modeChanger("else_mode"),
          });
      setState(() {
        barcodeModelObject = null;
        scanResult = "";
      });
      Navigator.of(context).pop();
    }
  }

  Future<void> _editBarcodeDialogue(BuildContext context) async {
    double width = MediaQuery.of(context).size.width;
    var _barcodeNameController = TextEditingController();
    final _formKey = new GlobalKey<FormState>();
    _barcodeNameController.text = barcodeModelObject.name;
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Container(
              child: Center(
                child: BarCodeImage(
                  // params: CodabarBarCodeParams(
                  params: Code128BarCodeParams(
                    barcodeModelObject.barcode_text, //this text will come through function
                    withText: true,
                  ),
                  onError: (error) {
                    _showToastMessage("$error ${getTranslated(context, "other_barcode_error")}");
                    _modeChanger("else_mode");
                  },
                ),
              ),
              width: width * 1.0,
              height: 110,
            ),
            elevation: 15,
            // backgroundColor: Colors.deepOrange,
            content: Form(
              key: _formKey,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: getTranslated(context, "other_barcode_name"),
                ),
                controller: _barcodeNameController,
                // maxLength: 10,
                validator: (String value) {
                  if (value.isEmpty) {
                    return getTranslated(context, "other_barcode_required");
                  }
                  return null;
                },
              ),
            ),
            actions: <Widget>[
              Container(
                width: width * 1.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: MaterialButton(
                        color: Colors.blue[800],
                        elevation: 3,
                        child: Text(
                          getTranslated(context, "back"),
                          style: TextStyle(
                              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          _modeChanger("else_mode");
                          setState(() {
                            barcodeModelObject = null;
                          });
                          _barcodeNameController.clear();
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: MaterialButton(
                        color: Colors.blue[800],
                        elevation: 3,
                        child: Text(
                          getTranslated(context, "submit"),
                          style: TextStyle(
                              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _saveBarcode(
                                barcodeModelObject.barcode_text, _barcodeNameController.text);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        });
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

  Future<void> _printingBarcodeDialogue(BuildContext context, String barcodeString) async {
    final _barcodeRangeController = TextEditingController();
    final _formKey = new GlobalKey<FormState>();
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(getTranslated(context, "other_print_barcode")),
            elevation: 15,
            // backgroundColor: Colors.deepOrange,
            content: Form(
              key: _formKey,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: getTranslated(context, "other_copy_no"),
                ),
                keyboardType: TextInputType.number,
                controller: _barcodeRangeController,
                // maxLength: 10,
                validator: (String value) {
                  if (value.isEmpty) {
                    return getTranslated(context, "other_renge_required");
                  }
                  return null;
                },
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                color: Colors.blue[800],
                elevation: 3,
                child: Text(
                  getTranslated(context, "cancel"),
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  _barcodeRangeController.clear();
                  // barcodeModelObject = null;
                  Navigator.of(context).pop();
                },
              ),
              MaterialButton(
                color: Colors.blue[800],
                elevation: 3,
                child: Text(
                  getTranslated(context, "submit"),
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BarcodePrinting(
                                  range: int.parse(_barcodeRangeController.text),
                                  barcodeText: barcodeString,
                                )));

                    // Navigator.of(context).pop();

                    // barcodeModelObject = null;
                  }
                },
              ),
            ],
          );
        });
  }
}
