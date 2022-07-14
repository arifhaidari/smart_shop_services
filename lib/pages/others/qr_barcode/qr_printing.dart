import 'dart:io';
import 'dart:ui';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/product_shopping_cart_invoicing.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pos/localization/localization_mixins.dart';

class QrPrinting extends StatefulWidget {
  final int range;
  final String qrData;

  QrPrinting({this.range, this.qrData});
  @override
  _QrPrintingState createState() => _QrPrintingState();
}

class _QrPrintingState extends State<QrPrinting> {
  final PosDatabase dbmanager = new PosDatabase();

  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];

  List<ProductShoppingCartInvoicing> invoicingList = List();
  String qrData;
  int range;

  @override
  void initState() {
    super.initState();
    setState(() {
      qrData = widget.qrData;
      range = widget.range;
    });

    printerManager.scanResults.listen((devices) async {
      setState(() {
        _devices = devices;
      });
    });
  }

  void _startScanDevices() {
    setState(() {
      _devices = [];
    });
    printerManager.startScan(Duration(seconds: 3));
  }

  void _stopScanDevices() {
    printerManager.stopScan();
  }

  Future<Ticket> _printReceipt(PaperSize paper, int loopCounter) async {
    final Ticket ticket = Ticket(paper);

    for (var i = 0; i < loopCounter; i++) {
      //qrData
      ticket.qrcode(
        qrData,
        align: PosAlign.center,
        size: QRSize(400.0.toInt()),
      ); // check both for quality and then select one ...

      // Print QR Code from image
      // try {
      //   const double qrSize = 150;
      //   final uiImg = await QrPainter(
      //     data: qrData,
      //     version: QrVersions.auto,
      //     gapless: false,
      //   ).toImageData(qrSize);
      //   final dir = await getTemporaryDirectory();
      //   final pathName = '${dir.path}/qr_tmp.jpg';
      //   // final pathName = '${dir.path}/qr_tmp.png';
      //   final qrFile = File(pathName);
      //   final imgFile = await qrFile.writeAsBytes(uiImg.buffer.asUint8List());
      //   final img = decodeImage(imgFile.readAsBytesSync());

      //   ticket.image(img, align: PosAlign.center);
      // } catch (e) {
      //   print(e);
      // }
      //
      ticket.feed(1);
    }

    // ticket.cut();
    return ticket;
  }

  void _completePrinting(PrinterBluetooth printer) async {
    printerManager.selectPrinter(printer);

    const PaperSize paper = PaperSize.mm80;

    final PosPrintResult res = await printerManager.printTicket(await _printReceipt(paper, range));

    _showToastMessage(getTranslated(context, "other_qr_printing"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[150],
      appBar: AppBar(
        title: Text(getTranslated(context, "other_qr_print")),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 270.0,
            child: ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: _devices.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Card(
                      elevation: 5,
                      child: InkWell(
                        splashColor: Colors.blueAccent,
                        onTap: () => _completePrinting(_devices[index]),
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 50,
                              padding: EdgeInsets.only(left: 10),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.print,
                                    color: Colors.blue[900],
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          _devices[index].name ?? '',
                                          style:
                                              TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        Text(_devices[index].address),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            // Divider(),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          ),
          Container(
            height: 70,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0, bottom: 15.0),
              child: FlatButton(
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.blue, width: 1, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(10.0)),
                color: Colors.blue[900],
                splashColor: Colors.pink[700],
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.home,
                      color: Colors.white,
                    ),
                    Text(
                      getTranslated(context, "other_go_back"),
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: printerManager.isScanningStream,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: _stopScanDevices,
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
              child: Icon(Icons.search),
              onPressed: _startScanDevices,
            );
          }
        },
      ),
    );
  }

  void _showToastMessage(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blueAccent,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
