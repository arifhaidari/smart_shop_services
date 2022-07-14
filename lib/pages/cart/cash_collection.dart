import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos/components/log_activity.dart';
import 'package:pos/components/mixins.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/invoice_model.dart';
import 'package:pos/db/order_model.dart';
import 'package:pos/db/product_model.dart';
import 'package:pos/db/product_shopping_cart_invoicing.dart';
import 'package:pos/db/session_model.dart';
import 'package:pos/db/shopping_product_model.dart';
import 'package:pos/db/user_model.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/cart/order_placed.dart';
import 'package:pos/pages/home/home_page.dart';
import 'package:pos/pages/product/Utility.dart';
//imports for invoicing
import 'package:qr_flutter/qr_flutter.dart';
import 'package:printing/printing.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:pdf/pdf.dart'; ////////
import 'package:pdf/widgets.dart' as pw; //////
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CashCollection extends StatefulWidget {
  final cartId;
  final operationType;

  CashCollection({this.cartId, this.operationType});
  @override
  _CashCollectionState createState() => _CashCollectionState();
}

class _CashCollectionState extends State<CashCollection> {
  final PosDatabase dbmanager = new PosDatabase();

  final _amountController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  bool returnOrderBool = false;

  double _changeDueAmount = 0;
  double _cashCollected = 0;

  int cartItemNo;
  double cartSubtotal;
  double cartPurchaseTotal;
  double cartTotalDiscount;
  int currentSessionId;

  //pay later
  List<ProductShoppingCartInvoicing> invoicingList = List();

  PrintingInfo printingInfo;

  final GlobalKey<State<StatefulWidget>> shareWidget = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _renderObjectKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> pickWidget = GlobalKey();
  final GlobalKey<State<StatefulWidget>> previewContainer = GlobalKey();

  List<ShoppingCartProductModel> shoppingCartProductModelList = List();
  final LogAcitvity logActivity = new LogAcitvity();
  bool log = false;

  //for invoicing
  String customerName;
  String customerAddress;
  String customerPhone;
  String customerEmail;
  String invoiceIssueDate;
  String invoiceDueDate;
  String qrcodeString;
  String invoiceNumber;
  double paidAmount = 0;
  String dueDateInvoice;
  final dueDateTemp = DateFormat("yyyy-MM-dd");

  @override
  void initState() {
    Printing.info().then((PrintingInfo info) {
      setState(() {
        printingInfo = info;
      });
    });
    super.initState();
    createList();
    _qrInvoiceGenerator();
    getUserInfo();
    _checkSessionStatus();
    _updateCartItemNoSubtotal();
    logActivity.logActivation().then((value) {
      if (value != null) {
        log = value.log_activate;
      }
    });
  }

  UserModel userModelObject;

  void getUserInfo() async {
    await dbmanager.getSingleUser().then((onValue) {
      if (onValue != null) {
        setState(() {
          userModelObject = onValue;
        });
      }
    });
  }

  void _qrInvoiceGenerator() async {
    Random rnd = Random();
    int min = 111111;
    int max = 999999;
    int r = min + rnd.nextInt(max - min);
    String nowTimeObject = DateTime.now().toString();

    String yearNowTime = nowTimeObject.substring(0, 4);
    String yearNowTimeTow = nowTimeObject.substring(0, 2);
    String monthNowTime = nowTimeObject.substring(5, 7);
    String dayNowTime = nowTimeObject.substring(8, 10);

    setState(() {
      invoiceIssueDate = nowTimeObject.substring(0, 10);
    });

    setState(() {
      invoiceNumber = yearNowTime + monthNowTime + dayNowTime + widget.cartId.toString();
    });

    setState(() {
      qrcodeString = yearNowTimeTow + monthNowTime + dayNowTime + r.toString();
    });

    await dbmanager.getSingleOrderByQr(qrcodeString).then((onValue) {
      if (onValue != null) {
        _qrInvoiceGenerator();
      }
    });
  }

  void _updateCartItemNoSubtotal() async {
    await dbmanager.getShoppingCartItemNo(widget.cartId).then((quantityNum) => {
          setState(() {
            if (quantityNum == null) {
              cartItemNo = 0;
            } else {
              cartItemNo = quantityNum;
            }
          }),
        });

    await dbmanager.getShoppingCartGrandTotal(widget.cartId).then((allProductSubtotal) => {
          setState(() {
            if (allProductSubtotal == null) {
              cartSubtotal = 0;
            } else {
              cartSubtotal = allProductSubtotal.toDouble();
            }
          }),
        });

    await dbmanager
        .getShoppingCartPurchaseTotal(widget.cartId)
        .then((allProductPurchaseSubtotal) => {
              setState(() {
                if (allProductPurchaseSubtotal == null) {
                  cartPurchaseTotal = 0;
                } else {
                  cartPurchaseTotal = allProductPurchaseSubtotal.toDouble();
                }
              }),
            });

    await dbmanager.getShoppingCartTotalDiscount(widget.cartId).then((allDiscounts) => {
          setState(() {
            if (allDiscounts == null) {
              cartTotalDiscount = 0;
            } else {
              cartTotalDiscount = allDiscounts.toDouble();
            }
          }),
        });
  }

  void _checkSessionStatus() async {
    await dbmanager.getCurrentSession().then((sessionExist) {
      if (sessionExist == null) {
        _createNewSessionDialogue(context);
      } else {
        _checkSessionDate(context, sessionExist);
      }
    });
  }

  void createList() async {
    await dbmanager.getShoppingCartById(widget.cartId).then((value) {
      if (value != null) {
        returnOrderBool = value.return_order;
      }
    });
    //the invoice list part
    await dbmanager.getProductShoppingCartListInvoicing(widget.cartId).then((theValue) {
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

  _checkSessionDate(BuildContext context, SessionModel sessionModelObject) async {
    String nowTimeObject = DateTime.now().toString();

    //nowTimeObject
    int yearNowTime = int.parse(nowTimeObject.substring(0, 4));
    int monthNowTime = int.parse(nowTimeObject.substring(5, 7));
    int dayNowTime = int.parse(nowTimeObject.substring(8, 10));

    //nowTimeObject
    int yearSessionTime = int.parse(sessionModelObject.opening_time.substring(0, 4));
    int monthSessionTime = int.parse(sessionModelObject.opening_time.substring(5, 7));
    int daySessionTime = int.parse(sessionModelObject.opening_time.substring(8, 10));

    if (sessionModelObject.opening_time.substring(0, 10) == nowTimeObject.substring(0, 10)) {
      currentSessionId = sessionModelObject.id;
    } else {
      if (sessionModelObject.opening_time.substring(0, 7) == nowTimeObject.substring(0, 7) &&
          dayNowTime > daySessionTime) {
        sessionEnder(sessionModelObject);
      } else if (yearSessionTime == yearNowTime && monthNowTime > monthSessionTime) {
        sessionEnder(sessionModelObject);
      } else if (yearNowTime > yearSessionTime) {
        sessionEnder(sessionModelObject);
      } else {
        _sessionErrorDialogue(context);
      }
    }
  }

  Future<void> _createNewSessionDialogue(BuildContext context) async {
    final _openingAmountController = TextEditingController();
    final _formKey = new GlobalKey<FormState>();
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              getTranslated(context, "cart_existing_cash"),
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
                controller: _openingAmountController,
                // maxLength: 10,
                validator: (String value) {
                  if (value.isEmpty) {
                    return getTranslated(context, "cart_amount_required");
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
                  //Navigate to home page
                  _openingAmountController.clear();
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
                    _createNewSessionObject(context, double.parse(_openingAmountController.text));
                  }
                },
              ),
            ],
          );
        });
  }

  void _createNewSessionObject(BuildContext context, double amount) async {
    SessionModel s = new SessionModel(
      opening_balance: amount,
      opening_time: DateTime.now().toString(),
      closing_time: null,
      session_comment: null,
      close_status: false,
      drawer_status: false,
    );
    dbmanager.createSession(s).then((id) => {
          currentSessionId = id,
          Navigator.of(context).pop(),
        });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.blue[900],
        title: Text(getTranslated(context, "cart_cash_collection")),
      ),

      //=========== Cash Collection body =============
      body: ListView(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  height: 125.0,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      color: Colors.blue[900],
                      child: Card(
                        child: Container(
                          color: Colors.blue[900],
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
                                            getTranslated(context, "cart_payable_cash"),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 30.0,
                                                fontWeight: FontWeight.bold),
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
                                            "$cartSubtotal (${getTranslated(context, "cart_grand_total")})",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 22.0,
                                                fontWeight: FontWeight.bold),
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
                  height: 180.0,
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
                                            getTranslated(context, "cart_cash_collection"),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold),
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
                                          child: Form(
                                            key: _formKey,
                                            child: TextFormField(
                                              decoration: InputDecoration(
                                                  labelText:
                                                      getTranslated(context, "cart_enter_amount")),
                                              keyboardType: TextInputType.number,
                                              controller: _amountController,
                                              // maxLength: 10,
                                              validator: (String value) {
                                                if (value.isEmpty) {
                                                  return getTranslated(
                                                      context, "cart_enter_amount_error");
                                                }

                                                return null;
                                              },
                                              onSaved: (String value) {
                                                _changeDueAmount = double.parse(value);
                                              },
                                              onChanged: (String str) {
                                                setState(() {
                                                  if (str == "") {
                                                    _changeDueAmount = 0;
                                                    _cashCollected = 0;
                                                  } else {
                                                    _changeDueAmount =
                                                        double.parse(str) - cartSubtotal;
                                                    _cashCollected = double.parse(str);
                                                  }
                                                });
                                              },
                                            ),
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
                                            "${getTranslated(context, "cart_change_due")}: $_changeDueAmount ",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold),
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
                                  if (_cashCollected >= cartSubtotal) {
                                    returnOrder();
                                  } else {
                                    _showToastMessage(
                                        getTranslated(context, "cart_entered_amount"));
                                  }
                                },
                                icon: FittedBox(
                                  child: Icon(
                                    Icons.assignment_return,
                                    color: Colors.white,
                                  ),
                                ),
                                label: FittedBox(
                                  child: Text(
                                    getTranslated(context, "return"),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ))),
                      ),
                      if (!returnOrderBool)
                        Expanded(
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                              child: FlatButton.icon(
                                  color: Colors.blue[900],
                                  onPressed: () {
                                    if (_cashCollected >= cartSubtotal) {
                                      _submitOrder(context);
                                    } else {
                                      _showToastMessage(
                                          getTranslated(context, "cart_entered_amount"));
                                    }
                                  },
                                  icon: FittedBox(
                                    child: Icon(
                                      Icons.done,
                                      color: Colors.white,
                                    ),
                                  ),
                                  label: FittedBox(
                                    child: Text(
                                      getTranslated(context, "cart_done"),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
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

      bottomNavigationBar: !returnOrderBool
          ? Container(
              height: 70,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0, bottom: 15.0),
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.blue, width: 1, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(15)),
                  color: Colors.blue[900],
                  splashColor: Colors.pink[700],
                  onPressed: () {
                    _invoiceDialogue(context, "print");
                  },
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Text(
                        getTranslated(context, "cart_pay_invoice"),
                        style: TextStyle(color: Colors.white, fontSize: 20.0),
                        textAlign: TextAlign.center,
                      )),
                      Icon(
                        Icons.print,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  void returnOrder() async {
    if (_formKey.currentState.validate()) {
      OrderModel mo = new OrderModel(
        order_subtotal: -cartSubtotal,
        order_purchase_price_total: -cartPurchaseTotal,
        order_discount: cartTotalDiscount,
        cash_collected: _cashCollected,
        change_due: _changeDueAmount,
        order_item_no: cartItemNo,
        timestamp: DateTime.now().toString(),
        qr_code_string: qrcodeString,
        payment_completion_status: _cashCollected >= cartSubtotal ? true : false,
        cart_id: widget.cartId,
        session_id: currentSessionId,
      );
      await dbmanager.makeOrder(mo).then((id) {
        if (log) {
          logActivity.recordLog(
              "${getTranslated(context, 'cart_return')}-#$id ${getTranslated(context, 'cart_added_orders')}",
              'return',
              id,
              "Orders",
              null);
        }
        if (widget.operationType == "order") {
          _updateCart(context);
        } else {
          _updateCartHold(context);
        }
        _showToastMessage(getTranslated(context, "cart_return_success"));
        _amountController.clear();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OrderPlaced(
                      orderId: id,
                      operationType: "return",
                    )));
      });
    }
  }

  Future<void> _invoiceDialogue(BuildContext context, String invoiceType) async {
    final _nameController = TextEditingController();
    final _paidAmountController = TextEditingController();
    final _addressController = TextEditingController();
    final _phoneController = TextEditingController();
    final _emailController = TextEditingController();
    final _dueDateController = TextEditingController();
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
                        controller: _nameController,
                        maxLength: 50,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return getTranslated(context, "cart_company_name_error");
                          }
                          return null;
                        },
                      ),
                      DateTimeField(
                        controller: _dueDateController,
                        decoration: InputDecoration(
                          hintText: getTranslated(context, "cart_invoice_due_date"),
                        ),
                        validator: (DateTime value) {
                          if (value == null) {
                            return getTranslated(context, "cart_invoice_due_date_error");
                          }
                          return null;
                        },
                        format: dueDateTemp,
                        onShowPicker: (context, currentValue) {
                          return showDatePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              initialDate: currentValue ?? DateTime.now(),
                              lastDate: DateTime(2030));
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: getTranslated(context, "cart_invoice_paid_amount"),
                        ),
                        keyboardType: TextInputType.number,
                        controller: _paidAmountController,
                        maxLength: 30,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: getTranslated(context, "cart_invoice_address"),
                        ),
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
                  _dueDateController.clear();
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
                    dueDateInvoice =
                        _dueDateController.text == "" ? "due_date_empty" : _dueDateController.text;
                    paidAmount = _paidAmountController.text == ""
                        ? 0.0
                        : double.parse(_paidAmountController.text);
                  });

                  String nowTimeObject = DateTime.now().toIso8601String();

                  String yearNowTime = nowTimeObject.substring(0, 4);
                  String monthNowTime = nowTimeObject.substring(5, 7);
                  String dayNowTime = nowTimeObject.substring(8, 10);

                  //date time pikcer values
                  int yearPickerTime;
                  int monthPickerTime;
                  int dayPickerTime;

                  if (dueDateInvoice != "due_date_empty") {
                    //date time pikcer values
                    yearPickerTime = int.parse(dueDateInvoice.substring(0, 4));
                    monthPickerTime = int.parse(dueDateInvoice.substring(5, 7));
                    dayPickerTime = int.parse(dueDateInvoice.substring(8, 10));
                  }

                  /////////////// Navigation to pages part//////////
                  if (dueDateInvoice != "due_date_empty") {
                    if (int.parse(yearNowTime) >= yearPickerTime &&
                        int.parse(monthNowTime) >= monthPickerTime &&
                        int.parse(dayNowTime) >= dayPickerTime) {
                      _showToastMessage(getTranslated(context, "cart_valid_date"));
                    } else if (paidAmount >= cartSubtotal) {
                      _showToastMessage(getTranslated(context, "cart_regular_checkout"));
                    } else {
                      if (_formKey.currentState.validate() && printingInfo?.canPrint == true) {
                        if (invoiceType == "print") {
                          _printPdf();
                        } else {
                          _saveInvoice();
                        }
                      }
                    }
                  } else {
                    _showToastMessage("Select a valid date");
                  }

                  //we can pass arguments through pop() constructor
                },
              ),
            ],
          );
        });
  }

  Future<void> _printPdf() async {
    Navigator.of(context).pop();
    _saveInvoice();
    try {
      final bool result = await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => (await generateDocument(format)).save());
    } catch (e) {
      final ScaffoldState scaffold = Scaffold.of(shareWidget.currentContext);
      scaffold.showSnackBar(SnackBar(
        content: Text('${getTranslated(context, "cart_invoice_error")}: ${e.toString()}'),
      ));
    }
  }

  void _saveInvoice() async {
    int orderId;
    //
    OrderModel mo = new OrderModel(
      order_subtotal: paidAmount > cartSubtotal ? cartSubtotal : paidAmount,
      order_discount: cartTotalDiscount,
      order_purchase_price_total: cartPurchaseTotal,
      cash_collected: paidAmount,
      change_due: paidAmount <= cartSubtotal ? 0 : paidAmount - cartSubtotal,
      order_item_no: cartItemNo,
      timestamp: DateTime.now().toString(),
      qr_code_string: qrcodeString,
      payment_completion_status: paidAmount >= cartSubtotal ? true : false,
      cart_id: widget.cartId,
      session_id: currentSessionId,
    );
    await dbmanager.makeOrder(mo).then((id) async {
      setState(() {
        orderId = id;
      });
      _getProductShoppingCartList();
      if (widget.operationType == "order") {
        _updateCart(context);
      } else {
        _updateCartHold(context);
      }
    });

    InvoiceModel invoiceModelObject = InvoiceModel(
      invoice_subtotal: cartSubtotal,
      invoice_discount: cartTotalDiscount,
      invoice_paid_amount: paidAmount,
      invoice_payable_amount: cartSubtotal - paidAmount,
      invoice_item_no: cartItemNo,
      customer_name: customerName == "" ? "Name: ............." : customerName,
      customer_address: customerAddress == "" ? "Address: ............." : customerAddress,
      customer_phone: customerPhone == "" ? "Phone: ............." : customerPhone,
      customer_email: customerEmail == "" ? "Email: ............." : customerEmail,
      qr_code_string: qrcodeString,
      invoice_number: invoiceNumber,
      invoice_issue_date: invoiceIssueDate,
      invoice_due_date: dueDateInvoice,
      invoice_paid_status: paidAmount < cartSubtotal ? false : true,
      cart_id: widget.cartId,
      session_id: currentSessionId,
      order_id: orderId,
    );
    await dbmanager.insertInvoice(invoiceModelObject).then((id) {});
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(
                  categoryId: "all_categories",
                  sentIndex: 0,
                )));
  }

  //////////////// UPDATE THE PRODUCT QUANTITY  STARTS //////////////

  void _getProductShoppingCartList() async {
    await dbmanager.getShoppingCartProductListByCartId(widget.cartId).then((product) {
      if (product != null) {
        setState(() {
          shoppingCartProductModelList = product;
        });
      }
    });
    _updateProductQuantity();
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

  //////////////// UPDATE THE PRODUCT QUANTITY  STARTS //////////////

  Future<pw.Document> generateDocument(PdfPageFormat theFormant) async {
    String rawPic;
    PdfImage assetImage;
    await dbmanager.getSingleUser().then((onValue) {
      setState(() {
        rawPic = onValue.logo;
      });
    });
    Uint8List finalImage;
    try {
      final image = await QrPainter(
        data: qrcodeString,
        version: QrVersions.auto,
        gapless: true,
      ).toImage(300);
      final a = await image.toByteData(format: ImageByteFormat.png);
      // return a.buffer.asUint8List();
      finalImage = a.buffer.asUint8List();
    } catch (e) {
      throw e;
    }

    final pw.Document doc = pw.Document();

    // Uint8List finalImage;
    final PdfImage qrImage = await pdfImageFromImageProvider(
      pdf: doc.document,
      image: MemoryImage(finalImage),
      // image: const AssetImage('images/bat.jpg'),
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
                            child: pw.Text("Issue Date: $invoiceIssueDate",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text("Due Date: $dueDateInvoice",
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
                            child: pw.Text("Subtotal: ${cartSubtotal + cartTotalDiscount}",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text("Disocunt: $cartTotalDiscount",
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
                            child: pw.Text("Net Total: $cartSubtotal",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16))),
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text("Paid Amount: $paidAmount",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16))),
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text("Payable Amout: ${cartSubtotal - paidAmount}",
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

  void _submitOrder(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      OrderModel mo = new OrderModel(
        order_subtotal: cartSubtotal,
        order_purchase_price_total: cartPurchaseTotal,
        order_discount: cartTotalDiscount,
        cash_collected: _cashCollected,
        change_due: _changeDueAmount,
        order_item_no: cartItemNo,
        timestamp: DateTime.now().toString(),
        qr_code_string: qrcodeString,
        payment_completion_status: _cashCollected >= cartSubtotal ? true : false,
        cart_id: widget.cartId,
        session_id: currentSessionId,
      );
      await dbmanager.makeOrder(mo).then((id) {
        if (widget.operationType == "order") {
          _updateCart(context);
        } else {
          _updateCartHold(context);
        }
        _amountController.clear();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OrderPlaced(
                      orderId: id,
                      operationType: "order",
                    )));
      });
    }
  }

  //set the cart unusable that we cannot add product to them
  void _updateCart(BuildContext context) async {
    await dbmanager.getShoppingCartById(widget.cartId).then((cartByidExist) {
      cartByidExist.subtotal = cartSubtotal;
      cartByidExist.cart_purchase_price_total = cartPurchaseTotal;
      cartByidExist.total_discount = cartTotalDiscount;
      cartByidExist.cart_item_quantity = cartItemNo;
      cartByidExist.checked_out = true;
      cartByidExist.on_hold = false;
      dbmanager.updateShoppingCart(cartByidExist).then((id) {});
      //the by cartByidExist object update the shopping cart and put on_hold = true
    });
  }

  void _updateCartHold(BuildContext context) async {
    await dbmanager.getShoppingCartHoldById(widget.cartId).then((cartByidExist) {
      cartByidExist.subtotal = cartSubtotal;
      cartByidExist.cart_purchase_price_total = cartPurchaseTotal;
      cartByidExist.total_discount = cartTotalDiscount;
      cartByidExist.cart_item_quantity = cartItemNo;
      cartByidExist.checked_out = true;
      cartByidExist.on_hold = false;
      dbmanager.updateShoppingCart(cartByidExist).then((id) {
        _amountController.clear();
      });
      //the by cartByidExist object update the shopping cart and put on_hold = true
    });
  }

  Future<void> _sessionErrorDialogue(BuildContext context) async {
    // double width = MediaQuery.of(context).size.width;
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              getTranslated(context, "cart_session_time_error"),
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            elevation: 15,
            content: Text(
              getTranslated(context, "cart_session_error_content"),
              style: TextStyle(color: Colors.green[900], fontSize: 14, fontWeight: FontWeight.bold),
            ),
            actions: <Widget>[
              MaterialButton(
                color: Colors.blue[800],
                elevation: 3,
                child: Text(
                  getTranslated(context, "okay"),
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  putOnHoldSessionError();
                },
              ),
            ],
          );
        });
  }

  void putOnHoldSessionError() async {
    await dbmanager.getShoppingCartById(widget.cartId).then((cartByidExist) {
      cartByidExist.subtotal = cartSubtotal;
      cartByidExist.cart_purchase_price_total = cartPurchaseTotal;
      cartByidExist.total_discount = cartTotalDiscount;
      cartByidExist.cart_item_quantity = cartItemNo;
      cartByidExist.on_hold = true;
      dbmanager.updateShoppingCart(cartByidExist).then((id) {
        _amountController.clear();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      categoryId: "all_categories",
                      sentIndex: 0,
                    )));
      });
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
