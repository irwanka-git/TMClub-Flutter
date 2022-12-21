// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, unrelated_type_equality_checks

import 'dart:convert';
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

class KelolaSurveyJawabScreen extends StatefulWidget {
  @override
  State<KelolaSurveyJawabScreen> createState() =>
      _KelolaSurveyJawabScreenState();
}

class _KelolaSurveyJawabScreenState extends State<KelolaSurveyJawabScreen>
    with SingleTickerProviderStateMixin {
  final authController = AuthController.to;
  final surveyController = SurveyController.to;
  final formKey = new GlobalKey<FormState>();
  late Survey itemSurvey;
  // ignore: non_constant_identifier_names
  final ListQuestions = <QuestionSurvey>[].obs;
  final ListQuestionPlay = <QuestionSurvey>[].obs;
  final ListFormAnswer = <dynamic>[].obs;
  final ListQuestionVisible = <String>[].obs;
  final isInitStateLoading = true.obs;
  @override
  void initState() {
    setState(() {
      isInitStateLoading(true);
    });
    itemSurvey = Get.arguments['survey'];
    //id_event = Get.arguments['survey'];
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      initStatedata();
      setState(() {
        isInitStateLoading(false);
      });
    });
  }

  void initStatedata() async {
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
                "${itemSurvey.title}",
                textScaleFactor: 1.1,
              )
            ],
          ),
          backgroundColor: GFColors.SUCCESS,
          elevation: 1,
        ),
        backgroundColor: Color.fromARGB(255, 243, 243, 244),
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
                delegate: isInitStateLoading.value == false
                    ? BuilderCardQuestion(
                        surveyController.ListQuestionIDVisible)
                    : BuilderListSkeletonCard(),
              ),
            )),
        Obx(() => Container(
              child: SliverList(
                delegate: isInitStateLoading.value == false
                    ? BuilderCardSubmitJawabanSurvey()
                    : BuilderEmptyCard(),
              ),
            )),
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
            if (surveyController.ListQuestionIDAlert.contains(
                question.questionID)) {
              alertRequired = true;
            }
            return Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: GFBorder(
                  color: alertRequired == false
                      ? GFColors.WHITE
                      : Color.fromARGB(255, 247, 80, 80),
                  padding: EdgeInsets.all(0),
                  type: GFBorderType.rRect,
                  dashedLine: alertRequired == false ? [1, 0] : [3, 0],
                  strokeWidth: alertRequired == false ? 1 : 2,
                  radius: Radius.circular(4),
                  child: GFCard(
                    elevation: 1,
                    color: GFColors.WHITE,
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
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
                child: Container(
                  decoration: BoxDecoration(color: GFColors.SUCCESS),
                  height: 15,
                ),
              ),
              Container(
                width: Get.width,
                decoration: BoxDecoration(
                  color: GFColors.WHITE,
                ),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      items.title!,
                      textScaleFactor: 1.2,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: GFColors.DARK),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Text(
                      "${items.description!}",
                      textScaleFactor: 1.1,
                      style: TextStyle(color: GFColors.DARK),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    RichText(
                      text: TextSpan(
                        // Note: Styles for TextSpans must be explicitly defined.
                        // Child text spans will inherit styles from parent
                        style: TextStyle(
                          fontSize: 12.0,
                          color: GFColors.DARK,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: '* ', style: TextStyle(color: Colors.red)),
                          TextSpan(text: 'Required'),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
                child: Container(
                  decoration: BoxDecoration(
                    color: GFColors.WHITE,
                    boxShadow: const [
                      BoxShadow(
                        color: GFColors.LIGHT,
                        offset: Offset(
                          5.0,
                          5.0,
                        ),
                        blurRadius: 10.0,
                        spreadRadius: 2.0,
                      ), //BoxShadow
                      BoxShadow(
                        color: Colors.white,
                        offset: Offset(0.0, 0.0),
                        blurRadius: 0.0,
                        spreadRadius: 0.0,
                      ), //BoxShadow
                    ],
                  ),
                  height: 10,
                ),
              ),
            ],
          ),
        );
      },
      childCount: 1,
    );
  }

  SliverChildBuilderDelegate BuilderCardSubmitJawabanSurvey() {
    return SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return Container(
            margin: EdgeInsets.only(top: 15),
            child: GFCard(
              color: GFColors.WHITE,
              margin: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 20),
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
              content: Container(
                child: GFButton(
                  onPressed: () async {
                    Get.defaultDialog(
                        contentPadding: const EdgeInsets.all(20),
                        title: "Confirmation",
                        titlePadding: const EdgeInsets.only(top: 10, bottom: 0),
                        middleText: "Are you sure you want to send answers to the survey?",
                        backgroundColor: CupertinoColors.white,
                        titleStyle:
                            const TextStyle(color: GFColors.DARK, fontSize: 16),
                        middleTextStyle:
                            const TextStyle(color: GFColors.DARK, fontSize: 14),
                        textCancel: "Cancel",
                        textConfirm: "Yes, Sure",
                        cancelTextColor: GFColors.SUCCESS,
                        confirmTextColor: Colors.white,
                        buttonColor: GFColors.SUCCESS,
                        onConfirm: () async {
                          setState(() {
                            isInitStateLoading(true);
                          });
                          Navigator.pop(Get.overlayContext!);
                          SmartDialog.showLoading(
                              msg: "Checking...", backDismiss: false);
                          bool validForm = false;
                          await surveyController.cekValidasiJawaban().then(
                              (value) => {validForm = value, print(value)});
                          if (validForm == false) {
                            //belum LENGKAP
                            GFToast.showToast(
                                'Your answer is not complete, please double check your answer!',
                                context,
                                trailing: const Icon(
                                  Icons.error_outline,
                                  color: GFColors.WARNING,
                                ),
                                toastDuration: 5,
                                toastPosition: GFToastPosition.TOP,
                                toastBorderRadius: 5.0);
                          } else {
                            //LENGKAP
                            var dataAnswer = {
                              "responses":
                                  surveyController.getConvertAnswerData()
                            };
                            //print(jsonEncode(dataAnswer));
                            //Navigator.pop(Get.overlayContext!);
                            SmartDialog.showLoading(
                                msg: "Submit Answer...", backDismiss: false);
                            bool result = false;
                            if (surveyController.isSurveyByEvent == false) {
                              await surveyController
                                  .submitJawabanSurvey(
                                      itemSurvey.id!, dataAnswer)
                                  .then((value) => result = value);
                            } else {
                              await surveyController
                                  .submitJawabanSurveyEvent(itemSurvey.id!,
                                      surveyController.idEventSurvey.value)
                                  .then((value) => result = value);
                            }

                            if (result == true) {
                              GFToast.showToast(
                                  'Thank you, your response was sent successfully!',
                                  context,
                                  trailing: const Icon(
                                    Icons.check_circle,
                                    color: GFColors.SUCCESS,
                                  ),
                                  toastDuration: 5,
                                  toastPosition: GFToastPosition.TOP,
                                  toastBorderRadius: 5.0);
                              Get.back();
                            } else {
                              GFToast.showToast(
                                  'An error occurred failed to send an answer!',
                                  context,
                                  trailing: const Icon(
                                    Icons.error_outline,
                                    color: GFColors.WARNING,
                                  ),
                                  toastDuration: 5,
                                  toastPosition: GFToastPosition.TOP,
                                  toastBorderRadius: 5.0);
                            }
                            SmartDialog.dismiss();
                          }
                          SmartDialog.dismiss();
                          setState(() {
                            isInitStateLoading(false);
                          });
                        },
                        radius: 0);
                  },
                  blockButton: true,
                  color: GFColors.SUCCESS,
                  icon: Icon(
                    CupertinoIcons.paperplane,
                    size: 16,
                    color: GFColors.WHITE,
                  ),
                  text: "Submit Answer",
                ),
              ),
            ));
      },
      childCount: 1,
    );
  }
}
