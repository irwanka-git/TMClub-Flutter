// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';
import 'package:tmcapp/controller/AppController.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/controller/SurveyController.dart';
import 'package:tmcapp/model/question_survey.dart';
import 'package:tmcapp/model/survey.dart';
import 'package:tmcapp/widget/form-preview-question.dart';
import 'package:tmcapp/widget/form-response-question.dart';
import 'package:tmcapp/widget/form_question.dart';
import 'package:tmcapp/widget/speed_dial.dart';

class KelolaSurveyDraftScreen extends StatefulWidget {
  @override
  State<KelolaSurveyDraftScreen> createState() =>
      _KelolaSurveyDraftScreenState();
}

class _KelolaSurveyDraftScreenState extends State<KelolaSurveyDraftScreen>
    with SingleTickerProviderStateMixin {
  final authController = AuthController.to;
  final surveyController = SurveyController.to;
  final formKey = GlobalKey<FormState>();
  final surveyID = "".obs;
  final isDraft = true.obs;
  final itemSurvey = Survey().obs;
  final isLoading = true.obs;
  var ListQuestion = <QuestionSurvey>[].obs;
  var fieldCard = <FormResponseQuestionSurvey>[].obs;
  var offsetScroll = 0.0.obs;
  var showFloatAddaction = true.obs;
  var tabQuestion = 0.obs;
  var _tabbarQuestioncontroller;

  void _onRefresh() async {
    // monitor network fetch
    isLoading.value = true;
    Survey temp =
        await surveyController.getInformasiDraftSurvey(surveyID.value);
    setState(() {
      itemSurvey(temp);
    });
    await surveyController.getListQuestionSurvey(surveyID.value);
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

  ScrollController scrollQuestionController = ScrollController();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    setState(() {
      surveyID(Get.arguments['surveyID']);
      itemSurvey(Get.arguments['itemSurvey']);
      isDraft(Get.arguments['isDraft']);
    });
    _tabbarQuestioncontroller = TabController(length: 2, vsync: this);
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      //akunController.getListAkun();
      await surveyController.getListQuestionSurvey(surveyID.value);
      isLoading.value = false;
    });
    // scrollQuestionController.addListener(() {
    //   double max = scrollQuestionController.positions.last.maxScrollExtent;
    //   double selisih = (max - scrollQuestionController.offset);
    //   if (selisih <= 20 && max > 0.0) {
    //     showFloatAddaction(false);
    //   } else {
    //     showFloatAddaction(true);
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // floatingActionButton: buildFloatingActionAdd(),
        // floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        appBar: AppBar(
          title: const Text("Create Survey"),
          backgroundColor: AppController.to.appBarColor.value,
          elevation: 1,
        ),
        backgroundColor: Color.fromARGB(255, 241, 239, 239),
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: const MaterialClassicHeader(
            color: CupertinoColors.activeOrange,
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: buildBodyPage(),
        ));
  }

  Widget buildBodyPage() {
    return Column(
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.center,
            child: CustomScrollView(
              controller: scrollQuestionController,
              slivers: [
                SliverPinnedToBoxAdapter(
                    child: Obx(() => Column(children: [
                          GFListTile(
                              title: Text(
                                "${itemSurvey.value.title!}",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              subTitle: Text(itemSurvey.value.description!,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.black54)),
                              color: GFColors.WHITE,
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.only(top: 0, bottom: 0),
                              icon: Padding(
                                padding: const EdgeInsets.all(0),
                                child: buildActionSurvey(context),
                              )),
                          Container(
                            margin: EdgeInsets.only(bottom: 5),
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 228, 241, 233)),
                            child: TabBar(
                              onTap: (value) {
                                tabQuestion(value);
                              },
                              labelColor: GFColors.DARK,
                              padding: EdgeInsets.symmetric(vertical: 0),
                              controller: _tabbarQuestioncontroller,
                              indicatorColor: CupertinoColors.activeGreen,
                              indicatorWeight: 4,
                              tabs: <Widget>[
                                new Tab(
                                  text: "Main Question",
                                  height: 35,
                                ),
                                new Tab(
                                  text: "Optional Questions",
                                  height: 35,
                                ),
                              ],
                            ),
                          ),
                        ]))),
                Obx(() => tabQuestion == 0
                    ? Container(
                        child: SliverList(
                          delegate: isLoading.value == false
                              ? BuilderListCard(
                                  surveyController.ListStatisQuestion)
                              : BuilderListSkeletonCard(),
                        ),
                      )
                    : Container(
                        child: SliverList(
                          delegate: isLoading.value == false
                              ? BuilderListCard(
                                  surveyController.ListDinamisQuestion)
                              : BuilderListSkeletonCard(),
                        ),
                      )),
              ],
            ),
          ),
        ),
        Obx(() => Container(
              decoration: BoxDecoration(color: GFColors.WHITE),
              margin: EdgeInsets.only(top: 5),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: isLoading.value == false &&
                        itemSurvey.value.isDraft == true
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GFButton(
                            textColor: GFColors.WHITE,
                            color: GFColors.SUCCESS,
                            onPressed: () async {
                              surveyController.setInsertIDQuestionDraft(
                                  DateTime.now()
                                      .microsecondsSinceEpoch
                                      .toString());
                              showModalSelectTypeQuestion("");
                            },
                            icon: Icon(CupertinoIcons.add_circled,
                                size: 16, color: GFColors.WHITE),
                            text: "Add Question",
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          GFButton(
                            textColor: GFColors.PRIMARY,
                            color: GFColors.LIGHT,
                            onPressed: () {
                              priviewFormSurvey();
                            },
                            icon: Icon(CupertinoIcons.eye,
                                size: 16, color: GFColors.PRIMARY),
                            text: "Preview",
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          GFButton(
                            color: GFColors.SECONDARY,
                            onPressed: SurveyController
                                        .to.ListStatisQuestion.length >
                                    0
                                ? () {
                                    Get.defaultDialog(
                                        contentPadding:
                                            const EdgeInsets.all(20),
                                        title: "Confirmation",
                                        titlePadding: const EdgeInsets.only(
                                            top: 10, bottom: 0),
                                        middleText:
                                            "Before sending the survey form, make sure all the information and survey questions are complete \n Are you sure you want to send the survey form?",
                                        backgroundColor: CupertinoColors.white,
                                        titleStyle: const TextStyle(
                                            color: GFColors.DARK, fontSize: 16),
                                        middleTextStyle: const TextStyle(
                                            color: GFColors.DARK, fontSize: 14),
                                        textCancel: "Cancel",
                                        textConfirm: "Yes, Continue",
                                        cancelTextColor: GFColors.DARK,
                                        confirmTextColor: Colors.white,
                                        buttonColor: GFColors.DARK,
                                        onConfirm: () async {
                                          SmartDialog.showLoading(
                                              msg: "Publish Survey...");
                                          Navigator.pop(Get.overlayContext!);
                                          bool result = false;
                                          await surveyController
                                              .submitGenerateFormSurveyToServer(
                                                  itemSurvey.value.draftID!)
                                              .then((value) => result = value);
                                          if (result == true) {
                                            GFToast.showToast(
                                                'New Survey / Questionnaire Successfully Published!',
                                                context,
                                                trailing: const Icon(
                                                  Icons.check_circle_outline,
                                                  color: GFColors.SUCCESS,
                                                ),
                                                toastPosition:
                                                    GFToastPosition.TOP,
                                                toastBorderRadius: 5.0);
                                            await surveyController
                                                .getListSurvey();
                                            //Navigator.pop(Get.context!);
                                            SmartDialog.dismiss();
                                            Get.offNamed('/kelola-survey');
                                          } else {
                                            GFToast.showToast(
                                                'An error occurred, the survey/questionnaire failed to save!',
                                                context,
                                                trailing: const Icon(
                                                  Icons.error_outline,
                                                  color: GFColors.DANGER,
                                                ),
                                                toastPosition:
                                                    GFToastPosition.TOP,
                                                toastBorderRadius: 5.0);
                                          }
                                        },
                                        radius: 0);
                                  }
                                : null,
                            icon: Icon(
                              CupertinoIcons.paperplane,
                              size: 16,
                              color: GFColors.WHITE,
                            ),
                            text: "Publish",
                          )
                        ],
                      )
                    : Container(),
              ),
            ))
      ],
    );
  }

  // ignore: non_constant_identifier_names
  SliverChildBuilderDelegate BuilderListCard(List<QuestionSurvey> items) {
    return SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return Obx(() => Container(
                child: GFCard(
              color: GFColors.WHITE,
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              title: GFListTile(
                margin: EdgeInsets.all(0),
                padding: EdgeInsets.only(top: 5),
                avatar: null,
                title: Text(
                  "${(index + 1).toString()}. ${items[index].questionText!}",
                  style: TextStyle(fontSize: 15),
                ),
                subTitle: Text(
                  "${surveyController.getQuestionType(items[index].questionType!)} ${items[index].isRequired == true ? " (Required)" : ""}",
                  style: TextStyle(
                      fontSize: 13, color: CupertinoColors.systemGrey2),
                ),
                icon: Container(
                    child: true
                        ? buildActionQuestion(context, items[index])
                        : Container()),
              ),
              // ignore: unnecessary_new, invalid_use_of_protected_member
              content: Obx(() => Container(
                      child: FormPreviewQuestionSurvey(
                    itemQuestion: items[index],
                  ))),
            )));
      },
      childCount: items.length,
    );
  }

  Container buildActionSurvey(BuildContext context) {
    return Container(
      child: itemSurvey.value.isDraft == true
          ? PopupMenuButton(
              onSelected: (_valueAction) {
                // your logic
                if (_valueAction == '/edit') {
                  showModalUpdateInformasiSurvey();
                }
                if (_valueAction == '/preview') {
                  //showFormQuestion("edit", item);
                  print("PREVIEW SURVEY");
                  priviewFormSurvey();
                }
                if (_valueAction == '/delete') {
                  //showFormQuestion("edit", item);
                  print("HAPUS DRAFT SURVEY");
                  deleteFormSurvey();
                }
              },
              itemBuilder: (BuildContext bc) {
                return [
                  PopupMenuItem(
                    child: GFListTile(
                      avatar: Icon(
                        Icons.edit_rounded,
                        size: 15,
                      ),
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.zero,
                      title: Text(
                        "Edit",
                        textScaleFactor: 1,
                      ),
                    ),
                    value: '/edit',
                  ),
                  PopupMenuItem(
                    child: GFListTile(
                      avatar: Icon(
                        Icons.remove_red_eye,
                        size: 15,
                      ),
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.zero,
                      title: Text(
                        "Preview",
                        textScaleFactor: 1,
                      ),
                    ),
                    value: '/preview',
                  ),
                  PopupMenuItem(
                    enabled: itemSurvey.value.isDraft == true,
                    child: GFListTile(
                      avatar: Icon(
                        Icons.delete_rounded,
                        size: 15,
                      ),
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.zero,
                      title: Text(
                        "Delete",
                        textScaleFactor: 1,
                      ),
                    ),
                    value: '/delete',
                  )
                ];
              },
            )
          : Container(
              child: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.remove_red_eye,
                    size: 16,
                  )),
            ),
    );
  }

  void priviewFormSurvey() {
    surveyController.generatePreviewFormSurvey(itemSurvey.value, false);
  }

  void deleteFormSurvey() {
    Get.defaultDialog(
        contentPadding: const EdgeInsets.all(20),
        title: "Confirmation",
        titlePadding: const EdgeInsets.only(top: 10, bottom: 0),
        middleText: "Are you sure you want to delete this survey draft?",
        backgroundColor: CupertinoColors.white,
        titleStyle: const TextStyle(color: GFColors.DARK, fontSize: 16),
        middleTextStyle: const TextStyle(color: GFColors.DARK, fontSize: 14),
        textCancel: "Cancel",
        textConfirm: "Yes, Sure",
        cancelTextColor: GFColors.WARNING,
        confirmTextColor: Colors.white,
        buttonColor: GFColors.WARNING,
        onConfirm: () async {
          SmartDialog.showLoading(msg: "Delete Draft..");
          bool result = false;
          Navigator.pop(Get.overlayContext!);
          await surveyController
              .deleteDraftSurveyFirebase(itemSurvey.value.draftID!)
              .then((value) => result = value);
          SmartDialog.dismiss();
          if (result == true) {
            GFToast.showToast(
                'Survey Draft Successfully Deleted!', context,
                trailing: const Icon(
                  Icons.check_circle_outline,
                  color: GFColors.SUCCESS,
                ),
                toastPosition: GFToastPosition.TOP,
                toastBorderRadius: 5.0);
            await surveyController.getListSurvey();
            Get.offNamed('/kelola-survey');
          }
        },
        radius: 0);
  }

  Container buildActionQuestion(BuildContext context, QuestionSurvey item) {
    return Container(
      child: itemSurvey.value.isDraft == false
          ? Container()
          : PopupMenuButton(
              onSelected: (_valueAction) async {
                // your logic
                if (_valueAction == '/edit') {
                  showFormQuestion("edit", item);
                }
                if (_valueAction == "/insert") {
                  int strig = 30;
                  var newID = int.parse(item.questionDraftID!) + strig;
                  bool ketemu = false;
                  while (ketemu == false) {
                    int indexCek = surveyController.ListQuestion.indexWhere(
                        (p0) => p0.questionDraftID == newID.toString());
                    if (indexCek == -1) {
                      ketemu = true;
                    } else {
                      strig--;
                      newID = int.parse(item.questionDraftID!) + strig;
                    }
                  }
                  surveyController.setInsertIDQuestionDraft(newID.toString());
                  showModalSelectTypeQuestion("");
                }
                if (_valueAction == '/delete') {
                  //showFormQuestion("edit", item);
                  Get.defaultDialog(
                      contentPadding: const EdgeInsets.all(20),
                      title: "Confirmation",
                      titlePadding: const EdgeInsets.only(top: 10, bottom: 0),
                      middleText: "Are you sure you want to delete this question?",
                      backgroundColor: CupertinoColors.white,
                      titleStyle:
                          const TextStyle(color: GFColors.DARK, fontSize: 16),
                      middleTextStyle:
                          const TextStyle(color: GFColors.DARK, fontSize: 14),
                      textCancel: "Cancel",
                      textConfirm: "Yes, Sure",
                      cancelTextColor: GFColors.DARK,
                      confirmTextColor: Colors.white,
                      buttonColor: GFColors.DARK,
                      onConfirm: () {
                        surveyController.deleteQuestionSurveyFirebase(
                            itemSurvey.value.draftID!, item.questionDraftID!);
                        Navigator.pop(Get.overlayContext!);
                      },
                      radius: 0);
                }
              },
              itemBuilder: (BuildContext bc) {
                return [
                  PopupMenuItem(
                    child: GFListTile(
                      avatar: Icon(
                        itemSurvey.value.isDraft == true
                            ? Icons.edit_rounded
                            : Icons.remove_red_eye,
                        size: 15,
                      ),
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.zero,
                      title: Text(
                        itemSurvey.value.isDraft == true ? "Edit" : "Lihat",
                        textScaleFactor: 1,
                      ),
                    ),
                    value: itemSurvey.value.isDraft == true ? '/edit' : '/view',
                  ),
                  PopupMenuItem(
                    enabled: itemSurvey.value.isDraft == true,
                    child: GFListTile(
                      avatar: Icon(
                        Icons.delete_rounded,
                        size: 15,
                      ),
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.zero,
                      title: Text(
                        "Delete",
                        textScaleFactor: 1,
                      ),
                    ),
                    value: '/delete',
                  ),
                  PopupMenuItem(
                    enabled: itemSurvey.value.isDraft == true,
                    child: GFListTile(
                      avatar: Icon(
                        Icons.add_box_outlined,
                        size: 15,
                      ),
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.zero,
                      title: Text(
                        "Question",
                        textScaleFactor: 1,
                      ),
                    ),
                    value: '/insert',
                  ),
                ];
              },
            ),
    );
  }

  SliverChildBuilderDelegate BuilderListSkeletonCard() {
    return SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SkeletonParagraph(
              style: SkeletonParagraphStyle(
                  lines: 1,
                  spacing: 5,
                  lineStyle: SkeletonLineStyle(
                    randomLength: false,
                    height: 180,
                    borderRadius: BorderRadius.circular(5),
                  )),
            ));
      },
      childCount: 3,
    );
  }

  // Padding buildFloatingActionAdd() {
  //   return Padding(
  //       padding: const EdgeInsets.all(10.0),
  //       child: Obx(() => Visibility(
  //             visible: (authController.user.value.role == "superadmin" ||
  //                         authController.user.value.role == "admin") &&
  //                     (showFloatAddaction.value == true ||
  //                         tabQuestion.value == 1)
  //                 ? true
  //                 : false,
  //             child: FloatingActionButton(
  //               heroTag: "float_survey_add",
  //               onPressed: () async {
  //                 surveyController.setInsertIDQuestionDraft(
  //                     DateTime.now().microsecondsSinceEpoch.toString());
  //                 showModalSelectTypeQuestion("");
  //               },
  //               backgroundColor: CupertinoColors.white,
  //               elevation: 6,
  //               child: const Icon(
  //                 Icons.add,
  //                 color: CupertinoColors.activeOrange,
  //                 size: 26.0,
  //               ),
  //               mini: true,
  //             ),
  //           )));
  // }

  void showModalUpdateInformasiSurvey() {
    final _titleController = TextEditingController();
    final _deskrispiController = TextEditingController();
    // final formKey = GlobalKey<FormState>();
    _titleController.text = itemSurvey.value.title!;
    _deskrispiController.text = itemSurvey.value.description!;

    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (_context) => Padding(
              padding: EdgeInsets.only(
                  top: 30,
                  right: 20,
                  left: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 30),
              child: Container(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 10.0),
                      Text("Update Survey Information"),
                      SizedBox(height: 20.0),
                      TextFormField(
                          minLines: 1,
                          maxLines: 4,
                          controller: _titleController,
                          style: const TextStyle(fontSize: 13, height: 2),
                          decoration: const InputDecoration(
                              prefixIcon: Icon(CupertinoIcons.doc_plaintext),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              labelText: "Survey Name",
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                              labelStyle:
                                  TextStyle(color: Colors.grey, fontSize: 13),
                              border: OutlineInputBorder()),
                          autocorrect: false,
                          validator: (_val) {
                            if (_val == "") {
                              return 'Required!';
                            }
                            return null;
                          }),
                      SizedBox(height: 20.0),
                      TextFormField(
                          minLines: 1,
                          maxLines: 6,
                          controller: _deskrispiController,
                          style: const TextStyle(fontSize: 13, height: 2),
                          decoration: const InputDecoration(
                              prefixIcon: Icon(CupertinoIcons.info_circle),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              labelText: "Description",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              labelStyle:
                                  TextStyle(color: Colors.grey, fontSize: 13),
                              border: OutlineInputBorder()),
                          autocorrect: false,
                          validator: (_val) {
                            if (_val == "") {
                              return 'Required!';
                            }
                            return null;
                          }),
                      SizedBox(height: 30.0),
                      GFButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) {
                            GFToast.showToast(
                                'Sorry, Survey Information Not Complete!!',
                                context,
                                trailing: const Icon(
                                  Icons.error_outline,
                                  color: GFColors.WARNING,
                                ),
                                toastPosition: GFToastPosition.BOTTOM,
                                toastBorderRadius: 5.0);
                            return;
                          }
                          String draftID = itemSurvey.value.draftID!;
                          var data = {
                            "title": _titleController.text,
                            "description": _deskrispiController.text,
                            "draft": true,
                            "draftID": draftID,
                            "createBy": authController.user.value.uid
                          };
                          Navigator.pop(context);
                          SmartDialog.showLoading(
                              msg: "Updated Survey...");
                          bool result = false;
                          await surveyController
                              .updateInformasiSurvey(draftID, data)
                              .then((value) => result = value);
                          SmartDialog.dismiss();
                          if (result == true) {
                            Survey temp = await surveyController
                                .getInformasiDraftSurvey(surveyID.value);
                            setState(() {
                              itemSurvey(temp);
                            });
                            GFToast.showToast(
                                'Updated Successfully!',
                                context,
                                trailing: const Icon(
                                  Icons.check_circle_outline,
                                  color: GFColors.SUCCESS,
                                ),
                                toastPosition: GFToastPosition.TOP,
                                toastBorderRadius: 5.0);
                            return;
                          } else {
                            GFToast.showToast(
                                'Failed to Update!', context,
                                trailing: const Icon(
                                  Icons.error_outline,
                                  color: GFColors.WARNING,
                                ),
                                toastPosition: GFToastPosition.BOTTOM,
                                toastBorderRadius: 5.0);
                          }
                        },
                        blockButton: true,
                        icon: Icon(
                          Icons.save_outlined,
                          size: 16,
                          color: GFColors.WHITE,
                        ),
                        color: CupertinoColors.activeGreen,
                        text: "Update",
                      ),
                      SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ));
  }

  showModalSelectTypeQuestion(String tipe) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (_context) => Padding(
              padding: EdgeInsets.only(
                  top: 15,
                  right: 20,
                  left: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 30),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 10.0),
                    Text(
                      "Add New Question",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("Please Select Question Type"),
                    SizedBox(height: 10.0),
                    GFButton(
                        color: GFColors.FOCUS,
                        type: GFButtonType.outline,
                        text: "Short Answer",
                        blockButton: true,
                        icon: Icon(
                          Icons.align_horizontal_left,
                          size: 15,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          QuestionSurvey questionItem =
                              QuestionSurvey(questionType: "1");
                          showFormQuestion("init", questionItem);
                        }),
                    GFButton(
                        color: GFColors.FOCUS,
                        type: GFButtonType.outline,
                        text: "Paragraf",
                        icon: Icon(
                          Icons.format_align_left_outlined,
                          size: 15,
                        ),
                        blockButton: true,
                        onPressed: () {
                          Navigator.pop(context);
                          QuestionSurvey questionItem =
                              QuestionSurvey(questionType: "2");
                          showFormQuestion("init", questionItem);
                        }),
                    GFButton(
                        color: GFColors.FOCUS,
                        type: GFButtonType.outline,
                        text: "Check Box",
                        icon: Icon(
                          Icons.check_box_outlined,
                          size: 15,
                        ),
                        blockButton: true,
                        onPressed: () {
                          Navigator.pop(context);
                          QuestionSurvey questionItem =
                              QuestionSurvey(questionType: "3");
                          showFormQuestion("init", questionItem);
                        }),
                    GFButton(
                        color: GFColors.FOCUS,
                        type: GFButtonType.outline,
                        text: "Radio (Multiple Choice)",
                        icon: Icon(
                          Icons.radio_button_checked,
                          size: 15,
                        ),
                        blockButton: true,
                        onPressed: () {
                          Navigator.pop(context);
                          QuestionSurvey questionItem =
                              QuestionSurvey(questionType: "4");
                          showFormQuestion("init", questionItem);
                        }),
                    GFButton(
                        color: GFColors.FOCUS,
                        type: GFButtonType.outline,
                        text: "Dropdown (Choice)",
                        icon: Icon(
                          Icons.arrow_drop_down_circle_outlined,
                          size: 15,
                        ),
                        blockButton: true,
                        onPressed: () {
                          Navigator.pop(context);
                          QuestionSurvey questionItem =
                              QuestionSurvey(questionType: "5");
                          showFormQuestion("init", questionItem);
                        }),
                    GFButton(
                        color: GFColors.FOCUS,
                        type: GFButtonType.outline,
                        text: "Range (Linear Scale)",
                        icon: Icon(
                          Icons.linear_scale,
                          size: 15,
                        ),
                        blockButton: true,
                        onPressed: () {
                          Navigator.pop(context);
                          QuestionSurvey questionItem =
                              QuestionSurvey(questionType: "6");
                          showFormQuestion("init", questionItem);
                        }),
                    GFButton(
                        color: GFColors.FOCUS,
                        type: GFButtonType.outline,
                        text: "Likert Scale",
                        icon: Icon(
                          Icons.grid_3x3_outlined,
                          size: 15,
                        ),
                        blockButton: true,
                        onPressed: () {
                          Navigator.pop(context);
                          QuestionSurvey questionItem =
                              QuestionSurvey(questionType: "7");
                          showFormQuestion("init", questionItem);
                        }),
                    GFButton(
                        color: GFColors.FOCUS,
                        type: GFButtonType.outline,
                        text: "Rating",
                        icon: Icon(
                          CupertinoIcons.star,
                          size: 15,
                        ),
                        blockButton: true,
                        onPressed: () {
                          Navigator.pop(context);
                          QuestionSurvey questionItem =
                              QuestionSurvey(questionType: "10");
                          showFormQuestion("init", questionItem);
                        }),
                    GFButton(
                        color: GFColors.FOCUS,
                        type: GFButtonType.outline,
                        text: "Date",
                        icon: Icon(
                          Icons.date_range,
                          size: 15,
                        ),
                        blockButton: true,
                        onPressed: () {
                          Navigator.pop(context);
                          QuestionSurvey questionItem =
                              QuestionSurvey(questionType: "8");
                          showFormQuestion("init", questionItem);
                        }),
                    GFButton(
                        color: GFColors.FOCUS,
                        type: GFButtonType.outline,
                        text: "Time (Hours)",
                        icon: Icon(
                          CupertinoIcons.clock,
                          size: 15,
                        ),
                        blockButton: true,
                        onPressed: () {
                          Navigator.pop(context);
                          QuestionSurvey questionItem =
                              QuestionSurvey(questionType: "9");
                          showFormQuestion("init", questionItem);
                        }),
                  ],
                ),
              ),
            ));
  }

  void showFormQuestion(String s, QuestionSurvey itemQuestion) async {
    if (s == "init") {
      String questionDraftID = surveyController.InsertIDQuestionDraft.value;
      var data = {
        "init": null,
        "question_id": "0",
        "question_text": "",
        "question_type": itemQuestion.questionType,
        "description": null,
        "is_required": false,
        "options": [],
        "is_other_option": false,
        "sub_questions": [],
        "question_draftid": questionDraftID
      };
      itemQuestion = QuestionSurvey.fromMap(data);
    }

    String tipe = "statis";
    if (tabQuestion.value == 0) {
      tipe = "statis";
    } else {
      tipe = "dinamis";
    }

    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        constraints: BoxConstraints(maxHeight: Get.height * 0.85),
        builder: (_context) => Padding(
              padding: EdgeInsets.only(
                  top: 20,
                  right: 20,
                  left: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 30),
              child: Container(
                child: FormQuestionSurvey(
                    itemQuestion: itemQuestion,
                    dinamis: tipe == "dinamis" ? true : false,
                    itemSurvey: itemSurvey.value,
                    action: s),
              ),
            ));
  }
}
