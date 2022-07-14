import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pos/localization/localization_mixins.dart';
import 'package:pos/pages/others/qr_barcode/barcode_tab.dart';
import 'package:pos/pages/others/qr_barcode/qr_tab.dart';

class ScannerQrHome extends StatefulWidget {
  @override
  _ScannerQrHomeState createState() => _ScannerQrHomeState();
}

class _ScannerQrHomeState extends State<ScannerQrHome> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue[900],
            bottom: TabBar(
              // isScrollable: true,
              indicatorColor: Colors.white,
              tabs: [
                Tab(
                  text: getTranslated(context, "other_barcode"),
                  icon: Icon(FontAwesomeIcons.barcode),
                ),
                Tab(text: getTranslated(context, "other_qr"), icon: Icon(FontAwesomeIcons.qrcode)),
              ],
            ),
            title: Text(getTranslated(context, "other_barcode_title")),
          ),
          body: TabBarView(
            children: [
              Padding(
                padding: EdgeInsets.all(3.0),
                child: BarcodeTab(),
              ),
              Padding(
                padding: EdgeInsets.all(3.0),
                child: QrTab(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
