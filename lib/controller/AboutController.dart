import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tmcapp/client.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/model/about_item.dart';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:tmcapp/model/resources.dart';

class AboutController extends GetxController {
  static AboutController get to => Get.find<AboutController>();
  //final isLoading = true.obs;
  final base_url = ApiClient().base_url;
  final appBarColor = CupertinoColors.activeOrange.color.obs;
  final listAbout = <AboutItem>[].obs;
  final isLoading = false.obs;
  final authController = AuthController.to;
  final currentAbout = AboutItem(id: 0).obs;
  final annualdirectories = <Resources>[].obs;

  addItemAnnualDirectories(Resources item) {
    annualdirectories.add(item);
  }

  clearItemAnnualDirectories() {
    annualdirectories.clear();
  }

  removeItemAnnualDirectori(index) {
    annualdirectories.removeAt(index);
  }

  Future<bool> getListAbout() async {
    currentAbout.value = AboutItem(id: 0);
    listAbout.clear();
    int currentID = 0;
    var response = await ApiClient().requestGet("/about/about/", null);
    if (response == null) {
      isLoading(false);
      return true;
    }
    for (var item in response) {
      var aboutItem = {
        "id": item['id'],
        "md": item['md'],
        "description": item['description'],
        "organizations": []
      };
      listAbout.add(AboutItem.fromMap(aboutItem));
      currentID = item['id'];
    }

    if (currentID > 0) {
      await getDetilAbout(currentID);
    } else {
      var aboutItem = {
        "id": 0,
        "md": "",
        "description": "",
        "organizations": [],
        "annual_directories": []
      };
      //print(aboutItem);
      currentAbout(AboutItem.fromMap(aboutItem));
    }
    isLoading(false);
    return true;
  }

  Future<bool> getDetilAbout(int id) async {
    listAbout.clear();
    var response = await ApiClient().requestGet("/about/about/${id}/", null);
    if (response == null) {
      isLoading(false);
      return true;
    }
    var aboutItem = {
      "id": response['id'],
      "md": response['md'],
      "description": response['description'],
      "organizations": response['organizations'],
      "annual_directories": response['annual_directories']
    };
    print(aboutItem);
    currentAbout(AboutItem.fromMap(aboutItem));
    isLoading(false);
    return true;
  }

  Future<bool> updateAbout(var data) async {
    dynamic headers = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    //print(data);
    //developer.log(jsonEncode(data));
    var response = {};
    if (currentAbout.value.id == 0) {
      response = await ApiClient().requestPost('/about/about/', data, headers);
    } else {
      var id = currentAbout.value.id;
      print("ID ABOUT:${id}");
      response = await ApiClient().patch('/about/about/${id}/', data, headers);
    }
    print(response);
    // if (listAbout.isEmpty) {
    //   response = await ApiClient().requestPost('/about/about/', data, headers);
    // } else {
    //   var id = currentAbout.value.id;
    //   response = await ApiClient().patch('/about/about/${id}', data, headers);
    //   print(response);
    // }
    //print(response);
    if (response['status_code'] == 201 || response['status_code'] == 200) {
      //var data = response['data'];
      return true;
    }
    return false;
  }
}
