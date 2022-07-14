import 'package:flutter/material.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/variant_option_model.dart';
import 'package:pos/db/variant_option_price.dart';
import 'package:pos/localization/localization_mixins.dart';

class ChooseVariantOptions extends StatefulWidget {
  final variantId;

  ChooseVariantOptions({
    this.variantId,
  });

  @override
  _ChooseVariantOptionsState createState() => _ChooseVariantOptionsState();
}

class _ChooseVariantOptionsState extends State<ChooseVariantOptions> {
  final PosDatabase dbmanager = new PosDatabase();
  List<VariantOption> variantOptionList = List();

  final _formKey = new GlobalKey<FormState>();

  Map<int, VariantOptionPrice> optionPriceMap = Map();

  @override
  void initState() {
    super.initState();
  }

  var priceTextEditingControllers = <TextEditingController>[];
  List<int> idList = List();

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
                if (_formKey.currentState.validate()) {
                  Navigator.pop(context, optionPriceMap);
                }
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
                                              optionPriceMap[vo.id] = VariantOptionPrice(
                                                variant_id: widget.variantId,
                                                option_id: vo.id,
                                                option_price: double.parse(_priceController.text),
                                              );
                                            }

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
}
