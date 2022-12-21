// ignore_for_file: prefer_const_constructors, unrelated_type_equality_checks, non_constant_identifier_names

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
                            if (valueNotif.contentTypeModel == "eventmodel") {
                              // NotifikasiController.to
                              //     .getNotifikasiCountUnreadSurvey();
                              SmartDialog.showLoading(msg: "Check Survey...");
                              var id_event = valueNotif.objectId!;
                              await NotifikasiController.to
                                  .getSurveyNeedResponse(id_event)
                                  .then((valueNeed) async {
                                //print(valueNeed);
                                SmartDialog.dismiss();
                                if (valueNeed != null) {
                                  int id_survey = valueNeed['id'];
                                  String title = valueNeed['title'];
                                  var openSurvey = Survey(
                                      id: id_survey,
                                      title: title,
                                      isDraft: false);
                                  //print("OPEN SURVEY NEED RESPONSE");
                                  SurveyController.to
                                      .generatePreviewFormSurveyEvent(
                                          openSurvey, id_event);
                                } else {
                                  //clear notifikasi ny ya
                                  ///notification/mark-read-all/
                                  // await NotifikasiController.to
                                  //     .markReadAll()
                                  //     .then((value) {
                                  //   if (value == true) {
                                  //     NotifikasiController.to
                                  //         .getNotifikasiCountUnreadSurvey();
                                  //   }
                                  // });
                                  GFToast.showToast(
                                      'You Have Completed This Survey!',
                                      context,
                                      trailing: const Icon(
                                        Icons.check_circle_outline,
                                        color: GFColors.WARNING,
                                      ),
                                      toastPosition: GFToastPosition.BOTTOM,
                                      toastBorderRadius: 5.0);
                                }
                              });
                            }

                            if (valueNotif.contentTypeModel ==
                                "formbuildermodel") {
                              SmartDialog.showLoading(msg: "Check Survey...");
                              //belum check sudah isi survey belum?
                              //generateOpenFormSurveyDirect
                              SurveyController.to.generateOpenFormSurveyDirect(
                                  valueNotif.objectId!, true);
                            }
                          }
                        });
                      },
                      padding: EdgeInsets.all(0),
                      avatar: Icon(
                        CupertinoIcons.bell,
                        size: 17,
                      ),
                      title: Text(
                        item.title!,
                        style: TextStyle(
                            fontWeight: item.isRead == false
                                ? FontWeight.bold
                                : FontWeight.normal),
                        textScaleFactor: 1.1,
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
