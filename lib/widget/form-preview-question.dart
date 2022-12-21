// ignore_for_file: public_member_api_docs, sort_constructors_first
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
import 'package:tmcapp/model/list_id.dart';
import 'package:tmcapp/model/question_survey.dart';
import 'package:tmcapp/model/survey.dart';

import 'image_widget.dart';

class FormPreviewQuestionSurvey extends StatelessWidget {
  final QuestionSurvey? itemQuestion;
  FormPreviewQuestionSurvey({required this.itemQuestion});

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
  Widget build(BuildContext context) {
    //question(itemQuestion);
    return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            itemQuestion!.questionType == "0" ? Container() : Container(),
            itemQuestion!.questionType == "1"
                ? Container(
                    child: generateResponseJawabanSingkat(),
                  )
                : Container(),
            itemQuestion!.questionType == "2"
                ? Container(
                    child: generateResponseJawabanParagraf(),
                  )
                : Container(),
            itemQuestion!.questionType == "3"
                ? Container(
                    child: generateResponseJawabanCheckBox(),
                  )
                : Container(),
            itemQuestion!.questionType == "3" &&
                    itemQuestion!.isOtherOption == true
                ? GFChecboxOther()
                : Container(),
            itemQuestion!.questionType == "4"
                ? Container(
                    child: generateResponseJawabanRadio(),
                  )
                : Container(),
            itemQuestion!.questionType == "4" &&
                    itemQuestion!.isOtherOption == true
                ? GFRadioOther()
                : Container(),
            itemQuestion!.questionType == "5"
                ? Container(
                    child: generateResponseJawabanDropdown(
                        itemQuestion!.isOtherOption!),
                  )
                : Container(),
            itemQuestion!.questionType == "6"
                ? Container(
                    child: generateResponseJawabanSkalaLinier(),
                  )
                : Container(),
            itemQuestion!.questionType == "7"
                ? Container(
                    child: generateResponseJawabanSkalaLikert(),
                  )
                : Container(),
            itemQuestion!.questionType == "8"
                ? Container(
                    child: generateResponseJawabanDate(),
                  )
                : Container(),
            itemQuestion!.questionType == "9"
                ? Container(
                    child: generateResponseJawabanTime(),
                  )
                : Container(),
            itemQuestion!.questionType == "10"
                ? Container(
                    child: generateResponseJawabanRating(),
                  )
                : Container(),
          ],
        ));
  }

  Container GFChecboxOther() {
    return Container(
      child: GFCheckboxListTile(
        title: TextFormField(
          readOnly: true,
          controller: responseTextController,
          style: const TextStyle(fontSize: 13, height: 2),
          decoration: const InputDecoration(
            fillColor: GFColors.DARK,
            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
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
        onChanged: (value) {},
        value: false,
        inactiveIcon: null,
      ),
    );
  }

  Widget generateResponseJawabanSingkat() {
    return Container(
        child: TextFormField(
      readOnly: true,
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
      readOnly: true,
      minLines: 3,
      maxLines: 8,
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
    return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(), //tambahkan ini
        separatorBuilder: (BuildContext context, int index) => const SizedBox(
              height: 8,
            ),
        itemCount: itemQuestion!.options!.length,
        itemBuilder: (BuildContext context, int index) {
          int nomorPilihan = index + 1;
          return GFCheckboxListTile(
            title: Text(
              itemQuestion!.options![index]['display_name'],
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
            onChanged: (value) {},
            value: false,
            inactiveIcon: null,
          );
        });
  }

  Container GFRadioOther() {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      child: GFRadioListTile(
        groupValue: true,
        title: TextFormField(
          readOnly: true,
          controller: responseTextController,
          style: const TextStyle(fontSize: 13, height: 2),
          decoration: const InputDecoration(
            fillColor: GFColors.DARK,
            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
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
        type: GFRadioType.basic,
        activeIcon: Icon(
          Icons.check,
          size: 15,
          color: Colors.white,
        ),
        position: GFPosition.start,
        onChanged: (value) {},
        value: false,
        inactiveIcon: null,
      ),
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
          itemCount: itemQuestion!.options!.length,
          itemBuilder: (BuildContext context, int index) {
            int nomorPilihan = index + 1;
            String label = itemQuestion!.options![index]['display_name'];
            String goto = itemQuestion!.options![index]['go_to_init'] != null
                ? " (Next: ${itemQuestion!.options![index]['go_to_init']})"
                : "";

            return GFRadioListTile(
              value: false,
              groupValue: true,
              title: Text(
                "${label} ${goto}",
                style: TextStyle(fontSize: 14),
              ),
              size: 18,
              activeBgColor: Colors.green,
              padding: EdgeInsets.only(top: 5),
              margin: EdgeInsets.all(0),
              type: GFRadioType.basic,
              activeIcon: Icon(
                Icons.check,
                size: 15,
                color: Colors.white,
              ),
              position: GFPosition.start,
              onChanged: (value) {},
              inactiveIcon: null,
            );
          }),
    );
  }

  Widget generateResponseJawabanDropdown(bool hasOther) {
    var stringItem = <String>[];
    for (var iter in itemQuestion!.options!) {
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
      child: GFDropdown(
        items: items,
        elevation: 2,
        isExpanded: true,
        hint: Text(
          "Select one..",
          style: TextStyle(fontSize: 14),
        ),
        onChanged: (newValue) {
          print(newValue);
          // setState(() {
          //   dropdownValue = newValue;
          // });
        },
      ),
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
          itemCount: itemQuestion!.options!.length,
          itemBuilder: (BuildContext context, int index) => Container(
            height: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(itemQuestion!.options![index]['display_name']),
                SizedBox(
                  height: 5,
                ),
                GFRadio(
                  size: 25,
                  activeBorderColor: GFColors.SUCCESS,
                  value: 0,
                  groupValue: false,
                  onChanged: (val) {},
                  inactiveIcon: null,
                  radioColor: GFColors.SUCCESS,
                ),
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
    for (var item in itemQuestion!.options!) {
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
    for (var indikator in itemQuestion!.subQuestions!) {
      int indexIndikator = itemQuestion!.subQuestions!.indexWhere(((element) =>
          element['question_text'] == indikator['question_text']));
      var cell = <DataCell>[];
      cell.add(DataCell(Text(
        "${indikator['question_text']}",
        textScaleFactor: 0.9,
      )));
      for (var option in itemQuestion!.options!) {
        cell.add(DataCell(Container(
          child: GFRadio(
            size: 20,
            activeBorderColor: GFColors.SUCCESS,
            value: option['display_name'],
            groupValue: "",
            onChanged: (val) {},
            inactiveIcon: null,
            radioColor: GFColors.SUCCESS,
          ),
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

  Widget generateResponseJawabanSkalaLikert3() {
    var listLikert = <Widget>[];
    int index = 0;
    int nomor = 1;
    for (var item in itemQuestion!.subQuestions!) {
      listLikert.add(itemSkalaLikert());
      listLikert.add(SizedBox(
        height: 10,
      ));
      listLikert.add(Text(
        "(${itemQuestion!.subQuestions![index]!['question_text']})",
        textAlign: TextAlign.center,
        style: TextStyle(color: GFColors.FOCUS),
      ));
      listLikert.add(Divider(
        height: 25,
      ));
      index++;
      nomor++;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: listLikert,
    );
  }

  Center itemSkalaLikert() {
    return Center(
      child: Container(
        height: 80,
        child: ListView.separated(
          separatorBuilder: (BuildContext context, int index) => const SizedBox(
            width: 15,
          ),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: itemQuestion!.options!.length,
          itemBuilder: (BuildContext context, int index) => Container(
            width: Get.width / 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Center(
                      child: Text(
                    itemQuestion!.options![index]['display_name'],
                    maxLines: 3,
                    style: TextStyle(fontSize: 12),
                  )),
                ),
                SizedBox(
                  height: 0,
                ),
                GFRadio(
                  size: 25,
                  activeBorderColor: GFColors.SUCCESS,
                  value: 0,
                  groupValue: false,
                  onChanged: (val) {},
                  inactiveIcon: null,
                  radioColor: GFColors.SUCCESS,
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
        //initialValue: _initialValue,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        //icon: Icon(Icons.event),
        dateLabelText: 'Date',
        use24HourFormat: true,
        locale: const Locale('id', 'ID'),
        onChanged: (val) {
          print(val);
          print(DateTime.parse(val).toIso8601String());
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
      //initialValue: _initialValue,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      //icon: Icon(Icons.event),
      dateLabelText: 'Time',
      use24HourFormat: true,
      locale: const Locale('id', 'ID'),
      onChanged: (val) {
        print(val);
        print(DateTime.parse(val).toIso8601String());
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
          child: GFRating(
        value: 3,
        color: GFColors.DARK,
        borderColor: GFColors.DARK,
        onChanged: (value) {
          // setState(() {
          //   _rating = value;
          // });
        },
      )),
    );
  }
}
