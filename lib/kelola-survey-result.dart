// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, unrelated_type_equality_checks

import 'dart:convert';
import 'dart:math';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';
import 'package:tmcapp/controller/AppController.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/controller/SurveyController.dart';
import 'package:tmcapp/model/question_survey.dart';
import 'package:tmcapp/model/survey.dart';
import 'package:tmcapp/widget/form-answer-question.dart';
import 'dart:developer' as developer;

class KelolaSurveyResultScreen extends StatefulWidget {
  @override
  State<KelolaSurveyResultScreen> createState() =>
      _KelolaSurveyResultScreenState();
}

class _KelolaSurveyResultScreenState extends State<KelolaSurveyResultScreen>
    with SingleTickerProviderStateMixin {
  final authController = AuthController.to;
  final surveyController = SurveyController.to;
  dynamic response = {}.obs;
  final id_event_ref = 0.obs;
  final isInitStateLoading = true.obs;
  final List<dynamic> questions = [].obs;

  @override
  void initState() {
    response(Get.arguments['response']);
    id_event_ref(Get.arguments['id_event']);
    developer.log(jsonEncode(response));
    if (response != null) {
      //int no = 1;
      for (var item in response['questions']) {
        var tempResponse = {
          "question_text": item['question_text'],
          "question_type": item['question_type'],
          "options": item['options'],
          "is_other_option": item['is_other_option'],
          "sub_questions": item['sub_questions'],
          "responses": item['responses'],
        };
        questions.add(tempResponse);
      }
    }
    //id_event = Get.arguments['survey'];
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
              Obx(() => Text(
                    isInitStateLoading == true
                        ? "Loading.."
                        : "${response['title']}",
                    textScaleFactor: 1.1,
                  ))
            ],
          ),
          backgroundColor: GFColors.SUCCESS,
          elevation: 1,
          actions: [
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () async {
                    print(response['id']);
                    print("Export Excel Survey");
                     surveyController.downloadExcelHasilSurvey(response['id'], response['title'], id_event_ref.value);
                  },
                  child: Icon(Icons.download_for_offline),
                )),
          ],
        ),
        backgroundColor: Color.fromARGB(255, 243, 243, 244),
        body: Obx(() => Container(
              child: isInitStateLoading == true ? Container() : buildBodyPage(),
            )));
  }

  Widget buildBodyPage() {
    var itemSurvey = Survey(
        id: response['id'],
        title: response['title'],
        description: response['description']);
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
                    ? BuilderCardQuestion(questions)
                    : BuilderListSkeletonCard(),
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

  SliverChildBuilderDelegate BuilderCardQuestion(List<dynamic> questionItem) {
    if (questionItem != null) {
      int urutan = 0;
      return SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return GFCard(
            elevation: 1,
            color: GFColors.WHITE,
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            title: GFListTile(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
              title: Container(
                margin: EdgeInsets.only(bottom: 5),
                child: Text("Pertanyaan Ke ${index + 1}"),
              ),
              subTitle: Text(
                questionItem[index]['question_text'],
                textScaleFactor: 1.2,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            content: Container(
              width: Get.width,
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
              child: generateViewResponse(questionItem[index]),
            ),
          );
        },
        childCount: questionItem.length,
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
                      "R E S U L T",
                      textScaleFactor: 1,
                      style: TextStyle(
                          fontWeight: FontWeight.w400, color: GFColors.DARK),
                    ),
                    SizedBox(
                      height: 5,
                    ),
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

  Widget generateViewResponse(dynamic questionItem) {
    if (questionItem['question_type'] == "1" ||
        questionItem['question_type'] == "2" ||
        questionItem['question_type'] == "3" ||
        questionItem['question_type'] == "8" ||
        questionItem['question_type'] == "9") {
      return BuildViewAnswerList(questionItem);
    }

    //radio, optional
    if (questionItem['question_type'] == "4" ||
        questionItem['question_type'] == "5" ||
        questionItem['question_type'] == "6") {
      return BuildViewAnswerOption(questionItem, "Jawaban Responden:");
    }

    //rating
    if (questionItem['question_type'] == "10") {
      return BuildViewAnswerRating(questionItem);
    }

    //likert
    if (questionItem['question_type'] == "7") {
      return BuildViewAnswerLikers(questionItem);
    }
    return Container();
  }

  Widget BuildViewAnswerOption(dynamic questionItem, String awal) {
    Map<String, double> dataMap = {};
    double countLainnya = 0;
    List<String> opsi = [];
    dynamic opsiCounter = {};
    for (var item in questionItem['options']) {
      opsi.add(item.toString());
      opsiCounter[item.toString()] = 0;
    }
    if (questionItem['is_other_option'] == true) {
      opsi.add("Lainnya");
      opsiCounter["Lainnya"] = 0;
    }

    for (var keyRespon in questionItem['responses'].keys) {
      double tempCount = double.parse(questionItem['responses']
              [keyRespon.toString()][0]['count']
          .toString());
      if (opsi.contains(keyRespon.toString())) {
        //var x = <String, double>{keyRespon.toString(): tempCount};
        opsiCounter[keyRespon.toString()] = tempCount;
      } else {
        countLainnya += tempCount;
      }
    }
    if (questionItem['is_other_option'] == true) {
      opsiCounter["Lainnya"] = countLainnya;
    }
    print(opsiCounter);
    for (var itemCounter in opsiCounter.keys) {
      var count = double.parse(opsiCounter[itemCounter.toString()].toString());
      var x = <String, double>{
        "${itemCounter.toString()} (${count.round()})": count
      };
      dataMap.addEntries(x.entries);
    }

    List<Widget> columns = [];
    columns.add(Text(
      "${awal}: ",
      textScaleFactor: 1.1,
    ));
    columns.add(SizedBox(
      height: 10,
    ));
    Widget pie = PieChart(
      dataMap: dataMap,
      chartLegendSpacing: 20,
      chartRadius: 180,
      legendOptions: LegendOptions(
        legendPosition: questionItem['question_type'] != "4"
            ? LegendPosition.right
            : LegendPosition.bottom,
        legendTextStyle:
            const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
      ),
      chartValuesOptions: ChartValuesOptions(
          decimalPlaces: 1,
          showChartValuesInPercentage: true,
          chartValueBackgroundColor: GFColors.WHITE,
          chartValueStyle: TextStyle(fontSize: 10, color: GFColors.DARK)),
    );
    columns.add(pie);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columns,
    );
  }

  Widget BuildViewAnswerRating(dynamic questionItem) {
    List<Widget> columns = [];
    columns.add(Text(
      "Jawaban responden: ",
      textScaleFactor: 1.1,
    ));
    columns.add(SizedBox(
      height: 8,
    ));
    var bintangs = [1, 2, 3, 4, 5];
    List<double> persenBintang = [];
    List<int> countBintang = [];
    persenBintang.add(0.0);
    countBintang.add(0);
    for (var itemBintang in bintangs) {
      persenBintang.add(0.0);
      countBintang.add(0);
    }

    //int no_response = 1;
    for (var itemRespon in questionItem['responses'].keys) {
      //print("ITEM RESPONS ${itemRespon}");
      var count = questionItem['responses'][itemRespon.toString()][0]['count'];
      var persen = double.parse(questionItem['responses'][itemRespon.toString()]
              [0]['persentage']
          .toString());
      persenBintang[int.parse(itemRespon.toString())] = persen.toPrecision(1);
      countBintang[int.parse(itemRespon.toString())] =
          int.parse(count.toString());
    }

    for (var itemBintang in bintangs) {
      columns.add(GFListTile(
        color: Color.fromARGB(255, 244, 244, 244),
        avatar: Container(),
        margin: EdgeInsets.zero,
        padding: EdgeInsets.only(top: 5, bottom: 5, right: 5),
        description: GFRating(
          itemCount: 5,
          size: GFSize.SMALL,
          value: double.parse(itemBintang.toString()),
          color: GFColors.WARNING,
          borderColor: CupertinoColors.separator,
          onChanged: (double rating) {},
        ),
        icon: Text(
          "${persenBintang[itemBintang]}% (${countBintang[itemBintang]})",
          textScaleFactor: 0.96,
        ),
      ));
      columns.add(SizedBox(
        height: 4,
      ));
    }

    //print(questionItem['response'].length);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columns,
    );
  }

  Widget BuildViewAnswerList(questionItem) {
    List<Widget> columns = [];
    columns.add(Text(
      "Jawaban Responden: ",
      textScaleFactor: 1.1,
    ));
    columns.add(SizedBox(
      height: 8,
    ));
    int no_response = 1;
    for (var itemRespon in questionItem['responses'].keys) {
      var count = questionItem['responses'][itemRespon.toString()][0]['count'];
      var persen = double.parse(questionItem['responses'][itemRespon.toString()]
                  [0]['persentage']
              .toString())
          .toPrecision(1);

      columns.add(GFListTile(
        color: Color.fromARGB(255, 244, 244, 244),
        avatar: Container(),
        margin: EdgeInsets.zero,
        padding: EdgeInsets.only(top: 5, bottom: 5, right: 5),
        description: Text(
          "${no_response}. ${itemRespon}",
        ),
        icon: Text(
          "${persen}% (${count})",
          textScaleFactor: 0.96,
        ),
      ));
      columns.add(SizedBox(
        height: 4,
      ));
      no_response++;
    }

    //print(questionItem['response'].length);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columns,
    );
  }

  Widget BuildViewAnswerLikers(questionItem) {
    var sub_questions = questionItem['sub_questions'];
    List<Widget> columns = [];
    for (var item in sub_questions) {
      String indikator = item['question_text'].toString();

      var questionItemIndikator = {
        "question_text": indikator,
        "question_type": "6",
        "options": questionItem['options'],
        "is_other_option": false,
        "sub_questions": [],
        "responses": item['responses'],
      };
      columns.add(BuildViewAnswerOption(questionItemIndikator, "${indikator}"));
      columns.add(SizedBox(
        height: 20,
      ));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columns,
    );
  }
}
