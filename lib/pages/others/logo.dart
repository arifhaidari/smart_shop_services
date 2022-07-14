import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos/db/db_helper.dart';
import 'package:pos/db/user_model.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/product/Utility.dart';

class Logo extends StatefulWidget {
  @override
  _LogoState createState() => _LogoState();
}

class _LogoState extends State<Logo> {
  final PosDatabase dbmanager = new PosDatabase();
  bool _inProcess = false;

  File imageFile;

  String imgString = "no_logo";

  UserModel userObject;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void getUser() async {
    await dbmanager.getSingleUser().then((value) {
      setState(() {
        userObject = value;
        imgString = value.logo;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final scren_width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.blue[900],
        title: Text(getTranslated(context, 'other_logo')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: scren_width * 0.7,
              child: Card(
                elevation: 5,
                child: Container(
                  margin: EdgeInsets.all(5),
                  color: Colors.white,
                  child: ListTile(
                    title: Text(
                      getTranslated(context, 'other_logo'),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {},
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: 200.0,
                          width: 200.0,
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
            ),
          ],
        ),
      ),
    );
  }

  Image getImageWidget() {
    if (imageFile != null) {
      return Image.file(
        imageFile, //_selectedFile,
        fit: BoxFit.cover,
      );
    } else if (imgString == "no_logo") {
      return Image.asset(
        "images/invoice_logo.png",
        fit: BoxFit.cover,
      );
    } else {
      return Utility.imageFromBase64String(imgString);
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
          maxWidth: 350,
          maxHeight: 350,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.blue[800],
            toolbarTitle: "POS Cropper",
            statusBarColor: Colors.deepOrange.shade900,
            backgroundColor: Colors.white,
          ));

      this.setState(() {
        imageFile = cropped;
        imgString = Utility.base64String(cropped.readAsBytesSync());
        _inProcess = false;
      });
      saveLogo();
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

  void saveLogo() async {
    userObject.logo = imgString;
    await dbmanager
        .updateUser(userObject)
        .then((value) => _showToastMessage(getTranslated(context, 'other_logo_updated')));
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
