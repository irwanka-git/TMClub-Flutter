// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/controller/CompanyController.dart';
import 'package:tmcapp/controller/EventController.dart';
import 'package:tmcapp/model/list_id.dart';

import 'image_widget.dart';

class FormAttedanceResult extends StatefulWidget {
  final Map<String, dynamic>? result;
  final double width;
  @override
  // ignore: overridden_fields
  final Key key;

  const FormAttedanceResult({
    required this.key,
    required this.result,
    required this.width,
  }) : super(key: key);
  @override
  _FormAttedanceResultState createState() => _FormAttedanceResultState();
}

class _FormAttedanceResultState extends State<FormAttedanceResult> {
  final CompanyController companyController = CompanyController.to;
  final AuthController auc = AuthController.to;
  final EventController eventController = EventController.to;
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();

  final attend_time = "".obs;
  final event_name = "".obs;
  final date_event = "".obs;
  @override
  void initState() {
    // TODO: implement initState
    DateTime map_attend_time = DateTime.parse(widget.result!['attend_time']);
    DateTime map_event_time = DateTime.parse(widget.result!['date_event']);
    if (widget.result!['attend_time'] != null) {
      attend_time.value =
          "${DateFormat(DateFormat.YEAR_MONTH_WEEKDAY_DAY, "id_ID").format(DateTime.parse(map_attend_time.toIso8601String()))} ${map_attend_time.toIso8601String().toString().substring(11, 16)}";
    }
    if (widget.result!['date_event'] != null) {
      date_event.value =
          "${DateFormat(DateFormat.YEAR_MONTH_WEEKDAY_DAY, "id_ID").format(DateTime.parse(map_event_time.toIso8601String()))} ${map_event_time.toIso8601String().toString().substring(11, 16)}";
    }
    event_name.value = widget.result!['event'];
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
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: Center(
                    child: Text(
                      "Absensi Berhasil",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Peserta",
                  style: TextStyle(
                      fontSize: 13, color: CupertinoColors.secondaryLabel),
                ),
                SizedBox(
                  height: 5,
                ),
                GFListTile(
                  padding: EdgeInsets.only(bottom: 10, left: 0, right: 8),
                  margin: EdgeInsets.all(3),
                  avatar: Center(
                    child: GFAvatar(
                      radius: 20,
                      backgroundImage:
                          Image.network(auc.user.value.photoURL).image,
                    ),
                  ),
                  subTitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auc.user.value.companyName,
                        style: TextStyle(
                            fontSize: 13,
                            color: CupertinoColors.secondaryLabel),
                      )
                    ],
                  ),
                  title: Text(
                    auc.user.value.displayName,
                    style:
                        TextStyle(fontSize: 14, color: CupertinoColors.black),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Acara",
                  style: TextStyle(
                      fontSize: 13, color: CupertinoColors.secondaryLabel),
                ),
                SizedBox(
                  height: 5,
                ),
                GFListTile(
                  padding: EdgeInsets.only(bottom: 10, left: 0, right: 8),
                  margin: EdgeInsets.all(3),
                  avatar: Icon(CupertinoIcons.calendar_today),
                  title: Text(
                    "${event_name.value}",
                  ),
                  subTitle: Text(
                    date_event.value,
                    style: TextStyle(
                        fontSize: 13, color: CupertinoColors.secondaryLabel),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Waktu Absensi",
                            style: TextStyle(
                                fontSize: 13,
                                color: CupertinoColors.secondaryLabel),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            "${attend_time.value}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14,
                                color: GFColors.DARK,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Icon(
                        CupertinoIcons.checkmark_alt_circle,
                        size: 25,
                        color: CupertinoColors.activeGreen,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  height: 15,
                ),
                GFButton(
                  onPressed: () {
                    Navigator.of(Get.context!).pop();
                  },
                  fullWidthButton: true,
                  color: CupertinoColors.activeGreen,
                  textColor: GFColors.WHITE,
                  text: "Kembali",
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
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
