// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:getwidget/colors/gf_color.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:tmcapp/client.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/model/answer_question.dart';
import 'package:tmcapp/model/notification.dart';
import 'package:tmcapp/model/question_survey.dart';
import 'package:tmcapp/model/survey.dart';
import 'dart:developer' as developer;

import 'BottomTabController.dart';

class NotifikasiController extends GetxController {
  static NotifikasiController get to => Get.find<NotifikasiController>();
  final notifikasiUnreadCount = 0.obs;
  final tabControl = BottomTabController.to;
  final ListNotification = <NotificationItem>[].obs;
  final isLoading = false.obs;

  void notifikasiAktivasiMember() {
    Get.snackbar('Attention', "Your account has not been activated, please contact the company PIC to activate",
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 10),
          icon: Icon(Icons.notifications, color: Colors.white,),
          borderColor: CupertinoColors.systemGrey,
          borderWidth: 1.0,
          margin: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
          backgroundColor: CupertinoColors.black,
          colorText: Colors.white);
  }
  void getNotifikasiCountUnreadSurvey() async {
    //print(DateTime.now());
    isLoading.value = true;
    if (AuthController.to.user.value.role == "member" &&
        AuthController.to.user.value.idCompany == "null") {
      //print("Please contact your company PIC for account activation");
      notifikasiAktivasiMember();
    }
    if ((AuthController.to.user.value.role == "member" ||
            AuthController.to.user.value.role == "PIC") &&
        AuthController.to.user.value.idCompany != "null") {
      notifikasiUnreadCount.value = 0;
      //print("Cek Notifikasi Survey");
      dynamic header = {
        HttpHeaders.authorizationHeader:
            'Token ${AuthController.to.user.value.token}'
      };
      int old_notifacation = tabControl.countNotificationItem.value;
      var response = await ApiClient()
          .requestGet("/notification/count/?status=unread", header);
      //print(response);
      if (response != null) {
        //print(response['notification_count']);
        notifikasiUnreadCount.value = response['notification_count'];
        tabControl.setcountNotificationItem(notifikasiUnreadCount.value);
        getListNotification();
        // if( notifikasiUnreadCount.value > 0){
        //    showNotificationAlert();
        // }
      }
    }
    if (AuthController.to.user.value.role == "") {
      tabControl.setcountNotificationItem(0);
    }
  }

  void getListNotification() async {
    ListNotification.clear();
    isLoading.value = true;
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${AuthController.to.user.value.token}'
    };
    // var response1 = await ApiClient().requestGet("/notification/?status=unread", header);
    // if (response1 != null) {
    //   for (var item in response1) {
    //     //print(item);
    //     ListNotification.add(Notification.fromMap(item));
    //   }
    // }

    var response2 =
        await ApiClient().requestGet("/notification/?status=unread", header);
    if (response2 != null) {
      for (var item in response2) {
        //print(item);
        ListNotification.add(NotificationItem.fromMap(item));
      }
    }
    isLoading.value = false;
  }

  // void clearNotificationAlert() async {
  //   print("CLEAR NOTIFIKASI");
  //   dynamic header = {
  //     HttpHeaders.authorizationHeader:
  //         'Token ${AuthController.to.user.value.token}'
  //   };
  //   var response = await ApiClient()
  //       .requestPost("/notification/mark-read-all/", null, header);
  //   print(response);
  // }

  Future<NotificationItem> getDetilNotification(int id) async {
    NotificationItem res = NotificationItem(id: 0);
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${AuthController.to.user.value.token}'
    };
    var response = await ApiClient().requestGet("/notification/${id}/", header);
    //print("getDetilNotfication");
    //print(response);
    if (response != null) {
      res = NotificationItem.fromMap(response);
    }
    return res;
  }

  Future<dynamic> getSurveyNeedResponse(int id) async {
    var result = null;
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
        result = {"id": item['id'], "title": item['title']};
        //print(result);
        return result;
      }
    }
    return result;
  }

  Future<bool> markReadAll() async {
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${AuthController.to.user.value.token}'
    };
    int old_notifacation = tabControl.countNotificationItem.value;
    var response = await ApiClient()
        .requestPost("/notification/mark-read-all/", null, header);
    //print(response);
    if (response != null) {
      return true;
    }
    return false;
  }
}
