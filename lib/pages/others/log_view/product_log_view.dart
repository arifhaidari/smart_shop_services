import 'package:flutter/material.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/logs/product_log.dart';
import 'package:pos/db/product_model.dart';
import 'package:pos/localization/localization_mixins.dart';

class ProductLogView extends StatefulWidget {
  final product;
  final productLog;

  ProductLogView({
    this.product,
    this.productLog,
  });

  @override
  _ProductLogViewState createState() => _ProductLogViewState();
}

class _ProductLogViewState extends State<ProductLogView> {
  final PosDatabase dbmanager = new PosDatabase();
  ProductLog productLog;
  Product product;
  //
  bool loading = false;
  //
  @override
  void initState() {
    super.initState();
    product = widget.product;
    productLog = widget.productLog;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.blue[900],
        title: Text(getTranslated(context, 'other_log_detail')),
      ),
      body: ListView(
        children: <Widget>[
          Card(
            elevation: 5,
            child: Container(
              margin: EdgeInsets.all(5),
              color: Colors.white,
              child: ListTile(
                title: Text(
                  getTranslated(context, 'other_before'),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 22, color: Colors.green[900]),
                  textAlign: TextAlign.center,
                ),
                // subtitle: Text("subs"),
              ),
            ),
          ),
          Card(
            elevation: 5,
            child: Container(
              // margin: EdgeInsets.all(20),
              color: Colors.white,
              child: ListTile(
                title: Text(
                  productLog.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green[900]),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            getTranslated(context, 'product_purchase_price'),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          ),
                          Text(
                            productLog.purchase.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            getTranslated(context, 'product_price'),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          ),
                          Text(
                            productLog.price.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            getTranslated(context, 'other_barcode'),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          ),
                          Text(
                            productLog.barcode == null ? "Not Available" : productLog.barcode,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            getTranslated(context, 'product_enable'),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          ),
                          Text(
                            productLog.enable_product
                                ? getTranslated(context, 'yes')
                                : getTranslated(context, 'no'),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            getTranslated(context, 'product_quantity'),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          ),
                          Text(
                            productLog.quantity.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            getTranslated(context, 'product_weight'),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          ),
                          Text(
                            productLog.weight.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            getTranslated(context, 'other_has_variant'),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          ),
                          Text(
                            productLog.has_variant
                                ? getTranslated(context, 'yes')
                                : getTranslated(context, 'no'),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Card(
            elevation: 5,
            child: Container(
              margin: EdgeInsets.all(5),
              color: Colors.white,
              child: ListTile(
                title: Text(
                  getTranslated(context, 'other_after'),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 22, color: Colors.green[900]),
                  textAlign: TextAlign.center,
                ),
                // subtitle: Text("subs"),
              ),
            ),
          ),
          Card(
            elevation: 5,
            child: Container(
              // margin: EdgeInsets.all(20),
              color: Colors.white,
              child: ListTile(
                title: Text(
                  product.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green[900]),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            getTranslated(context, 'product_purchase_price'),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          ),
                          Text(
                            product.purchase.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            getTranslated(context, 'product_price'),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          ),
                          Text(
                            product.price.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            getTranslated(context, 'other_barcode'),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          ),
                          Text(
                            product.barcode == null ? "Not Available" : product.barcode,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            getTranslated(context, 'product_enable'),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          ),
                          Text(
                            product.enable_product
                                ? getTranslated(context, 'yes')
                                : getTranslated(context, 'no'),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            getTranslated(context, 'product_quantity'),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          ),
                          Text(
                            product.quantity.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            getTranslated(context, 'product_weight'),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          ),
                          Text(
                            product.weight.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            getTranslated(context, 'other_has_variant'),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          ),
                          Text(
                            product.has_variant
                                ? getTranslated(context, 'yes')
                                : getTranslated(context, 'no'),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.blue[900]),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
