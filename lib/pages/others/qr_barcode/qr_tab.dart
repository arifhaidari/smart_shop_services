import 'dart:math';
import 'package:pos/db/qr_code_model.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/home/placeholder.dart';
import 'package:pos/pages/others/qr_barcode/qr_printing.dart';
import 'package:random_color/random_color.dart';
import 'package:flutter/material.dart';
import 'package:pos/db/db_helper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrTab extends StatefulWidget {
  @override
  _QrTabState createState() => _QrTabState();
}

class _QrTabState extends State<QrTab> {
  final PosDatabase dbmanager = PosDatabase();
  String functionMode = "else_mode";
  String scanResult = "";
  QrcodeModel qrcodeModelObject;

  Widget _myQrcodeImage(String qrcodeImageMode) {
    double width = MediaQuery.of(context).size.width;
    if (qrcodeImageMode == "generate") {
      String startString = "FSH";
      String endString = "POS";
      Random rnd = Random();
      int min = 100000000;
      int max = 999999999;
      int r = min + rnd.nextInt(max - min);
      String qrcodeString = startString + r.toString() + endString;

      /// after creating the random text then check if database has it already or not then create new one
      _isSameBarcode(qrcodeString);
      return Column(
        children: <Widget>[
          Container(
            width: width,
            margin: const EdgeInsets.fromLTRB(0, 15, 0, 8),
            child: Center(
              child: QrImage(
                data: qrcodeString,
                version: QrVersions.auto,
                size: 170.0,
                gapless: true,
                errorStateBuilder: (cxt, err) {
                  _showToastMessage("$err ${getTranslated(context, "other_barcode_error")}");
                  _modeChanger("else_mode");
                  return Container(
                    child: Center(
                      child: Text(
                        getTranslated(context, "other_qr_unknown_error"),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Text(
            qrcodeString,
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
                            _saveQrcodeDialogue(context, qrcodeString);
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
                            _printingQrDialogue(context, qrcodeString);
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
    } else if (qrcodeImageMode == "regenerate") {
      String startString = "FSH";
      String endString = "POS";
      Random rnd = Random();
      int min = 100000000;
      int max = 999999999;
      int r = min + rnd.nextInt(max - min);
      String qrcodeString = startString + r.toString() + endString;

      /// after creating the random text then check if database has it already or not then create new one
      _isSameBarcode(qrcodeString);
      return Column(
        children: <Widget>[
          Container(
            width: width,
            margin: const EdgeInsets.fromLTRB(0, 15, 0, 8),
            child: Center(
              child: QrImage(
                data: qrcodeString,
                version: QrVersions.auto,
                size: 170.0,
                gapless: true,
                errorStateBuilder: (cxt, err) {
                  return Container(
                    child: Center(
                      child: Text(
                        getTranslated(context, "other_qr_unknown_error"),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Text(
            qrcodeModelObject.qr_data,
            style: TextStyle(color: Colors.blue[900], fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Text(
            qrcodeModelObject.name,
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
                              qrcodeModelObject = null;
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
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ))),
                ),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                      child: FlatButton.icon(
                          color: Colors.blue[900],
                          onPressed: () {
                            _saveQrcodeDialogue(context, qrcodeString);
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
                            _printingQrDialogue(context, qrcodeString);
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
    } else if (qrcodeImageMode == "list_tile_mode") {
      return Column(
        children: <Widget>[
          Container(
            width: width,
            margin: const EdgeInsets.fromLTRB(0, 15, 0, 8),
            child: Center(
              child: QrImage(
                data: qrcodeModelObject.qr_data,
                version: QrVersions.auto,
                size: 170.0,
                gapless: true,
                errorStateBuilder: (cxt, err) {
                  _showToastMessage(
                    "$err ${getTranslated(context, "other_barcode_error")}",
                  );
                  _modeChanger("else_mode");
                  return Container(
                    child: Center(
                      child: Text(
                        getTranslated(context, getTranslated(context, "other_qr_unknown_error")),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Text(
            qrcodeModelObject.qr_data,
            style: TextStyle(color: Colors.blue[900], fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Text(
            qrcodeModelObject.name,
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
                              qrcodeModelObject = null;
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
                            _editQrcodeDialogue(context);
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
                            _printingQrDialogue(context, qrcodeModelObject.qr_data);
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
      _isSameBarcode(qrcodeImageMode);
      if (qrcodeModelObject != null) {
        return Column(
          children: <Widget>[
            Container(
              width: width,
              margin: const EdgeInsets.fromLTRB(0, 15, 0, 8),
              child: Center(
                child: QrImage(
                  data: qrcodeImageMode,
                  version: QrVersions.auto,
                  size: 170.0,
                  gapless: true,
                  errorStateBuilder: (cxt, err) {
                    setState(() {
                      scanResult = "";
                    });
                    _showToastMessage(
                      "$err ${getTranslated(context, "other_barcode_error")}",
                    );
                    _modeChanger("else_mode");
                    return Container(
                      child: Center(
                        child: Text(
                          getTranslated(context, "other_qr_unknown_error"),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Text(
              qrcodeModelObject.qr_data,
              style: TextStyle(color: Colors.blue[900], fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              qrcodeModelObject.name,
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
                                qrcodeModelObject = null;
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
                              _saveQrcodeDialogue(context, scanResult);
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
                              _printingQrDialogue(context, scanResult);
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
          children: <Widget>[
            Container(
              width: width,
              margin: const EdgeInsets.fromLTRB(0, 15, 0, 8),
              child: Center(
                child: QrImage(
                  data: qrcodeImageMode,
                  version: QrVersions.auto,
                  size: 170.0,
                  gapless: true,
                  errorStateBuilder: (cxt, err) {
                    setState(() {
                      scanResult = "";
                    });
                    _showToastMessage("$err ${getTranslated(context, "other_barcode_error")}");
                    _modeChanger("else_mode");
                    return Container(
                      child: Center(
                        child: Text(
                          getTranslated(context, "other_qr_unknown_error"),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Text(
              qrcodeImageMode,
              style: TextStyle(color: Colors.blue[900], fontSize: 15, fontWeight: FontWeight.bold),
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
                                qrcodeModelObject = null;
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
                              _saveQrcodeDialogue(context, scanResult);
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
                              _printingQrDialogue(context, scanResult);
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

  Widget _silverBackground(String qrcodeImage) {
    if (functionMode == "regenerate_mode") {
      //after pressing  on Listtile and scanned the qrcode
      return SliverAppBar(
        backgroundColor: Colors.white,
        floating: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        expandedHeight: 310.0,
        flexibleSpace: FlexibleSpaceBar(
          background: _myQrcodeImage("regenerate"), // it associated with edit button
        ),
      );
    } else if (functionMode == "list_tile_mode") {
      //after pressing  on Listtile
      return SliverAppBar(
        // title: MyAppBar(),
        // pinned: true,
        floating: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        expandedHeight: 310.0,
        flexibleSpace: FlexibleSpaceBar(
          // collapseMode: CollapseMode.pin,
          background: _myQrcodeImage("list_tile_mode"),
        ),
      );
    } else if (functionMode == "generate_mode") {
      // after pressing generate button
      return SliverAppBar(
        backgroundColor: Colors.white,
        floating: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        expandedHeight: 300.0,
        flexibleSpace: FlexibleSpaceBar(
          background: _myQrcodeImage("generate"),
        ),
      );
    } else if (functionMode == "scan_mode") {
      // after pressing generate button and scan button
      return SliverAppBar(
        backgroundColor: Colors.white,
        floating: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        expandedHeight: 310.0,
        flexibleSpace: FlexibleSpaceBar(
          background: _myQrcodeImage("scan_mode"), // it associated with edit button
        ),
      );
    } else if (functionMode == "re_scan_mode") {
      // after pressing generate button and scan button
      return SliverAppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        expandedHeight: 310.0,
        flexibleSpace: FlexibleSpaceBar(
          background: _myQrcodeImage("re_scan_mode"), // it associated with edit button
        ),
      );
    } else {
      //when we open first
      return SliverAppBar(
        backgroundColor: Colors.white,
        floating: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {},
        ),
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
                      child: FlatButton.icon(
                          color: Colors.white,
                          onPressed: () {
                            _modeChanger("generate_mode");
                          },
                          icon: FittedBox(
                            child: Icon(
                              FontAwesomeIcons.qrcode,
                              color: Colors.blue[900],
                            ),
                          ),
                          label: FittedBox(
                            child: Text(
                              getTranslated(context, "other_generate_button"),
                              style: TextStyle(
                                  color: Colors.blue[900],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          )),
                    ),
                    Expanded(
                      child: FlatButton.icon(
                          color: Colors.white,
                          onPressed: () {
                            _customQrcodeDialogue(context);
                          },
                          icon: FittedBox(
                            child: Icon(
                              FontAwesomeIcons.keyboard,
                              color: Colors.blue[900],
                            ),
                          ),
                          label: FittedBox(
                            child: Text(
                              getTranslated(context, "other_qr_custom"),
                              style: TextStyle(
                                  color: Colors.blue[900],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          )),
                    ),
                    Expanded(
                      child: FlatButton.icon(
                          color: Colors.white,
                          onPressed: () {
                            _scanQrcode();
                          },
                          icon: FittedBox(
                            child: Icon(
                              FontAwesomeIcons.cameraRetro,
                              color: Colors.blue[900],
                            ),
                          ),
                          label: FittedBox(
                            child: Text(
                              getTranslated(context, "other_scan_button"),
                              style: TextStyle(
                                  color: Colors.blue[900],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          )),
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

  Future _scanQrcode() async {
    try {
      var qrResult = await BarcodeScanner.scan();
      if (qrcodeModelObject == null) {
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

  List<QrcodeModel> qrcodeList = List();
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 1));

    return null;
  }

  Widget _qrcodeListTile(QrcodeModel qrcodeObject, List<QrcodeModel> myBarcodeList, int myIndex) {
    double width = MediaQuery.of(context).size.width;
    RandomColor _randomColor = RandomColor();
    Color _color = _randomColor.randomColor(colorSaturation: ColorSaturation.highSaturation);

    var nameInitial = qrcodeObject.name[0].toUpperCase();

    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      key: Key(qrcodeObject.name),
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
                      dbmanager.deleteQrcode(qrcodeObject.id).then((onValue) {});
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
                        dbmanager.deleteQrcode(qrcodeObject.id).then((onValue) {});
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
          icon: FontAwesomeIcons.qrcode,
          onTap: () {
            listController.animateTo(0,
                duration: Duration(microseconds: 500), curve: Curves.easeInOut);
            setState(() {
              qrcodeModelObject = qrcodeObject;
            });
            _modeChanger("list_tile_mode");
            _silverBackground("list_tile_mode");
          },
          // onTap: () => _showSnackBar('Share'),
        ),
      ],
      child: Container(
        width: width * 1.0,
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
              qrcodeObject.name,
              style: TextStyle(color: Colors.black, fontSize: 17.0, fontWeight: FontWeight.bold),
            ),
            contentPadding: EdgeInsets.all(0.0),
            subtitle: Text(
              qrcodeObject.qr_data,
              style:
                  TextStyle(color: Colors.blue[900], fontSize: 15.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ),
    );
  }

  /////////////// List part ends ////////////////
  final ScrollController listController = ScrollController();
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
                  future: dbmanager.getQrcodeList(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      qrcodeList = snapshot.data;
                      if (qrcodeList.length == 0) {
                        return Container(
                          child: Center(child: PlaceHolderContent()),
                        );
                      }

                      return ListView.builder(
                          controller: listController,
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: qrcodeList == null ? 0 : qrcodeList.length,
                          itemBuilder: (context, index) {
                            QrcodeModel iml = qrcodeList[index];
                            return _qrcodeListTile(iml, qrcodeList, index);
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
      if (value != null) {
        _showToastMessage(getTranslated(context, "other_qr_exist"));
        _modeChanger("else_mode");
      }
    });
  }

  Future<void> _customQrcodeDialogue(BuildContext context) async {
    double width = MediaQuery.of(context).size.width;
    final _qrcodeTextController = TextEditingController();
    final _qrcodeNameController = TextEditingController();
    final _formKey = new GlobalKey<FormState>();
    String customQrText = "";
    String qrName = "No Name";
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(getTranslated(context, "other_custom_qr")),
            elevation: 15,
            // backgroundColor: Colors.deepOrange,
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Container(
                  height: 180,
                  width: width * 1.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: getTranslated(context, "other_qr_text"),
                        ),
                        controller: _qrcodeTextController,
                        maxLength: 50,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return getTranslated(context, "other_qr_required");
                          }
                          return null;
                        },
                        onChanged: (String saveVal) {
                          setState(() {
                            if (saveVal == "") {
                              customQrText = "";
                            } else {
                              customQrText = saveVal;
                            }
                          });
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: getTranslated(context, "other_qr_name"),
                        ),
                        controller: _qrcodeNameController,
                        maxLength: 20,
                        onChanged: (String val) {
                          setState(() {
                            if (val == "") {
                              qrName = "No Name";
                            } else {
                              qrName = val;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
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
                  _qrcodeTextController.clear();
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
                    if (customQrText.length > 0) {
                      _saveQrcode(customQrText, qrName);
                    } else {
                      _showToastMessage(getTranslated(context, "other_qr_empty"));
                      _modeChanger("else_mode");
                    }
                  }
                },
              ),
            ],
          );
        });
  }

  Future<void> _saveQrcodeDialogue(BuildContext context, String qrcodeString) async {
    double width = MediaQuery.of(context).size.width;
    final _qrcodeNameController = TextEditingController();
    final _formKey = new GlobalKey<FormState>();
    if (qrcodeModelObject != null) {
      _qrcodeNameController.text = qrcodeModelObject.name;
    }
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 170,
                  width: width * 1.0,
                  child: Center(
                    child: QrImage(
                      data: qrcodeString,
                      version: QrVersions.auto,
                      size: 150.0,
                      gapless: true,
                      errorStateBuilder: (cxt, err) {
                        setState(() {
                          scanResult = "";
                        });
                        _showToastMessage("$err ${getTranslated(context, "other_barcode_error")}");
                        _modeChanger("else_mode");
                        return Container(
                          child: Center(
                            child: Text(
                              getTranslated(context, "other_qr_unknown_error"),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Text(
                  qrcodeString,
                  style:
                      TextStyle(color: Colors.blue[900], fontSize: 15, fontWeight: FontWeight.bold),
                )
              ],
            ),
            elevation: 15,
            // backgroundColor: Colors.deepOrange,
            content: Form(
              key: _formKey,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: getTranslated(context, "other_qr_name"),
                ),
                controller: _qrcodeNameController,
                // maxLength: 10,
                validator: (String value) {
                  if (value.isEmpty) {
                    return getTranslated(context, "other_qr_required");
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
                    qrcodeModelObject = null;
                    scanResult = "";
                  });
                  _qrcodeNameController.clear();
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
                    _saveQrcode(qrcodeString, _qrcodeNameController.text);
                  }
                },
              ),
            ],
          );
        });
  }

  void _saveQrcode(String qrcodeString, String barcodeName) async {
    if (qrcodeModelObject != null) {
      qrcodeModelObject.name = barcodeName;
      qrcodeModelObject.qr_data = qrcodeString;
      await dbmanager.updateQrcode(qrcodeModelObject).then((updateValue) {
        _modeChanger("else_mode");
      });
      setState(() {
        qrcodeModelObject = null;
        scanResult = "";
      });

      Navigator.of(context).pop();
    } else {
      QrcodeModel b = new QrcodeModel(name: barcodeName, qr_data: qrcodeString);
      await dbmanager.insertQrcode(b).then((id) => {
            _modeChanger("else_mode"),
          });

      setState(() {
        qrcodeModelObject = null;
        scanResult = "";
      });

      Navigator.of(context).pop();
    }
  }

  Future<void> _editQrcodeDialogue(BuildContext context) async {
    double width = MediaQuery.of(context).size.width;
    var _qrcodeNameController = TextEditingController();
    final _formKey = new GlobalKey<FormState>();
    _qrcodeNameController.text = qrcodeModelObject.name;
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 170,
                  width: width * 1.0,
                  child: Center(
                    child: QrImage(
                      data: qrcodeModelObject.qr_data,
                      version: QrVersions.auto,
                      size: 170.0,
                      gapless: true,
                      errorStateBuilder: (cxt, err) {
                        _showToastMessage("$err ${getTranslated(context, "other_barcode_error")}");
                        _modeChanger("else_mode");
                        return Container(
                          child: Center(
                            child: Text(
                              getTranslated(context, "other_qr_unknown_error"),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    qrcodeModelObject.qr_data,
                    style: TextStyle(
                        color: Colors.blue[900], fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            elevation: 15,
            // backgroundColor: Colors.deepOrange,
            content: Form(
              key: _formKey,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: getTranslated(context, "other_qr_name"),
                ),
                controller: _qrcodeNameController,
                // maxLength: 10,
                validator: (String value) {
                  if (value.isEmpty) {
                    return getTranslated(context, "other_qr_required");
                  }

                  return null;
                },
              ),
            ),
            actions: <Widget>[
              Container(
                width: width * 0.8,
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
                            qrcodeModelObject = null;
                          });
                          _qrcodeNameController.clear();
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
                            _saveQrcode(qrcodeModelObject.qr_data, _qrcodeNameController.text);
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

  Future<void> _printingQrDialogue(BuildContext context, String qrCodeString) async {
    final _barcodeRangeController = TextEditingController();
    final _formKey = new GlobalKey<FormState>();
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(getTranslated(context, "other_qr_print")),
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
                            builder: (context) => QrPrinting(
                                  range: int.parse(_barcodeRangeController.text),
                                  qrData: qrCodeString,
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
