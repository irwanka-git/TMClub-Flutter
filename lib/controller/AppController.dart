import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tmcapp/client.dart';
import 'package:tmcapp/controller/BlogController.dart';
import 'package:tmcapp/controller/ChatController.dart';
import 'package:tmcapp/controller/CompanyController.dart';
import 'package:tmcapp/controller/EventController.dart';
import 'package:tmcapp/controller/ImageController.dart';
import 'package:tmcapp/model/event_tmc.dart';
import 'package:tmcapp/model/event_tmc_detil.dart';
import 'package:tmcapp/model/list_id.dart';

class AppController extends GetxController {
  static AppController get to => Get.find<AppController>();
  //final isLoading = true.obs;
  final base_url = ApiClient().base_url;
  final appBarColor = CupertinoColors.activeOrange.color.obs;

  setAppBar(Color color_) {
    appBarColor(color_);
  }

  setAppBarRole(String role) {
    appBarColor(CupertinoColors.activeOrange.color);
    if (role == "superadmin") {
      setAppBar(CupertinoColors.activeBlue.color);
    }
    if (role == "admin") {
      setAppBar(CupertinoColors.activeGreen.color);
    }
    if (role == "member") {
      setAppBar(Color.fromARGB(255, 255, 140, 52));
    }
    if (role == "PIC") {
      setAppBar(Color.fromARGB(255, 2, 66, 79));
    }
  }
}
