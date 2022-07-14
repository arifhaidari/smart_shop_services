import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/variant_option_model.dart';
import 'package:pos/db/product_variant_option.dart';
import 'package:pos/localization/localization_mixins.dart';

class EditVariantOptions extends StatefulWidget {
  final variantId;
  final productId;

  EditVariantOptions({
    this.variantId,
    this.productId,
  });

  @override
  _EditVariantOptionsState createState() => _EditVariantOptionsState();
}

class _EditVariantOptionsState extends State<EditVariantOptions> {
  final PosDatabase dbmanager = new PosDatabase();

  List<VariantOption> variantOptionList = List();

  var priceTextEditingControllers = <TextEditingController>[];
  List optionId = List();
  final _formKey = new GlobalKey<FormState>();

  var refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    variantOptionList = [];
    optionId = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.blue[900],
        title: Text(getTranslated(context, "variant_option_selection")),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.done, color: Colors.white),
              onPressed: () {
                _submitProductVariantOption(context);
                Navigator.of(context).pop();
              }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Expanded(
                  child: FutureBuilder(
                future: dbmanager.getVariantOptionList(widget.variantId),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    variantOptionList = snapshot.data;
                    return ListView.builder(
                        itemCount: variantOptionList == null ? 0 : variantOptionList.length,
                        itemBuilder: (context, index) {
                          VariantOption vo = variantOptionList[index];

                          final _priceController = TextEditingController();
                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                                color: Colors.white,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(20.0, 3.0, 8.0, 3.0),
                                        child: Text(
                                          vo.option_name,
                                          style: TextStyle(
                                              color: Colors.black, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                              labelText: getTranslated(context, "product_price")),
                                          keyboardType: TextInputType.number,
                                          controller: _priceController,
                                          validator: (String value) {
                                            if (value != "") {
                                              priceTextEditingControllers.add(_priceController);
                                              optionId.add(vo.id);
                                            }

                                            // print("stored data");
                                            // print(_priceController.text);
                                            // print(vo.id);
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                          );
                        });
                  }
                  return Container(child: Center(child: new CircularProgressIndicator()));
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _submitProductVariantOption(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      if (widget.productId != null) {
        for (var i = 0; i <= optionId.length; i++) {
          try {
            if (priceTextEditingControllers[i].text != "") {
              ProductVariantOption cpj = new ProductVariantOption(
                product_id: widget.productId,
                variant_id: widget.variantId,
                option_id: optionId[i],
                price: double.parse(priceTextEditingControllers[i].text),
              );

              await dbmanager.insertProdcutVariantOption(cpj).then((id) => {});
            }
          } // end of try
          catch (e) {
            _showToastMessage(e.toString());
          }
        } //for loop ending

        ///Update the has_varian=true of this product

        await dbmanager.getSingleProduct(widget.productId).then((productObject) => {
              productObject.has_variant = true,
              dbmanager.updateProduct(productObject).then((id) => {}),
            });
      }
    } //form state ending
    else {
      _showToastMessage(getTranslated(context, "invalid_form"));
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
}
