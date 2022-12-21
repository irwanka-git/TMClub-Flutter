// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmcapp/authentication.dart';
import 'package:tmcapp/client.dart';
import 'package:tmcapp/controller/AppController.dart';
import 'package:tmcapp/controller/BottomTabController.dart';
import 'package:tmcapp/controller/ChatController.dart';
import 'package:tmcapp/controller/NotifikasiController.dart';
import 'package:tmcapp/model/user.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthController extends GetxController {
  static AuthController get to => Get.find<AuthController>();
  final appController = AppController.to;
  final isLoading = true.obs;
  final isLogin = false.obs;
  final konfirmRegistrasiAkun = false.obs;
  final user = UserLogin(
          companyName: "",
          role: "",
          token: "",
          email: "",
          displayName: "",
          photoURL: "",
          uid: "",
          idCompany: "",
          isLogin: false)
      .obs;
  final tabControl = BottomTabController.to;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void initFirebase() {
    Authentication.initializeFirebase();
  }

  void setKonfirmRegistrasiAkun(bool _val) {
    konfirmRegistrasiAkun(_val);
  }

  Future<void> cekUserLogin() async {
    User? _user = await Authentication.getCurrentUser();
    if (_user == null) {
      isLogin(false);
      user(UserLogin(
        email: "",
        displayName: "",
        photoURL: "",
        idCompany: "",
        uid: "",
        isLogin: false,
        companyName: "",
        token: "",
        role: "",
      ));
    } else {
      print("CEK AKUN USER");
      await getCurrentUser();
      print("Token User: ${user.value.token}");
      appController.setAppBarRole(user.value.role);
      if (user.value.token == "") {
        //belum selesai registrasi
        user(UserLogin(
          companyName: "",
          email: "",
          displayName: "",
          photoURL: "",
          idCompany: "",
          uid: "",
          isLogin: false,
          token: "",
          role: "",
        ));
        await deleteUserFirebase(user.value.email);
        await Authentication.signOut(context: Get.context!);
        isLogin(false);
        return;
      }
      cekNotifikasiUser();
      isLogin(true);
    }
  }

  void cekNotifikasiUser() {
    if (user.value.uid != "") {
      ChatController.to.listenMessageInbox(user.value.uid);
    }
    NotifikasiController.to.getNotifikasiCountUnreadSurvey();
  }

  String generate_uuid(String email) {
    var byte1 = const Utf8Encoder().convert(email);
    Digest md5hash = md5.convert(byte1);
    var byte2 = const Utf8Encoder().convert(md5hash.toString());
    Digest sha1hash = sha1.convert(byte2);
    return sha1hash.toString();
  }

  Future<bool> submitRegistrasiAkun(
      User? _user, String namaPengguna, String nomorTelepon) async {
    String email = _user!.email!;
    String uid_generate = generate_uuid(email);
    dynamic user_server = {
      "uid": uid_generate,
      "email": email,
      "name": namaPengguna
    };
    dynamic user_firebase = {
      "companyName": "",
      "uid": uid_generate,
      "email": email,
      "displayName": namaPengguna,
      "role": "member",
      "photoURL": _user.photoURL,
      "nomorTelepon": nomorTelepon,
      "idCompany": "",
      "isSignIn": true,
      "token": "",
      "creationTime": _user.metadata.creationTime!.toIso8601String(),
      "lastSignInTime": _user.metadata.lastSignInTime!.toIso8601String()
    };
    print(user_firebase);
    //return false;

    bool succesFirebase = false;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .set(
          user_firebase,
          SetOptions(merge: false),
        )
        .then((value) => succesFirebase = true)
        .catchError(
          (error) => succesFirebase = false,
        );

    if (succesFirebase == true) {
      print("Berhasil Buat Firebase user");
      String getToken = "";
      await getTokenUserSystem(user_server).then((value) => getToken = value);
      if (getToken == "") {
        print("Gagal dapatin Token Server");
        await deleteUserFirebase(email);
        return false;
      }
      print("Berhasil dapatin Token ${getToken}");
      dynamic headers = {HttpHeaders.authorizationHeader: 'Token ${getToken}'};
      var data_user = {
        "name": namaPengguna,
        "phone_number": nomorTelepon,
      };
      bool updateToken = false;
      var response =
          await ApiClient().patch('/account/update-me/', data_user, headers);
      //print(response['status_code']);
      if (response['status_code'] == 201 || response['status_code'] == 200) {
        await FirebaseFirestore.instance.collection('users').doc(email).set(
          {
            "token": getToken,
            "lastSignInTime": _user.metadata.lastSignInTime!.toIso8601String()
          },
          SetOptions(merge: true),
        ).then((value) => updateToken = true);
      }
      if (updateToken == true) {
        return true;
      } else {
        await deleteUserFirebase(_user.email!);
        return false;
      }
    }
    return false;
  }

  Future<bool> deleteUserFirebase(String email) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .delete()
        .then(
          (doc) => print("User deleted"),
          onError: (e) => print("Error updating document $e"),
        );
    print("Delete Akun");
    return true;
  }

  // Future<bool> submitInviteMemberCompany(String email, String idCompany) async {
  //   //print(data);
  //   var data = {
  //     "email": email,
  //   };
  //   var response = await ApiClient()
  //       .requestPost('/company/${idCompany}/invite/', data, null);
  //   //print(response);
  //   if (response['status_code'] == 200) {
  //     return true;
  //   }
  //   return false;
  // }

  Future<String> getTokenUserSystem(Map<String, dynamic> data) async {
    //print(data);
    var response = await ApiClient().requestPost('/authenticate/', data, null);
    //print(response);
    if (response['status_code'] == 200) {
      var data = response['data'];
      print("NAME TOKEN: ${data['name']}");
      return data['token'];
    }
    if (response['status_code'] == 422) {
      //print(response['message']['id']);
      print("ERRROR GET TOKEN");
      return "";
    }
    return "";
  }

  Future<void> sinkronAccountMeServerToFirebase(UserLogin _user) async {
    //print(data);
    dynamic headers = {HttpHeaders.authorizationHeader: 'Token ${_user.token}'};
    var response = await ApiClient().requestGet('/account/me/', headers);
    print("RESP: ${response}");
    if (response == null) {
      return;
    }
    if (response['status_code'] == 201 || response['status_code'] == 200) {
      var data = response['data'];
      //if (user.role != "superadmin") {
      await FirebaseFirestore.instance.collection('users').doc(_user.email).set(
        {
          "displayName": data['name'],
          "role": data['role'] == "admin" && _user.role == "superadmin"
              ? "superadmin"
              : data['role'],
          "idCompany": data['company_id'].toString(),
          "companyName":
              data['company_name'] != null ? data['company_name'] : "",
          "nomorTelepon":
              data['phone_number'] != null ? data['phone_number'] : "",
          "transaction_number": data['transaction_number'] != null
              ? data['transaction_number']
              : "",
        },
        SetOptions(merge: true),
      ).then((value) async => {
            await getCurrentUser(),
            appController.setAppBarRole(user.value.role)
          });
      return;
    }
    if (response['status_code'] == 422) {
      //print(response['message']['id']);
      return;
    }
    return;
  }

  Future<void> signin(BuildContext _context) async {
    User? _userCurrent = await Authentication.getCurrentUser();
    if (_userCurrent != null) {
      await Authentication.signOut(context: _context);
    }
    isLoading(true);
    User? _user = await Authentication.signInWithGoogle(context: _context);
    isLoading(false);
    if (_user != null) {
      isLogin(true);
      await getCurrentUser();
      await sinkronAccountMeServerToFirebase(user.value);
      print(user.value.displayName);
      dynamic cekUser = {
        "uid": user.value.uid,
        "email": user.value.email,
        "name": user.value.displayName
      };
      String newToken = await getTokenUserSystem(cekUser);
      if (user.value.token != newToken) {
        bool updateToken = false;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user.email)
            .set(
          {
            "token": newToken,
            "lastSignInTime": _user.metadata.lastSignInTime!.toIso8601String()
          },
          SetOptions(merge: true),
        ).then((value) => updateToken = true);
      }
      appController.setAppBarRole(user.value.role);
      Get.snackbar('Login Success', 'Welcome ${user.value.displayName}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: CupertinoColors.black,
          margin: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          colorText: Colors.white);
      tabControl.bottomTabControl.jumpToTab(0);
      cekNotifikasiUser();
    } else {
      isLogin(false);
      user(UserLogin(
          email: "",
          displayName: "",
          companyName: "",
          photoURL: "",
          uid: "",
          token: "",
          idCompany: "",
          isLogin: false,
          role: ""));
    }
  }

  Future<void> signout(BuildContext _context) async {
    User? _user = await Authentication.getCurrentUser();
    await Authentication.signOut(context: _context);
    appController.setAppBarRole("");
    //set session login
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.email)
        .set(
          {
            "isSignIn": false,
            "lastSignInTime": DateTime.now().toIso8601String()
          },
          SetOptions(merge: true),
        )
        .then((value) => print("Berhasil"))
        .catchError((error) => print("Failed to merge data: $error"));

    user(UserLogin(
        role: "",
        email: "",
        displayName: "",
        idCompany: "",
        photoURL: "",
        token: "",
        companyName: "",
        uid: "",
        isLogin: false));
    cekUserLogin();
    Get.snackbar('Logout', 'Logout Success',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: CupertinoColors.black,
        colorText: Colors.white);
    cekNotifikasiUser();
  }

  Future<void> getCurrentUser() async {
    print("GET CURRENT USER");
    UserLogin? _temp;
    User? _user = await Authentication.getCurrentUser();
    if (_user != null) {
      print(_user.email);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.email!)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          var _data = documentSnapshot;
          UserLogin _temp = UserLogin(
              email: _data['email']!,
              companyName: _data['companyName']!,
              isLogin: true,
              role: _data['role']!,
              token: _data['token'],
              idCompany: _data['idCompany'],
              displayName: _data['displayName']!,
              photoURL: _data['photoURL']!,
              uid: _data['uid']!);
          user(_temp);
        }
      });
    }
  }
}
