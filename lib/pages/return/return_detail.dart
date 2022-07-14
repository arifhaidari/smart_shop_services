import 'package:flutter/material.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/order_model.dart';
import 'package:pos/db/product_shopping_cart_join.dart';
import 'package:pos/db/selected_product_variant.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/home/placeholder.dart';
import 'package:pos/pages/product/Utility.dart';

class ReturnDetail extends StatefulWidget {
  final orderObject;

  ReturnDetail({this.orderObject});
  @override
  _ReturnDetailState createState() => _ReturnDetailState();
}

class _ReturnDetailState extends State<ReturnDetail> {
  final PosDatabase dbmanager = new PosDatabase();

  List<ProductShoppingCartJoin> productShopingCartJoinList = List();

  OrderModel orderModelObject;

  @override
  void initState() {
    super.initState();
    setState(() {
      orderModelObject = widget.orderObject;
    });
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
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.blue[900],
        title: Text(getTranslated(context, "return_detail")),
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
                color: Colors.blue[900],
                onPressed: () {},
              ),
              floating: true,
              expandedHeight: 200.0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[900],
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
                              "${getTranslated(context, "returned")}: ${orderModelObject.order_subtotal - orderModelObject.order_discount}",
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              "${getTranslated(context, "return_charge")}: ${orderModelObject.order_discount}",
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              "${getTranslated(context, "invoice_net_total")}: ${orderModelObject.order_subtotal}",
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              "${getTranslated(context, "cart_cash_collected")}: ${orderModelObject.cash_collected}",
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              "${getTranslated(context, "cart_change_due")}: ${orderModelObject.change_due}",
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
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
                  FutureBuilder(
                      future: dbmanager.getProductShoppingCartListById(orderModelObject.cart_id),
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
                                                    orderModelObject.cart_id),
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
                                                    "${getTranslated(context, "return_charge")}: ${pscj.shopping_cart_product_discount}",
                                                    style: TextStyle(
                                                        color: Colors.black, fontSize: 15.0),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(3.0),
                                                  child: Text(
                                                    "${getTranslated(context, "invoice_net_total")}: ${pscj.shopping_cart_product_subtotal}",
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
}
