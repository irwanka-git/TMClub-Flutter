// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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
import 'dart:math';

class FormQuestionSurvey extends StatefulWidget {
  final QuestionSurvey? itemQuestion;
  final Survey? itemSurvey;
  final String? action;
  final bool? dinamis;
  const FormQuestionSurvey(
      {required this.itemQuestion,
      required this.itemSurvey,
      required this.dinamis,
      required this.action});
  @override
  _FormQuestionSurveyState createState() => _FormQuestionSurveyState();
}

class _FormQuestionSurveyState extends State<FormQuestionSurvey>
    with SingleTickerProviderStateMixin {
  final question = QuestionSurvey().obs;
  final survey = Survey().obs;
  final isRequired = false.obs;
  final questionText = "".obs;
  final questionType = "".obs;
  final description = "".obs;
  final options = [].obs;
  final isOtherOption = false.obs;
  final subQuestions = [].obs;
  final initDefault = "".obs;
  final isHasInitValue = false.obs;
  final _currentIntValueSkalaLinier = 1.obs;
  final minSkala = 1.obs;
  final maxSkala = 6.obs;
  final batasMinimalSkala = 1;
  final batasMaksimalSkala = 8;
  final listInitGoTo = <String>[].obs;

  late FocusNode myFocusNode;
  GlobalKey<FormState> _formKeyQuestion = GlobalKey<FormState>();

  final TextEditingController questiontextController = TextEditingController();
  final TextEditingController minSkalatextController = TextEditingController();
  final TextEditingController maxSkalatextController = TextEditingController();
  final optiontextController = <TextEditingController>[].obs;
  final subQuestionController = <TextEditingController>[].obs;
  final listDinamisQuestion = <QuestionSurvey>[].obs;
  var _tabbarRadiocontroller;
  @override
  void initState() {
    setState(() {
      question(widget.itemQuestion);
      survey(widget.itemSurvey);
      isRequired(question.value.isRequired);
      questionText(question.value.questionText);
      questionType(question.value.questionType);
      description(question.value.description);
      options(question.value.options);
      isOtherOption(question.value.isOtherOption);
      subQuestions(question.value.subQuestions);
      isHasInitValue(false);
      if (question.value.init != null || widget.dinamis == true) {
        isHasInitValue(true);
      }
      questiontextController.text = questionText.value;
      //skala linear
      if (questionType.value == "6") {
        var listSkala = <int>[];
        for (var opt in options) {
          listSkala.add(int.parse(opt['display_name']));
        }
        if (options.length > 0) {
          minSkala(listSkala.reduce(min));
          maxSkala(listSkala.reduce(max));
        }
        setState(() {
          minSkalatextController.text = minSkala.value.toString();
          maxSkalatextController.text = maxSkala.value.toString();
        });
      }
    });
    super.initState();
    _tabbarRadiocontroller = TabController(length: 2, vsync: this);
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        //padding: EdgeInsets.only(bottom: 12),
        child: Form(
            key: _formKeyQuestion,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${SurveyController.to.getQuestionType(question.value.questionType!)}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Divider(
                  height: 10,
                ),
                question.value.questionType == "1"
                    ? Container(
                        child: generateFormJawabanSingkat(),
                      )
                    : Container(),
                question.value.questionType == "2"
                    ? Container(
                        child: generateFormJawabanParagraf(),
                      )
                    : Container(),
                question.value.questionType == "3"
                    ? Container(
                        child: generateFormJawabanCheckBox(),
                      )
                    : Container(),
                question.value.questionType == "4"
                    ? Container(
                        child: generateFormJawabanRadio(),
                      )
                    : Container(),
                question.value.questionType == "5"
                    ? Container(
                        child: generateFormJawabanDropdown(),
                      )
                    : Container(),
                question.value.questionType == "6"
                    ? Container(
                        child: generateFormJawabanSkalaLinier(),
                      )
                    : Container(),
                question.value.questionType == "7"
                    ? Container(
                        child: generateFormJawabanSkalaLikert(),
                      )
                    : Container(),
                question.value.questionType == "8"
                    ? Container(
                        child: generateFormJawabanDate(),
                      )
                    : Container(),
                question.value.questionType == "9"
                    ? Container(
                        child: generateFormJawabanTime(),
                      )
                    : Container(),
                question.value.questionType == "10"
                    ? Container(
                        child: generateFormJawabanRating(),
                      )
                    : Container(),
              ],
            )));
  }

  Widget generateFormJawabanSingkat() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 20,
        ),
        TextFormField(
            controller: questiontextController,
            style: const TextStyle(fontSize: 13, height: 2),
            decoration: const InputDecoration(
                fillColor: GFColors.DARK,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                labelText: "Question",
                hintText: "Enter Question..",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                border: OutlineInputBorder()),
            autocorrect: false,
            validator: (_val) {
              if (_val == "") {
                return 'Required Filled!';
              }
              return null;
            }),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Required"),
            GFToggle(
              onChanged: (val) {
                val == true ? isRequired(true) : isRequired(false);
              },
              enabledTrackColor: CupertinoColors.activeGreen,
              value: isRequired.value == true ? true : false,
              type: GFToggleType.ios,
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 20,
        ),
        GFButton(
            blockButton: true,
            color: GFColors.SUCCESS,
            text: "Simpan",
            onPressed: () async {
              if (!_formKeyQuestion.currentState!.validate()) {
                GFToast.showToast(
                    'Sorry, Inquiry Form Not Complete!', context,
                    trailing: const Icon(
                      Icons.error_outline,
                      color: GFColors.WARNING,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                return;
              }

              var data = {
                "init": isHasInitValue.value == true
                    ? question.value.questionDraftID
                    : null,
                "question_id": "0",
                "question_text": questiontextController.text,
                "question_type": questionType.value,
                "description": null,
                "is_required": isRequired.value,
                "options": [],
                "is_other_option": false,
                "sub_questions": [],
                "question_draftid": question.value.questionDraftID
              };
              SmartDialog.showLoading(msg: "Save Survey Questions..");
              bool result = false;
              await SurveyController.to
                  .submitQuestionSurveyFirebase(survey.value.draftID!,
                      question.value.questionDraftID!, data)
                  .then((value) => result = value);
              SmartDialog.dismiss();
              if (result == true) {
                GFToast.showToast('Question saved successfully!', context,
                    trailing: const Icon(
                      Icons.check_circle_outline,
                      color: GFColors.SUCCESS,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                Navigator.pop(Get.context!);
                if (widget.action == "init") {
                  SurveyController.to
                      .getListQuestionSurvey(survey.value.draftID!);
                } else {
                  SurveyController.to.updateQuestionSurvey(
                      question.value.questionDraftID!, data);
                }
              } else {
                GFToast.showToast('Gagal Simpan Pertanyaan!', context,
                    trailing: const Icon(
                      Icons.error_outline,
                      color: GFColors.DANGER,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                return;
              }
            }),
      ],
    );
  }

  Widget generateFormJawabanParagraf() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 20,
        ),
        TextFormField(
            minLines: 1,
            maxLines: 4,
            controller: questiontextController,
            style: const TextStyle(fontSize: 13, height: 2),
            decoration: const InputDecoration(
                fillColor: GFColors.DARK,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                labelText: "Question",
                hintText: "Enter Question..",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                border: OutlineInputBorder()),
            autocorrect: false,
            validator: (_val) {
              if (_val == "") {
                return 'Required Filled!';
              }
              return null;
            }),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Required"),
            GFToggle(
              onChanged: (val) {
                val == true ? isRequired(true) : isRequired(false);
              },
              enabledTrackColor: CupertinoColors.activeGreen,
              value: isRequired.value == true ? true : false,
              type: GFToggleType.ios,
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 20,
        ),
        GFButton(
            blockButton: true,
            color: GFColors.SUCCESS,
            text: "Simpan",
            onPressed: () async {
              if (!_formKeyQuestion.currentState!.validate()) {
                GFToast.showToast(
                    'Sorry, Inquiry Form Not Complete!', context,
                    trailing: const Icon(
                      Icons.error_outline,
                      color: GFColors.WARNING,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                return;
              }

              var data = {
                "init": isHasInitValue.value == true
                    ? question.value.questionDraftID
                    : null,
                "question_id": "0",
                "question_text": questiontextController.text,
                "question_type": questionType.value,
                "description": null,
                "is_required": isRequired.value,
                "options": [],
                "is_other_option": false,
                "sub_questions": [],
                "question_draftid": question.value.questionDraftID
              };
              SmartDialog.showLoading(msg: "Save Survey Questions..");
              bool result = false;
              await SurveyController.to
                  .submitQuestionSurveyFirebase(survey.value.draftID!,
                      question.value.questionDraftID!, data)
                  .then((value) => result = value);
              SmartDialog.dismiss();
              if (result == true) {
                GFToast.showToast('Question saved successfully!', context,
                    trailing: const Icon(
                      Icons.check_circle_outline,
                      color: GFColors.SUCCESS,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                Navigator.pop(Get.context!);
                if (widget.action == "init") {
                  SurveyController.to
                      .getListQuestionSurvey(survey.value.draftID!);
                } else {
                  SurveyController.to.updateQuestionSurvey(
                      question.value.questionDraftID!, data);
                }
              } else {
                GFToast.showToast('Gagal Simpan Pertanyaan!', context,
                    trailing: const Icon(
                      Icons.error_outline,
                      color: GFColors.DANGER,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                return;
              }
            }),
      ],
    );
  }

  Widget generateFormJawabanCheckBox() {
    //optiontextController.add(TextEditingController());
     optiontextController.clear();
    for (var item in options) {
      var temp = new TextEditingController();
      temp.text = item['display_name'];
      optiontextController.add(temp);
    }
    if (options.length == 0) {
     
      var temp = new TextEditingController();
      optiontextController.add(temp);
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 20,
        ),
        TextFormField(
            minLines: 1,
            maxLines: 4,
            controller: questiontextController,
            style: const TextStyle(fontSize: 13, height: 2),
            decoration: const InputDecoration(
                fillColor: GFColors.DARK,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                labelText: "Question",
                hintText: "Enter Question..",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                border: OutlineInputBorder()),
            autocorrect: false,
            validator: (_val) {
              if (_val == "") {
                return 'Required Filled!';
              }
            }),
        SizedBox(
          height: 20,
        ),
        Container(
          width: Get.width,
          child: Text("Answer Choice"),
        ),
        SizedBox(
          height: 15,
        ),
        Obx(
          () => ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(), //tambahkan ini
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(
                    height: 8,
                  ),
              itemCount: optiontextController.length,
              itemBuilder: (BuildContext context, int index) {
                int nomorPilihan = index + 1;
                return TextFormField(
                    style: const TextStyle(fontSize: 13, height: 2),
                    controller: optiontextController[index],
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.check_box_rounded),
                        suffixIcon: IconButton(
                          onPressed: () {
                            if (index > 0) optiontextController.removeAt(index);
                          },
                          icon: Icon(Icons.clear),
                        ),
                        border: OutlineInputBorder(),
                        fillColor: GFColors.DARK,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                        labelText: "Pilihan ${nomorPilihan.toString()}",
                        hintText: "Input Options..",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        labelStyle:
                            TextStyle(color: Colors.grey, fontSize: 13)),
                    autocorrect: false,
                    validator: (_val) {
                      if (_val == "") {
                        return 'Required Filled!';
                      }
                    });
              }),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text("Add \"More\"")),
                    GFToggle(
                      onChanged: (val) {
                        val == true
                            ? isOtherOption(true)
                            : isOtherOption(false);
                      },
                      enabledTrackColor: CupertinoColors.activeGreen,
                      value: isOtherOption.value == true ? true : false,
                      type: GFToggleType.ios,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              GFButton(
                onPressed: () {
                  optiontextController.add(TextEditingController());
                },
                blockButton: true,
                type: GFButtonType.outline,
                color: GFColors.DARK,
                text: "Add Answer Options",
              ),
            ],
          ),
        ),
        Divider(
          height: 25,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Required"),
            GFToggle(
              onChanged: (val) {
                val == true ? isRequired(true) : isRequired(false);
              },
              enabledTrackColor: CupertinoColors.activeGreen,
              value: isRequired.value == true ? true : false,
              type: GFToggleType.ios,
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 20,
        ),
        GFButton(
            blockButton: true,
            color: GFColors.SUCCESS,
            text: "Save",
            onPressed: () async {
              if (!_formKeyQuestion.currentState!.validate()) {
                GFToast.showToast(
                    'Sorry, Inquiry Form Not Complete!', context,
                    trailing: const Icon(
                      Icons.error_outline,
                      color: GFColors.WARNING,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                return;
              }
              List<dynamic> optionsQuestion = [];
              for (var item in optiontextController) {
                optionsQuestion
                    .add({"display_name": item.text, "go_to_init": null});
              }
              var data = {
                "init": isHasInitValue.value == true
                    ? question.value.questionDraftID
                    : null,
                "question_id": question.value.questionID,
                "question_text": questiontextController.text,
                "question_type": questionType.value,
                "description": null,
                "is_required": isRequired.value,
                "options": optionsQuestion,
                "is_other_option": isOtherOption.value,
                "sub_questions": [],
                "question_draftid": question.value.questionDraftID
              };
              // print(data);
              // return;
              SmartDialog.showLoading(msg: "Save Survey Questions..");
              bool result = false;
              await SurveyController.to
                  .submitQuestionSurveyFirebase(survey.value.draftID!,
                      question.value.questionDraftID!, data)
                  .then((value) => result = value);
              SmartDialog.dismiss();
              if (result == true) {
                GFToast.showToast('Question saved successfully!', context,
                    trailing: const Icon(
                      Icons.check_circle_outline,
                      color: GFColors.SUCCESS,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                Navigator.pop(Get.context!);
                if (widget.action == "init") {
                  SurveyController.to
                      .getListQuestionSurvey(survey.value.draftID!);
                } else {
                  SurveyController.to.updateQuestionSurvey(
                      question.value.questionDraftID!, data);
                }
              } else {
                GFToast.showToast('Failed to Save Question!', context,
                    trailing: const Icon(
                      Icons.error_outline,
                      color: GFColors.DANGER,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                return;
              }
            }),
      ],
    );
  }

  Widget generateDropdownPertanyaanKondisional(int index) {
    String label = "";
    if (index < optiontextController.length) {
      int nomor = index + 1;
      label = nomor.toString();
    }
    var selectedQuestion = null;
    if (listInitGoTo[index] != "") {
      String keyInit = listInitGoTo[index];
      QuestionSurvey? cek = SurveyController.to.ListDinamisQuestion
          .firstWhereOrNull((element) => element.init == keyInit);
      if (cek != null) {
        selectedQuestion = cek;
      }
    }
    //print(listInitGoTo);

    return DropdownSearch<QuestionSurvey>(
      itemAsString: (item) => item!.questionText!,
      onChanged: (value) => {
        if (value == null)
          {listInitGoTo[index] = ""}
        else
          {listInitGoTo[index] = value.init!}
      },
      showClearButton: true,
      selectedItem: selectedQuestion,
      mode: Mode.BOTTOM_SHEET,
      showSearchBox: true,
      items: listDinamisQuestion,
      dropdownBuilder: _customDropDownCondQuestion,
      popupItemBuilder: _customPopupItemCondQuestion,
      dropdownSearchDecoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          labelText: "Pilihan ${label}",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
          labelStyle: TextStyle(color: Colors.grey, fontSize: 14),
          border: OutlineInputBorder()),
      showFavoriteItems: true,
      searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      )),
    );
  }

  Widget _customDropDownCondQuestion(
      BuildContext context, QuestionSurvey? item) {
    return Container(
        margin: EdgeInsets.all(0),
        child: (item == null)
            ? const ListTile(
                minLeadingWidth: 2,
                horizontalTitleGap: 4,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4.0, vertical: 2),
                dense: true,
                visualDensity: VisualDensity(vertical: -3),
                title: Text("Search Questions",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(235, 158, 158, 158))),
              )
            : ListTile(
                minLeadingWidth: 2,
                horizontalTitleGap: 4,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4.0, vertical: 2),
                dense: true,
                visualDensity: VisualDensity(vertical: -3),
                title: Text(
                  item.questionText!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13),
                ),
              ));
  }

  Widget _customPopupItemCondQuestion(
      BuildContext context, QuestionSurvey item, bool isSelected) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: ListTile(
          minLeadingWidth: 2,
          horizontalTitleGap: 8,
          contentPadding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 0),
          dense: true,
          visualDensity: VisualDensity(vertical: -3),
          title: Text(
            item.questionText!,
            style: TextStyle(fontSize: 14),
          ),
          subtitle: Text(
            SurveyController.to.getQuestionType(item.questionType!),
            style: TextStyle(fontSize: 12),
          ),
        ));
  }

  Widget generateFormJawabanRadio() {
    optiontextController.clear();
    listInitGoTo.clear();
    for (var item in options) {
      var temp = new TextEditingController();
      temp.text = item['display_name'];
      optiontextController.add(temp);
      listInitGoTo.add(item['go_to_init'] ?? "");
    }
    if (options.length == 0) {
      var temp = new TextEditingController();
      optiontextController.add(temp);
      listInitGoTo.add("");
    }
    var tabIndex = 0.obs;
    listDinamisQuestion.clear();
    List<String> alreadyGoto = SurveyController.to
        .getUsedDinamisQuestion(question.value.questionDraftID!);
    for (var item in SurveyController.to.ListDinamisQuestion) {
      if (alreadyGoto.length > 0) {
        if (alreadyGoto.contains(item.init!) == false) {
          listDinamisQuestion.add(item);
        }
      } else {
        listDinamisQuestion.add(item);
      }
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 20,
        ),
        TextFormField(
            minLines: 1,
            maxLines: 4,
            controller: questiontextController,
            style: const TextStyle(fontSize: 13, height: 2),
            decoration: const InputDecoration(
                fillColor: GFColors.DARK,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                labelText: "Question",
                hintText: "Enter Question..",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                border: OutlineInputBorder()),
            autocorrect: false,
            validator: (_val) {
              if (_val == "") {
                return 'Required Filled!';
              }
            }),
        SizedBox(
          height: 20,
        ),
        TabBar(
          onTap: (value) {
            tabIndex(value);
          },
          labelColor: GFColors.DARK,
          indicatorColor: GFColors.PRIMARY,
          indicatorSize: TabBarIndicatorSize.tab,
          padding: EdgeInsets.symmetric(vertical: 2),
          controller: _tabbarRadiocontroller,
          tabs: <Widget>[
            new Tab(
              text: "Answer Choice",
              height: 35,
            ),
            new Tab(
              text: "Next Question",
              height: 35,
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Obx(
          () => Visibility(
            visible: tabIndex.value == 0 ? true : false,
            child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(), //tambahkan ini
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(
                      height: 8,
                    ),
                itemCount: optiontextController.length,
                itemBuilder: (BuildContext context, int index) {
                  int nomorPilihan = index + 1;
                  return TextFormField(
                      style: const TextStyle(fontSize: 13, height: 2),
                      controller: optiontextController[index],
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.radio_button_checked_outlined),
                          suffixIcon: IconButton(
                            onPressed: () {
                              if (index > 0) {
                                listInitGoTo.removeAt(index);
                                optiontextController.removeAt(index);
                              }
                            },
                            icon: Icon(Icons.clear),
                          ),
                          border: OutlineInputBorder(),
                          fillColor: GFColors.DARK,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                          labelText: "Choice ${nomorPilihan.toString()}",
                          hintText: "Input Options..",
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 14),
                          labelStyle:
                              TextStyle(color: Colors.grey, fontSize: 13)),
                      autocorrect: false,
                      validator: (_val) {
                        if (_val == "") {
                          return 'Required Filled!';
                        }
                      });
                }),
          ),
        ),
        Obx(
          () => Visibility(
            visible:
                tabIndex.value == 1 && widget.dinamis == false ? true : false,
            child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(), //tambahkan ini
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(
                      height: 8,
                    ),
                itemCount: listInitGoTo.length,
                itemBuilder: (BuildContext context, int index) {
                  int nomorPilihan = index + 1;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: generateDropdownPertanyaanKondisional(index),
                  );
                }),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text("Add \"More\"")),
                    GFToggle(
                      onChanged: (val) {
                        val == true
                            ? isOtherOption(true)
                            : isOtherOption(false);
                      },
                      enabledTrackColor: CupertinoColors.activeGreen,
                      value: isOtherOption.value == true ? true : false,
                      type: GFToggleType.ios,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              GFButton(
                onPressed: () {
                  optiontextController.add(TextEditingController());
                  listInitGoTo.add("");
                },
                blockButton: true,
                type: GFButtonType.outline,
                color: GFColors.DARK,
                text: "Add Answer Options",
              ),
            ],
          ),
        ),
        Divider(
          height: 25,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Required"),
            GFToggle(
              onChanged: (val) {
                val == true ? isRequired(true) : isRequired(false);
              },
              enabledTrackColor: CupertinoColors.activeGreen,
              value: isRequired.value == true ? true : false,
              type: GFToggleType.ios,
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 20,
        ),
        GFButton(
            blockButton: true,
            color: GFColors.SUCCESS,
            text: "Simpan",
            onPressed: () async {
              if (!_formKeyQuestion.currentState!.validate()) {
                GFToast.showToast(
                    'Sorry, Inquiry Form Not Complete!', context,
                    trailing: const Icon(
                      Icons.error_outline,
                      color: GFColors.WARNING,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                return;
              }
              List<dynamic> optionsQuestion = [];
              int cr7 = 0;
              bool duplikatInitGo = false;
              String last_goto = "";
              List<String> alreadyGoto = SurveyController.to
                  .getUsedDinamisQuestion(question.value.questionDraftID!);
              for (var init_goto in listInitGoTo) {
                if (alreadyGoto.length > 0) {
                  if (alreadyGoto.contains(init_goto)) {
                    GFToast.showToast(
                        'Mohon Maaf, Optional Questions Can Only Be Used Once!',
                        context,
                        trailing: const Icon(
                          Icons.error_outline,
                          color: GFColors.DANGER,
                        ),
                        toastPosition: GFToastPosition.TOP,
                        toastBorderRadius: 5.0);
                    return;
                  }
                }
              }

              if (duplikatInitGo == false) {
                for (var item in optiontextController) {
                  String validDinamisQuestionOther = "";
                  var cek = listInitGoTo[cr7] != ""
                      ? SurveyController.to.ListDinamisQuestion
                          .firstWhereOrNull(
                              (element) => element.init == listInitGoTo[cr7])
                      : null;
                  if (cek == null) {
                    validDinamisQuestionOther = "";
                  } else {
                    validDinamisQuestionOther = listInitGoTo[cr7];
                  }
                  optionsQuestion.add({
                    "display_name": item.text,
                    "go_to_init": validDinamisQuestionOther == ""
                        ? null
                        : validDinamisQuestionOther
                  });
                  cr7++;
                }
              }
              var data = {
                "init": isHasInitValue.value == true
                    ? question.value.questionDraftID
                    : null,
                "question_id": question.value.questionID,
                "question_text": questiontextController.text,
                "question_type": questionType.value,
                "description": null,
                "is_required": isRequired.value,
                "options": optionsQuestion,
                "is_other_option": isOtherOption.value,
                "sub_questions": [],
                "question_draftid": question.value.questionDraftID
              };
              // print(data);
              // return;
              SmartDialog.showLoading(msg: "Save Survey Questions..");
              bool result = false;
              await SurveyController.to
                  .submitQuestionSurveyFirebase(survey.value.draftID!,
                      question.value.questionDraftID!, data)
                  .then((value) => result = value);
              SmartDialog.dismiss();
              if (result == true) {
                GFToast.showToast('Question saved successfully!', context,
                    trailing: const Icon(
                      Icons.check_circle_outline,
                      color: GFColors.SUCCESS,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                Navigator.pop(Get.context!);
                if (widget.action == "init") {
                  SurveyController.to
                      .getListQuestionSurvey(survey.value.draftID!);
                } else {
                  SurveyController.to.updateQuestionSurvey(
                      question.value.questionDraftID!, data);
                }
              } else {
                GFToast.showToast('Failed to Save Question!', context,
                    trailing: const Icon(
                      Icons.error_outline,
                      color: GFColors.DANGER,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                return;
              }
            }),
      ],
    );
  }

  Widget generateFormJawabanDropdown() {
    //optiontextController.add(TextEditingController());
    for (var item in options) {
      var temp = new TextEditingController();
      temp.text = item['display_name'];
      optiontextController.add(temp);
    }
    if (options.length == 0) {
      var temp = new TextEditingController();
      optiontextController.add(temp);
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 20,
        ),
        TextFormField(
            minLines: 1,
            maxLines: 4,
            controller: questiontextController,
            style: const TextStyle(fontSize: 13, height: 2),
            decoration: const InputDecoration(
                fillColor: GFColors.DARK,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                labelText: "Question",
                hintText: "Enter Question..",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                border: OutlineInputBorder()),
            autocorrect: false,
            validator: (_val) {
              if (_val == "") {
                return 'Required Filled!';
              }
            }),
        SizedBox(
          height: 20,
        ),
        Container(
          width: Get.width,
          child: Text("Answer Choice"),
        ),
        SizedBox(
          height: 15,
        ),
        Obx(
          () => ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(), //tambahkan ini
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(
                    height: 8,
                  ),
              itemCount: optiontextController.length,
              itemBuilder: (BuildContext context, int index) {
                int nomorPilihan = index + 1;
                return TextFormField(
                    style: const TextStyle(fontSize: 13, height: 2),
                    controller: optiontextController[index],
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.radio_button_checked_outlined),
                        suffixIcon: IconButton(
                          onPressed: () {
                            if (index > 0) optiontextController.removeAt(index);
                          },
                          icon: Icon(Icons.clear),
                        ),
                        border: OutlineInputBorder(),
                        fillColor: GFColors.DARK,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                        labelText: "Pilihan ${nomorPilihan.toString()}",
                        hintText: "Masukan Pilihan..",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        labelStyle:
                            TextStyle(color: Colors.grey, fontSize: 13)),
                    autocorrect: false,
                    validator: (_val) {
                      if (_val == "") {
                        return 'Required Filled!';
                      }
                    });
              }),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          child: Column(
            children: [
              GFButton(
                onPressed: () {
                  optiontextController.add(TextEditingController());
                },
                blockButton: true,
                type: GFButtonType.outline,
                color: GFColors.DARK,
                text: "Add Answer Options",
              ),
            ],
          ),
        ),
        Divider(
          height: 25,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Required"),
            GFToggle(
              onChanged: (val) {
                val == true ? isRequired(true) : isRequired(false);
              },
              enabledTrackColor: CupertinoColors.activeGreen,
              value: isRequired.value == true ? true : false,
              type: GFToggleType.ios,
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 20,
        ),
        GFButton(
            blockButton: true,
            color: GFColors.SUCCESS,
            text: "Simpan",
            onPressed: () async {
              if (!_formKeyQuestion.currentState!.validate()) {
                GFToast.showToast(
                    'Sorry, Inquiry Form Not Complete!', context,
                    trailing: const Icon(
                      Icons.error_outline,
                      color: GFColors.WARNING,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                return;
              }
              List<dynamic> optionsQuestion = [];
              for (var item in optiontextController) {
                optionsQuestion
                    .add({"display_name": item.text, "go_to_init": null});
              }
              var data = {
                "init": isHasInitValue.value == true ? initDefault.value : null,
                "question_id": question.value.questionID,
                "question_text": questiontextController.text,
                "question_type": questionType.value,
                "description": null,
                "is_required": isRequired.value,
                "options": optionsQuestion,
                "is_other_option": isOtherOption.value,
                "sub_questions": [],
                "question_draftid": question.value.questionDraftID
              };
              // print(data);
              // return;
              SmartDialog.showLoading(msg: "Save Survey Questions..");
              bool result = false;
              await SurveyController.to
                  .submitQuestionSurveyFirebase(survey.value.draftID!,
                      question.value.questionDraftID!, data)
                  .then((value) => result = value);
              SmartDialog.dismiss();
              if (result == true) {
                GFToast.showToast('Question saved successfully!', context,
                    trailing: const Icon(
                      Icons.check_circle_outline,
                      color: GFColors.SUCCESS,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                Navigator.pop(Get.context!);
                if (widget.action == "init") {
                  SurveyController.to
                      .getListQuestionSurvey(survey.value.draftID!);
                } else {
                  SurveyController.to.updateQuestionSurvey(
                      question.value.questionDraftID!, data);
                }
              } else {
                GFToast.showToast('Error Question Saved!', context,
                    trailing: const Icon(
                      Icons.error_outline,
                      color: GFColors.DANGER,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                return;
              }
            }),
      ],
    );
  }

  Widget generateFormJawabanSkalaLinier() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 20,
        ),
        TextFormField(
            controller: questiontextController,
            style: const TextStyle(fontSize: 13, height: 2),
            decoration: const InputDecoration(
                fillColor: GFColors.DARK,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                labelText: "Question",
                hintText: "Enter Question..",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                border: OutlineInputBorder()),
            autocorrect: false,
            validator: (_val) {
              if (_val == "") {
                return 'Required Filled!';
              }
              return null;
            }),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 90,
              child: TextFormField(
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  keyboardType: TextInputType.number,
                  controller: minSkalatextController,
                  style: const TextStyle(fontSize: 13, height: 2),
                  decoration: const InputDecoration(
                      fillColor: GFColors.DARK,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                      labelText: "Min.",
                      hintText: "Min.",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                      border: OutlineInputBorder()),
                  autocorrect: false,
                  validator: (_val) {
                    if (_val == "") {
                      return 'Required Filled!';
                    }
                    return null;
                  }),
            ),
            Text("Until"),
            Container(
              width: 90,
              child: TextFormField(
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  keyboardType: TextInputType.number,
                  controller: maxSkalatextController,
                  style: const TextStyle(fontSize: 13, height: 2),
                  decoration: const InputDecoration(
                      fillColor: GFColors.DARK,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                      labelText: "Max.",
                      hintText: "Max.",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                      border: OutlineInputBorder()),
                  autocorrect: false,
                  validator: (_val) {
                    if (_val == "") {
                      return 'Required Filled!';
                    }
                    return null;
                  }),
            ),
          ],
        ),
        SizedBox(
          height: 25,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Required"),
            GFToggle(
              onChanged: (val) {
                val == true ? isRequired(true) : isRequired(false);
              },
              enabledTrackColor: CupertinoColors.activeGreen,
              value: isRequired.value == true ? true : false,
              type: GFToggleType.ios,
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 20,
        ),
        GFButton(
            blockButton: true,
            color: GFColors.SUCCESS,
            text: "Save",
            onPressed: () async {
              if (!_formKeyQuestion.currentState!.validate()) {
                GFToast.showToast(
                    'Sorry, Inquiry Form Not Complete!', context,
                    trailing: const Icon(
                      Icons.error_outline,
                      color: GFColors.WARNING,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                return;
              }

              int minS = int.parse(minSkalatextController.text);
              int maxS = int.parse(maxSkalatextController.text);
              if (minS >= maxS) {
                GFToast.showToast(
                    'Maximum Scale must be greater than Minimum Scale!',
                    context,
                    trailing: const Icon(
                      Icons.error_outline,
                      color: GFColors.WARNING,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                return;
              }
              if (minS < batasMinimalSkala) {
                GFToast.showToast(
                    'Minimum Scale Limit Is ${batasMinimalSkala}!', context,
                    trailing: const Icon(
                      Icons.error_outline,
                      color: GFColors.WARNING,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                return;
              }
              if (maxS > batasMaksimalSkala) {
                GFToast.showToast(
                    'Minimum Scale Limit Is ${batasMaksimalSkala}!',
                    context,
                    trailing: const Icon(
                      Icons.error_outline,
                      color: GFColors.WARNING,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                return;
              }
              //build options skala range
              var listSkala = <int>[];
              var listOption = [];

              for (var i = minS; i <= maxS; i++) {
                var temp = {"display_name": i.toString(), "go_to_init": null};
                listOption.add(temp);
              }
              var data = {
                "init": isHasInitValue.value == true ? initDefault.value : null,
                "question_id": "0",
                "question_text": questiontextController.text,
                "question_type": questionType.value,
                "description": null,
                "is_required": isRequired.value,
                "options": listOption,
                "is_other_option": false,
                "sub_questions": [],
                "question_draftid": question.value.questionDraftID
              };
              SmartDialog.showLoading(msg: "Save Survey Questions..");
              bool result = false;
              await SurveyController.to
                  .submitQuestionSurveyFirebase(survey.value.draftID!,
                      question.value.questionDraftID!, data)
                  .then((value) => result = value);
              SmartDialog.dismiss();
              if (result == true) {
                GFToast.showToast('Question saved successfully!', context,
                    trailing: const Icon(
                      Icons.check_circle_outline,
                      color: GFColors.SUCCESS,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                Navigator.pop(Get.context!);
                if (widget.action == "init") {
                  SurveyController.to
                      .getListQuestionSurvey(survey.value.draftID!);
                } else {
                  SurveyController.to.updateQuestionSurvey(
                      question.value.questionDraftID!, data);
                }
              } else {
                GFToast.showToast('Gagal Simpan Pertanyaan!', context,
                    trailing: const Icon(
                      Icons.error_outline,
                      color: GFColors.DANGER,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                return;
              }
            }),
      ],
    );
  }

  Widget generateFormJawabanSkalaLikert() {
    //optiontextController.add(TextEditingController());
    for (var item in subQuestions) {
      var temp = new TextEditingController();
      temp.text = item['question_text'];
      subQuestionController.add(temp);
    }
    if (subQuestions.length == 0) {
      var temp = new TextEditingController();
      subQuestionController.add(temp);
    }

    for (var item in options) {
      var temp = new TextEditingController();
      temp.text = item['display_name'];
      optiontextController.add(temp);
    }
    if (options.length == 0) {
      var temp = new TextEditingController();
      optiontextController.add(temp);
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 20,
        ),
        TextFormField(
            minLines: 1,
            maxLines: 4,
            controller: questiontextController,
            style: const TextStyle(fontSize: 13, height: 2),
            decoration: const InputDecoration(
                fillColor: GFColors.DARK,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                labelText: "Question",
                hintText: "Enter Question..",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                border: OutlineInputBorder()),
            autocorrect: false,
            validator: (_val) {
              if (_val == "") {
                return 'Required Filled!';
              }
            }),
        SizedBox(
          height: 20,
        ),
        Container(
          width: Get.width,
          child: Text("Sub Question (Indicator)"),
        ),
        SizedBox(
          height: 15,
        ),
        Obx(
          () => ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(), //tambahkan ini
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(
                    height: 8,
                  ),
              itemCount: subQuestionController.length,
              itemBuilder: (BuildContext context, int index) {
                int nomorPilihan = index + 1;
                return TextFormField(
                    style: const TextStyle(fontSize: 13, height: 2),
                    controller: subQuestionController[index],
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.radio_button_checked_outlined),
                        suffixIcon: IconButton(
                          onPressed: () {
                            if (index > 0)
                              subQuestionController.removeAt(index);
                          },
                          icon: Icon(Icons.clear),
                        ),
                        border: OutlineInputBorder(),
                        fillColor: GFColors.DARK,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                        labelText: "Sub Questions ${nomorPilihan.toString()}",
                        hintText: "Masukan Sub Questions..",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        labelStyle:
                            TextStyle(color: Colors.grey, fontSize: 13)),
                    autocorrect: false,
                    validator: (_val) {
                      if (_val == "") {
                        return 'Required Filled!';
                      }
                    });
              }),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          child: Column(
            children: [
              GFButton(
                onPressed: () {
                  subQuestionController.add(TextEditingController());
                },
                blockButton: true,
                type: GFButtonType.outline,
                color: GFColors.DARK,
                text: "Add Sub Question",
              ),
            ],
          ),
        ),
        Divider(
          height: 25,
        ),
        Obx(
          () => ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(), //tambahkan ini
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(
                    height: 8,
                  ),
              itemCount: optiontextController.length,
              itemBuilder: (BuildContext context, int index) {
                int nomorPilihan = index + 1;
                return TextFormField(
                    style: const TextStyle(fontSize: 13, height: 2),
                    controller: optiontextController[index],
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.radio_button_checked_outlined),
                        suffixIcon: IconButton(
                          onPressed: () {
                            if (index > 0) optiontextController.removeAt(index);
                          },
                          icon: Icon(Icons.clear),
                        ),
                        border: OutlineInputBorder(),
                        fillColor: GFColors.DARK,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                        labelText: "Choice ${nomorPilihan.toString()}",
                        hintText: "Please Select Choisee..",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        labelStyle:
                            TextStyle(color: Colors.grey, fontSize: 13)),
                    autocorrect: false,
                    validator: (_val) {
                      if (_val == "") {
                        return 'Required Filled!';
                      }
                    });
              }),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          child: Column(
            children: [
              GFButton(
                onPressed: () {
                  if (optiontextController.length < 5) {
                    optiontextController.add(TextEditingController());
                  }
                },
                blockButton: true,
                type: GFButtonType.outline,
                color: GFColors.DARK,
                text: "Add Answer Options",
              ),
            ],
          ),
        ),
        Divider(
          height: 25,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Required"),
            GFToggle(
              onChanged: (val) {
                val == true ? isRequired(true) : isRequired(false);
              },
              enabledTrackColor: CupertinoColors.activeGreen,
              value: isRequired.value == true ? true : false,
              type: GFToggleType.ios,
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 20,
        ),
        GFButton(
            blockButton: true,
            color: GFColors.SUCCESS,
            text: "Simpan",
            onPressed: () async {
              if (!_formKeyQuestion.currentState!.validate()) {
                GFToast.showToast(
                    'Sorry, Inquiry Form Not Complete!', context,
                    trailing: const Icon(
                      Icons.error_outline,
                      color: GFColors.WARNING,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                return;
              }
              List<dynamic> optionsQuestion = [];
              for (var item in optiontextController) {
                optionsQuestion
                    .add({"display_name": item.text, "go_to_init": null});
              }
              List<dynamic> optionsSubQuestion = [];
              for (var item in subQuestionController) {
                optionsSubQuestion.add({"question_text": item.text});
              }
              var data = {
                "init": isHasInitValue.value == true ? initDefault.value : null,
                "question_id": question.value.questionID,
                "question_text": questiontextController.text,
                "question_type": questionType.value,
                "description": null,
                "is_required": isRequired.value,
                "options": optionsQuestion,
                "is_other_option": isOtherOption.value,
                "sub_questions": optionsSubQuestion,
                "question_draftid": question.value.questionDraftID
              };

              // print(data);
              // return;
              SmartDialog.showLoading(msg: "Save Survey Questions..");
              bool result = false;
              await SurveyController.to
                  .submitQuestionSurveyFirebase(survey.value.draftID!,
                      question.value.questionDraftID!, data)
                  .then((value) => result = value);
              SmartDialog.dismiss();
              if (result == true) {
                GFToast.showToast('Question saved successfully!', context,
                    trailing: const Icon(
                      Icons.check_circle_outline,
                      color: GFColors.SUCCESS,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                Navigator.pop(Get.context!);
                if (widget.action == "init") {
                  SurveyController.to
                      .getListQuestionSurvey(survey.value.draftID!);
                } else {
                  SurveyController.to.updateQuestionSurvey(
                      question.value.questionDraftID!, data);
                }
              } else {
                GFToast.showToast('Failed to Save Question!', context,
                    trailing: const Icon(
                      Icons.error_outline,
                      color: GFColors.DANGER,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                return;
              }
            }),
      ],
    );
  }

  Widget generateFormJawabanDate() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 20,
        ),
        TextFormField(
            controller: questiontextController,
            style: const TextStyle(fontSize: 13, height: 2),
            decoration: const InputDecoration(
                fillColor: GFColors.DARK,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                labelText: "Question",
                hintText: "Enter Question..",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                border: OutlineInputBorder()),
            autocorrect: false,
            validator: (_val) {
              if (_val == "") {
                return 'Required Filled!';
              }
              return null;
            }),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Required"),
            GFToggle(
              onChanged: (val) {
                val == true ? isRequired(true) : isRequired(false);
              },
              enabledTrackColor: CupertinoColors.activeGreen,
              value: isRequired.value == true ? true : false,
              type: GFToggleType.ios,
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 20,
        ),
        GFButton(
            blockButton: true,
            color: GFColors.SUCCESS,
            text: "Simpan",
            onPressed: () async {
              if (!_formKeyQuestion.currentState!.validate()) {
                GFToast.showToast(
                    'Sorry, Inquiry Form Not Complete!', context,
                    trailing: const Icon(
                      Icons.error_outline,
                      color: GFColors.WARNING,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                return;
              }

              var data = {
                "init": isHasInitValue.value == true ? initDefault.value : null,
                "question_id": "0",
                "question_text": questiontextController.text,
                "question_type": questionType.value,
                "description": null,
                "is_required": isRequired.value,
                "options": [],
                "is_other_option": false,
                "sub_questions": [],
                "question_draftid": question.value.questionDraftID
              };
              SmartDialog.showLoading(msg: "Save Survey Questions..");
              bool result = false;
              await SurveyController.to
                  .submitQuestionSurveyFirebase(survey.value.draftID!,
                      question.value.questionDraftID!, data)
                  .then((value) => result = value);
              SmartDialog.dismiss();
              if (result == true) {
                GFToast.showToast('Question saved successfully!', context,
                    trailing: const Icon(
                      Icons.check_circle_outline,
                      color: GFColors.SUCCESS,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                Navigator.pop(Get.context!);
                if (widget.action == "init") {
                  SurveyController.to
                      .getListQuestionSurvey(survey.value.draftID!);
                } else {
                  SurveyController.to.updateQuestionSurvey(
                      question.value.questionDraftID!, data);
                }
              } else {
                GFToast.showToast('Gagal Simpan Pertanyaan!', context,
                    trailing: const Icon(
                      Icons.error_outline,
                      color: GFColors.DANGER,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                return;
              }
            }),
      ],
    );
  }

  Widget generateFormJawabanTime() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 20,
        ),
        TextFormField(
            controller: questiontextController,
            style: const TextStyle(fontSize: 13, height: 2),
            decoration: const InputDecoration(
                fillColor: GFColors.DARK,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                labelText: "Question",
                hintText: "Enter Question..",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                border: OutlineInputBorder()),
            autocorrect: false,
            validator: (_val) {
              if (_val == "") {
                return 'Required Filled!';
              }
              return null;
            }),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Required"),
            GFToggle(
              onChanged: (val) {
                val == true ? isRequired(true) : isRequired(false);
              },
              enabledTrackColor: CupertinoColors.activeGreen,
              value: isRequired.value == true ? true : false,
              type: GFToggleType.ios,
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 20,
        ),
        GFButton(
            blockButton: true,
            color: GFColors.SUCCESS,
            text: "Simpan",
            onPressed: () async {
              if (!_formKeyQuestion.currentState!.validate()) {
                GFToast.showToast(
                    'Sorry, Inquiry Form Not Complete!', context,
                    trailing: const Icon(
                      Icons.error_outline,
                      color: GFColors.WARNING,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                return;
              }

              var data = {
                "init": isHasInitValue.value == true ? initDefault.value : null,
                "question_id": "0",
                "question_text": questiontextController.text,
                "question_type": questionType.value,
                "description": null,
                "is_required": isRequired.value,
                "options": [],
                "is_other_option": false,
                "sub_questions": [],
                "question_draftid": question.value.questionDraftID
              };
              SmartDialog.showLoading(msg: "Save Survey Questions..");
              bool result = false;
              await SurveyController.to
                  .submitQuestionSurveyFirebase(survey.value.draftID!,
                      question.value.questionDraftID!, data)
                  .then((value) => result = value);
              SmartDialog.dismiss();
              if (result == true) {
                GFToast.showToast('Question saved successfully!', context,
                    trailing: const Icon(
                      Icons.check_circle_outline,
                      color: GFColors.SUCCESS,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                Navigator.pop(Get.context!);
                if (widget.action == "init") {
                  SurveyController.to
                      .getListQuestionSurvey(survey.value.draftID!);
                } else {
                  SurveyController.to.updateQuestionSurvey(
                      question.value.questionDraftID!, data);
                }
              } else {
                GFToast.showToast('Gagal Simpan Pertanyaan!', context,
                    trailing: const Icon(
                      Icons.error_outline,
                      color: GFColors.DANGER,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                return;
              }
            }),
      ],
    );
  }

  Widget generateFormJawabanRating() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 20,
        ),
        TextFormField(
            controller: questiontextController,
            style: const TextStyle(fontSize: 13, height: 2),
            decoration: const InputDecoration(
                fillColor: GFColors.DARK,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                labelText: "Question",
                hintText: "Enter Question..",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                border: OutlineInputBorder()),
            autocorrect: false,
            validator: (_val) {
              if (_val == "") {
                return 'Required Filled!';
              }
              return null;
            }),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Required"),
            GFToggle(
              onChanged: (val) {
                val == true ? isRequired(true) : isRequired(false);
              },
              enabledTrackColor: CupertinoColors.activeGreen,
              value: isRequired.value == true ? true : false,
              type: GFToggleType.ios,
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 20,
        ),
        GFButton(
            blockButton: true,
            color: GFColors.SUCCESS,
            text: "Simpan",
            onPressed: () async {
              if (!_formKeyQuestion.currentState!.validate()) {
                GFToast.showToast(
                    'Sorry, Inquiry Form Not Complete!', context,
                    trailing: const Icon(
                      Icons.error_outline,
                      color: GFColors.WARNING,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                return;
              }

              var data = {
                "init": isHasInitValue.value == true ? initDefault.value : null,
                "question_id": "0",
                "question_text": questiontextController.text,
                "question_type": questionType.value,
                "description": null,
                "is_required": isRequired.value,
                "options": [],
                "is_other_option": false,
                "sub_questions": [],
                "question_draftid": question.value.questionDraftID
              };
              SmartDialog.showLoading(msg: "Save Survey Questions..");
              bool result = false;
              await SurveyController.to
                  .submitQuestionSurveyFirebase(survey.value.draftID!,
                      question.value.questionDraftID!, data)
                  .then((value) => result = value);
              SmartDialog.dismiss();
              if (result == true) {
                GFToast.showToast('Question saved successfully!', context,
                    trailing: const Icon(
                      Icons.check_circle_outline,
                      color: GFColors.SUCCESS,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                Navigator.pop(Get.context!);
                if (widget.action == "init") {
                  SurveyController.to
                      .getListQuestionSurvey(survey.value.draftID!);
                } else {
                  SurveyController.to.updateQuestionSurvey(
                      question.value.questionDraftID!, data);
                }
              } else {
                GFToast.showToast('Failed to Save Question!', context,
                    trailing: const Icon(
                      Icons.error_outline,
                      color: GFColors.DANGER,
                    ),
                    toastPosition: GFToastPosition.TOP,
                    toastBorderRadius: 5.0);
                return;
              }
            }),
      ],
    );
  }
}
