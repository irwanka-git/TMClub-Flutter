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
import 'package:tmcapp/controller/SurveyController.dart';
import 'package:tmcapp/model/list_id.dart';
import 'package:tmcapp/model/question_survey.dart';
import 'package:tmcapp/model/survey.dart';

import 'image_widget.dart';

class FormResponseQuestionSurvey extends StatefulWidget {
  final QuestionSurvey? itemQuestion;
  //final Survey? itemSurvey;
  final bool enable;
  const FormResponseQuestionSurvey(
      {required this.itemQuestion, required this.enable});
  @override
  _FormResponseQuestionSurveyState createState() =>
      _FormResponseQuestionSurveyState();
}

class _FormResponseQuestionSurveyState
    extends State<FormResponseQuestionSurvey> {
  final question = QuestionSurvey().obs;
  final isRequired = false.obs;
  final questionText = "".obs;
  final questionType = "".obs;
  final description = "".obs;
  final options = [].obs;
  final isOtherOption = false.obs;
  final subQuestions = [].obs;
  final init = "".obs;
  final initDefault = "".obs;
  final isHasInitValue = false.obs;
  final response = "".obs;
  final responseTextController = TextEditingController();
  final checkboxValue = [].obs;

  @override
  void initState() {
    setState(() {
      question(widget.itemQuestion);
      isRequired(question.value.isRequired);
      questionText(question.value.questionText);
      questionType(question.value.questionType);
      description(question.value.description);
      options(question.value.options);
      isOtherOption(question.value.isOtherOption);
      subQuestions(question.value.subQuestions);
      for (var item in options) {
        checkboxValue.add(false);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            question.value.questionType == "0" ? Container() : Container(),
            question.value.questionType == "1"
                ? Container(
                    child: generateResponseJawabanSingkat(),
                  )
                : Container(),
            question.value.questionType == "2"
                ? Container(
                    child: generateResponseJawabanParagraf(),
                  )
                : Container(),
            question.value.questionType == "3"
                ? Container(
                    child: generateResponseJawabanCheckBox(),
                  )
                : Container(),
          ],
        ));
  }

  Widget generateResponseJawabanSingkat() {
    return Container(
        child: TextFormField(
      readOnly: widget.enable == false ? true : false,
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
      readOnly: widget.enable == false ? true : false,
      minLines: 1,
      maxLines: 4,
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

  Widget generateResponseJawabanCheckBox() {
    return Obx(() => ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(), //tambahkan ini
        separatorBuilder: (BuildContext context, int index) => const SizedBox(
              height: 8,
            ),
        itemCount: options.length,
        itemBuilder: (BuildContext context, int index) {
          int nomorPilihan = index + 1;
          return GFCheckboxListTile(
            title: Text(
              options[index]['display_name'],
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
              setState(() {
                widget.enable == true ? checkboxValue[index] = value : null;
              });
            },
            value: checkboxValue[index],
            inactiveIcon: null,
          );
        }));
  }
}
