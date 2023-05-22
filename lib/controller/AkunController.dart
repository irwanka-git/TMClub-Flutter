// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmcapp/client.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/controller/CompanyController.dart';
import 'package:tmcapp/model/akun_firebase.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AkunController extends GetxController {
  static AkunController get to => Get.find<AkunController>();
  final ListAkun = <AkunFirebase>[].obs;
  final ListAllAkun = <AkunFirebase>[].obs;

  final authController = AuthController.to;
  final isLoading = true.obs;
  final updateValueNomorVA = "".obs;

  Future<void> getListAllAkun() async {
    isLoading(true);
    print("GET ALL USER FIREBASE");
    //await CompanyController.to.getListCompany();
    //var collection = await ApiClient().requestGet("/company/", null);
    ListAllAkun.clear();
    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        ///print(doc['displayName']);
        AkunFirebase temp = AkunFirebase(
          displayName: doc['displayName'],
          email: doc['email'],
          idCompany: doc['idCompany'],
          companyName: doc['companyName'],
          photoUrl: doc['photoURL'],
          role: doc['role'],
          phoneNumber: doc['nomorTelepon'] != null ? doc['nomorTelepon'] : "",
          uid: doc['uid'],
        );
        ListAllAkun.add(temp);
        //print("CEK AKUN:${temp.displayName}");
      });
    });
    isLoading(false);
    return;
  }

  Future<void> getListAkun(String role) async {
    isLoading(true);
    //await CompanyController.to.getListCompany();
    //var collection = await ApiClient().requestGet("/company/", null);
    ListAkun.clear();
    if (role != "") {
      FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: "${role}")
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          ///print(doc['displayName']);
          AkunFirebase temp = AkunFirebase(
            displayName: doc['displayName'],
            email: doc['email'],
            idCompany: doc['idCompany'],
            photoUrl: doc['photoURL'],
            role: doc['role'],
            phoneNumber: doc['nomorTelepon'] != null ? doc['nomorTelepon'] : "",
            uid: doc['uid'],
          );
          ListAkun.add(temp);
          //print("CEK AKUN:${temp.displayName}");
        });
      });
    } else {
      FirebaseFirestore.instance
          .collection('users')
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          AkunFirebase temp = AkunFirebase(
            displayName: doc['displayName'],
            email: doc['email'],
            idCompany: doc['idCompany'],
            photoUrl: doc['photoURL'],
            role: doc['role'],
            phoneNumber: doc['nomorTelepon'] != null ? doc['nomorTelepon'] : "",
            uid: doc['uid'],
          );
          ListAkun.add(temp);
        });
      });
    }
    isLoading(false);
    return;
  }

  Future<void> getListAkunAdmin() async {
    isLoading(true);
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };

    ListAkun.clear();
    print("/reference/list-user/?role=admin");
    var collection = await ApiClient()
        .requestGet("/reference/list-user/?role=admin", header);
    var emailRegistrant = <String>[];
    for (var item in collection) {
      if (item['role'] == "admin") {
        emailRegistrant.add(item['email']);
        AkunFirebase temp = AkunFirebase(
          displayName: item['name'],
          email: item['email'],
          idCompany:
              item['company_id'] != null ? item['company_id'].toString() : "",
          companyName: item['company_name'] != null ? item['company_name'] : "",
          photoUrl: "",
          role: 'admin',
          phoneNumber: "",
          uid: "",
        );
        ListAkun.add(temp);
      }
    }
    if (emailRegistrant.length > 0) {
      if (ListAkun.length > 0) {
        int current_index = 0;
        ListAkun.forEach((element) {
          String? email = element.email;
          int index_cari =
              ListAllAkun.indexWhere((element) => element.email == email);
          ListAkun[current_index].phoneNumber =
              ListAllAkun[index_cari].phoneNumber ?? "";
          ListAkun[current_index].uid = ListAllAkun[index_cari].uid ?? "";
          ListAkun[current_index].photoUrl =
              ListAllAkun[index_cari].photoUrl ?? "";
          current_index++;
        });
      }
    }
    //await CompanyController.to.getListCompany();
    //var collection = await ApiClient().requestGet("/company/", null);
    //reference/list-user/?role=member&company_id=8
    isLoading(false);
    return;
  }

  Future<void> getListAkunPIC() async {
    isLoading(true);
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };

    ListAkun.clear();
    print("/reference/list-user/?role=PIC");
    var collection =
        await ApiClient().requestGet("/reference/list-user/?role=PIC", header);
    var emailRegistrant = <String>[];
    for (var item in collection) {
      if (item['role'] == "PIC") {
        emailRegistrant.add(item['email']);
        AkunFirebase temp = AkunFirebase(
          displayName: item['name'],
          email: item['email'],
          idCompany:
              item['company_id'] != null ? item['company_id'].toString() : "",
          companyName: item['company_name'] != null ? item['company_name'] : "",
          photoUrl: "",
          role: 'PIC',
          phoneNumber: "",
          uid: "",
        );
        ListAkun.add(temp);
      }
    }
    print(emailRegistrant.length);
    if (ListAkun.length > 0) {
      int current_index = 0;
      ListAkun.forEach((element) {
        String? email = element.email;
        int index_cari =
            ListAllAkun.indexWhere((element) => element.email == email);
        ListAkun[current_index].phoneNumber =
            ListAllAkun[index_cari].phoneNumber ?? "";
        ListAkun[current_index].uid = ListAllAkun[index_cari].uid ?? "";
        ListAkun[current_index].photoUrl =
            ListAllAkun[index_cari].photoUrl ?? "";
        current_index++;
      });
    }

    //await CompanyController.to.getListCompany();
    //var collection = await ApiClient().requestGet("/company/", null);
    //reference/list-user/?role=member&company_id=8
    isLoading(false);
    return;
  }

  Future<void> getListAkunMember() async {
    isLoading(true);
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    String url = "/reference/list-user/?role=member";
    if (authController.user.value.role == "PIC") {
      String company_id = authController.user.value.idCompany;
      print("Company ID: ${company_id}");
      url = "/reference/list-user/?role=member&company_id=${company_id}";
      print(url);
    }
    ListAkun.clear();
    //print("/reference/list-user/?role=member");
    var collection = await ApiClient().requestGet(url, header);
    var emailRegistrant = <String>[];
    for (var item in collection) {
      if ((item['role'] == "member" || item['role'] == "PIC") &&
          item['company_id'] != null) {
        emailRegistrant.add(item['email']);
        AkunFirebase temp = AkunFirebase(
          displayName: item['name'],
          email: item['email'],
          idCompany:
              item['company_id'] != null ? item['company_id'].toString() : "",
          companyName: item['company_name'] != null ? item['company_name'] : "",
          photoUrl: "",
          role: 'admin',
          phoneNumber: "",
          uid: "",
        );
        ListAkun.add(temp);
      }
    }
    if (ListAkun.length > 0) {
      int current_index = 0;
      ListAkun.forEach((element) {
        String? email = element.email;
        int index_cari =
            ListAllAkun.indexWhere((element) => element.email == email);
        ListAkun[current_index].phoneNumber =
            ListAllAkun[index_cari].phoneNumber ?? "";
        ListAkun[current_index].uid = ListAllAkun[index_cari].uid ?? "";
        ListAkun[current_index].photoUrl =
            ListAllAkun[index_cari].photoUrl ?? "";
        current_index++;
      });
    }
    //await CompanyController.to.getListCompany();
    //var collection = await ApiClient().requestGet("/company/", null);
    //reference/list-user/?role=member&company_id=8
    isLoading(false);
    return;
  }

  Future<void> getListAkunByMe() async {
    //List<AkunFirebase> tempList = [];
    dynamic headers = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    ListAkun.clear();
    String idCompany = authController.user.value.idCompany;
    if (idCompany == "") {
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: "member")
        .where('idCompany', isEqualTo: "${idCompany}")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        ///print(doc['displayName']);
        AkunFirebase temp = AkunFirebase(
          displayName: doc['displayName'],
          email: doc['email'],
          idCompany: doc['idCompany'],
          photoUrl: doc['photoURL'],
          role: doc['role'],
          phoneNumber: doc['nomorTelepon'] != null ? doc['nomorTelepon'] : "",
          uid: doc['uid'],
        );
        ListAkun.add(temp);
        //print("CEK AKUN:${temp.displayName}");
      });
    });
    return;
  }

  Future<List<AkunFirebase>> generateListAkun(String role) async {
    await CompanyController.to.getListCompany();
    //var collection = await ApiClient().requestGet("/company/", null);
    List<AkunFirebase> tempList = [];
    if (role != "") {
      FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: "${role}")
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          ///print(doc['displayName']);
          AkunFirebase temp = AkunFirebase(
            displayName: doc['displayName'],
            email: doc['email'],
            idCompany: doc['idCompany'],
            photoUrl: doc['photoURL'],
            role: doc['role'],
            phoneNumber: doc['nomorTelepon'] != null ? doc['nomorTelepon'] : "",
            uid: doc['uid'],
          );
          tempList.add(temp);
          //print("CEK AKUN:${temp.displayName}");
        });
      });
    } else {
      FirebaseFirestore.instance
          .collection('users')
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          AkunFirebase temp = AkunFirebase(
            displayName: doc['displayName'],
            email: doc['email'],
            idCompany: doc['idCompany'],
            photoUrl: doc['photoURL'],
            role: doc['role'],
            phoneNumber: doc['nomorTelepon'] != null ? doc['nomorTelepon'] : "",
            uid: doc['uid'],
          );
          tempList.add(temp);
        });
      });
    }
    return tempList;
  }

  Future<bool> updateAkunSaya(String name, String phone_number) async {
    dynamic headers = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var data = {
      "name": name,
      "phone_number": phone_number,
    };
    var response =
        await ApiClient().patch('/account/update-me/', data, headers);
    //print(response['status_code']);
    if (response['status_code'] == 201 || response['status_code'] == 200) {
      return true;
    }
    return false;
  }

  Future<AkunFirebase> getAkunFirebasebyEmail(String email) async {
    AkunFirebase result = AkunFirebase();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data();
        result = AkunFirebase.fromJson(jsonEncode(data));
      }
    });
    return result;
  }

  Future<bool> submitInviteAdminByEmail(String email) async {
    dynamic headers = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    //print(data);
    var data = {
      "email": email,
    };
    var response =
        await ApiClient().requestPost('/account/invite-admin/', data, headers);
    //print(response['status_code']);
    if (response['status_code'] == 201 || response['status_code'] == 200) {
      return true;
    }
    return false;
  }

  Future<bool> submitInviteMemberByEmail(String email, String idCompany) async {
    dynamic headers = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    //print(data);
    var data = {
      "email": email,
    };
    var response = await ApiClient()
        .requestPost('/company/${idCompany}/invite/', data, headers);
    //print(response['status_code']);
    if (response['status_code'] == 201) {
      return true;
    }
    return false;
  }

  Future<AkunFirebase> getMyAkun() async {
    AkunFirebase _temp = AkunFirebase();
    await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: authController.user.value.uid)
        .limit(1)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var _data in querySnapshot.docs) {
        //print("USER: ${_data['photoURL']}");
        _temp = AkunFirebase(
            email: _data['email']!,
            companyName: _data['companyName']!,
            role: _data['role']!,
            idCompany: _data['idCompany'],
            displayName: _data['displayName']!,
            phoneNumber: _data['nomorTelepon'],
            transactionNumber: _data['transaction_number'],
            photoUrl: _data['photoURL']!,
            uid: _data['uid']!);
      }
    });
    return _temp;
  }

  Future<String> getMyNumberVA() async {
    dynamic headers = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var response = await ApiClient().requestGet('/account/me/', headers);
    print("RESP: ${response}");
    if (response == null) {
      return "";
    } else {
      return response['data']['transaction_number'];
    }
  }

  Future<bool> submitInvitePICByEmail(
      String email, String idCompany, String nomor_va) async {
    dynamic headers = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    //print(data);
    var data = {
      "email": email,
    };
    var response = await ApiClient()
        .requestPost('/company/${idCompany}/invite-pic/', data, headers);
    //print(response);
    if (response['status_code'] == 201) {
      return true;
    }
    return false;
  }

  Future<bool> submitRevokeAdmin(String email) async {
    dynamic headers = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    //print(data);
    var data = {
      "email": email,
    };
    var response =
        await ApiClient().requestPost('/account/delete-admin/', data, headers);
    //print(response['status_code']);
    if (response['status_code'] == 201 || response['status_code'] == 200) {
      return true;
    }
    return false;
  }

  Future<bool> submitRevokePIC(String email, String id) async {
    dynamic headers = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    //print(data);
    var data = {
      "email": email,
    };

    var response = await ApiClient()
        .requestPost('/company/${id}/remove-pic/', data, headers);
    //print(response['status_code']);
    if (response['status_code'] == 201 || response['status_code'] == 200) {
      return true;
    }
    return false;
  }

  Future<bool> submitRevokeMember(String email, String id) async {
    dynamic headers = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    //print(data);
    var data = {
      "email": email,
    };
    var response = await ApiClient()
        .requestPost('/company/${id}/remove-member/', data, headers);
    //print(response['status_code']);
    if (response['status_code'] == 201 || response['status_code'] == 200) {
      return true;
    }
    return false;
  }

  Future<bool> updateRoleFirebase(String email, String role) async {
    bool result = false;
    await FirebaseFirestore.instance.collection('users').doc(email).set(
      {
        "role": role,
      },
      SetOptions(merge: true),
    ).then((value) => result = true);
    return result;
  }

  Future<bool> updateRoleCompanyFirebase(
      String email, String role, String idCompany) async {
    bool result = false;
    await FirebaseFirestore.instance.collection('users').doc(email).set(
      {
        "role": role,
        "idCompany": "${idCompany}",
      },
      SetOptions(merge: true),
    ).then((value) => result = true);
    return result;
  }

  Future<bool> updateCompanyFirebase(String email, String idCompany) async {
    bool result = false;
    await FirebaseFirestore.instance.collection('users').doc(email).set(
      {
        "idCompany": "${idCompany}",
      },
      SetOptions(merge: true),
    ).then((value) => result = true);
    return result;
  }

  Future<AkunFirebase> setMemberRoleByEmail(String email) async {
    AkunFirebase result = AkunFirebase();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data();
        result = AkunFirebase.fromJson(jsonEncode(data));
      }
    });
    return result;
  }

  Future<void> callWhatsappMe(String? phoneNumber) async {
    var whatsapp = "${phoneNumber}";
    var whatsappURlAndroid =
        "whatsapp://send?phone=" + whatsapp + "&text=hello";
    var whatappURLIos = "https://wa.me/$whatsapp?text=${Uri.parse("hello")}";
    if (Platform.isIOS) {
      // for iOS phone only
      if (await canLaunchUrlString(whatappURLIos)) {
        await launchUrlString(whatappURLIos, mode: LaunchMode.platformDefault);
      } else {
        ScaffoldMessenger.of(Get.context!)
            .showSnackBar(SnackBar(content: new Text("whatsapp no installed")));
      }
    } else {
      // android , web
      if (await canLaunchUrlString(whatsappURlAndroid)) {
        await launchUrlString(whatsappURlAndroid,
            mode: LaunchMode.platformDefault);
      } else {
        ScaffoldMessenger.of(Get.context!)
            .showSnackBar(SnackBar(content: new Text("whatsapp no installed")));
      }
    }
  }

  Future<bool> updateNomorVA(
      String email, String company_id, String nomor_va) async {
    dynamic headers = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    updateValueNomorVA.value = "";
    //print(data);
    var data = {"email": "${email}", "transaction_number": "${nomor_va}"};

    var response = await ApiClient()
        .requestPost('/company/${company_id}/set-va/', data, headers);
    //print(response);
    if (response['status_code'] == 201 || response['status_code'] == 200) {
      print("berhasil update");
      updateValueNomorVA.value = nomor_va;
      return true;
    }
    return false;
  }
}
