// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

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
import 'package:tmcapp/widget/form-answer-question.dart';
import 'package:tmcapp/widget/form-preview-question.dart';
import 'package:tmcapp/widget/form-response-question.dart';
import 'package:tmcapp/widget/form_question.dart';
import 'package:tmcapp/widget/speed_dial.dart';

class KelolaSurveyPreviewScreen extends StatefulWidget {
  @override
  State<KelolaSurveyPreviewScreen> createState() =>
      _KelolaSurveyPreviewScreenState();
}

class _KelolaSurveyPreviewScreenState extends State<KelolaSurveyPreviewScreen>
    with SingleTickerProviderStateMixin {
  final authController = AuthController.to;
  final surveyController = SurveyController.to;
  final formKey = new GlobalKey<FormState>();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  late Survey itemSurvey;
  // ignore: non_constant_identifier_names
  final ListQuestions = <QuestionSurvey>[].obs;
  final ListQuestionPlay = <QuestionSurvey>[].obs;
  final ListFormAnswer = <dynamic>[].obs;
  final ListQuestionVisible = <String>[].obs;
  final isInitStateLoading = true.obs;
  @override
  void initState() {
    itemSurvey = Get.arguments['survey'];
    ListQuestionPlay.clear();
    if (itemSurvey.questions != null) {
      int urutan = 1;
      // ListQuestionVisible.clear();
      surveyController.clearQuestionVisible();
      surveyController.clearQuestionPlaying();

      isInitStateLoading(true);
      for (var item in itemSurvey.questions!) {
        //ListQuestions.value.add(item);
        surveyController.addQuestionPlaying(item);
        ListQuestionPlay.add(item);
        var mapForm = {
          "questionID": item.questionID,
          "form": FormAnswerQuestionSurvey(key: UniqueKey(), itemQuestion: item)
        };
        setState(() {
          ListFormAnswer.add(mapForm);
        });
        if (item.init == null) {
          surveyController.addQuestionVisible(item.questionID!);
        }
      }
    }
    setState(() {
      isInitStateLoading(true);
    });
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      setState(() {
        isInitStateLoading(false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Preview",
                textScaleFactor: 0.9,
              ),
              Text(
                "${itemSurvey.title}",
                textScaleFactor: 0.85,
              )
            ],
          ),
          backgroundColor: AppController.to.appBarColor.value,
          elevation: 1,
        ),
        backgroundColor: Color.fromARGB(255, 244, 244, 244),
        body: buildBodyPage());
  }

  Widget buildBodyPage() {
    return CustomScrollView(
      slivers: [
        itemSurvey != null
            ? Container(
                child: SliverList(
                  delegate: BuilderCardInfoSurvey(itemSurvey),
                ),
              )
            : SliverPinnedToBoxAdapter(),
        Obx(() => Container(
              child: SliverList(
                delegate: surveyController.isLoading.value == false
                    ? BuilderCardQuestion(
                        surveyController.ListQuestionIDVisible)
                    : BuilderListSkeletonCard(),
              ),
            ))
      ],
    );
  }

  SliverChildBuilderDelegate BuilderEmptyCard() {
    return SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return Container();
      },
      childCount: 0,
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
                    height: 100,
                    borderRadius: BorderRadius.circular(5),
                  )),
            ));
      },
      childCount: 5,
    );
  }

  SliverChildBuilderDelegate BuilderCardQuestion(List<String> items) {
    if (items != null) {
      int urutan = 0;
      return SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          QuestionSurvey? question = ListQuestionPlay.firstWhereOrNull(
              (element) => element.questionID == items[index]);
          if (question != null) {
            urutan = surveyController.ListQuestionIDVisible.indexOf(
                    question.questionID) +
                1;
            var form = ListFormAnswer.firstWhereOrNull(
                (element) => element['questionID'] == question.questionID);
            bool alertRequired = false;

            return Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: GFBorder(
                  color: alertRequired == false
                      ? GFColors.LIGHT
                      : Color.fromARGB(255, 247, 80, 80),
                  padding: EdgeInsets.all(0),
                  type: GFBorderType.rRect,
                  dashedLine: alertRequired == false ? [1, 0] : [3, 0],
                  strokeWidth: alertRequired == false ? 1 : 2,
                  radius: Radius.circular(4),
                  child: GFCard(
                    elevation: 1,
                    color: alertRequired == false
                        ? GFColors.WHITE
                        : Color.fromARGB(255, 247, 225, 225),
                    margin: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                    title: GFListTile(
                      margin: EdgeInsets.all(0),
                      padding: EdgeInsets.only(top: 10),
                      avatar: null,
                      title: RichText(
                        text: TextSpan(
                          // Note: Styles for TextSpans must be explicitly defined.
                          // Child text spans will inherit styles from parent
                          style: TextStyle(
                            fontSize: 14.0,
                            color: GFColors.DARK,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                                text:
                                    '${(urutan).toString()}. ${question.questionText!}'),
                            TextSpan(
                                text:
                                    '${question.isRequired == true ? " *" : ""}',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ),
                    content: Container(child: form['form']),
                  ),
                ));
          } else {
            return Container();
          }
        },
        childCount: items.length,
      );
    }
    return SliverChildBuilderDelegate((BuildContext context, int index) {});
  }

  SliverChildBuilderDelegate BuilderCardInfoSurvey(Survey items) {
    return SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return Container(
            margin: EdgeInsets.only(top: 15, bottom: 5),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: GFBorder(
                color: GFColors.LIGHT,
                padding: EdgeInsets.all(0),
                type: GFBorderType.rRect,
                dashedLine: [1, 0],
                strokeWidth: 2,
                radius: Radius.circular(4),
                child: GFCard(
                  color: GFColors.WHITE,
                  margin: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                  title: GFListTile(
                    margin: EdgeInsets.all(0),
                    padding: EdgeInsets.only(top: 5, left: 5),
                    title: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(
                        items.title!,
                        textScaleFactor: 1.1,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    subTitle: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(
                        "${items.description!}",
                        textScaleFactor: 1,
                        style: TextStyle(
                            color: CupertinoColors.darkBackgroundGray),
                      ),
                    ),
                    icon: Container(
                        child: itemSurvey.isDraft == false &&
                                authController.user.value.role == "admin"
                            ? buildActionSurvey(context)
                            : Container()),
                    description: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 4),
                      child: RichText(
                        text: TextSpan(
                          // Note: Styles for TextSpans must be explicitly defined.
                          // Child text spans will inherit styles from parent
                          style: TextStyle(
                            fontSize: 12.0,
                            color: GFColors.DARK,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                                text: '* ',
                                style: TextStyle(color: Colors.red)),
                            TextSpan(text: 'Required'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // ignore: unnecessary_new, invalid_use_of_protected_member
                  content: Container(),
                )));
      },
      childCount: 1,
    );
  }

  Container buildActionSurvey(BuildContext context) {
    return Container(
        child: PopupMenuButton(
      onSelected: (_valueAction) async {
        // your logic
        if (_valueAction == '/salin') {
          print("SALIN SURVEY");
          salinFormSurvey();
        }
        if (_valueAction == '/delete') {
          //showFormQuestion("edit", item);
          print("HAPUS SURVEY");
          deleteFormSurvey();
        }
        if (_valueAction == '/isi-survey') {
          //showFormQuestion("edit", item);
          print("ISI SURVEY");
          surveyController.generatePreviewFormSurvey(itemSurvey, true);
        }

        if (_valueAction == '/send-survey') {
          //showFormQuestion("edit", item);
          print("ISI SURVEY");
          Get.toNamed("/kelola-survey-send", arguments: {'item':itemSurvey});
        }

        if (_valueAction == '/hasil-survey') {
          //showFormQuestion("edit", item);
          print("HASUIL SURVEY");
          await SurveyController.to
              .getResultSurveyByID(itemSurvey.id!)
              .then((response) {
            //print(response);
            if (response != null) {
              Get.toNamed('/event-result-survey',
                  arguments: {'response': response,'id_event':0});
            }
            SmartDialog.dismiss();
          });
        }
      },
      itemBuilder: (BuildContext bc) {
        return [
          PopupMenuItem(
            child: GFListTile(
              avatar: Icon(
                Icons.copy,
                size: 15,
              ),
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
              title: Text(
                "Copy",
                textScaleFactor: 1,
              ),
            ),
            value: '/salin',
          ),
          PopupMenuItem(
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
            child: GFListTile(
              avatar: Icon(
                Icons.edit,
                size: 15,
              ),
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
              title: Text(
                "Fill Survey",
                textScaleFactor: 1,
              ),
            ),
            value: '/isi-survey',
          ),
          PopupMenuItem(
            child: GFListTile(
              avatar: Icon(
                Icons.pie_chart_rounded,
                size: 15,
              ),
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
              title: Text(
                "Result",
                textScaleFactor: 1,
              ),
            ),
            value: '/hasil-survey',
          ),
          PopupMenuItem(
            child: GFListTile(
              avatar: Icon(
                Icons.send,
                size: 15,
              ),
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
              title: Text(
                "Send Survey",
                textScaleFactor: 1,
              ),
            ),
            value: '/send-survey',
          ),
        ];
      },
    ));
  }

  void salinFormSurvey() {
    final _titleController = TextEditingController();
    final _deskrispiController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    _titleController.text = itemSurvey.title!;
    _deskrispiController.text = itemSurvey.description!;

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
                      Text("Please Complete the Survey Form Information"),
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
                              labelText: "Nama Survey",
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
                              labelText: "Deskripsi",
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
                          Navigator.pop(context);
                          SmartDialog.showLoading(
                              msg: "Copy Survey Questions...");
                          String draftID =
                              "${DateTime.now().millisecondsSinceEpoch}${surveyController.generateRandomString(10)}";
                          var dataSurvey = {
                            "id": 0,
                            "title": _titleController.text,
                            "description": _deskrispiController.text,
                            "draft": true,
                            "draftID": draftID,
                            "createBy": authController.user.value.uid
                          };
                          bool result = false;
                          await surveyController
                              .generateInitSurvey(draftID, dataSurvey)
                              .then((value) => result = value);
                          if (result == true) {
                            bool resultQuestion = false;
                            List<QuestionSurvey> questions =
                                itemSurvey.questions!;
                            for (var itemQuestion in questions) {
                              String questionDraftID = DateTime.now()
                                  .microsecondsSinceEpoch
                                  .toString();
                              var dataQuestion = {
                                "init": itemQuestion.init,
                                "question_id": "0",
                                "question_text": itemQuestion.questionText,
                                "question_type": itemQuestion.questionType,
                                "description": null,
                                "is_required": itemQuestion.isRequired,
                                "options": itemQuestion.options,
                                "is_other_option": itemQuestion.isOtherOption,
                                "sub_questions": itemQuestion.subQuestions,
                                "question_draftid": questionDraftID
                              };
                              await SurveyController.to
                                  .submitQuestionSurveyFirebase(
                                      draftID, questionDraftID, dataQuestion)
                                  .then((value) => resultQuestion = value);
                            }
                            if (resultQuestion == true) {
                              SmartDialog.dismiss();
                              await surveyController.getListSurvey();
                              Get.offNamed('/kelola-survey-draft', arguments: {
                                "surveyID": draftID,
                                "isDraft": true,
                                "itemSurvey": Survey.fromMap(dataSurvey)
                              });
                            }
                          }
                        },
                        blockButton: true,
                        icon: Icon(
                          CupertinoIcons.plus_app,
                          size: 16,
                          color: GFColors.WHITE,
                        ),
                        color: CupertinoColors.activeGreen,
                        text: "Copy Survey",
                      ),
                      SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ));
  }

  void deleteFormSurvey() {
    Get.defaultDialog(
        contentPadding: const EdgeInsets.all(20),
        title: "Confirmation",
        titlePadding: const EdgeInsets.only(top: 10, bottom: 0),
        middleText: "Are you sure you want to delete this survey?",
        backgroundColor: CupertinoColors.white,
        titleStyle: const TextStyle(color: GFColors.DARK, fontSize: 16),
        middleTextStyle: const TextStyle(color: GFColors.DARK, fontSize: 14),
        textCancel: "Cancel",
        textConfirm: "Yes, Sure",
        cancelTextColor: GFColors.DANGER,
        confirmTextColor: Colors.white,
        buttonColor: GFColors.DANGER,
        onConfirm: () async {
          SmartDialog.showLoading(msg: "Delete Survey..");
          bool result = false;
          Navigator.pop(Get.overlayContext!);
          await surveyController
              .submitDeleteSurveyServer(itemSurvey.id!)
              .then((value) => result = value);
          SmartDialog.dismiss();
          if (result == true) {
            GFToast.showToast('Deleted Successfully!', context,
                trailing: const Icon(
                  Icons.check_circle_outline,
                  color: GFColors.SUCCESS,
                ),
                toastPosition: GFToastPosition.TOP,
                toastBorderRadius: 5.0);
            await surveyController.getListSurvey();
            Navigator.pop(Get.context!);
          }
        },
        radius: 0);
  }
}
