import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pos/components/log_activity.dart';
import 'package:pos/components/mixins.dart';
import 'package:pos/db/barcode_model.dart';
import 'package:pos/db/category_product_model.dart';
import 'package:pos/db/product_variant_option.dart';
import 'package:pos/db/variant_model.dart';
import 'package:pos/db/variant_option_price.dart';
import 'package:pos/db/variant_product_model.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/categories/choose_category.dart';
import 'package:pos/pages/variant/choose_variant.dart';
import 'Utility.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/category_model.dart';
import 'package:pos/db/product_model.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final PosDatabase dbmanager = new PosDatabase();
  final LogAcitvity logActivity = new LogAcitvity();
  bool log = false;

  File imageFile;

  bool _inProcess = false;
  String imgString = "default_text";
  String currentLanguage = "en";

  @override
  void initState() {
    super.initState();
    _defaultBarcodeGenerator();
    getOrCreateLanguage();
    logActivity.logActivation().then((value) {
      if (value != null) {
        log = value.log_activate;
      }
    });
  }

  void getOrCreateLanguage() async {
    await dbmanager.getLanguageList().then((value) async {
      if (value.length > 0) {
        await dbmanager.getActiveLanguage().then((value) {
          setState(() {
            currentLanguage = value.language_code;
          });
        });
      } else {
        createLanguages();
      }
    });
  }

  String result = "";
  String randomGeneratedBarcode;
  void _defaultBarcodeGenerator() async {
    Random rnd = Random();
    int min = 111111111;
    int max = 999999999;
    int r = min + rnd.nextInt(max - min);
    String barcodeTemp = 351.toString() + r.toString();

    await dbmanager.getProductBarcode(barcodeTemp).then((value) {
      if (value == null) {
        setState(() {
          result = barcodeTemp;
          randomGeneratedBarcode = barcodeTemp;
        });
      } else {
        _showToastMessage(getTranslated(context, "other_barcode_exist"));
      }
    });
  }

  Future _scanQR() async {
    try {
      var qrResult = await BarcodeScanner.scan();

      await dbmanager.getProductBarcode(qrResult.rawContent.toString()).then((value) {
        if (value == null) {
          setState(() {
            result = qrResult.rawContent.toString();
          });
        } else {
          _showToastMessage(getTranslated(context, "other_barcode_exist"));
        }
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          _showToastMessage(getTranslated(context, "home_camera_denied"));
        });
      } else {
        setState(() {
          _showToastMessage("${getTranslated(context, "home_unknown_error")} $ex");
        });
      }
    } on FormatException {
      setState(() {
        _showToastMessage(getTranslated(context, "home_press_back_button"));
      });
    } catch (ex) {
      setState(() {
        _showToastMessage("${getTranslated(context, "home_unknown_error")} $ex");
      });
    }
  }

  getImage(ImageSource source) async {
    this.setState(() {
      _inProcess = true;
    });
    File image = await ImagePicker.pickImage(source: source);
    if (image != null) {
      File cropped = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 100,
          maxWidth: 80,
          maxHeight: 80,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.blue[800],
            toolbarTitle: "Smart Shop Cropper",
            statusBarColor: Colors.deepOrange.shade900,
            backgroundColor: Colors.white,
          ));

      this.setState(() {
        imageFile = cropped;
        imgString = Utility.base64String(cropped.readAsBytesSync());
        _inProcess = false;
      });
    } else {
      this.setState(() {
        _inProcess = false;
      });
    }
    Navigator.of(context).pop();
  }

  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(getTranslated(context, "product_media")),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Divider(
                      height: 10.0,
                      color: Colors.blue[900],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: Text(getTranslated(context, "product_gallery")),
                        onTap: () {
                          getImage(ImageSource.gallery);
                        },
                      ),
                    ),
                    Divider(
                      height: 10.0,
                      color: Colors.blue[900],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: Text(getTranslated(context, "product_camera")),
                        onTap: () {
                          getImage(ImageSource.camera);
                        },
                      ),
                    ),
                    Divider(
                      height: 10.0,
                      color: Colors.blue[900],
                    ),
                  ],
                ),
              ));
        });
  }

  Widget getImageWidget() {
    if (imageFile != null) {
      return Image.file(
        imageFile, //_selectedFile,
        width: 300,
        height: 300,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        "images/invoice_logo.png",
        fit: BoxFit.cover,
      );
    }
  }

  final _nameController = TextEditingController();
  final _aliasController = TextEditingController();
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

  ///////////////////////

  List<Category> categorySelectedList = List();

  List<Variant> variantSelectedList = List();
  Map<String, dynamic> finalMap = Map();
//
  Map<int, Variant> selectedVariantsMap = Map(); // Done
  Map<int, List<VariantOptionPrice>> variantOptionMap = Map(); //Done

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.blue[900],
        title: Text(getTranslated(context, "product_add")),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.done, color: Colors.white),
              onPressed: () {
                _submitProduct(context);
              }),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Card(
                  elevation: 5,
                  child: Container(
                    margin: EdgeInsets.all(5),
                    color: Colors.white,
                    child: ListTile(
                      title: Text(
                        getTranslated(context, "product_image"),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {},
                      subtitle: Column(
                        children: <Widget>[
                          Container(
                            height: 120.0,
                            width: 150.0,
                            child: FlatButton(
                              onPressed: () {
                                _showChoiceDialog(context);
                              },
                              child: getImageWidget(),
                            ),
                          ),
                          Text(
                            getTranslated(context, "product_tap_camera"),
                          )
                        ],
                      ),
                      // subtitle: Text("subs"),
                    ),
                  ),
                ),
                Card(
                  elevation: 5,
                  child: Container(
                    margin: EdgeInsets.all(5),
                    color: Colors.white,
                    child: ListTile(
                        title: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                getTranslated(context, "other_barcode"),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                                child: Align(
                              alignment: Alignment.centerRight,
                              child: Align(
                                alignment: Alignment.center,
                                child: IconButton(
                                  icon: Icon(Icons.refresh),
                                  onPressed: () {
                                    _defaultBarcodeGenerator();
                                  },
                                ),
                              ),
                            )),
                            Expanded(
                                child: Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: Icon(FontAwesomeIcons.barcode),
                                onPressed: () {
                                  _scanQR();
                                },
                              ),
                            ))
                          ],
                        ),
                        onTap: () {},
                        subtitle: Column(
                          children: <Widget>[
                            Text(
                              result,
                              style: TextStyle(fontSize: 18.0),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )),
                  ),
                ),
                Card(
                  elevation: 5,
                  child: Container(
                    margin: EdgeInsets.all(5),
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
                                enableProduct
                                    ? getTranslated(context, "product_disable")
                                    : getTranslated(context, "product_enable"),
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
                          //Alias Name
                          if (currentLanguage != 'en')
                            TextFormField(
                              decoration: InputDecoration(
                                  labelText: getTranslated(context, 'product_english_name')),
                              controller: _aliasController,
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return getTranslated(context, 'product_english_name_required');
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
                Card(
                  elevation: 5,
                  child: Container(
                    margin: EdgeInsets.all(5),
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Card(
                  elevation: 5,
                  child: Container(
                    margin: EdgeInsets.all(3),
                    color: Colors.white,
                    child: ListTile(
                      title: Text(getTranslated(context, "category"),
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Builder(builder: (context) {
                            if (categorySelectedList.length == 0) {
                              return Text(getTranslated(context, "product_no_category"));
                            }
                            return ListView.builder(
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                itemCount:
                                    categorySelectedList == null ? 0 : categorySelectedList.length,
                                itemBuilder: (context, index) {
                                  Category ct = categorySelectedList[index];
                                  return Text(
                                    ct.name,
                                  );
                                });
                          })
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChooseCategory(
                                      categoryObjectList: categorySelectedList,
                                    ))).then((onValue) {
                          if (onValue != null) {
                            setState(() {
                              categorySelectedList = [];
                              Map<int, Category> mapList = Map();
                              mapList = onValue;
                              for (var key in mapList.keys) {
                                categorySelectedList.add(mapList[key]);
                              }
                            });
                          }
                        });
                      },
                    ),
                  ),
                ),
                Card(
                  elevation: 5,
                  child: Container(
                    margin: EdgeInsets.all(3),
                    color: Colors.white,
                    child: ListTile(
                      title: Text(getTranslated(context, "variant"),
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Builder(builder: (context) {
                            if (variantSelectedList.length == 0) {
                              return Text(getTranslated(context, "product_no_variant"));
                            }
                            return ListView.builder(
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                itemCount:
                                    variantSelectedList == null ? 0 : variantSelectedList.length,
                                itemBuilder: (context, index) {
                                  Variant ct = variantSelectedList[index];
                                  return Text(
                                    ct.name,
                                  );
                                });
                          })
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          if (selectedVariantsMap != null && variantOptionMap != null) {
                            finalMap['variant_list'] = selectedVariantsMap;
                            finalMap['option_list'] = variantOptionMap;
                          }
                        });
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChooseVariant(
                                      objectMap: finalMap == null ? null : finalMap,
                                    ))).then((onValue) {
                          if (onValue != null) {
                            variantSelectedList = [];

                            setState(() {
                              finalMap = onValue;
                            });
                            int counter = 1;
                            for (var key in finalMap.keys) {
                              if (counter == 1) {
                                //variant_list
                                selectedVariantsMap = finalMap[key];
                                counter++;
                              } else {
                                //option_list
                                variantOptionMap = finalMap[key];
                              }
                            }

                            setState(() {
                              for (var key in selectedVariantsMap.keys) {
                                variantSelectedList.add(selectedVariantsMap[key]);
                              }
                            });
                          } else {}
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _submitProduct(BuildContext context) async {
    if (_formKey.currentState.validate() &&
        double.parse(_purchasePriceController.text) <= double.parse(_priceController.text)) {
      try {
        Product p = new Product(
          name: _nameController.text,
          alias: currentLanguage != "en" ? _aliasController.text : "no_alias",
          price: double.parse(_priceController.text),
          purchase: double.parse(_purchasePriceController.text),
          picture: imgString,
          barcode: result,
          enable_product: enableProduct,
          quantity: int.parse(_quantityController.text),
          weight: _weightController.text == "" ? 0 : double.parse(_weightController.text),
          has_variant: variantSelectedList.length != 0 ? true : false,
        );

        await dbmanager.insertProduct(p).then((id) {
          if (variantSelectedList.length != 0) {
            _storeVriantOption(id);
            _storeVariant(id);
          }
          if (categorySelectedList.length != 0) {
            _submitCategoryProduct(id);
          }
          if (log) {
            logActivity.recordLog("${p.name} ${getTranslated(context, 'category_added')}",
                'add_product', id, "Product", null);
          }
          _saveProductBarcode(_nameController.text, id, result);
        });
      } catch (e) {
        _showToastMessage(e.toString());
      }
      Navigator.of(context).pop();
    } // form validation ends
    else {
      _showToastMessage(getTranslated(context, "product_invalid_form"));
    }
  }

  void _submitCategoryProduct(int productId) async {
    if (productId != null && categorySelectedList.length != 0) {
      // for (var i = 0; i <= categorySelectedList.length; i++) {
      categorySelectedList.forEach((categoryValue) async {
        try {
          CategoryProductJoin cpj = new CategoryProductJoin(
            category_id: categoryValue.id,
            product_id: productId,
          );

          await dbmanager.insertCategoryProduct(cpj).then((id) => {});
        } catch (e) {
          _showToastMessage(e.toString());
        }
      });
    } else {}
  }

  ////// variant part

  void _storeVariant(int productId) async {
    variantSelectedList.forEach((variantObject) async {
      VariantProductJoin vpj =
          VariantProductJoin(variant_id: variantObject.id, product_id: productId);

      await dbmanager.insertVariantProduct(vpj).then((onValue) {});
    });
  }

  void _storeVriantOption(int productId) async {
    List<VariantOptionPrice> vopList = List();
    for (var key in variantOptionMap.keys) {
      vopList = variantOptionMap[key];

      vopList.forEach((variantOptionPriceObject) async {
        ProductVariantOption cpj = new ProductVariantOption(
          product_id: productId,
          variant_id: variantOptionPriceObject.variant_id,
          option_id: variantOptionPriceObject.option_id,
          price: variantOptionPriceObject.option_price,
        );
        await dbmanager.insertProdcutVariantOption(cpj).then((onValue) {});
      });
    }
  }

  void _saveProductBarcode(String productName, int productId, String productBarcode) async {
    if (randomGeneratedBarcode == productBarcode) {
      BarcodeModel bm =
          BarcodeModel(name: productName, product_id: productId, barcode_text: productBarcode);

      await dbmanager.insertBarcode(bm).then((onValue) {});
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
