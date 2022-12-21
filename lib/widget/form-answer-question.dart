// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:date_time_picker/date_time_picker.dart';
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
import 'package:tmcapp/controller/SurveyController.dart';
import 'package:tmcapp/model/answer_question.dart';
import 'package:tmcapp/model/list_id.dart';
import 'package:tmcapp/model/question_survey.dart';
import 'package:tmcapp/model/survey.dart';
import 'dart:developer' as developer;
import 'image_widget.dart';

class FormAnswerQuestionSurvey extends StatefulWidget {
  final QuestionSurvey? itemQuestion;
  FormAnswerQuestionSurvey({required Key key, required this.itemQuestion})
      : super(key: key);
  @override
  _FormAnswerQuestionSurveyState createState() =>
      _FormAnswerQuestionSurveyState();
}

class _FormAnswerQuestionSurveyState extends State<FormAnswerQuestionSurvey> {
  final responseTextController = TextEditingController();
  final selectedValue = "".obs;
  final checkboxValue = [].obs;
  final radioOtherValue = "".obs;
  final checkboxOtherValue = false.obs;
  final radioLikert = <String>[].obs;
  final questionID = "".obs;
  final itemQuestion = QuestionSurvey().obs;
  final isLoading = true.obs;
  final surveyController = SurveyController.to;

  @override
  void initState() {
    setState(() {
      isLoading(true);
      //question(itemQuestion);
      itemQuestion(widget.itemQuestion);
      questionID(itemQuestion.value.questionID);
      checkboxValue.clear();
      //selectedValue("");
      responseTextController.clear();
      radioLikert.clear();
      var answerQuestion =
          surveyController.getAnswerQuestion(itemQuestion.value.questionID!);

      if (itemQuestion.value.questionType == "1" ||
          itemQuestion.value.questionType == "2" ||
          itemQuestion.value.questionType == "8" ||
          itemQuestion.value.questionType == "9") {
        responseTextController.text = answerQuestion.answer![0];
      }

      if (itemQuestion.value.questionType == "5" ||
          itemQuestion.value.questionType == "6" ||
          itemQuestion.value.questionType == "10") {
        selectedValue(answerQuestion.answer![0]);
      }
      //kasus checkbox
      if (itemQuestion.value.questionType == "3") {
        int icek = 0;
        for (var answerCek in answerQuestion.answer!) {
          if (icek < itemQuestion.value.options!.length) {
            if (answerCek != "") {
              checkboxValue.add(true);
            } else {
              checkboxValue.add(false);
            }
          } else {
            if (answerCek != "") {
              checkboxOtherValue(true);
              responseTextController.text = answerCek;
            } else {
              checkboxOtherValue.value = true;
              responseTextController.text = "";
            }
          }
        }
      }
      //kasus radio only
      if (itemQuestion.value.questionType == "4") {
        String currentAnswer = answerQuestion.answer![0];
        selectedValue(currentAnswer);
        if (currentAnswer != "") {
          if (itemQuestion.value.isOtherOption == true) {
            if (itemQuestion.value.options!.indexWhere(
                    (element) => element['display_name'] == currentAnswer) ==
                -1) {
              radioOtherValue(currentAnswer);
              responseTextController.text = currentAnswer;
            }
          }
        }
      }

      //kasus skala likert
      if (itemQuestion.value.questionType == "7") {
        for (var answerCek in answerQuestion.answer!) {
          radioLikert.add(answerCek);
        }
      }
    });
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      setState(() {
        isLoading(false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //selectedValue("");
    return Obx(() => isLoading.value == false
        ? Container(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                itemQuestion.value.questionType == "0"
                    ? Container()
                    : Container(),
                itemQuestion.value.questionType == "1"
                    ? Container(
                        child: generateResponseJawabanSingkat(),
                      )
                    : Container(),
                itemQuestion.value.questionType == "2"
                    ? Container(
                        child: generateResponseJawabanParagraf(),
                      )
                    : Container(),
                itemQuestion.value.questionType == "3"
                    ? Container(
                        child: generateResponseJawabanCheckBox(),
                      )
                    : Container(),
                itemQuestion.value.questionType == "3" &&
                        itemQuestion.value.isOtherOption == true
                    ? GFChecboxOther()
                    : Container(),
                itemQuestion.value.questionType == "4"
                    ? Container(
                        child: generateResponseJawabanRadio(),
                      )
                    : Container(),
                itemQuestion.value.questionType == "4" &&
                        itemQuestion.value.isOtherOption == true
                    ? GFRadioOther()
                    : Container(),
                itemQuestion.value.questionType == "5"
                    ? Container(
                        child: generateResponseJawabanDropdown(
                            itemQuestion.value.isOtherOption!),
                      )
                    : Container(),
                itemQuestion.value.questionType == "6"
                    ? Container(
                        child: generateResponseJawabanSkalaLinier(),
                      )
                    : Container(),
                itemQuestion.value.questionType == "7"
                    ? Container(
                        child: generateResponseJawabanSkalaLikert(),
                      )
                    : Container(),
                itemQuestion.value.questionType == "8"
                    ? Container(
                        child: generateResponseJawabanDate(),
                      )
                    : Container(),
                itemQuestion.value.questionType == "9"
                    ? Container(
                        child: generateResponseJawabanTime(),
                      )
                    : Container(),
                itemQuestion.value.questionType == "10"
                    ? Container(
                        child: generateResponseJawabanRating(),
                      )
                    : Container(),
              ],
            ))
        : Container());
  }

  Widget generateResponseJawabanSingkat() {
    return Container(
        child: TextFormField(
      readOnly: false,
      onChanged: (val) {
        updateTextValue(val);
      },
      controller: responseTextController,
      style: const TextStyle(fontSize: 13, height: 2),
      decoration: const InputDecoration(
          fillColor: GFColors.DARK,
          contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          labelText: "Answer",
          hintText: "Answer..",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
          border: OutlineInputBorder()),
      autocorrect: false,
      validator: null,
    ));
  }

  Widget generateResponseJawabanParagraf() {
    return Container(
        child: TextFormField(
      readOnly: false,
      minLines: 3,
      maxLines: 8,
      onChanged: (val) {
        updateTextValue(val);
      },
      controller: responseTextController,
      style: const TextStyle(fontSize: 13, height: 2),
      decoration: const InputDecoration(
          fillColor: GFColors.DARK,
          contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          labelText: "Answer",
          hintText: "Answer..",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
          border: OutlineInputBorder()),
      autocorrect: false,
      validator: null,
    ));
  }

  Container GFChecboxOther() {
    return Container(
      child: Obx(() => GFCheckboxListTile(
            title: TextFormField(
              readOnly: false,
              controller: responseTextController,
              style: const TextStyle(fontSize: 13, height: 2),
              decoration: const InputDecoration(
                fillColor: GFColors.DARK,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                labelText: "Lainnya",
                hintText: "Lainnya..",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              autocorrect: false,
              validator: null,
            ),
            size: 18,
            activeBgColor: Colors.green,
            padding: EdgeInsets.all(0),
            margin: EdgeInsets.all(0),
            type: GFCheckboxType.square,
            activeIcon: Icon(
              Icons.check,
              size: 15,
              color: Colors.white,
            ),
            position: GFPosition.start,
            onChanged: (value) {
              checkboxOtherValue.value = value;
              updateCheckboxAnswerValue();
            },
            value: checkboxOtherValue.value,
            inactiveIcon: null,
          )),
    );
  }

  Widget generateResponseJawabanCheckBox() {
    return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(), //tambahkan ini
        separatorBuilder: (BuildContext context, int index) => const SizedBox(
              height: 8,
            ),
        itemCount: itemQuestion.value.options!.length,
        itemBuilder: (BuildContext context, int index) {
          int nomorPilihan = index + 1;
          return Obx(() => GFCheckboxListTile(
                title: Text(
                  itemQuestion.value.options![index]['display_name'],
                  style: TextStyle(fontSize: 14),
                ),
                size: 18,
                activeBgColor: Colors.green,
                padding: EdgeInsets.all(0),
                margin: EdgeInsets.all(0),
                type: GFCheckboxType.square,
                activeIcon: Icon(
                  Icons.check,
                  size: 15,
                  color: Colors.white,
                ),
                position: GFPosition.start,
                onChanged: (value) {
                  checkboxValue[index] = value;
                  //print(checkboxValue.value);
                  updateCheckboxAnswerValue();
                },
                value: checkboxValue[index],
                inactiveIcon: null,
              ));
        });
  }

  Container GFRadioOther() {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      child: Obx(() => GFRadioListTile(
            groupValue: selectedValue.value != "" ? selectedValue.value : null,
            title: TextFormField(
              readOnly: false,
              onFieldSubmitted: (val) {
                radioOtherValue.value = val;
                int cekExist = itemQuestion.value.options!
                    .indexWhere((element) => element['display_name'] == val);
                if (cekExist > -1) {
                  responseTextController.clear();
                  radioOtherValue.value = "";
                  selectedValue.value = "";
                }
              },
              controller: responseTextController,
              style: const TextStyle(fontSize: 13, height: 2),
              decoration: const InputDecoration(
                fillColor: GFColors.DARK,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                labelText: "Lainnya",
                hintText: "Lainnya..",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              autocorrect: false,
              validator: null,
            ),
            size: 20,
            activeBorderColor: GFColors.SUCCESS,
            padding: EdgeInsets.all(0),
            margin: EdgeInsets.all(0),
            type: GFRadioType.basic,
            radioColor: GFColors.SUCCESS,
            position: GFPosition.start,
            icon: null,
            onChanged: (value) {
              if (value != "") {
                selectedValue.value = value;
                updateSelectedValue();
              }
            },
            value: radioOtherValue.value,
            inactiveIcon: null,
          )),
    );
  }

  Widget generateResponseJawabanRadio() {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(), //tambahkan ini
          separatorBuilder: (BuildContext context, int index) => const SizedBox(
                height: 8,
              ),
          itemCount: itemQuestion.value.options!.length,
          itemBuilder: (BuildContext context, int index) {
            int nomorPilihan = index + 1;
            String label = itemQuestion.value.options![index]['display_name'];
            return Obx(() => GFRadioListTile(
                  key: UniqueKey(),
                  value: label,
                  groupValue: selectedValue.value,
                  title: Text(
                    label,
                    style: TextStyle(fontSize: 14),
                  ),
                  size: 20,
                  activeBorderColor: GFColors.SUCCESS,
                  padding: EdgeInsets.symmetric(vertical: 5),
                  margin: EdgeInsets.symmetric(vertical: 0),
                  type: GFRadioType.basic,
                  radioColor: GFColors.SUCCESS,
                  position: GFPosition.start,
                  icon: null,
                  onChanged: (value) {
                    selectedValue.value = value;
                    updateSelectedValue();
                    triggerVisibleDinamis();
                  },
                  inactiveIcon: null,
                ));
          }),
    );
  }

  Widget generateResponseJawabanDropdown(bool hasOther) {
    var stringItem = <String>[];
    for (var iter in itemQuestion.value.options!) {
      stringItem.add(iter['display_name']);
    }
    var items = stringItem
        .map((value) => DropdownMenuItem(
              value: value,
              child: Text(
                value,
                style: TextStyle(fontSize: 15),
              ),
            ))
        .toList();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() => GFDropdown(
            items: items,
            value: selectedValue.value != "" ? selectedValue.value : null,
            elevation: 2,
            isExpanded: true,
            hint: Text(
              "Select one..",
              style: TextStyle(fontSize: 14),
            ),
            onChanged: (newValue) {
              selectedValue.value = newValue.toString();
              updateSelectedValue();
            },
          )),
    );
  }

  Widget generateResponseJawabanSkalaLinier() {
    return Center(
      child: Container(
        height: 50,
        child: ListView.separated(
          separatorBuilder: (BuildContext context, int index) => const SizedBox(
            width: 20,
          ),
          physics: ClampingScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: itemQuestion.value.options!.length,
          itemBuilder: (BuildContext context, int index) => Container(
            height: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  itemQuestion.value.options![index]['display_name'],
                  textScaleFactor: 0.95,
                ),
                SizedBox(
                  height: 5,
                ),
                Obx(() => GFRadio(
                      size: 20,
                      activeBorderColor: GFColors.SUCCESS,
                      value: itemQuestion.value.options![index]['display_name']
                          .toString(),
                      groupValue: selectedValue.value,
                      onChanged: (val) {
                        selectedValue.value = val.toString();
                        updateSelectedValue();
                      },
                      inactiveIcon: null,
                      radioColor: GFColors.SUCCESS,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget generateResponseJawabanSkalaLikert() {
    var columns = <DataColumn>[];
    columns.add(DataColumn(
      label: Text(""),
    ));
    for (var item in itemQuestion.value.options!) {
      columns.add(DataColumn(
        numeric: true,
        label: Container(
          width: 30,
          child: RotatedBox(
            quarterTurns: 3,
            child: Container(
              width: 500,
              padding: EdgeInsets.only(left: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['display_name'],
                    textAlign: TextAlign.left,
                    textScaleFactor: 0.85,
                    maxLines: 2,
                    style: const TextStyle(fontWeight: FontWeight.w400),
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ));
    }
    var rows = <DataRow>[];
    int index = 0;
    for (var indikator in itemQuestion.value.subQuestions!) {
      int indexIndikator = itemQuestion.value.subQuestions!.indexWhere(
          ((element) =>
              element['question_text'] == indikator['question_text']));
      var cell = <DataCell>[];
      cell.add(DataCell(Text(
        "${indikator['question_text']}",
        textScaleFactor: 0.9,
      )));
      for (var option in itemQuestion.value.options!) {
        cell.add(DataCell(Container(
          child: Obx(() => GFRadio(
                size: 20,
                activeBorderColor: GFColors.SUCCESS,
                value: option['display_name'],
                groupValue: radioLikert[indexIndikator],
                onChanged: (val) {
                  radioLikert[indexIndikator] = val.toString();
                  updateSkalaLikertValue();
                },
                inactiveIcon: null,
                radioColor: GFColors.SUCCESS,
              )),
        )));
      }
      index++;
      rows.add(
        DataRow(
          cells: cell,
        ),
      );
    }
    return DataTable(
        headingRowHeight: 100,
        dataRowHeight: 50,
        columnSpacing: 5,
        horizontalMargin: 5,
        columns: columns,
        rows: rows);
  }

  Widget generateResponseJawabanDate() {
    return Container(
      child: DateTimePicker(
        readOnly: false,
        decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
            labelText: "Tanggal",
            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
            labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
            border: OutlineInputBorder()),
        type: DateTimePickerType.date,
        dateMask: 'd MMMM, yyyy',
        controller: null,
        initialValue: responseTextController.text,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        //icon: Icon(Icons.event),
        dateLabelText: 'Date',
        use24HourFormat: true,
        locale: const Locale('id', 'ID'),
        onChanged: (val) {
          updateTextValue(val);
        },
        validator: (val) {
          if (val == "") {
            return 'Required Filled!';
          }
          return null;
        },
      ),
    );
  }

  Widget generateResponseJawabanTime() {
    return Container(
        child: DateTimePicker(
      readOnly: false,
      decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
          labelText: "HH:MM",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
          border: OutlineInputBorder()),
      type: DateTimePickerType.time,
      dateMask: 'HH:MM',
      controller: null,
      initialValue: responseTextController.text,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      //icon: Icon(Icons.event),
      dateLabelText: 'Time',
      use24HourFormat: true,
      locale: const Locale('id', 'ID'),
      onChanged: (val) {
        updateTextValue(val);
      },
      validator: (val) {
        if (val == "") {
          return 'Required Filled!';
        }
        return null;
      },
    ));
  }

  Widget generateResponseJawabanRating() {
    return Container(
      child: Center(
          child: Obx(() => GFRating(
                itemCount: 5,
                value: selectedValue.value != ""
                    ? double.parse(selectedValue.value)
                    : 0,
                color: GFColors.WARNING,
                borderColor: CupertinoColors.separator,
                onChanged: (value) {
                  selectedValue.value = value.round().toString();
                  updateSelectedValue();
                },
              ))),
    );
  }

  void updateCheckboxAnswerValue() {
    int ceki = 0;
    List<String> tempAnswer = [];
    for (var options in itemQuestion.value.options!) {
      if (checkboxValue[ceki] == true) {
        tempAnswer.add(options['display_name']);
      } else {
        tempAnswer.add("");
      }
      ceki++;
    }
    if (itemQuestion.value.isOtherOption == true) {
      if (checkboxOtherValue.value == true) {
        tempAnswer.add(responseTextController.text);
      } else {
        tempAnswer.add("");
      }
    }
    surveyController.updateAnswerQuestion(questionID.value, tempAnswer);
    AnswerQuestion xx = surveyController.getAnswerQuestion(questionID.value);

    print(xx.id!);
    print(xx.answer!);
  }

  void updateSelectedValue() {
    SurveyController.to
        .updateAnswerQuestion(questionID.value, [selectedValue.value]);
    AnswerQuestion xx = surveyController.getAnswerQuestion(questionID.value);
    print(xx.id);
    print(xx.answer);
  }

  void updateTextValue(String val) {
    surveyController.updateAnswerQuestion(questionID.value, [val]);
    AnswerQuestion xx = surveyController.getAnswerQuestion(questionID.value);
    print(xx.id);
    print(xx.answer);
  }

  void updateSkalaLikertValue() {
    List<String> tempAnswer = [];
    int ceki = 0;
    for (var options in itemQuestion.value.subQuestions!) {
      tempAnswer.add(radioLikert[ceki]);
      ceki++;
    }
    surveyController.updateAnswerQuestion(questionID.value, tempAnswer);
    AnswerQuestion xx = surveyController.getAnswerQuestion(questionID.value);
    print(xx.id);
    print(xx.answer);
  }

  void triggerVisibleDinamis() {
    int currentQuestionindex = surveyController.ListQuestionIDVisible.indexOf(
        itemQuestion.value.questionID);
    List<dynamic> cekValue = [];
    for (var item in itemQuestion.value.options!) {
      String _questionID = "";
      if (item['go_to_init'] != null) {
        QuestionSurvey? cek =
            surveyController.ListQuestionPlay.firstWhereOrNull(
                (element) => element.init == item['go_to_init']);
        if (cek != null) {
          _questionID = cek.questionID!;
        }
      }
      if (_questionID != "") {
        cekValue
            .add({"value": item['display_name'], "questionID": _questionID});
      }
    }
    developer.log(jsonEncode(surveyController.ListQuestionIDVisible));
    if (cekValue.length > 0) {
      SmartDialog.showLoading(msg: "Loading..");
    }
    for (var item in cekValue) {
      if (item['value'] != selectedValue.value) {
        Future.delayed(Duration(milliseconds: 200), () {
          surveyController.removeQuestionVisible(item['questionID']);
        });
      } else {
        Future.delayed(Duration(milliseconds: 200), () {
          var qs = surveyController.ListQuestionPlay.firstWhereOrNull(
              (element) => element.questionID == item['questionID']);
          var answerQS = surveyController.getDefaultAnswer(qs!);
          surveyController.updateAnswerQuestion(
              item['questionID'], answerQS.answer!);
          surveyController.insertQuestionVisible(
              currentQuestionindex + 1, item['questionID']);
        });
      }
    }
    SmartDialog.dismiss();
    developer.log(jsonEncode(surveyController.ListQuestionIDVisible));
  }
}
