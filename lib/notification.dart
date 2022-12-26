// ignore_for_file: prefer_const_constructors, unrelated_type_equality_checks, non_constant_identifier_names

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:getwidget/getwidget.dart';
import 'package:skeletons/skeletons.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/controller/BottomTabController.dart';
import 'package:flutter/material.dart';
import 'package:tmcapp/controller/EventController.dart';
import 'package:tmcapp/controller/NotifikasiController.dart';
import 'package:tmcapp/controller/SurveyController.dart';
import 'package:tmcapp/model/survey.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final bottomTabControl = BottomTabController.to;
  late ScrollController _scrollController;
  final Color _foregroundColor = Colors.white;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AuthController.to.user.value.isLogin == false
        ? Scaffold(
            backgroundColor: Colors.grey.shade50,
            body: const Center(
              child: Text("You are not logged in yet..."),
            ))
        : Scaffold(
            backgroundColor: Colors.grey.shade50,
            body: Obx(() => Container(
                  child: NotifikasiController.to.isLoading.value == false
                      ? BuildListBody()
                      : BuildListLoading(),
                )));
  }

  void openScreenInvoice(String invoiceNumber) {
    Get.toNamed('/invoice-detil', arguments: {'invoice_number': invoiceNumber});
  }

  Widget BuildListBody() {
    return NotifikasiController.to.ListNotification.isNotEmpty
        ? Container(
            margin: EdgeInsets.only(top: 5),
            padding: EdgeInsets.all(5),
            child: Obx(() => ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: NotifikasiController.to.ListNotification.length,
                itemBuilder: (BuildContext context, int index) {
                  var item = NotifikasiController.to.ListNotification[index];
                  return GFListTile(
                      onTap: () async {
                        print(item.toMap());

                        NotifikasiController.to
                            .getDetilNotification(item.id!)
                            .then((valueNotif) async {
                          print(valueNotif.toMap());

                          if (valueNotif.id! > 0) {
                            NotifikasiController.to
                                .getNotifikasiCountUnreadSurvey();
                            // openScreenInvoice('I8wz');
                            // return null;
                            if (valueNotif.contentTypeModel ==
                                "formbuildermodel") {
                              SmartDialog.showLoading(msg: "Check...");
                              //belum check sudah isi survey belum?
                              //generateOpenFormSurveyDirect
                              SurveyController.to.generateOpenFormSurveyDirect(
                                  valueNotif.objectId!, true);
                            }

                            if (valueNotif.contentTypeModel == "eventmodel") {
                              SmartDialog.showLoading(msg: "Check...");
                              //belum check sudah isi survey belum?
                              //generateOpenFormSurveyDirect
                              EventController.to.openScreenItem(
                                  valueNotif.objectId!.toString());
                            }

                            if (valueNotif.contentTypeModel == "invoice") {
                              SmartDialog.showLoading(msg: "Check...");
                              //belum check sudah isi survey belum?
                              //generateOpenFormSurveyDirect
                              openScreenInvoice(
                                  valueNotif.objectId!.toString());
                            }
                          }
                        });
                      },
                      padding: EdgeInsets.all(0),
                      avatar: Icon(
                        CupertinoIcons.bell,
                        size: 17,
                      ),
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          item.createdAt != null
                              ? Text(
                                  "${DateFormat(DateFormat.YEAR_MONTH_WEEKDAY_DAY, "id_ID").format(DateTime.parse(item.createdAt!.toIso8601String()))} ${item.createdAt!.toIso8601String().toString().substring(11, 16)}",
                                  style: TextStyle(
                                      color: CupertinoColors.inactiveGray,
                                      fontWeight: item.isRead == false
                                          ? FontWeight.bold
                                          : FontWeight.normal),
                                  textScaleFactor: 0.8)
                              : Container(),
                          Text(
                            item.title!,
                            style: TextStyle(
                                fontWeight: item.isRead == false
                                    ? FontWeight.bold
                                    : FontWeight.normal),
                            textScaleFactor: 1.1,
                          ),
                        ],
                      ),
                      subTitle: Text(
                        item.summary!,
                        style: TextStyle(
                            fontWeight: item.isRead == false
                                ? FontWeight.bold
                                : FontWeight.normal),
                        textScaleFactor: 0.89,
                      ));
                })),
          )
        : Container(
            child: Center(
              child: Text("No notifications yet"),
            ),
          );
  }

  Widget BuildListLoading() {
    return Container(
      margin: EdgeInsets.only(top: 5),
      padding: EdgeInsets.all(5),
      child: Obx(() => ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: NotifikasiController.to.ListNotification.length,
          itemBuilder: (BuildContext context, int index) {
            var item = NotifikasiController.to.ListNotification[index];
            return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SkeletonParagraph(
                  style: SkeletonParagraphStyle(
                      lines: 2,
                      spacing: 5,
                      lineStyle: SkeletonLineStyle(
                        randomLength: false,
                        height: 15,
                        borderRadius: BorderRadius.circular(5),
                      )),
                ));
          })),
    );
  }
}
