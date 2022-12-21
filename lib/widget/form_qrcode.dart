// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:getwidget/getwidget.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/controller/CompanyController.dart';
import 'package:tmcapp/controller/EventController.dart';
import 'package:tmcapp/model/list_id.dart';

import 'image_widget.dart';

class FormQrCode extends StatefulWidget {
  final String qrcode_image_source;
  final double width;
  @override
  // ignore: overridden_fields
  final Key key;

  const FormQrCode({
    required this.key,
    required this.qrcode_image_source,
    required this.width,
  }) : super(key: key);
  @override
  _FormQrCodeState createState() => _FormQrCodeState();
}

class _FormQrCodeState extends State<FormQrCode> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.transparent),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              width: widget.width * 0.88,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              decoration: BoxDecoration(
                  color: GFColors.DARK,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Scan the QR Code to take attendance",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GFBorder(
                    strokeWidth: 2,
                    color: CupertinoColors.lightBackgroundGray,
                    radius: Radius.circular(10),
                    type: GFBorderType.rRect,
                    dashedLine: [3, 0],
                    child: Image.network(
                      widget.qrcode_image_source,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              )),
        ],
      ),
    );
  }

  Widget _customDropDown(BuildContext context, ListID? item) {
    return Container(
        margin: EdgeInsets.all(0),
        child: (item == null)
            ? const ListTile(
                contentPadding: EdgeInsets.all(0),
                title: Text("Search Company",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(235, 158, 158, 158))),
              )
            : ListTile(
                minLeadingWidth: 2,
                horizontalTitleGap: 8,
                leading: Icon(CupertinoIcons.building_2_fill),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
                dense: true,
                visualDensity: VisualDensity(vertical: -3),
                title: Text(
                  item.title,
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  item.subtitle,
                  style: TextStyle(fontSize: 12),
                ),
              ));
  }

  Widget _customPopupItem(BuildContext context, ListID item, bool isSelected) {
    print(isSelected);
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: CupertinoColors.separator, width: 1)),
          color: Colors.transparent,
        ),
        child: ListTile(
          minLeadingWidth: 2,
          horizontalTitleGap: 8,
          leading: Icon(CupertinoIcons.building_2_fill),
          contentPadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
          dense: true,
          visualDensity: VisualDensity(vertical: -3),
          title: Text(
            item.title,
            style: TextStyle(fontSize: 14),
          ),
          subtitle: Text(
            item.subtitle,
            style: TextStyle(fontSize: 12),
          ),
        ));
  }
}
