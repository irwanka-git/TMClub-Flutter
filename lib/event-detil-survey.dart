// ignore_for_file: non_constant_identifier_names, prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';
import 'package:tmcapp/controller/AppController.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/controller/EventController.dart';
import 'package:tmcapp/controller/SurveyController.dart';
import 'package:tmcapp/model/event_tmc_detil.dart';
import 'package:tmcapp/model/resources.dart';
import 'package:tmcapp/model/survey.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetilSurveyScreen extends StatefulWidget {
  @override
  State<EventDetilSurveyScreen> createState() => _EventDetilSurveyScreenState();
}

class _EventDetilSurveyScreenState extends State<EventDetilSurveyScreen> {
  final authController = AuthController.to;
  //final AkunController akunController = AkunController.to;
  final EventController eventController = EventController.to;

  TextEditingController _searchSurveyTextcontroller = TextEditingController();
  var ListSurvey = <Survey>[].obs;
  var ListSurveyEvent = <Survey>[].obs;
  var isLoading = true.obs;
  var searchTextFocus = false.obs;
  var needResponseID = <int>[].obs;
  final itemAcara = EventTmcDetil(pk: 0).obs;

  Future<void> getDataSurvey() async {
    await eventController.getListSurvey(itemAcara.value.pk!);
    //setState(() {
    if (eventController.ListSurveyEvent.isNotEmpty) {
      ListSurveyEvent.clear();
      for (var item in eventController.ListSurveyEvent) {
        //Survey itemSurvey = Survey.fromMap(item);
        ListSurveyEvent.add(item);
      }
    }
    if (authController.user.value.role == "member") {
      needResponseID.clear();
      await SurveyController.to
          .getListNeedSurvey(itemAcara.value.pk!)
          .then((valueNeed) {
        for (var item in valueNeed) {
          needResponseID.add(item);
        }
      });
    }
    _searchTextcontroller.text = "";
    // });
    isLoading.value = false;
    return;
  }

  void _onRefresh() async {
    // monitor network fetch
    isLoading.value = true;
    //await CompanyController.to.getListCompany();
    await getDataSurvey();
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    isLoading.value = false;
    _refreshController.refreshCompleted();
    isLoading.value = false;
  }

  void _onLoading() async {
    // monitor network fetch
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  TextEditingController _searchTextcontroller = TextEditingController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    setState(() {
      itemAcara(Get.arguments['event']);
      isLoading.value = true;
    });

    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      //companyController.getListCompany();
      await getDataSurvey();
      await SurveyController.to.getListSurvey();
      ListSurvey.clear();
      print("AMBIL LIST SURVEY");
      for (var item in SurveyController.to.ListSurvey) {
        print(item.title!);
        if (item.isDraft == false) {
          ListSurvey.add(item);
        }
      }
      isLoading.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: buildFloatingActionAdd(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: AppBar(
          titleSpacing: 0,
          title: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isLoading.value == false
                      ? Text(
                          "Survey (${ListSurveyEvent.value.length})",
                          style: TextStyle(fontSize: 18),
                        )
                      : Container(),
                  Text(
                    "${itemAcara.value.title}",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              )),
          backgroundColor: AppController.to.appBarColor.value,
          elevation: 1,
        ),
        backgroundColor: Theme.of(context).canvasColor,
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: const MaterialClassicHeader(
            color: CupertinoColors.activeOrange,
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: BuildListBody(),
        ));
  }

  Visibility buildFloatingActionAdd() {
    return Visibility(
      visible: authController.user.value.role == "admin" ? true : false,
      child: Wrap(
          direction: Axis.horizontal, //use vertical to show  on vertical axis
          children: [
            Obx(() => Container(
                margin: EdgeInsets.all(5),
                child: Visibility(
                  visible: ListSurveyEvent.value.length > 0 ? true : false,
                  child: FloatingActionButton(
                    mini: true,
                    heroTag: "float_send",
                    onPressed: () async {
                      //action code for button 2

                      SmartDialog.showLoading(
                          msg: "Send Notification Survey...");
                      bool berhasil = false;
                      await eventController
                          .submitSendNotifikasi(itemAcara.value.pk!)
                          .then((value) => berhasil = value);
                      SmartDialog.dismiss();
                      if (berhasil) {
                        GFToast.showToast(
                            'Send Notification Success!',
                            Get.context!,
                            trailing: const Icon(
                              Icons.check_circle,
                              color: GFColors.SUCCESS,
                            ),
                            toastPosition: GFToastPosition.BOTTOM,
                            toastBorderRadius: 5.0);
                      } else {
                        GFToast.showToast(
                            'Failed, Send Notification',
                            Get.context!,
                            trailing: const Icon(
                              Icons.error_outline,
                              color: GFColors.WARNING,
                            ),
                            toastPosition: GFToastPosition.BOTTOM,
                            toastBorderRadius: 5.0);
                      }
                    },
                    backgroundColor: CupertinoColors.activeOrange,
                    child: Icon(CupertinoIcons.paperplane),
                  ),
                ))),
            Container(
                margin: EdgeInsets.all(5),
                child: FloatingActionButton(
                  mini: true,
                  heroTag: "float_add",
                  onPressed: () {
                    //action code for button 2
                    showModalAddsurvey();
                  },
                  backgroundColor: CupertinoColors.activeBlue,
                  child: Icon(Icons.add),
                ))
          ]),
    );
  }

  void showModalAddsurvey() {
    var ListSelectSurvey = <Survey>[];
    List<int> id_survey =
        ListSurveyEvent.value.map((item) => item.id!).toList();

    for (var item in ListSurvey) {
      if (id_survey.contains(item.id) == false) {
        ListSelectSurvey.add(item);
      }
    }

    _searchSurveyTextcontroller.clear();
    final ListSurveyBottomSheet = <Survey>[].obs;
    setState(() {
      ListSurveyBottomSheet.clear();
      ListSurveyBottomSheet.addAll(ListSelectSurvey);
    });

    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
              padding: EdgeInsets.only(
                  top: 20,
                  right: 20,
                  left: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10.0),
                  TextField(
                    controller: _searchSurveyTextcontroller,
                    onChanged: (text) {
                      if (text == "") {
                        setState(() {
                          ListSurveyBottomSheet.clear();
                          ListSurveyBottomSheet.addAll(ListSelectSurvey);
                        });
                        return;
                      }
                      setState(() {
                        ListSurveyBottomSheet.value = ListSelectSurvey.where(
                            (p0) => p0.title!
                                .toLowerCase()
                                .contains(text.toLowerCase())).toList();
                      });
                    },
                    decoration: InputDecoration(
                        prefixIcon: Icon(CupertinoIcons.search),
                        contentPadding: EdgeInsets.only(top: 10),
                        border: OutlineInputBorder(),
                        hintText: 'Search'),
                  ),
                  SingleChildScrollView(
                    child: Container(
                      constraints: BoxConstraints(maxHeight: Get.height * 0.4),
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Column(children: [
                        Expanded(
                          flex: 2,
                          child: Obx(() => ListView.builder(
                              itemCount: ListSurveyBottomSheet.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GFListTile(
                                  title:
                                      Text(ListSurveyBottomSheet[index].title!,
                                          style: TextStyle(
                                            fontSize: 16,
                                          )),
                                  subTitle: Text(
                                    "${ListSurveyBottomSheet[index].description}",
                                    textScaleFactor: 0.8,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 8),
                                  margin: EdgeInsets.all(0),
                                  avatar: Icon(
                                    CupertinoIcons.checkmark_rectangle,
                                    size: 18,
                                  ),
                                  onTap: () async {
                                    Navigator.of(Get.context!).pop();
                                    //print(ListSurveyBottomSheet[index].email);
                                    if (id_survey.contains(
                                            ListSurveyBottomSheet[index].id!) ==
                                        false) {
                                      print(ListSurveyBottomSheet[index].id);
                                      List<int> surveyId = [];
                                      for (var n in ListSurveyEvent) {
                                        surveyId.add(n.id!);
                                      }
                                      surveyId.add(
                                          ListSurveyBottomSheet[index].id!);
                                      SmartDialog.showLoading(
                                          msg: "Tambahkan Survey...");
                                      bool berhasil = false;
                                      var dataSurvey = {"surveys_id": surveyId};
                                      print(dataSurvey);
                                      await eventController
                                          .submitSetSurveyEvent(
                                              itemAcara.value.pk!, dataSurvey)
                                          .then((value) => berhasil = value);
                                      SmartDialog.dismiss();
                                      if (berhasil == true) {
                                        ListSurveyEvent.add(
                                            ListSurveyBottomSheet[index]);
                                        GFToast.showToast(
                                            'Survey Berhasil Ditambahkan ke Event!',
                                            Get.context!,
                                            trailing: const Icon(
                                              Icons.check_circle,
                                              color: GFColors.SUCCESS,
                                            ),
                                            toastPosition:
                                                GFToastPosition.BOTTOM,
                                            toastBorderRadius: 5.0);
                                      } else {
                                        GFToast.showToast(
                                            'Survey Gagal Ditambahkan ke Event!',
                                            Get.context!,
                                            trailing: const Icon(
                                              Icons.error_outline,
                                              color: GFColors.WARNING,
                                            ),
                                            toastPosition:
                                                GFToastPosition.BOTTOM,
                                            toastBorderRadius: 5.0);
                                      }
                                      //ListSurveyEvent.add(ListSurveyBottomSheet[index]);
                                    }
                                  },
                                );
                              })),
                        )
                      ]),
                    ),
                  )
                ],
              ),
            ));
  }

  CustomScrollView BuildListBody() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).canvasColor,
          stretch: true,
          pinned: true,
          leading: Container(),
          floating: true,
          toolbarHeight: 20.0 + kToolbarHeight,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: SizedBox(
              height: 45,
              child: Container(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: TextField(
                  onTap: () {
                    setState(() {
                      searchTextFocus.value == true;
                    });
                  },
                  controller: _searchTextcontroller,
                  onChanged: (text) {
                    if (text == "") {
                      setState(() {
                        ListSurveyEvent(eventController.ListSurveyEvent);
                      });
                      return;
                    }
                    ListSurveyEvent.value =
                        eventController.ListSurveyEvent.where((p0) => p0.title!
                            .toLowerCase()
                            .contains(text.toLowerCase())).toList();
                  },
                  decoration: InputDecoration(
                      prefixIcon: Icon(CupertinoIcons.search),
                      contentPadding: EdgeInsets.only(top: 10),
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          _searchTextcontroller.clear();
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          setState(() {
                            ListSurveyEvent(eventController.ListSurveyEvent);
                          });
                        },
                        icon: Icon(Icons.clear),
                      ),
                      hintText: 'Search'),
                ),
              ),
            ),
          ),
        ),
        Obx(() => Container(
              child: SliverList(
                delegate: isLoading.value == false
                    ? BuilderListCard(ListSurveyEvent)
                    : BuilderListSkeletonCard(),
              ),
            )),
      ],
    );
  }

  SliverChildBuilderDelegate BuilderListCard(List<Survey> _ListSurvey) {
    List<Survey> _listResult = _ListSurvey;
    return SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return Container(
            child: GFListTile(
          onTap: () async {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            if (authController.user.value.role == "member") {
              SmartDialog.showLoading(msg: "Check..");
              needResponseID.clear();
              await SurveyController.to
                  .getListNeedSurvey(itemAcara.value.pk!)
                  .then((valueNeed) {
                for (var item in valueNeed) {
                  needResponseID.add(item);
                }
              });
              SmartDialog.dismiss();
              if (needResponseID.contains(_listResult[index].id)) {
                SurveyController.to.generatePreviewFormSurveyEvent(
                    _listResult[index], itemAcara.value.pk!);
              } else {
                GFToast.showToast('You have filled out the survey!', context,
                    trailing: const Icon(
                      Icons.check_circle_outline,
                      color: GFColors.WARNING,
                    ),
                    toastPosition: GFToastPosition.BOTTOM,
                    toastBorderRadius: 5.0);
              }
            }

            if (authController.user.value.role == "admin") {
              SmartDialog.showLoading(msg: "Check Result..");
              //SmartDialog.dismiss();
              await SurveyController.to
                  .getResultSurveyByEvent(
                      itemAcara.value.pk!, _listResult[index].id!)
                  .then((response) {
                //print(response);
                if (response != null) {
                  Get.toNamed('/event-result-survey',
                      arguments: {'response': response, 'id_event':itemAcara.value.pk!});
                }
                SmartDialog.dismiss();
              });
            }
            //print("Lihat Hasil Survey");
            //_launchInBrowser(Uri.parse(_listResult[index].url!));
            //showDetilAkun(_listResult[index]);
          },
          onLongPress: () {
            print("Remove Survey");
            //_launchInBrowser(Uri.parse(_listResult[index].url!));
            //showDetilAkun(_listResult[index]);
            authController.user.value.role == "admin"
                ? showKonfirmDelete(_listResult[index])
                : null;
          },
          title: Text(_listResult[index].title!,
              style: TextStyle(
                fontSize: 16,
              )),
          subTitle: Text(
            "${_listResult[index].description}",
            textScaleFactor: 0.8,
            overflow: TextOverflow.ellipsis,
          ),
          icon: authController.user.value.role == "member"
              ? Container(
                  child: Obx(() => Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: !needResponseID
                                    .contains(_listResult[index].id!) &&
                                isLoading.value == false
                            ? Icon(
                                CupertinoIcons.check_mark_circled,
                                size: 16,
                                color: GFColors.SUCCESS,
                              )
                            : Icon(Icons.edit, size: 16, color: GFColors.LIGHT),
                      )),
                )
              : Container(),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          margin: EdgeInsets.only(left: 10),
          avatar: Icon(
            CupertinoIcons.doc,
            size: 25,
          ),
          // icon: Container(
          //     child: authController.user.value.role == "admin"
          //         ? IconButton(
          //             onPressed: () {},
          //             icon: Icon(
          //               CupertinoIcons.bell,
          //               size: 16,
          //             ),
          //             splashRadius: 20,
          //           )
          //         : Container()),
        ));
      },
      childCount: _listResult.length,
    );
  }

  SliverChildBuilderDelegate BuilderListSkeletonCard() {
    return SliverChildBuilderDelegate(
      (BuildContext context, int index) {
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
      },
      childCount: 8,
    );
  }

  void showKonfirmDelete(Survey item) async {
    await Get.defaultDialog(
        contentPadding: const EdgeInsets.all(20),
        title: "Confirmation",
        titlePadding: const EdgeInsets.only(top: 10, bottom: 0),
        middleText: "Yakin ingin hapus Survey \n[${item.title}]",
        backgroundColor: CupertinoColors.white,
        titleStyle: const TextStyle(color: Colors.black, fontSize: 16),
        middleTextStyle: const TextStyle(
            color: CupertinoColors.darkBackgroundGray, fontSize: 14),
        textCancel: "Cancel",
        textConfirm: "Yes, Delete",
        buttonColor: GFColors.DANGER,
        cancelTextColor: GFColors.DANGER,
        confirmTextColor: GFColors.WHITE,
        onConfirm: () async {
          Navigator.of(Get.overlayContext!).pop();

          bool result = false;
          var survey_id = <int>[];
          for (var n in ListSurveyEvent) {
            survey_id.add(n.id!);
          }
          survey_id.remove(item.id);
          SmartDialog.showLoading(msg: "Hapus Survey dari Event...");
          var data_survey = {"surveys_id": survey_id};
          bool berhasil = false;
          await eventController
              .submitSetSurveyEvent(itemAcara.value.pk!, data_survey)
              .then((value) => result = value);
          SmartDialog.dismiss();
          if (result == true) {
            int indexOfDelete =
                ListSurveyEvent.indexWhere((element) => element.id == item.id);
            if (indexOfDelete > -1) {
              ListSurveyEvent.removeAt(indexOfDelete);
            }

            GFToast.showToast('Survey Berhasil Dihapus dari Event!', context,
                trailing: const Icon(
                  Icons.check_circle,
                  color: GFColors.SUCCESS,
                ),
                toastPosition: GFToastPosition.BOTTOM,
                toastBorderRadius: 5.0);
          } else {
            GFToast.showToast('Gagal Hapus Survey dari Event!', context,
                trailing: const Icon(
                  Icons.error_outline,
                  color: GFColors.DANGER,
                ),
                toastPosition: GFToastPosition.BOTTOM,
                toastBorderRadius: 5.0);
          }
        },
        radius: 0);
  }
}
