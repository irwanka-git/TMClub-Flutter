// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tmcapp/client.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/model/company.dart';
import 'package:tmcapp/model/event_tmc.dart';
import 'package:tmcapp/model/event_tmc_detil.dart';
import 'package:tmcapp/model/list_id.dart';

class CompanyController extends GetxController {
  final ListCompany = <Company>[].obs;
  static CompanyController get to => Get.find<CompanyController>();
  final authController = AuthController.to;
  final isLoading = true.obs;

  // void getListCompanyFirebase() async {
  //   isLoading(true);
  //   ListCompany.clear();
  //   CollectionReference company =
  //       FirebaseFirestore.instance.collection('company');
  //   await company.get().then((QuerySnapshot querySnapshot) {
  //     querySnapshot.docs.forEach((doc) {
  //       ListCompany.add(ListID(
  //           id: doc['id'], title: doc['companyName'], subtitle: doc['city']));
  //     });
  //   });
  //   isLoading(false);
  // }

  Future<void> getListCompany() async {
    isLoading(true);

    var collection = await ApiClient().requestGet("/company/", null);
    if (collection == null) {
      return;
    }
    ListCompany.clear();
    for (var item in collection) {
      ListCompany.add(Company.fromJson(jsonEncode(item)));
    }
    isLoading(false);
    return;
  }

  Future<Company?> getCompanybyPK(int pk) async {
    var resultCompany = Company();
    var response = await ApiClient().requestGet("/company/$pk/", null);
    if (response != null) {
      resultCompany = Company.fromJson(jsonEncode(response));
      return resultCompany;
    }
    return null;
  }

  String getCompanyName(String idCompany) {
    //int pk = int.parse(idCompany);
    print("jumlah Company: ${ListCompany.value.length}");
    print("ID Company: ${idCompany.toString()}");

    if (ListCompany.value.isNotEmpty) {
      var cek = ListCompany.value
          .firstWhereOrNull((element) => element.pk! == idCompany.toString());
      if (cek != null) {
        return cek.displayName!;
      }
      return "";
    }
    return "";
  }

  Company? getCompanyByListByPK(String idCompany) {
    //int pk = int.parse(idCompany);
    print("jumlah Company: ${ListCompany.value.length}");
    print("ID Company: ${idCompany.toString()}");
    Company? cek = Company();
    if (ListCompany.value.isNotEmpty) {
      cek = ListCompany.value
          .firstWhereOrNull((element) => element.pk! == idCompany.toString());
    }
    return cek;
  }

  Future<bool> postingCreate(Map<String, dynamic> data) async {
    dynamic headers = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    //print(data);
    var response = await ApiClient().requestPost('/company/', data, headers);
    //print(response['status_code']);
    if (response['status_code'] == 201) {
      var data = response['data'];
      return true;
    }
    return false;
  }

  Future<bool> updateCompany(Map<String, dynamic> data, String pk) async {
    dynamic headers = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    //print(data);
    var response = await ApiClient().patch('/company/${pk}/', data, headers);
    //print(response);
    if (response['status_code'] == 200) {
      var data = response['data'];
      return true;
    }
    return false;
  }

  Future<bool> deleteCompany(String pk) async {
    dynamic headers = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    //print(data);
    var response = await ApiClient().delete('/company/${pk}/', headers);
    //print(response);
    if (response['status_code'] == 200) {
      var data = response['data'];
      return true;
    }
    return false;
  }
}
