import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pos/components/log_activity.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/invoice_model.dart';
import 'package:pos/db/product_shopping_cart_invoicing.dart';
import 'package:pos/db/product_shopping_cart_join.dart';
import 'package:pos/db/selected_product_variant.dart';
import 'package:pos/db/shopping_cart_model.dart';
import 'package:pos/db/user_model.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/home/placeholder.dart';
import 'package:pos/pages/product/Utility.dart';
import 'package:random_color/random_color.dart';

//printing

import 'package:qr_flutter/qr_flutter.dart';
import 'package:printing/printing.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:pdf/pdf.dart'; ////////
import 'package:pdf/widgets.dart' as pw; //////

class InvoiceDetail extends StatefulWidget {
  final invoiceObject;

  InvoiceDetail({this.invoiceObject});
  @override
  _InvoiceDetailState createState() => _InvoiceDetailState();
}

class _InvoiceDetailState extends State<InvoiceDetail> {
  final PosDatabase dbmanager = new PosDatabase();

  List<ProductShoppingCartJoin> productShopingCartJoinList = List();

  RandomColor _randomColor = RandomColor();
  List<ProductShoppingCartInvoicing> invoicingList = List();
  InvoiceModel invoiceModel;
  final LogAcitvity logActivity = new LogAcitvity();
  bool log = false;
  bool backup = false;
  @override
  void initState() {
    super.initState();
    setState(() {
      invoiceModel = widget.invoiceObject;
    });
    createList();
    getInvoiceSideInfo();
    logActivity.logActivation().then((value) {
      if (value != null) {
        log = value.log_activate;
        backup = value.backup_activation;
      }
    });
  }

  UserModel userModelObject;
  ShoppingCartModel shoppingCartModelObject;

  void getInvoiceSideInfo() async {
    await dbmanager.getSingleUser().then((onValue) {
      if (onValue != null) {
        setState(() {
          userModelObject = onValue;
        });
      }
    });
    await dbmanager.getShoppingCartInvoicing(invoiceModel.cart_id).then((onValue) {
      setState(() {
        shoppingCartModelObject = onValue;
      });
    });
  }

  void createList() async {
    //the invoice list part
    await dbmanager.getProductShoppingCartListInvoicing(invoiceModel.cart_id).then((theValue) {
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

  Future<void> _printPdf() async {
    try {
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => (await generateDocument(format)).save());
    } catch (e) {
      _showToastMessage('Error: ${e.toString()}');
    }
  }

  Widget _productAvatar(String pic) {
    if (pic == "default_text") {
      return CircleAvatar(
        radius: 30.0,
        child: ClipOval(
          child: SizedBox(
            width: 120.0,
            height: 120.0,
            child: Image.asset("images/no_image.jpg"),
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: 30.0,
        child: ClipOval(
          child: SizedBox(
            width: 120.0,
            height: 120.0,
            child: Utility.imageFromBase64String(pic),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    Color _color = _randomColor.randomColor(colorSaturation: ColorSaturation.highSaturation);
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.blue[900],
        title: Text(getTranslated(context, "invoice_detail_title")),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () {
              _printPdf();
            },
          ),
          IconButton(
            icon: Icon(Icons.attach_money),
            onPressed: () {
              if (invoiceModel.invoice_paid_status == false) {
                _payInvoiceDialogue(context);
              } else {
                _showToastMessage(getTranslated(context, "invoice_payment_completion"));
              }
            },
          ),
        ],
      ),

      //List of orders
      body: Padding(
        padding: EdgeInsets.all(3.0),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: Icon(Icons.shop),
                // color: const Color(0xff7c94b6),
                color: Colors.blue[900],
                onPressed: () {},
              ),
              // pinned: true,
              floating: true,
              expandedHeight: 250.0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  // transform: Matrix4.rotationZ(0.05),
                  decoration: BoxDecoration(
                    color: Colors.blue[900],
                    // color: const Color(0xff7c94b6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue[900],
                      width: 8,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              "${getTranslated(context, "home_subtotal")}: ${invoiceModel.invoice_subtotal == null ? 0.0 : invoiceModel.invoice_subtotal + invoiceModel.invoice_discount}",
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              "${getTranslated(context, "cart_discount")}: ${invoiceModel.invoice_discount}",
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              "${getTranslated(context, "invoice_net_total")}: ${invoiceModel.invoice_subtotal}",
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          // Divider(
                          //   color: Colors.white,
                          // ),
                          Text(
                            "*******************************",
                            style: TextStyle(color: Colors.white),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              invoiceModel.customer_name,
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              invoiceModel.customer_address,
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              invoiceModel.customer_phone,
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              invoiceModel.customer_email,
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                <Widget>[
                  Container(
                    margin: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
                    child: Card(
                      elevation: 5.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(
                            "${getTranslated(context, "invoice")}-#: ${invoiceModel.invoice_number}",
                            style: TextStyle(
                                color: Colors.blue[900],
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold),
                          ),
                          contentPadding: EdgeInsets.all(0.0),
                          subtitle: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text(
                                        "${getTranslated(context, "invoice_paid")}: ${invoiceModel.invoice_paid_amount}",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text(
                                        "${getTranslated(context, "invoice_issue")}: ${invoiceModel.invoice_issue_date}",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold),
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
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text(
                                        "${getTranslated(context, "invoice_payable")}: ${invoiceModel.invoice_payable_amount}",
                                        style: TextStyle(
                                            color: Colors.green[900],
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text(
                                        "${getTranslated(context, "invoice_due")}: ${invoiceModel.invoice_due_date}",
                                        style: TextStyle(
                                            color: Colors.green[900],
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold),
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

                  ////////// Customer profile starts here

                  FutureBuilder(
                      future: dbmanager.getProductShoppingCartListById(invoiceModel.cart_id),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          productShopingCartJoinList = snapshot.data;

                          if (productShopingCartJoinList.length == 0) {
                            return Container(
                              child: Center(child: PlaceHolderContent()),
                            );
                          }
                          return ListView.builder(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount: productShopingCartJoinList.length,
                              itemBuilder: (context, index) {
                                ProductShoppingCartJoin pscj = productShopingCartJoinList[index];
                                return Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Card(
                                    elevation: 5,
                                    child: ListTile(
                                      leading: _productAvatar(pscj.picture),
                                      subtitle: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(3.0),
                                                  child: Text(
                                                    pscj.name,
                                                    style: TextStyle(
                                                        color: Colors.blue[900],
                                                        fontSize: 18.0,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: <Widget>[
                                              FutureBuilder(
                                                future: dbmanager.getSelectedProductVariantListById(
                                                    pscj.shopping_cart_product_id,
                                                    pscj.main_product_id,
                                                    invoiceModel.cart_id),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    List<SelectedProductVariantModel>
                                                        selectedPVMList = snapshot.data;
                                                    return ListView.builder(
                                                        shrinkWrap: true,
                                                        physics: ClampingScrollPhysics(),
                                                        itemCount: selectedPVMList == null
                                                            ? 0
                                                            : selectedPVMList.length,
                                                        itemBuilder: (context, index) {
                                                          SelectedProductVariantModel spv =
                                                              selectedPVMList[index];
                                                          return Row(
                                                            children: <Widget>[
                                                              Expanded(
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        width: 1,
                                                                        color: Colors.blue[900]),
                                                                  ),
                                                                  child: Text(
                                                                    spv.option_name,
                                                                    style: TextStyle(
                                                                      color: Colors.black,
                                                                      fontSize: 15.0,
                                                                    ),
                                                                    textAlign: TextAlign.center,
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        width: 1,
                                                                        color: Colors.blue[900]),
                                                                  ),
                                                                  child: Text(
                                                                    "${spv.price}",
                                                                    style: TextStyle(
                                                                        color: Colors.black,
                                                                        fontSize: 15.0),
                                                                    textAlign: TextAlign.center,
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  "",
                                                                  style: TextStyle(
                                                                      color: Colors.black,
                                                                      fontSize: 15.0),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        });
                                                  }
                                                  return Container(
                                                      child: Center(
                                                          child: new CircularProgressIndicator()));
                                                },
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(3.0),
                                                  child: Text(
                                                    "${getTranslated(context, "cart_quantity")}-${pscj.shopping_cart_product_quantity}",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15.0,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(3.0),
                                                  child: Text(
                                                    "${getTranslated(context, "home_subtotal")}: ${pscj.shopping_cart_product_subtotal + pscj.shopping_cart_product_discount}",
                                                    style: TextStyle(
                                                        color: Colors.black, fontSize: 15.0),
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
                                                  padding: const EdgeInsets.all(3.0),
                                                  child: Text(
                                                    "${getTranslated(context, "cart_discount")}: ${pscj.shopping_cart_product_discount}",
                                                    style: TextStyle(
                                                        color: Colors.black, fontSize: 15.0),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(3.0),
                                                  child: Text(
                                                    "${getTranslated(context, "total")}: ${pscj.shopping_cart_product_subtotal}",
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 15.0,
                                                        fontWeight: FontWeight.bold),
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
                                );
                              });
                        }
                        return Container(child: Center(child: new CircularProgressIndicator()));
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _payInvoiceDialogue(BuildContext context) async {
    final _inovoiceAmountController = TextEditingController();
    final _formKey = new GlobalKey<FormState>();
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              getTranslated(context, "invoice_pay_remaining"),
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
            ),
            elevation: 15,
            // backgroundColor: Colors.deepOrange,
            content: Form(
              key: _formKey,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: getTranslated(context, "cart_enter_amount"),
                ),
                keyboardType: TextInputType.number,
                controller: _inovoiceAmountController,
                // maxLength: 10,
                validator: (String value) {
                  if (value.isEmpty) {
                    return getTranslated(context, "cart_enter_amount_error");
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
                  _inovoiceAmountController.clear();
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
                    _payRemainingAmount(double.parse(_inovoiceAmountController.text));
                    _inovoiceAmountController.clear();
                  }
                },
              ),
            ],
          );
        });
  }

  void _payRemainingAmount(double paidAmount) async {
    Navigator.of(context).pop();
    Navigator.pop(context);

    if (invoiceModel.invoice_payable_amount <= paidAmount) {
      await dbmanager.getSingleOrder(invoiceModel.order_id).then((singleOrderObject) async {
        if (singleOrderObject != null) {
          if (log) {
            logActivity.recordLog(
                "${getTranslated(context, 'invoice')}-${invoiceModel.invoice_number} ${getTranslated(context, 'note_paid_completely')}",
                'complete_invoice',
                singleOrderObject.id,
                'Orders',
                null);
          }
        }
      });
    } else {
      if (log) {
        logActivity.recordLog(
            "$paidAmount ${getTranslated(context, 'note_paid_to')} ${getTranslated(context, 'invoice')}-${invoiceModel.invoice_number}",
            'pay_invoice',
            invoiceModel.id,
            'Invoices',
            null);
      }
    }

    paidAmount >= invoiceModel.invoice_payable_amount
        ? invoiceModel.invoice_paid_status = true
        : invoiceModel.invoice_paid_status = false;
    invoiceModel.invoice_paid_amount += paidAmount;
    invoiceModel.invoice_payable_amount <= paidAmount
        ? invoiceModel.invoice_payable_amount = 0.0
        : invoiceModel.invoice_payable_amount -= paidAmount;

    await dbmanager.updateInvoice(invoiceModel).then((theValue) {});
    if (backup) {
      logActivity.recordBackupHistory("Invoice", invoiceModel.id, 'Edit');
    }

    if (invoiceModel.invoice_payable_amount <= paidAmount) {
      await dbmanager.getSingleOrder(invoiceModel.order_id).then((singleOrderObject) async {
        if (singleOrderObject != null) {
          singleOrderObject.order_subtotal = invoiceModel.invoice_subtotal;
          singleOrderObject.change_due =
              invoiceModel.invoice_paid_amount - invoiceModel.invoice_subtotal;
          singleOrderObject.cash_collected = invoiceModel.invoice_paid_amount;
          singleOrderObject.payment_completion_status = true;

          await dbmanager.updateOrder(singleOrderObject).then((onValue) {});
        }
      });
    }
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

  Future<pw.Document> generateDocument(PdfPageFormat theFormant) async {
    String rawPic;
    PdfImage assetImage;
    await dbmanager.getSingleUser().then((onValue) {
      if (onValue != null) {
        setState(() {
          rawPic = onValue.logo;
        });
      }
    });
    //
    Uint8List finalImage;
    try {
      final image = await QrPainter(
        data: invoiceModel.qr_code_string, // the issue is here in qr_code_stirng
        version: QrVersions.auto,
        gapless: true,
      ).toImage(300);
      final a = await image.toByteData(format: ImageByteFormat.png);

      finalImage = a.buffer.asUint8List();
    } catch (e) {
      _showToastMessage(e.toString());
      throw e;
    }
    final pw.Document doc = pw.Document();

    final PdfImage qrImage = await pdfImageFromImageProvider(
      pdf: doc.document,
      image: MemoryImage(finalImage),
      // image: const AssetImage('images/bat.jpg'),
    );

    // if (rawPic == null) {
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
          margin: pw.EdgeInsets.fromLTRB(40, 70, 25, 40),
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
                            child: pw.Text(invoiceModel.customer_name,
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Align(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(invoiceModel.customer_address,
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Align(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(invoiceModel.customer_phone,
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Align(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(invoiceModel.customer_email,
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
                            child: pw.Text("Invoice #: ${invoiceModel.invoice_number}",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text("Issue Date: ${invoiceModel.invoice_issue_date}",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text("Due Date: ${invoiceModel.invoice_due_date}",
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
                ...invoicingList.map(
                  (item) => [
                    "${item.name}",
                    "${item.shopping_cart_product_quantity} x ${item.price}",
                    item.shopping_cart_product_discount == 0
                        ? "0"
                        : item.shopping_cart_product_discount.toString(),
                    item.shopping_cart_product_subtotal.toString(),
                  ],
                )
              ]),
              pw.SizedBox(height: 15.0),

              pw.Row(children: <pw.Widget>[
                pw.Expanded(
                  child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      // height: 120.0,
                      child: pw.Container(
                          width: 110.0,
                          height: 110.0,
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
                            child: pw.Text(
                                "Subtotal: ${shoppingCartModelObject.subtotal == null ? 0.0 : shoppingCartModelObject.subtotal + (shoppingCartModelObject.total_discount)}",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text("Disocunt: ${shoppingCartModelObject.total_discount}",
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
                              "=============================",
                              textAlign: pw.TextAlign.center,
                            )),
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                                "Net Total: ${shoppingCartModelObject.subtotal == null ? 0.0 : shoppingCartModelObject.subtotal}",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16))),
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text("Paid Amount: ${invoiceModel.invoice_paid_amount}",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16))),
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                                "Payable Amout: ${shoppingCartModelObject.subtotal == null ? 0.0 : shoppingCartModelObject.subtotal - invoiceModel.invoice_paid_amount}",
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
