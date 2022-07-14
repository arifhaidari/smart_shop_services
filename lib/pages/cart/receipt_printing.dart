// import 'dart:io';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/order_model.dart';
import 'package:pos/db/product_shopping_cart_invoicing.dart';
import 'package:pos/db/user_model.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/home/home_page.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:image/image.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:fluttertoast/fluttertoast.dart';

class RecieptPrinting extends StatefulWidget {
  final orderObject;

  RecieptPrinting({this.orderObject});
  @override
  _RecieptPrintingState createState() => _RecieptPrintingState();
}

class _RecieptPrintingState extends State<RecieptPrinting> {
  final PosDatabase dbmanager = new PosDatabase();

  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];

  List<ProductShoppingCartInvoicing> invoicingList = List();
  OrderModel orderObject;
  List<int> barcodeNumbers = List();
  // String tempVal = "351217106857";
  String currentLanguage = "en";

  @override
  void initState() {
    super.initState();
    setState(() {
      orderObject = widget.orderObject;
    });
    _createList();
    getUserInfo();
    createBarcode();

    printerManager.scanResults.listen((devices) async {
      // print('UI: Devices found ${devices.length}');
      setState(() {
        _devices = devices;
      });
    });
  }

  void createBarcode() async {
    setState(() {
      for (var i = 0; i < orderObject.qr_code_string.length; i++) {
        barcodeNumbers.add(int.parse(orderObject.qr_code_string[i]));
      }
    });
  }

  UserModel userModelObject;

  void getUserInfo() async {
    await dbmanager.getSingleUser().then((onValue) {
      if (onValue != null) {
        userModelObject = onValue;
      }
    });
  }

  void _createList() async {
    await dbmanager.getProductShoppingCartListInvoicing(orderObject.cart_id).then((theValue) {
      theValue.forEach((invoiceValue) {
        ProductShoppingCartInvoicing productShoppingCartInvoicing = ProductShoppingCartInvoicing(
          name: invoiceValue.alias == "no_alias" ? invoiceValue.name : invoiceValue.alias,
          price: invoiceValue.price,
          has_variant: invoiceValue.has_variant,
          shopping_cart_product_quantity: invoiceValue.shopping_cart_product_quantity,
          shopping_cart_product_subtotal: invoiceValue.shopping_cart_product_subtotal,
          shopping_cart_product_discount: invoiceValue.shopping_cart_product_discount,
          shopping_cart_has_variant_option: invoiceValue.shopping_cart_has_variant_option,
        );
        invoicingList.add(productShoppingCartInvoicing);
      });
    });
  }

  void _startScanDevices() {
    setState(() {
      _devices = [];
    });
    if (printerManager != null) {
      printerManager.startScan(Duration(seconds: 3));
    }
  }

  void _stopScanDevices() {
    if (printerManager != null) {
      printerManager.stopScan();
    }
  }

  Future<Ticket> _printReceipt(PaperSize paper) async {
    final Ticket ticket = Ticket(paper);

    ticket.text(userModelObject.business,
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));

    ticket.text(userModelObject.address, styles: PosStyles(align: PosAlign.center));
    ticket.text(userModelObject.phone, styles: PosStyles(align: PosAlign.center));

    ticket.hr();
    ticket.row([
      PosColumn(text: 'Qty', width: 1),
      PosColumn(text: 'Item', width: 7),
      PosColumn(text: 'Price', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(text: 'Total', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);

    for (var i = 0; i < invoicingList.length; i++) {
      // print("value of index i: $i");
      ticket.row(
          //
          [
            PosColumn(text: invoicingList[i].shopping_cart_product_quantity.toString(), width: 1),
            PosColumn(text: invoicingList[i].name, width: 7),
            PosColumn(
                text: invoicingList[i].price.toString(),
                width: 2,
                styles: PosStyles(align: PosAlign.right)),
            PosColumn(
                text: invoicingList[i].shopping_cart_product_subtotal.toString(),
                width: 2,
                styles: PosStyles(align: PosAlign.right))
          ]

          //
          );
    }

    ticket.hr();

    ticket.row([
      PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: PosStyles(
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
          text: '${orderObject.order_subtotal}',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
    ]);

    ticket.hr(ch: '=');
    // ticket.hr(ch: '=', linesAfter: 1);

    ticket.row([
      PosColumn(
          text: 'Discount',
          width: 7,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size1)),
      PosColumn(
          text: orderObject.order_discount.toString(),
          width: 5,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size1)),
    ]);

    ticket.row([
      PosColumn(
          text: 'Recieve',
          width: 7,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size1)),
      PosColumn(
          text: orderObject.cash_collected.toString(),
          width: 5,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size1)),
    ]);

    ticket.row([
      PosColumn(
          text: 'Change',
          width: 7,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size1)),
      PosColumn(
          text: orderObject.change_due.toString(),
          width: 5,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size1)),
    ]);

    // ticket.feed(2);
    ticket.text('Thank you!', styles: PosStyles(align: PosAlign.center, bold: true));
    ticket.text('Order-# ${orderObject.qr_code_string}',
        styles: PosStyles(align: PosAlign.center, bold: true));

    final now = DateTime.now();
    final formatter = DateFormat("yMMMMd").add_jm();
    final String timestamp = formatter.format(now);
    ticket.text(timestamp, styles: PosStyles(align: PosAlign.center));
    //
    if (barcodeNumbers.length != 0) {
      ticket.barcode(Barcode.code39(barcodeNumbers));
      // ticket.barcode(Barcode.codabar(barcodeNumbers));
      // ticket.barcode(Barcode.upcA(barcodeNumbers));
    }
    // ticket.qrcode(
    //   orderObject.qr_code_string,
    //   align: PosAlign.center,
    //   size: QRSize(400.0.toInt()),
    // ); // check both for quality and then select one ...
    // ticket.feed(1);

    // Print QR Code from image
    // try {
    //   String qrData = orderObject.qr_code_string;
    //   const double qrSize = 150;
    //   final uiImg = await QrPainter(
    //     data: qrData,
    //     version: QrVersions.auto,
    //     gapless: false,
    //   ).toImageData(qrSize);
    //   final dir = await getTemporaryDirectory();
    //   final pathName = '${dir.path}/qr_tmp.png';
    //   final qrFile = File(pathName);
    //   final imgFile = await qrFile.writeAsBytes(uiImg.buffer.asUint8List());
    //   final img = decodeImage(imgFile.readAsBytesSync());

    //   ticket.image(img, align: PosAlign.center);
    // } catch (e) {
    //   print(e);
    // }

    ticket.hr();
    ticket.text("Powered by Focus, 0728333663, smartshop.services",
        styles: PosStyles(align: PosAlign.center));

    ticket.feed(1);
    ticket.cut();
    return ticket;
  }

  void _completePrinting(PrinterBluetooth printer) async {
    printerManager.selectPrinter(printer);

    const PaperSize paper = PaperSize.mm80;

    final PosPrintResult res = await printerManager.printTicket(await _printReceipt(paper));

    _showToastMessage(getTranslated(context, "cart_receipt_success"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[150],
      appBar: AppBar(
        title: Text(getTranslated(context, "cart_receipt_printing")),
        elevation: 0.1,
        backgroundColor: Colors.blue[900],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 250.0,
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePage(
                                categoryId: "all_categories",
                                sentIndex: 0,
                              )));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.home,
                      color: Colors.white,
                    ),
                    Text(
                      getTranslated(context, "cart_back_home"),
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
              backgroundColor: Colors.blue[900],
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

class Receipt {
  String name;
  int unitPrice;
  int quantity;
  int price;
  int discount;
  int subtotal;

  Receipt({this.name, this.unitPrice, this.quantity, this.price, this.discount, this.subtotal});
}
