import 'package:flutter/material.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/home/placeholder.dart';
import 'package:pos/pages/product/add_product.dart';
import 'package:pos/pages/product/edit_product.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/product_model.dart';
import 'package:pos/pages/search/search_product.dart';
import 'Utility.dart';

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final PosDatabase dbmanager = new PosDatabase();

  List<Product> productList = List();
  List<Product> productListSearch = List();

  var refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setupList();
  }

  void setupList() async {
    await dbmanager.getProductList().then((product) {
      setState(() {
        productListSearch = product;
        // product.forEach((p) {
        //   productListSearch.add(p);
        // });
      });
    });
  }

  void getDataList() async {
    await dbmanager.getProductList().then((value) {
      setState(() {
        productList = value;
      });
    });
  }

  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(milliseconds: 50));

    return null;
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
        title: Text(getTranslated(context, "more_product")),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () {
                showSearch(
                        context: context,
                        delegate: SearchProduct(searchProductList: productListSearch))
                    .then((value) => getDataList());
              }),
          IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddProduct()))
                    .then((value) => getDataList());
              }),
        ],
      ),

      //List of orders
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: refreshList,
        child: Column(
          children: <Widget>[
            Expanded(
                child: FutureBuilder(
              future: dbmanager.getProductList(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  productList = snapshot.data;
                  if (productList.length == 0) {
                    return Container(
                      child: Center(child: PlaceHolderContent()),
                    );
                  }
                  return ListView.builder(
                      itemCount: productList == null ? 0 : productList.length,
                      itemBuilder: (context, index) {
                        Product p = productList[index];
                        return Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Card(
                            elevation: 5,
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditProduct(
                                              productObject: p,
                                              productList: productList,
                                              updateIndex: index,
                                            ))).then((value) => getDataList());
                              },
                              leading: _productAvatar(p.picture),
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
                                            "${p.name}",
                                            style: TextStyle(
                                                color: p.enable_product
                                                    ? Colors.blue[900]
                                                    : Colors.grey,
                                                fontSize: 18.0,
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
                                          padding: const EdgeInsets.all(3.0),
                                          child: Text(
                                            "${p.quantity} - ${getTranslated(context, "analytics_in_stock")}",
                                            style: TextStyle(
                                                color:
                                                    p.enable_product ? Colors.black : Colors.grey,
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
                                          padding: const EdgeInsets.all(3.0),
                                          child: Text(
                                            "${p.price}",
                                            style: TextStyle(
                                                color: p.enable_product ? Colors.red : Colors.grey,
                                                fontSize: 15.0),
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
              },
            )),
          ],
        ),
      ),
    );
  }
}
