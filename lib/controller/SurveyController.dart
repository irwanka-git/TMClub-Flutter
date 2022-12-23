// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tmcapp/client.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/controller/CompanyController.dart';
import 'package:tmcapp/model/akun_firebase.dart';
import 'package:tmcapp/model/answer_question.dart';
import 'package:tmcapp/model/question_survey.dart';
import 'package:tmcapp/model/survey.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:developer' as developer;
import 'package:path/path.dart' as path;

class SurveyController extends GetxController {
  final ListSurvey = <Survey>[].obs;
  final ListQuestion = <QuestionSurvey>[].obs;
  final ListStatisQuestion = <QuestionSurvey>[].obs;
  final ListDinamisQuestion = <QuestionSurvey>[].obs;
  final ListUsedDinamisQuestion = <String>[].obs;
  final ListConditionQuestion = <QuestionSurvey>[].obs;
  final ListQuestionPlay = <QuestionSurvey>[].obs;
  final ListQuestionIDAlert = <String>[].obs;
  final ListAnswer = <AnswerQuestion>[].obs;
  final ListQuestionIDVisible = <String>[].obs;

  static SurveyController get to => Get.find<SurveyController>();
  final authController = AuthController.to;
  final isLoading = true.obs;
  final InsertIDQuestionDraft = "".obs;
  final isSurveyByEvent = false.obs;
  final idEventSurvey = 0.obs;

  Future<void> getListSurvey() async {
    isLoading(true);
    //await CompanyController.to.getListCompany();
    //var collection = await ApiClient().requestGet("/company/", null);
    ListSurvey.clear();
    isLoading(true);
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };

    ListSurvey.clear();
    var collection = await ApiClient().requestGet("/survey/", header);
    for (var item in collection) {
      Survey temp = Survey.fromJson(jsonEncode(item));
      ListSurvey.add(temp);
    }
    await getListDraftSurveyFirebase();
    ListSurvey.sort((a, b) => a.draftID!.compareTo(b.draftID!));
    isLoading(false);
    return;
  }

  Future<void> getDetilSurvey(int id_survey) async {
    isLoading(true);
    //await CompanyController.to.getListCompany();
    //var collection = await ApiClient().requestGet("/company/", null);
    ListSurvey.clear();
    isLoading(true);
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };

    ListSurvey.clear();
    var collection = await ApiClient().requestGet("/survey/", header);
    for (var item in collection) {
      Survey temp = Survey.fromJson(jsonEncode(item));
      ListSurvey.add(temp);
    }
    await getListDraftSurveyFirebase();
    ListSurvey.sort((a, b) => a.draftID!.compareTo(b.draftID!));
    isLoading(false);
    return;
  }

  Future<void> getListDraftSurveyFirebase() async {
    isLoading(true);
    CollectionReference survey =
        FirebaseFirestore.instance.collection('survey');
    await survey
        .where('createBy', isEqualTo: authController.user.value.uid)
        .where('draft', isEqualTo: true)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        ListSurvey.add(Survey(
            id: 0,
            draftID: doc['draftID'],
            title: doc['title'],
            isDraft: doc['draft'],
            description: doc['description']));
      });
    });
    isLoading(false);
    return;
  }

  String getQuestionType(String id) {
    var QuestionType = {
      "0": "",
      "1": "Jawaban Singkat",
      "2": "Paragraf",
      "3": "Kotak Centang",
      "4": "Pilihan Ganda",
      "5": "Dropdown",
      "6": "Range (Skala Linier)",
      "7": "Skala Likert",
      "8": "Date (Tanggal)",
      "9": "Time (Jam)",
      "10": "Rating",
    };
    return QuestionType[id]!;
  }

  String generateRandomString(int length) {
    final _random = Random();
    const _availableChars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final randomString = List.generate(length,
            (index) => _availableChars[_random.nextInt(_availableChars.length)])
        .join();

    return randomString;
  }

  Future<bool> generateInitSurvey(String draftID, dynamic data) async {
    bool result = false;
    await FirebaseFirestore.instance
        .collection('survey')
        .doc(draftID)
        .set(
          data,
          SetOptions(merge: true),
        )
        .then((value) => result = true)
        .catchError((error) => print("Failed to add user: $error"));
    if (result == true) {
      await FirebaseFirestore.instance
          .collection('survey')
          .doc(draftID)
          .collection('questions')
          .doc(DateTime.now().microsecondsSinceEpoch.toString())
          .set({"question_type": "0", "question_text": ""})
          .then((value) => result = true)
          .catchError((error) => result = false);
    }
    return result;
  }

  Future<bool> updateInformasiSurvey(String draftID, dynamic data) async {
    bool result = false;
    await FirebaseFirestore.instance
        .collection('survey')
        .doc(draftID)
        .set(
          data,
          SetOptions(merge: true),
        )
        .then((value) => result = true)
        .catchError((error) => print("Failed to add user: $error"));
    return result;
  }

  Future<void> getListQuestionSurvey(String draftID) async {
    isLoading(true);
    //await CompanyController.to.getListCompany();
    //var collection = await ApiClient().requestGet("/company/", null);
    ListQuestion.clear();
    ListStatisQuestion.clear();
    ListDinamisQuestion.clear();

    isLoading(true);
    CollectionReference questionSurvey =
        FirebaseFirestore.instance.collection('survey');
    await questionSurvey
        .doc(draftID)
        .collection('questions')
        .where('question_type', isNotEqualTo: "0")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var item = {
          "init": doc['init'],
          "question_id": doc['question_id'],
          "question_text": doc['question_text'],
          "question_type": doc['question_type'],
          "description": doc['description'],
          "is_required": doc['is_required'],
          "options": doc['options'],
          "is_other_option": doc['is_other_option'],
          "sub_questions": doc['sub_questions'],
          "question_draftid": doc['question_draftid']
        };
        ListQuestion.add(QuestionSurvey.fromMap(item));
      });
    });
    ListQuestion.sort(
        (a, b) => a.questionDraftID!.compareTo(b.questionDraftID!));

    for (var item in ListQuestion) {
      if (item.init == null) {
        ListStatisQuestion.add(item);
      } else {
        ListDinamisQuestion.add(item);
      }
    }

    isLoading(false);
    return;
  }

  List<String> getUsedDinamisQuestion(String except) {
    List<String> usedDinamis = [];
    for (var item in ListQuestion) {
      if (item.questionType == "4" && item.questionDraftID != except) {
        for (var option in item.options!) {
          if (option['go_to_init'] != null) {
            usedDinamis.add(option['go_to_init']);
          }
        }
      }
    }
    return usedDinamis;
  }

  Future<void> getListConditionQuestionSurvey(
      String draftID, List<String> except) async {
    isLoading(true);
    //await CompanyController.to.getListCompany();
    //var collection = await ApiClient().requestGet("/company/", null);
    ListConditionQuestion.clear();
    isLoading(true);
    CollectionReference questionSurvey =
        FirebaseFirestore.instance.collection('survey');
    await questionSurvey
        .doc(draftID)
        .collection('questions')
        .where('init', isNull: false)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var item = {
          "init": doc['init'],
          "question_id": doc['question_id'],
          "question_text": doc['question_text'],
          "question_type": doc['question_type'],
          "description": doc['description'],
          "is_required": doc['is_required'],
          "options": doc['options'],
          "is_other_option": doc['is_other_option'],
          "sub_questions": doc['sub_questions'],
          "question_draftid": doc['question_draftid']
        };
        ListConditionQuestion.add(QuestionSurvey.fromMap(item));
      });
    });
    ListConditionQuestion.sort(
        (a, b) => a.questionDraftID!.compareTo(b.questionDraftID!));
    isLoading(false);
    return;
  }

  void setInsertIDQuestionDraft(String id) {
    InsertIDQuestionDraft(id);
  }

  Future<void> updateQuestionSurvey(
      String questionDraftID, dynamic data) async {
    isLoading(true);
    int index =
        ListQuestion.indexWhere((p0) => p0.questionDraftID == questionDraftID);
    isLoading(false);
    if (index >= 0) {
      ListQuestion[index] = QuestionSurvey.fromMap(data);
    }
    int index2 = ListStatisQuestion.indexWhere(
        (p0) => p0.questionDraftID == questionDraftID);
    isLoading(false);
    if (index2 >= 0) {
      ListStatisQuestion[index2] = QuestionSurvey.fromMap(data);
    }
    int index3 = ListDinamisQuestion.indexWhere(
        (p0) => p0.questionDraftID == questionDraftID);
    isLoading(false);
    if (index3 >= 0) {
      ListDinamisQuestion[index] = QuestionSurvey.fromMap(data);
    }
    return;
  }

  Future<bool> submitQuestionSurveyFirebase(
      String draftID, String questionDraftID, dynamic data) async {
    bool result = false;
    await FirebaseFirestore.instance
        .collection('survey')
        .doc(draftID)
        .collection('questions')
        .doc(questionDraftID)
        .set(
          data,
          SetOptions(merge: true),
        )
        .then((value) => result = true)
        .catchError((error) => print("Failed to add user: $error"));
    return result;
  }

  Future<void> deleteQuestionSurveyFirebase(
      String draftID, String questionDraftID) async {
    bool result = false;
    await FirebaseFirestore.instance
        .collection('survey')
        .doc(draftID)
        .collection('questions')
        .doc(questionDraftID)
        .delete()
        .then((value) => result = true)
        .catchError((error) => print("Failed to add user: $error"));
    if (result == true) {
      int index = ListQuestion.indexWhere(
          (p0) => p0.questionDraftID == questionDraftID);
      if (index > -1) {
        ListQuestion.removeAt(index);
      }
      int index2 = ListStatisQuestion.indexWhere(
          (p0) => p0.questionDraftID == questionDraftID);
      if (index2 > -1) {
        ListStatisQuestion.removeAt(index2);
      }
      int index3 = ListDinamisQuestion.indexWhere(
          (p0) => p0.questionDraftID == questionDraftID);
      if (index3 > -1) {
        ListDinamisQuestion.removeAt(index3);
      }
    }
    return;
  }

  Future<bool> deleteDraftSurveyFirebase(String draftID) async {
    bool result = false;
    await FirebaseFirestore.instance
        .collection('survey')
        .doc(draftID)
        .delete()
        .then((value) => result = true)
        .catchError((error) => print("Failed to add user: $error"));
    return result;
  }

  Future<Survey> getInformasiDraftSurvey(String draftID) async {
    Survey result = Survey();
    await FirebaseFirestore.instance
        .collection('survey')
        .doc(draftID)
        .get()
        .then((DocumentSnapshot data) {
      if (data.exists) {
        result = Survey(
            id: 0,
            title: data['title'],
            isDraft: data['draft'],
            description: data['description']!,
            draftID: draftID);
      }
    });
    return result;
  }

  Future<List<QuestionSurvey>> getListQuestionSurveyValue(
      String draftID) async {
    var listResult = <QuestionSurvey>[];
    listResult.clear();
    CollectionReference questionSurvey =
        FirebaseFirestore.instance.collection('survey');
    await questionSurvey
        .doc(draftID)
        .collection('questions')
        .where('question_type', isNotEqualTo: "0")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var item = {
          "init": doc['init'],
          "question_id": doc['question_draftid'],
          "question_text": doc['question_text'],
          "question_type": doc['question_type'],
          "description": doc['description'],
          "is_required": doc['is_required'],
          "options": doc['options'],
          "is_other_option": doc['is_other_option'],
          "sub_questions": doc['sub_questions'],
          "question_draftid": doc['question_draftid']
        };
        listResult.add(QuestionSurvey.fromMap(item));
      });
    });
    listResult.sort((a, b) => a.questionDraftID!.compareTo(b.questionDraftID!));
    return listResult;
  }

  Future<bool> submitGenerateFormSurveyToServer(String draftID) async {
    var dataSubmit = {};
    bool validSurvey = false;
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };

    await FirebaseFirestore.instance
        .collection('survey')
        .doc(draftID)
        .get()
        .then((DocumentSnapshot data) {
      if (data.exists) {
        dataSubmit['title'] = data['title'];
        dataSubmit['description'] = data['description'];
        validSurvey = true;
      }
    });
    if (validSurvey) {
      await getListQuestionSurvey(draftID);
      dataSubmit['questions'] = [];

      for (var question in ListStatisQuestion) {
        var getOption = [];
        for (var item in question.options!) {
          getOption.add(item);
        }
        if (question.options!.length > 0) {
          int index = 0;
          for (var item in question.options!) {
            if (item['go_to_init'] != null) {
              var cek = ListDinamisQuestion.firstWhereOrNull(
                  (element) => element.init == item['go_to_init']);
              if (cek == null) {
                getOption[index]['go_to_init'] = null;
              }
            }
          }
        }
        //developer.log("options", error: jsonEncode(getOption));
        var _questionTmp = {
          "init": null,
          "question_text": question.questionText ?? "" as String,
          "question_type": question.questionType!,
          "description": question.description,
          "is_required": question.isRequired!,
          "is_other_option": question.isOtherOption!,
          "options": getOption,
          "sub_questions": question.subQuestions ?? [],
        };
        dataSubmit['questions'].add(_questionTmp);
      }

      for (var question in ListDinamisQuestion) {
        var getOption = [];
        for (var item in question.options!) {
          getOption.add(item);
        }
        if (question.options!.isNotEmpty) {
          int index = 0;
          for (var item in question.options!) {
            if (item['go_to_init'] != null) {
              var cek = ListDinamisQuestion.firstWhereOrNull(
                  (element) => element.init == item['go_to_init']);
              if (cek == null) {
                getOption[index]['go_to_init'] = null;
              }
            }
          }
        }
        //developer.log("options", error: jsonEncode(getOption));
        var _questionTmp = {
          "init": question.init,
          "question_text": question.questionText ?? "" as String,
          "question_type": question.questionType!,
          "description": question.description,
          "is_required": question.isRequired!,
          "is_other_option": question.isOtherOption!,
          "options": getOption,
          "sub_questions": question.subQuestions ?? [],
        };
        dataSubmit['questions'].add(_questionTmp);
      }
      developer.log("data submit", error: jsonEncode(dataSubmit));
      //return false;
      if (dataSubmit['questions'] == []) {
        return false;
      }
      var response =
          await ApiClient().requestPost('/survey/', dataSubmit, header);
      //print(response);
      if (response['status_code'] == 201 || response['status_code'] == 200) {
        //print(response['data']);
        deleteDraftSurveyFirebase(draftID);
        return true;
      }
    }
    return false;
  }

  Future<dynamic> getResultSurveyByEvent(int id_event, int id_survey) async {
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    String url =
        '/survey/${id_event.toString()}/${id_survey.toString()}/result/';
    //print(url);
    var response = await ApiClient().requestGet(url, header);
    if (response != null) {
      //print(response);
      return response;
    }
    return null;
  }

  Future<dynamic> getResultSurveyByID(int id_survey) async {
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    String url = '/survey/${id_survey.toString()}/result/';
    //print(url);
    var response = await ApiClient().requestGet(url, header);
    if (response != null) {
      //print(response);
      return response;
    }
    return null;
  }

  Future<bool> submitJawabanSurvey(int id, dynamic data) async {
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    developer.log(jsonEncode(data));
    String url = '/survey/${id.toString()}/response/';
    //print(url);
    var response = await ApiClient().requestPost(url, data, header);
    //print(response);
    if (response['status_code'] == 201 ||
        response['status_code'] == 204 ||
        response['status_code'] == 200) {
      //print(response['data']);
      //deleteDraftSurveyFirebase(draftID);
      return true;
    }
    return false;
  }

  Future<bool> submitJawabanSurveyEvent(int id_survey, int id_event) async {
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var data = {"survey_id": id_survey, "responses": getConvertAnswerData()};
    developer.log(jsonEncode(data));

    ///event/{id}/survey/
    String url = '/event/${id_event.toString()}/survey/';
    //print(url);
    var response = await ApiClient().requestPost(url, data, header);
    //print(response);
    if (response['status_code'] == 201 ||
        response['status_code'] == 204 ||
        response['status_code'] == 200) {
      //print(response['data']);
      //deleteDraftSurveyFirebase(draftID);
      return true;
    }
    return false;
  }

  Future<bool> submitDeleteSurveyServer(int surveyID) async {
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var response = await ApiClient().delete('/survey/${surveyID}/', header);
    //print(response);
    if (response == null || response == "") {
      print("KOK BISA NULLL");
      return true;
    }
    if (response['status_code'] == 404) {
      //print(response['data']);
      return false;
    }
    if (response['status_code'] == 200 ||
        response['status_code'] == 201 ||
        response['status_code'] == 204) {
      //print(response['data']);
      return true;
    }
    return false;
  }

  Future<void> createInitAnswer(List<QuestionSurvey> questions) async {
    ListAnswer.clear();
    for (var item in questions) {
      ListAnswer.add(getDefaultAnswer(item));
    }
    clearQuestionIDAlert();
    print("MEMBUAT INIT ANSWEWER");
    return;
  }

  AnswerQuestion getDefaultAnswer(QuestionSurvey item) {
    String id = item.questionID!;
    List<String> answer = [];
    if (item.questionType == "1" ||
        item.questionType == "2" ||
        item.questionType == "4" ||
        item.questionType == "5" ||
        item.questionType == "6" ||
        item.questionType == "8" ||
        item.questionType == "9" ||
        item.questionType == "10") {
      answer.add("");
    }
    if (item.questionType == "3") {
      for (var option in item.options!) {
        answer.add("");
      }
      if (item.isOtherOption == true) {
        answer.add("");
      }
    }
    if (item.questionType == "7") {
      for (var subQuestion in item.subQuestions!) {
        answer.add("");
      }
    }
    var _ans = {
      "id": id,
      "answer": answer,
      "required": item.isRequired!,
      "question_type": item.questionType
    };
    //print(_ans);
    return AnswerQuestion.fromMap(_ans);
  }

  void clearQuestionPlaying() {
    ListQuestionPlay.clear();
  }

  void clearQuestionIDAlert() {
    ListQuestionIDAlert.clear();
  }

  void addQuestionIDAlert(String questionID) {
    ListQuestionIDAlert.add(questionID);
  }

  void addQuestionPlaying(QuestionSurvey question) {
    ListQuestionPlay.add(question);
  }

  void clearQuestionVisible() {
    ListQuestionIDVisible.clear();
  }

  void addQuestionVisible(String questionID) {
    ListQuestionIDVisible.add(questionID);
  }

  void insertQuestionVisible(int index, String questionID) {
    isLoading(true);
    int getIndex = ListQuestionIDVisible.indexOf(questionID);
    if (getIndex == -1) {
      ListQuestionIDVisible.insert(index, questionID);
    }
    isLoading(false);
  }

  void removeQuestionVisible(String questionID) {
    isLoading(true);
    int getIndex = ListQuestionIDVisible.indexOf(questionID);
    if (getIndex > -1) {
      ListQuestionIDVisible.removeAt(getIndex);
    }
    isLoading(false);
  }

  AnswerQuestion getAnswerQuestion(String questionID) {
    AnswerQuestion result = AnswerQuestion();
    AnswerQuestion? cek =
        ListAnswer.firstWhereOrNull((element) => element.id == questionID);
    if (cek != null) {
      return cek;
    }
    return result;
  }

  void updateAnswerQuestion(String questionID, List<String> answer) {
    int index = ListAnswer.indexWhere((element) => element.id == questionID);
    if (index > -1) {
      bool isRequired = ListAnswer[index].required!;
      ListAnswer[index] = AnswerQuestion.fromMap(
          {"id": questionID, "answer": answer, "required": isRequired});
    }
  }

  Future<void> generatePreviewFormSurvey(Survey itemSurvey, bool submit) async {
    if (itemSurvey.isDraft == false) {
      dynamic header = {
        HttpHeaders.authorizationHeader:
            'Token ${authController.user.value.token}'
      };
      SmartDialog.showLoading(msg: "Loading...");
      var result = Survey();
      var collection =
          await ApiClient().requestGet("/survey/${itemSurvey.id}", header);
      if (collection == null) {
        return;
      } else {
        result = Survey.fromMap(collection);
        if (collection['questions'] != []) {
          for (var item in collection['questions']) {
            result.addQuestion(QuestionSurvey.fromMap(item));
          }
        }
      }
      if (result.questions != null) {
        await createInitAnswer(result.questions!);
      }

      Future.delayed(Duration(milliseconds: 200), () {
        SmartDialog.dismiss();
        if (submit == true) {
          isSurveyByEvent.value = false;
          Get.toNamed('/kelola-survey-input', arguments: {'survey': result});
        } else {
          Get.toNamed('/kelola-survey-preview', arguments: {'survey': result});
        }
      });
    } else {
      var result = Survey();
      SmartDialog.showLoading(msg: "Loading...");
      await getInformasiDraftSurvey(itemSurvey.draftID!)
          .then((value) => result = value);
      var resultQuestion = [];
      await getListQuestionSurveyValue(itemSurvey.draftID!)
          .then((value) => resultQuestion.addAll(value));
      for (var item in resultQuestion) {
        result.addQuestion(item);
      }
      if (result.questions != null) {
        await createInitAnswer(result.questions!);
      }

      Future.delayed(Duration(milliseconds: 300), () {
        SmartDialog.dismiss();
        Get.toNamed('/kelola-survey-preview', arguments: {'survey': result});
      });
    }
  }

  Future<void> generateOpenFormSurveyDirect(int idSurvey, bool submit) async {
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    SmartDialog.showLoading(msg: "Loading...");
    var result = Survey();
    var collection =
        await ApiClient().requestGet("/survey/${idSurvey}", header);
    if (collection == null) {
      return;
    } else {
      result = Survey.fromMap(collection);
      if (collection['questions'] != []) {
        for (var item in collection['questions']) {
          result.addQuestion(QuestionSurvey.fromMap(item));
        }
      }
    }
    if (result.questions != null) {
      await createInitAnswer(result.questions!);
    }

    Future.delayed(Duration(milliseconds: 200), () {
      SmartDialog.dismiss();
      Get.toNamed('/kelola-survey-input', arguments: {'survey': result});
    });
  }

  Future<void> generatePreviewFormSurveyEvent(
      Survey itemSurvey, int id_event) async {
    if (itemSurvey.isDraft == false) {
      dynamic header = {
        HttpHeaders.authorizationHeader:
            'Token ${authController.user.value.token}'
      };
      SmartDialog.showLoading(msg: "Loading...");
      var result = Survey();
      var collection =
          await ApiClient().requestGet("/survey/${itemSurvey.id}", header);
      if (collection == null) {
        print("SURVEY NOT FOUND");
        return;
      } else {
        result = Survey.fromMap(collection);
        if (collection['questions'] != []) {
          for (var item in collection['questions']) {
            result.addQuestion(QuestionSurvey.fromMap(item));
          }
        }
      }
      if (result.questions != null) {
        await createInitAnswer(result.questions!);
      }
      isSurveyByEvent.value = true;
      idEventSurvey.value = id_event;
      SmartDialog.dismiss();
      //developer.log(jsonEncode(result));
      Get.toNamed('/kelola-survey-input', arguments: {'survey': result});
    }
  }

  Future<void> generatePreviewFormSurveyEventOffNamed(
      Survey itemSurvey, int id_event) async {
    if (itemSurvey.isDraft == false) {
      dynamic header = {
        HttpHeaders.authorizationHeader:
            'Token ${authController.user.value.token}'
      };
      SmartDialog.showLoading(msg: "Loading...");
      var result = Survey();
      var collection =
          await ApiClient().requestGet("/survey/${itemSurvey.id}", header);
      if (collection == null) {
        return;
      } else {
        result = Survey.fromMap(collection);
        if (collection['questions'] != []) {
          for (var item in collection['questions']) {
            result.addQuestion(QuestionSurvey.fromMap(item));
          }
        }
      }
      if (result.questions != null) {
        await createInitAnswer(result.questions!);
      }
      isSurveyByEvent.value = true;
      idEventSurvey.value = id_event;
      SmartDialog.dismiss();
      Get.offNamed('/kelola-survey-input', arguments: {'survey': result});
    }
  }

  List<dynamic> getConvertAnswerData() {
    var responsAnswer = [];

    for (var item in ListAnswer.value) {
      if (ListQuestionIDVisible.contains(item.id)) {
        QuestionSurvey? questionCurrent = ListQuestionPlay.firstWhereOrNull(
            (element) => element.questionID == item.id);
        List<String> arrAnswer = item.answer!;
        List<String> arrAnswerValid = [];
        arrAnswerValid.clear();
        for (var ans in arrAnswer) {
          if (ans != "") {
            arrAnswerValid.add(ans);
          }
        }
        print("QUESTION TYPE: ${item.questionType}");

        if (questionCurrent!.questionType != "7") {
          String cekAnswer = arrAnswerValid.join(';');
          //print(cekAnswer);
          //print("${item.id} ${item.required}");
          var temp = {"question_id": item.id, "response": cekAnswer};
          responsAnswer.add(temp);
        } else {
          //KHUSUS SUB QUESTION (LIKER)
          int index = 0;
          for (var subQus in questionCurrent.subQuestions!) {
            var temp = {
              "question_id": subQus["question_id"].toString(),
              "response": arrAnswerValid[index]
            };
            //print(temp);
            responsAnswer.add(temp);
            index++;
          }
        }
      }
    }
    return responsAnswer;
  }

  Future<bool> cekValidasiJawaban() async {
    clearQuestionIDAlert();
    bool valid = true;
    isLoading(true);
    //print(ListQuestionIDVisible.length);

    for (var item in ListAnswer.value) {
      if (ListQuestionIDVisible.contains(item.id)) {
        //developer.log(jsonEncode(item));
        QuestionSurvey? question = ListQuestionPlay.firstWhereOrNull(
            (element) => element.questionID == item.id);
        List<String> arrAnswer = item.answer!;
        List<String> arrAnswerValid = [];
        arrAnswerValid.clear();
        for (var ans in arrAnswer) {
          if (ans != "") {
            arrAnswerValid.add(ans);
          }
        }
        String cekAnswer = arrAnswerValid.join(';');
        //developer.log(jsonEncode(question!));
        //print(item.id);
        print(cekAnswer);
        print("${item.id} ${item.required}");
        if (cekAnswer == "" && item.required == true) {
          addQuestionIDAlert(item.id!);
          valid = false;
        }
        //skala likert
        // print(arrAnswerValid.length);
        // print(question!.subQuestions!.length);
        // print(question.questionType!);
        if (question!.questionType == "7") {
          if (arrAnswerValid.isNotEmpty) {
            if (arrAnswerValid.length != question.subQuestions!.length) {
              addQuestionIDAlert(item.id!);
              print("LIKERT KURANG ${item.id!}");
              valid = false;
            }
          } else {
            if (question.isRequired == true) {
              addQuestionIDAlert(item.id!);
              print("LIKERT REQUIRED ${item.id!}");
              valid = false;
            }
          }
        }
      }
    }
    await Future.delayed(Duration(milliseconds: 500), () {
      isLoading(false);
      return valid;
    });
    return valid;
  }

  Future<List<int>> getListNeedSurvey(int id) async {
    List<int> result = [];
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${AuthController.to.user.value.token}'
    };
    // /event/{id}/survey-need-response/
    var response = await ApiClient()
        .requestGet("/event/${id.toString()}/survey-need-response/", header);
    //print(response);
    if (response != null) {
      for (var item in response) {
        //print(item);
        result.add(item['id']);
      }
    }
    return result;
  }

  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();
    final info = statuses[Permission.storage].toString();
    print(info);
  }

  Future<void> openFile(filePath) async {
    final _result = await OpenFile.open(filePath);
  }

  Future<bool> downloadExcelHasilSurvey(
      int id, String title, int id_event_ref) async {
    _requestPermission();
    SmartDialog.showLoading(msg: "Download...");
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var url = "";
    if (id_event_ref == 0) {
      url = "/survey/${id}/result-export/";
    } else {
      url = "/survey/${id_event_ref}/${id}/result-export/";
    }
    print(url);
    var response = await ApiClient().requestPostBlob(url, null, header);
    //print(response['header']['content-disposition']);
    //print(response['content']);

    String path_download = '';
    if (Platform.isIOS) {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      path_download = appDocDir.path;
    } else {
      path_download = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOWNLOADS);
    }

    Random random = Random();
    int _randomNumber12 = 1000 + random.nextInt(8000);

    // This is the saved image path
    // You can use it to display the saved image later
    final downloadPathExcel = path.join(path_download,
        "${_randomNumber12.toString()}${title}-result-survey.xlsx");

    // Downloading
    final imageFile = File(downloadPathExcel);
    String savePath = "";
    await imageFile
        .writeAsBytes(response['content'])
        .then((value) => savePath = value.path);
    await OpenFile.open(downloadPathExcel);
    SmartDialog.dismiss();
    return true;
  }

  Future<bool> sendNotificationFilter(
      int id, String param, dynamic postdata) async {
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    //print('/event/${pk.toString()}/survey-send/');
    var url = '/survey/${id}/send/${param}';
    print(url);
    var response = await ApiClient().requestPost(url, postdata, header);
    if (response == null) {
      return false;
    }
    print(response);
    if (response['status_code'] == 201 || response['status_code'] == 200) {
      //print(response['data']);
      return true;
    }
    return false;
  }
}
