import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:pos/components/log_activity.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/product_model.dart';
import 'package:pos/localization/localization_mixins.dart';

class UpdateByNotification extends StatefulWidget {
  final int noteId;
  final String productId;
  final String noteType;

  UpdateByNotification({this.noteId, this.productId, this.noteType});

  @override
  _UpdateByNotificationState createState() => _UpdateByNotificationState();
}

class _UpdateByNotificationState extends State<UpdateByNotification> {
  final PosDatabase dbmanager = new PosDatabase();
  final LogAcitvity logActivity = new LogAcitvity();
  bool log = false;
  bool backup = false;

  Product productObject;

  String name;
  String purschase;
  String price;
  String quantity;
  String weight;
  @override
  void initState() {
    super.initState();
    _getProductObject(widget.productId);
    seenNote();
    logActivity.logActivation().then((value) {
      if (value != null) {
        log = value.log_activate;
        backup = value.backup_activation;
      }
    });
  }

  void seenNote() async {
    await dbmanager
        .getSingleNotificationByProduct(widget.productId, widget.noteType, widget.noteId)
        .then((onValue) async {
      if (onValue != null) {
        if (onValue.seen_status != true) {
          onValue.seen_status = true;
          await dbmanager.updateNote(onValue).then((onValue) {
            // print('successfully note updated');
          });
        }
      }
    });
  }

  void _getProductObject(String productId) async {
    await dbmanager.getSingleProduct(int.parse(productId)).then((object) {
      setState(() {
        productObject = object;
        name = object.name;
        purschase = object.purchase.toString();
        price = object.price.toString();
        quantity = object.quantity.toString();
        weight = object.weight.toString();
      });
    });
  }

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _weightController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();

  bool enableProduct = true;
  onSwitchedEnableProduct(bool newVal) {
    setState(() {
      enableProduct = newVal;
    });
  }

  @override
  Widget build(BuildContext context) {
    //assign some default value to check the logical error
    _nameController.text = name;
    _priceController.text = price;
    _purchasePriceController.text = purschase;
    _quantityController.text = quantity;
    _weightController.text = weight;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.blue[900],
        title: Text(getTranslated(context, "notification_edit")),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.done, color: Colors.white),
              onPressed: () {
                _submitEditProductByNotification(context);

                Navigator.pop(context);
              }),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
                  child: Container(
                    color: Colors.white,
                    child: ListTile(
                      title: Text(
                        getTranslated(context, "product_general_info"),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {},
                      subtitle: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Switch(
                                  value: enableProduct,
                                  onChanged: (newVal) {
                                    onSwitchedEnableProduct(newVal);
                                  },
                                ),
                              ),
                              Text(
                                getTranslated(context, "product_enable"),
                                style: TextStyle(color: Colors.indigo, fontSize: 15.0),
                              )
                            ],
                          ),
                          TextFormField(
                            decoration:
                                InputDecoration(labelText: getTranslated(context, "product_name")),
                            controller: _nameController,
                            validator: (String value) {
                              if (value.isEmpty) {
                                return getTranslated(context, "product_name_required");
                              }

                              return null;
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                            child: TextFormField(
                              decoration: InputDecoration(
                                  labelText: getTranslated(context, "product_purchase_price")),
                              keyboardType: TextInputType.number,
                              controller: _purchasePriceController,
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return getTranslated(context, "product_purchase_price_required");
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                            child: TextFormField(
                              decoration: InputDecoration(
                                  labelText: getTranslated(context, "product_price")),
                              keyboardType: TextInputType.number,
                              controller: _priceController,
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return getTranslated(context, "product_price_required");
                                }

                                return null;
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Divider(
                  color: Colors.blue[900],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
                  child: Container(
                    color: Colors.white,
                    child: ListTile(
                      title: Text(
                        getTranslated(context, "product_inventory"),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {},
                      subtitle: Column(
                        children: <Widget>[
                          TextFormField(
                            decoration: InputDecoration(
                                labelText: getTranslated(context, "product_quantity")),
                            keyboardType: TextInputType.number,
                            controller: _quantityController,
                            validator: (String value) {
                              if (value.isEmpty) {
                                return getTranslated(context, "product_quantity_required");
                              }

                              return null;
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                            child: TextFormField(
                              decoration: InputDecoration(
                                  labelText: getTranslated(context, "product_weight")),
                              keyboardType: TextInputType.number,
                              controller: _weightController,
                              validator: (String value) {
                                return null;
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitEditProductByNotification(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      try {
        if (log) {
          logActivity
              .recordLog(
                  "${productObject.name} ${getTranslated(context, 'note_edited_to')} ${_nameController.text}",
                  'edit_product',
                  productObject.id,
                  'Product',
                  productObject)
              .then((value) {
            saveEditProduct();
          });
        } else {
          saveEditProduct();
        }
      } catch (e) {
        _displayFlutterToastMessage(e);
      }
    } // form validation ends
    else {
      _displayFlutterToastMessage(getTranslated(context, "invalid_form"));
    }
  }

  void saveEditProduct() async {
    Product p = productObject;
    p.name = _nameController.text;
    p.price = double.parse(_priceController.text);
    p.purchase = double.parse(_purchasePriceController.text);
    p.enable_product = enableProduct;
    p.quantity = int.parse(_quantityController.text);
    p.weight = _weightController.text == "" ? 0 : double.parse(_weightController.text);

    await dbmanager.updateProduct(p).then((id) {});

    if (backup) {
      logActivity.recordBackupHistory("Product", productObject.id, 'Edit');
    }
  }

  void _displayFlutterToastMessage(String msg) {
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
