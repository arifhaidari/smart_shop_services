import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pos/components/log_activity.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/order_model.dart';
import 'package:pos/db/product_model.dart';
import 'package:pos/db/product_shopping_cart_invoicing.dart';
import 'package:pos/db/product_shopping_cart_join.dart';
import 'package:pos/db/shopping_product_model.dart';
import 'package:pos/db/user_model.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/cart/receipt_printing.dart';
import 'package:pos/pages/home/home_page.dart';
import 'package:pdf/pdf.dart'; ////////
import 'package:pdf/widgets.dart' as pw; //////
import 'package:pos/pages/product/Utility.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:printing/printing.dart';

class OrderPlaced extends StatefulWidget {
  final orderId;
  final operationType;

  OrderPlaced({this.orderId, this.operationType});
  @override
  _OrderPlacedState createState() => _OrderPlacedState();
}

class _OrderPlacedState extends State<OrderPlaced> {
  final PosDatabase dbmanager = new PosDatabase();

  List<ProductShoppingCartInvoicing> invoicingList = List();

  PrintingInfo printingInfo;

  final GlobalKey<State<StatefulWidget>> shareWidget = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _renderObjectKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> pickWidget = GlobalKey();
  final GlobalKey<State<StatefulWidget>> previewContainer = GlobalKey();

  OrderModel placedOrderObject;

  List<ProductShoppingCartJoin> productShoppingCartItems = List();
  List<ShoppingCartProductModel> shoppingCartProductModelList = List();

  double grandTotal = 0;
  double cashCollected = 0;
  double changeDue = 0;
  int cartId;

  //for invoicing
  double orderSubtotal = 0;
  double orderDiscount = 0;
  int orderId;
  String customerName;
  String customerAddress;
  String customerPhone;
  String customerEmail;
  String orderQrCodeString;

  UserModel userModelObject;
  final LogAcitvity logActivity = new LogAcitvity();
  bool log = false;

  @override
  void initState() {
    Printing.info().then((PrintingInfo info) {
      setState(() {
        printingInfo = info;
      });
    });
    super.initState();
    _getOrderInfo();
    // createList();
    getUserInfo();
    activateLogs();
  }

  void activateLogs() async {
    logActivity.createLogActivation('active_log');
  }

  void getUserInfo() async {
    await dbmanager.getSingleUser().then((onValue) {
      if (onValue != null) {
        setState(() {
          userModelObject = onValue;
        });
      }
    });
  }

  void _getOrderInfo() async {
    await dbmanager.getSingleOrder(widget.orderId).then((orderObject) {
      setState(() {
        placedOrderObject = orderObject;
        grandTotal = placedOrderObject.order_subtotal;
        cashCollected = placedOrderObject.cash_collected;
        changeDue = placedOrderObject.change_due;
        cartId = placedOrderObject.cart_id;
        orderSubtotal = placedOrderObject.order_subtotal + placedOrderObject.order_discount;
        orderDiscount = placedOrderObject.order_discount;
        orderId = placedOrderObject.id;
        orderQrCodeString = placedOrderObject.qr_code_string;
      });
    }).then((value) => createList());

    _getProductShoppingCartList();
  }

  void createList() async {
    await dbmanager.getProductShoppingCartListInvoicing(cartId).then((theValue) {
      if (theValue != null) {
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
      }
    });
  }

  void _getProductShoppingCartList() async {
    await dbmanager.getShoppingCartProductListByCartId(cartId).then((product) {
      if (product != null) {
        setState(() {
          shoppingCartProductModelList = product;
          // product.forEach((p) {
          //   .add(p);
          // });
        });
      }
    });
    if (widget.operationType == "order") {
      _updateProductQuantity();
    } else {
      _updateProductQuantityByReturn();
    }
  }

  void _updateProductQuantity() async {
    Product productObject;
    Map<int, int> productIdQuantity = Map(); //<product_id, product_quantity>
    shoppingCartProductModelList.forEach((p) async {
      if (productIdQuantity.containsKey(p.product_id)) {
        productIdQuantity[p.product_id] = productIdQuantity[p.product_id] + p.product_quantity;
      } else {
        productIdQuantity[p.product_id] = p.product_quantity;
      }
    }); //end of foreach

    for (int key in productIdQuantity.keys) {
      await dbmanager.getSingleProduct(key).then((singleObject) => {
            productObject = singleObject,
          });

      productObject.quantity = productObject.quantity - productIdQuantity[key];

      await dbmanager.updateProduct(productObject).then((id) => {
            productObject = null,
          });
    }
  }

  void _updateProductQuantityByReturn() async {
    Product productObject;
    Map<int, int> productIdQuantity = Map(); //<product_id, product_quantity>
    shoppingCartProductModelList.forEach((p) async {
      if (productIdQuantity.containsKey(p.product_id)) {
        productIdQuantity[p.product_id] = productIdQuantity[p.product_id] + p.product_quantity;
      } else {
        productIdQuantity[p.product_id] = p.product_quantity;
      }
    }); //end of foreach

    for (int key in productIdQuantity.keys) {
      await dbmanager.getSingleProduct(key).then((singleObject) => {
            productObject = singleObject,
          });

      productObject.quantity = productObject.quantity + productIdQuantity[key];

      await dbmanager.updateProduct(productObject).then((id) => {
            productObject = null,
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.blue[900],
        title: Text(getTranslated(context, "cart_order")),
      ),

      //=========== Cash Collection body =============
      body: ListView(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  height: 210.0,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      color: Colors.blue[800],
                      child: Card(
                        child: Container(
                          color: Colors.blue[800],
                          child: ListTile(
                            subtitle: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              // mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        child: Column(
                                          children: <Widget>[
                                            Material(
                                              borderRadius: BorderRadius.all(Radius.circular(50.0)),
                                              elevation: 10,
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Image.asset(
                                                  'images/done8.png',
                                                  width: 80,
                                                  height: 80,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                getTranslated(context, "cart_order"),
                                                style:
                                                    TextStyle(color: Colors.white, fontSize: 20.0),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 130.0,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      color: Colors.white,
                      child: Card(
                        child: Container(
                          color: Colors.white,
                          child: ListTile(
                            subtitle: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                // mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(
                                            getTranslated(context, "cart_cash_collected"),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(
                                            "${cashCollected.toString()}",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(
                                            getTranslated(context, "cart_grand_total"),
                                            style: TextStyle(
                                                color: Colors.blue[900],
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(
                                            "${grandTotal.toString()}",
                                            style: TextStyle(
                                              color: Colors.blue[900],
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(
                                            getTranslated(context, "cart_change_due"),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(
                                            "${changeDue.toString()}",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  height: 70.0,
                  width: width * 1.0,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                            child: FlatButton.icon(
                                color: Colors.blue[900],
                                onPressed: () {
                                  _invoiceDialogue(context, "print");
                                },
                                icon: FittedBox(
                                  child: Icon(
                                    FontAwesomeIcons.fileInvoiceDollar,
                                    color: Colors.white,
                                  ),
                                ),
                                label: FittedBox(
                                  child: Text(
                                    getTranslated(context, "cart_invoice"),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  ),
                                ))),
                      ),
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                            child: FlatButton.icon(
                                color: Colors.blue[900],
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => RecieptPrinting(
                                                orderObject: placedOrderObject,
                                              )));
                                },
                                icon: FittedBox(
                                  child: Icon(
                                    FontAwesomeIcons.receipt,
                                    color: Colors.white,
                                  ),
                                ),
                                label: FittedBox(
                                  child: Text(
                                    getTranslated(context, "cart_receipt"),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  ),
                                ))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
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
              children: <Widget>[
                Icon(
                  Icons.home,
                  color: Colors.white,
                ),
                Expanded(
                    child: Text(
                  getTranslated(context, "cart_back_home"),
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                  textAlign: TextAlign.center,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _invoiceDialogue(BuildContext context, String invoiceType) async {
    final _nameController = TextEditingController();
    final _addressController = TextEditingController();
    final _phoneController = TextEditingController();
    final _emailController = TextEditingController();
    final _formKey = new GlobalKey<FormState>();
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              getTranslated(context, "cart_invoice_detail"),
              style: TextStyle(color: Colors.blue[900]),
            ),
            elevation: 15,
            // backgroundColor: Colors.deepOrange,
            content: SingleChildScrollView(
              child: Container(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: getTranslated(context, "cart_company_name"),
                        ),
                        keyboardType: TextInputType.url,
                        controller: _nameController,
                        maxLength: 50,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return getTranslated(context, "cart_company_name_error");
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: getTranslated(context, "cart_invoice_address"),
                        ),
                        keyboardType: TextInputType.url,
                        controller: _addressController,
                        maxLength: 60,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: getTranslated(context, "cart_invoice_phone"),
                        ),
                        keyboardType: TextInputType.number,
                        controller: _phoneController,
                        maxLength: 14,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: getTranslated(context, "cart_invoice_email"),
                        ),
                        keyboardType: TextInputType.url,
                        controller: _emailController,
                        maxLength: 50,
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
                  _nameController.clear();
                  _addressController.clear();
                  _phoneController.clear();
                  _emailController.clear();
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
                  setState(() {
                    customerName = _nameController.text;
                    customerAddress = _addressController.text;
                    customerPhone = _phoneController.text;
                    customerEmail = _emailController.text;
                  });
                  if (_formKey.currentState.validate() &&
                      printingInfo?.canPrint == true &&
                      invoiceType == "print") {
                    _printPdf();
                  }
                },
              ),
            ],
          );
        });
  }

  Future<void> _printPdf() async {
    Navigator.of(context).pop();
    try {
      final bool result = await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => (await generateDocument(format)).save());
      // _showPrintedToast(result); // it only become true if it becomes printed

    } catch (e) {
      final ScaffoldState scaffold = Scaffold.of(shareWidget.currentContext);
      scaffold.showSnackBar(SnackBar(
        content: Text('${getTranslated(context, "cart_invoice_error")}: ${e.toString()}'),
      ));
    }
  }

  Future<pw.Document> generateDocument(PdfPageFormat theFormant) async {
    String rawPic;
    PdfImage assetImage;
    await dbmanager.getSingleUser().then((onValue) {
      setState(() {
        rawPic = onValue.logo;
      });
    });
    String nowTimeObject = DateTime.now().toIso8601String();

    String yearNowTime = nowTimeObject.substring(0, 4);
    String monthNowTime = nowTimeObject.substring(5, 7);
    String dayNowTime = nowTimeObject.substring(8, 10);
    String invoiceDate = nowTimeObject.substring(0, 10);

    String invoiceNumber = yearNowTime + monthNowTime + dayNowTime + orderId.toString();

    Uint8List finalImage;

    try {
      final image = await QrPainter(
        data: orderQrCodeString,
        version: QrVersions.auto,
        gapless: true,
      ).toImage(300);
      final a = await image.toByteData(format: ImageByteFormat.png);

      finalImage = a.buffer.asUint8List();
    } catch (e) {
      throw e;
    }

    final pw.Document doc = pw.Document();

    final PdfImage qrImage = await pdfImageFromImageProvider(
      pdf: doc.document,
      image: MemoryImage(finalImage),
    );

    if (rawPic == "no_logo") {
      assetImage = await pdfImageFromImageProvider(
        pdf: doc.document,
        image: const AssetImage('images/invoice_logo.png'),
      );
    } else {
      assetImage = await pdfImageFromImageProvider(
        pdf: doc.document,
        // image: const NetworkImage(""),
        image: (Utility.imageFromBase64String(rawPic)).image,
      );
    }

    doc.addPage(
      pw.MultiPage(
          pageFormat: theFormant,
          // margin: pw.EdgeInsets.all(10),
          margin: pw.EdgeInsets.fromLTRB(40, 15, 25, 40),
          build: (pw.Context context) {
            return <pw.Widget>[
              pw.Row(children: <pw.Widget>[
                pw.Expanded(
                  child: pw.Container(
                      // width: width * 0.6,
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Column(children: <pw.Widget>[
                        pw.Align(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(userModelObject.name,
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Align(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(userModelObject.business,
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Align(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(userModelObject.address,
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Align(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(userModelObject.phone,
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Align(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(
                                userModelObject.email == null
                                    ? "example@abc.com"
                                    : userModelObject.email,
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      ])),
                ),
                pw.Expanded(
                  child: pw.Align(
                      alignment: pw.Alignment.centerRight,
                      // height: 120.0,
                      child: pw.Container(
                          width: 90.0,
                          height: 90.0,
                          alignment: pw.Alignment.centerRight,
                          child: pw.Image(assetImage))),
                ),
              ]),
              pw.SizedBox(height: 20.0),

              pw.Row(children: <pw.Widget>[
                ///////////////////
                pw.Expanded(
                  child: pw.Container(
                      // width: width * 0.6,
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Column(children: <pw.Widget>[
                        pw.Header(
                          text: "Bill To:",
                          margin: pw.EdgeInsets.fromLTRB(0, 0, 30, 0),
                        ),
                        pw.Align(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(
                                customerName == "" ? "Name: ............." : customerName,
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Align(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(
                                customerAddress == "" ? "Address: ............." : customerAddress,
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Align(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(
                                customerPhone == "" ? "Phone: ............." : customerPhone,
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Align(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(
                                customerEmail == "" ? "Email: ............." : customerEmail,
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      ])),
                ),
                ////////////////
                pw.Expanded(
                  child: pw.Container(
                      // width: width * 0.6,
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Column(children: <pw.Widget>[
                        pw.Header(
                          text: "Invoice Terms:",
                          margin: pw.EdgeInsets.fromLTRB(30, 0, 0, 0),
                        ),
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text("Invoice #: $invoiceNumber",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text("Date: $invoiceDate",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text("Due Date: Paid",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(" Terms ..................",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      ])),
                ),
              ]),

              pw.SizedBox(height: 20.0),

              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                    "******************************************************************************",
                    textAlign: pw.TextAlign.center),
              ),
              /////////////
              pw.SizedBox(height: 10.0),
              pw.Table.fromTextArray(context: context, data: <List<String>>[
                <String>['Description', 'Quatity - Unit Price', 'Discount', 'Line Total'],
                ...invoicingList.map((item) => [
                      // item.has_variant == true ? run list of variant : item.name,
                      "${item.name}",
                      "${item.shopping_cart_product_quantity} x ${item.price}",
                      item.shopping_cart_product_discount == 0
                          ? "0"
                          : item.shopping_cart_product_discount.toString(),
                      item.shopping_cart_product_subtotal.toString()
                    ])
              ]),
              pw.SizedBox(height: 15.0),

              pw.Row(children: <pw.Widget>[
                pw.Expanded(
                  child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      // height: 120.0,
                      child: pw.Container(
                          width: 90.0,
                          height: 90.0,
                          alignment: pw.Alignment.centerLeft,
                          child: pw.Image(qrImage))),
                ),
                pw.Expanded(
                  child: pw.Container(
                      // width: width * 0.6,
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Column(children: <pw.Widget>[
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text("Subtotal: $orderSubtotal",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text("Disocunt: $orderDiscount",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text("Tax Rate: 0.00 %",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text("Total Tax: 0.00",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                              "====================",
                              textAlign: pw.TextAlign.center,
                            )),
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text("Net Total: $grandTotal",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16))),
                      ])),
                ),
              ]),

              pw.SizedBox(height: 20.0),

              pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text("Thank you for your business",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),

              pw.Footer(
                  margin: const pw.EdgeInsets.all(30),
                  title: pw.Column(children: <pw.Widget>[
                    pw.Text(
                        "------------------------------------------------------------------------------------------------------------------------"),
                    pw.Text(
                        "Powered by Focus, smartshop.services, contact: +93728333663, email: info@smartshop.services"),
                  ]))
            ];
          }),
    );
    return doc;
  }
}
