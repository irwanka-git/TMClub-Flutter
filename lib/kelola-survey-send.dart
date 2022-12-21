// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, unrelated_type_equality_checks

import 'dart:convert';
import 'dart:math';

import 'package:dropdown_search/dropdown_search.dart';
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
import 'package:tmcapp/controller/CompanyController.dart';
import 'package:tmcapp/controller/SurveyController.dart';
import 'package:tmcapp/model/company.dart';
import 'package:tmcapp/model/question_survey.dart';
import 'package:tmcapp/model/survey.dart';
import 'package:tmcapp/widget/form-answer-question.dart';

class KelolaSurveySendScreen extends StatefulWidget {
  @override
  State<KelolaSurveySendScreen> createState() => _KelolaSurveySendScreenState();
}

class _KelolaSurveySendScreenState extends State<KelolaSurveySendScreen>
    with SingleTickerProviderStateMixin {
  final authController = AuthController.to;
  final surveyController = SurveyController.to;
  final companyController = CompanyController.to;
  final formKey = new GlobalKey<FormState>();
  late Survey itemSurvey;
  // ignore: non_constant_identifier_names
  final ListQuestions = <QuestionSurvey>[].obs;
  final ListQuestionPlay = <QuestionSurvey>[].obs;
  final ListFormAnswer = <dynamic>[].obs;
  final ListQuestionVisible = <String>[].obs;
  final isInitStateLoading = true.obs;
  final selectAllCompany = false.obs;
  final selectedCompanyID = "".obs;
  final selectRole = "".obs;

  @override
  void initState() {
    setState(() {
      isInitStateLoading(true);
    });
    itemSurvey = Get.arguments['item'];
    //id_event = Get.arguments['survey'];
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await CompanyController.to.getListCompany().then((value) {
        setState(() {
          isInitStateLoading(false);
        });
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
                "${itemSurvey.title}",
                textScaleFactor: 1.1,
              )
            ],
          ),
          backgroundColor: GFColors.SUCCESS,
          elevation: 1,
        ),
        backgroundColor: Color.fromARGB(255, 243, 243, 244),
        body: Obx(() => Container(
              child:
                  isInitStateLoading == false ? buildBodyPage() : Container(),
            )));
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
      ],
    );
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
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Send Notification Survey",
                      textScaleFactor: 1.1,
                      style: TextStyle(color: GFColors.DARK),
                    ),
                    SizedBox(
                      height: 4,
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
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(color: GFColors.WHITE),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Send To:"),
                    SizedBox(
                      height: 5,
                    ),
                    generateSelectRoleDropdown(),
                    SizedBox(
                      height: 20,
                    ),
                    GFCheckboxListTile(
                      title: Text(
                        'All Companies',
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
                          selectAllCompany.value = value;
                        });
                      },
                      value: selectAllCompany.value,
                      inactiveIcon: null,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    DropdownSearch<Company>(
                      enabled: selectAllCompany.value == false,
                      itemAsString: (item) => item!.companyAsStringByName(),
                      onChanged: (value) =>
                          {selectedCompanyID.value = value!.pk!},
                      mode: Mode.DIALOG,
                      showSearchBox: true,
                      items: companyController.ListCompany,
                      dropdownBuilder: _customDropDownCompany,
                      popupItemBuilder: _customPopupItemCompany,
                      dropdownSearchDecoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                          labelText: "Company",
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 14),
                          labelStyle:
                              TextStyle(color: Colors.grey, fontSize: 13),
                          border: OutlineInputBorder()),
                      showFavoriteItems: true,
                      searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      )),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GFButton(
                      icon: Icon(
                        Icons.send,
                        color: GFColors.WHITE,
                        size: 18,
                      ),
                      color: GFColors.SUCCESS,
                      onPressed: ()async {
                        // print(selectedCompanyID.value);
                        // print(selectAllCompany.value);
                        // print(selectRole.value);
                        if (selectAllCompany.value == false &&
                                selectedCompanyID.value == "" ||
                            selectRole.value == "") {
                          GFToast.showToast(
                              'Please Select Company and User Type!', context,
                              trailing: const Icon(
                                Icons.error_outline,
                                color: GFColors.WARNING,
                              ),
                              toastBorderRadius: 5.0);
                        } else {
                          var param = "?role=${selectRole.value.toLowerCase()}";
                          if (selectAllCompany.value == false) {
                            param =
                                "?role=${selectRole.value.toLowerCase()}&company_id=${selectedCompanyID.value}";
                          }
                          var postData = {"email": []};
                          bool succesSend = false;
                          SmartDialog.showLoading(msg: "Sending..");
                          await surveyController.sendNotificationFilter(itemSurvey.id!, param, postData).then((value){
                            succesSend = value;
                          });
                          SmartDialog.dismiss();
                          if(succesSend==true){
                              GFToast.showToast(
                                  'Notification Sent Successfully', context,
                                  trailing: const Icon(
                                    Icons.check,
                                    color: GFColors.SUCCESS,
                                  ),
                                  toastPosition: GFToastPosition.BOTTOM,
                                  toastBorderRadius: 5.0);
                          }else{
                            GFToast.showToast(
                                  'Notification Sent Failed', context,
                                  toastPosition: GFToastPosition.BOTTOM,
                                  trailing: const Icon(
                                    Icons.error_outline,
                                    color: GFColors.DANGER,
                                  ),
                                  toastBorderRadius: 5.0);
                          }
                          
                        }
                      },
                      text: "Send Notification",
                      blockButton: true,
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

  Widget _customDropDownCompany(BuildContext context, Company? item) {
    return Container(
      child: Obx(() => selectAllCompany.value == false
          ? Container(
              margin: EdgeInsets.all(0),
              child: (item == null)
                  ? Text("Search Company",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 13,
                          color: Color.fromARGB(235, 158, 158, 158)))
                  : Text(
                      item.displayName!,
                      style: TextStyle(fontSize: 14),
                    ))
          : Container(
              child: Text(
                "All",
                style: TextStyle(fontSize: 14),
              ),
            )),
    );
  }

  Widget _customPopupItemCompany(
      BuildContext context, Company item, bool isSelected) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: ListTile(
          minLeadingWidth: 2,
          contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 3),
          dense: true,
          visualDensity: VisualDensity(vertical: -3),
          title: Text(
            item.displayName!,
            style: TextStyle(fontSize: 14),
          ),
        ));
  }

  Widget generateSelectRoleDropdown() {
    var stringItem = <String>[];
    //stringItem.add('ADMIN');
    stringItem.add('PIC');
    stringItem.add('MEMBER');
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
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: Obx(() => GFDropdown(
            items: items,
            value: selectRole.value != "" ? selectRole.value : null,
            elevation: 2,
            isExpanded: true,
            hint: Text(
              "Choose..",
              style: TextStyle(fontSize: 14),
            ),
            onChanged: (newValue) {
              selectRole.value = newValue.toString();
            },
          )),
    );
  }
}
