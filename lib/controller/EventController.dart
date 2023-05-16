// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:external_path/external_path.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tmcapp/client.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/controller/BottomTabController.dart';
import 'package:tmcapp/controller/CompanyController.dart';
import 'package:tmcapp/controller/SearchController.dart';
import 'package:tmcapp/model/event_tmc.dart';
import 'package:tmcapp/model/event_tmc_detil.dart';
import 'package:tmcapp/model/invoice.dart';
import 'package:tmcapp/model/media.dart';
import 'package:tmcapp/model/payment_method.dart';
import 'package:tmcapp/model/registrant.dart';
import 'package:tmcapp/model/resources.dart';
import 'package:tmcapp/model/survey.dart';
import 'package:path/path.dart' as path;
import 'dart:io' show Platform;

class EventController extends GetxController {
  var ListEvent = <EventTmc>[].obs;
  static EventController get to => Get.find<EventController>();
  final isLoading = true.obs;
  final authController = AuthController.to;
  final myAttendanceThisEvent = null.obs;
  final konfirmRegistrasiMandiri = "".obs;
  final qrCodeScanResult = "".obs;
  var ListEventAsAdmin = <EventTmc>[].obs;
  var ListEventAsPeserta = <EventTmc>[].obs;
  var ListMyEvent = <EventTmc>[].obs;
  var ListMyRegistrant = <Registrant>[].obs;
  var ListResourcesEvent = <Resources>[].obs;
  var ListSurveyEvent = <Survey>[].obs;
  var ListImageMedia = <ImageMedia>[].obs;
  var ListSurvey = <int>[].obs;
  var imageSertifikat = <Uint8List>[].obs;
  var excelPartisipant = <Uint8List>[].obs;

  Future<void> getListEvent() async {
    ListEvent.clear();
    isLoading(true);
    var collection = await ApiClient().requestGet("/event/", null);
    if (collection == null) {
      return;
    }
    for (var item in collection) {
      ListEvent.add(EventTmc.fromJson(jsonEncode(item)));
    }
    ListEvent.sort((a, b) => b.date!.compareTo(a.date!));
    if (BottomTabController.to.bottomTabControl.index == 1) {
      SearchController.to.setSearchingRef("event");
    }
    isLoading(false);
    return;
  }

  Future<void> openScreenItem(String id) async {
    SmartDialog.showLoading(msg: "Loading..");
    await getDetilEvent(int.parse(id)).then((value) async => {
          SmartDialog.dismiss(),
          if (value.pk! > 0)
            {
              Get.toNamed('/event-detil', arguments: {'event': value})
            }
          else
            {
              Get.snackbar('Opps.', "Terjadi Kesalahan, ACARA Gagal dimuat",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: CupertinoColors.systemYellow,
                  colorText: Colors.black)
            }
        });
    return;
  }

  Future<void> getListMyEventAsAdmin() async {
    isLoading(true);
    ListEvent.clear();
    var collection = await ApiClient().requestGet("/event/", null);
    for (var item in collection) {
      ListEvent.add(EventTmc.fromJson(jsonEncode(item)));
    }
    isLoading(false);
    return;
  }

  Future<void> getListMyEvent() async {
    //List<EventTmc> list = <EventTmc>[];
    print("GET LIST MY EVENT");
    ListMyEvent.clear();
    isLoading(true);
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var collection;
    if (authController.user.value.role == "admin") {
      collection = await ApiClient().requestGet("/event/myevent/", header);
      if (collection == null) {
        isLoading(false);
        return;
      }
      for (var item in collection) {
        ListMyEvent.add(EventTmc.fromJson(jsonEncode(item)));
      }
    }
    if (authController.user.value.role == "member" ||
        authController.user.value.role == "PIC") {
      collection =
          await ApiClient().requestGet("/event/my-registered-event/", header);
      if (collection == null) {
        isLoading(false);
        return;
      }
      for (var item in collection) {
        EventTmc temp = EventTmc(
          pk: item['event_id'],
          title: item['title'],
          date: DateTime.parse(item['event_date']),
          venue: item['venue'],
          mainImageUrl: item['main_image_url'],
          description: item['description'],
          isFree: item['is_free'],
        );
        ListMyEvent.add(temp);
      }
    }
    isLoading(false);
    if (collection == null) {
      return;
    } else {
      ListMyEvent.sort((a, b) => b.date!.compareTo(a.date!));
    }

    return;
  }

  Future<void> getListMyRegistrant(int pk) async {
    ListMyRegistrant.clear();
    isLoading(true);
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    print("/event/${pk}/register-list-by-pic/");
    var collection = await ApiClient()
        .requestGet("/event/${pk}/register-list-by-pic/", header);
    var emailRegistrant = <String>[];
    if (collection == null) {
      return;
    }
    List<dynamic> companyList = [];
    for (var item in collection) {
      emailRegistrant.add(item['email']);
      //companyList[item['email']] = item['company_name'];
    }
    if (emailRegistrant.length > 0) {
      await FirebaseFirestore.instance
          .collection('users')
          .where('email', whereIn: emailRegistrant)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          Registrant temp = Registrant(
            displayName: doc['displayName'],
            email: doc['email'],
            companyId: doc['idCompany'],
            companyName: doc['companyName'],
            photoUrl: doc['photoURL'],
            phoneNumber: doc['nomorTelepon'] != null ? doc['nomorTelepon'] : "",
          );
          ListMyRegistrant.add(temp);
        });
      });
    }
    isLoading(false);
    return;
  }

  Future<void> getListPeserta(int pk) async {
    ListMyRegistrant.clear();
    isLoading(true);
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var collection =
        await ApiClient().requestGet("/event/${pk}/register-list/", header);
    var emailRegistrant = <String>[];
    List<Map<String, dynamic>> registrar = [];
    for (var item in collection) {
      emailRegistrant.add(item['email']);
      var regitem = {
        "email": item['email'].toString(),
        "attendance_time": item['attendance_time'] != null
            ? item['attendance_time'].toString()
            : "",
      };
      registrar.add(regitem);
    }
    if (emailRegistrant.length > 0) {
      await FirebaseFirestore.instance
          .collection('users')
          .where('email', whereIn: emailRegistrant)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          final attendanceTimeItem =
              registrar.firstWhere((e) => e['email'] == doc['email']);

          Registrant temp = Registrant(
              displayName: doc['displayName'],
              email: doc['email'],
              companyId: doc['idCompany'],
              companyName:
                  CompanyController.to.getCompanyName(doc['idCompany']),
              photoUrl: doc['photoURL'],
              phoneNumber:
                  doc['nomorTelepon'] != null ? doc['nomorTelepon'] : "",
              attendance_time: attendanceTimeItem != null
                  ? attendanceTimeItem['attendance_time']
                  : "");
          ListMyRegistrant.add(temp);
        });
      });
    }
    isLoading(false);
    return;
  }

  Future<List> getListEmailPeserta(int pk) async {
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var collection =
        await ApiClient().requestGet("/event/${pk}/register-list/", header);
    var emailRegistrant = <String>[];
    for (var item in collection) {
      emailRegistrant.add(item['email']);
    }
    return emailRegistrant;
  }

  Future<bool> cekIsMyEvent(int pk) async {
    //return false;
    print("CEK EVENT SAYA!");
    bool isMyEvent = false;
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var collection;
    if (authController.user.value.role == "admin") {
      collection = await ApiClient().requestGet("/event/myevent/", header);
      for (var item in collection) {
        if (item['pk'] == pk) {
          isMyEvent = true;
          return true;
        }
      }
    }

    if (authController.user.value.role == "member" ||
        authController.user.value.role == "PIC") {
      collection =
          await ApiClient().requestGet("/event/my-registered-event/", header);
      for (var item in collection) {
        if (item['event_id'] == pk) {
          isMyEvent = true;
          print("is my event: ${isMyEvent}");
          return true;
        }
      }
    }

    // if (authController.user.value.role == "PIC" ) {
    //   collection =
    //       await ApiClient().requestGet("/event/${pk}}/register-list-by-pic/", header);
    //   for (var item in collection) {
    //     if (item['email'] == authController.user.value.email) {
    //       isMyEvent = true;
    //       return true;
    //     }
    //   }
    // }
    print("is my event: ${isMyEvent}");
    return isMyEvent;
  }

  Future<String> cekMyAttadanceEvent(int pk) async {
    //return false;
    print("CEK STATUS ABSENSI $pk");
    String myAttadance = "";
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var collection;
    if (authController.user.value.role == "member" ||
        authController.user.value.role == "PIC") {
      collection =
          await ApiClient().requestGet("/event/my-registered-event/", header);
      for (var item in collection) {
        print(item);
        if (item['event_id'] == pk) {
          if (item["attendance_time"] != null) {
            myAttadance = item["attendance_time"].toString();
          }
        }
      }
    }

    return myAttadance;
  }

  Future<List> cekListMyAttadanceEvent(int pk) async {
    //return false;
    print("CEK STATUS ABSENSI $pk");
    var attandence_list = <String>[];
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var collection;
    if (authController.user.value.role == "member" ||
        authController.user.value.role == "PIC") {
      collection =
          await ApiClient().requestGet("/event/my-registered-event/", header);
      for (var item in collection) {
        //print(item);
        if (item['event_id'] == pk) {
          if (item["attendance"] != []) {
            for (var item_atten in item["attendance"]) {
              print(item_atten);
              String jam = item_atten['attendance_time'];
              jam = jam.substring(0, 8);
              String waktu = (item_atten['attendance_date'] + " " + jam);
              attandence_list.add(
                  "${DateFormat(DateFormat.YEAR_MONTH_WEEKDAY_DAY, "id_ID").format(DateTime.parse(waktu))} ${jam}");
            }
          }
        }
      }
    }

    return attandence_list;
  }

  void getStatusMyAttendanceEvent(int pk) {
    var val = null;
    myAttendanceThisEvent(val);
  }

  void setMyAttendanceEvent(dynamic val) {
    myAttendanceThisEvent(val);
  }

  Future<EventTmcDetil> getDetilEvent(int pk) async {
    EventTmcDetil resultEventTmcDetil = EventTmcDetil();
    var response = await ApiClient().requestGet("/event/${pk}/", null);
    if (response != null) {
      print(jsonEncode(response));
      resultEventTmcDetil = EventTmcDetil.fromJson(jsonEncode(response));
      return resultEventTmcDetil;
    }
    return resultEventTmcDetil;
  }

  Future<String> getQRCodeAbsensi(int pk) async {
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var response = await ApiClient().requestGet("/event/$pk/qrcode", header);
    if (response != null) {
      if (response['qr_url'] != "") {
        return response['qr_url'];
      }
    }
    return "";
  }

  Future<bool> deleteEvent(int pk) async {
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var response = await ApiClient().delete('/event/$pk/', header);
    //print(response['status_code']);
    if (response['status_code'] == 200) {
      return true;
    }
    return false;
  }

  Future<bool> updateEvent(Map<String, dynamic> data, int pk) async {
    //print("DATA ${data}");
    //return true;
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var response = await ApiClient().patch('/event/$pk/', data, header);
    if (response['status_code'] == 200) {
      //var data = response['data'];
      //print("OKE");
      return true;
    }
    return false;
  }

  Future<bool> postingEventBaru(Map<String, dynamic> data) async {
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var response = await ApiClient().requestPost('/event/', data, header);
    //print(response['status_code']);
    if (response['status_code'] == 201) {
      var data = response['data'];
      return true;
    }
    return false;
  }

  Future<bool> submitRegistrasiMandiri(int pk) async {
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var response = await ApiClient()
        .requestPost('/event/${pk}/registration/', null, header);
    //print(response['status_code']);
    if (response['status_code'] == 201) {
      var data = response['data'];
      return true;
    }
    return false;
  }

  Future<Invoice> submitRegistrasiByPIC(int pk, List<String> listEmail) async {
    Invoice invoice = Invoice(invoiceNumber: "", eventId: 0);
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var data = {"email": listEmail};
    print(data);
    //return false;
    var response = await ApiClient()
        .requestPost('/event/${pk}/registration-pic/', data, header);
    print(response);
    if (response['status_code'] == 201 || response['status_code'] == 200) {
      var invoice_number = response['data']['invoice_number'];
      var temp = {"invoice_number": invoice_number, "event_id": pk};
      invoice = Invoice.fromMap(temp);
      return invoice;
    }
    if (response['status_code'] == 422) {
      var invoice_number = response['data']['invoice_number'];
      var temp = {
        "invoice_number": "",
        "event_id": pk,
        "error_message":
            response['message']['en'] + ' Invoice Number: ${invoice_number}'
      };
      invoice = Invoice.fromMap(temp);
      return invoice;
    }
    // if (response['status_code'] == 500) {
    //   //var data = response['data'];
    //   return invoice;
    // }
    return invoice;
  }

  Future<Invoice> submitGetInvoiceNumberRegistrasiByPIC(
      int pk, List<String> listEmail) async {
    Invoice invoice = Invoice(invoiceNumber: "", eventId: 0);
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var data = {"email": listEmail};
    print(data);
    //return false;
    var response = await ApiClient()
        .requestPost('/event/${pk}/registration-pic/', data, header);
    print(response);
    if (response['status_code'] == 201 || response['status_code'] == 200) {
      var invoice_number = response['data']['invoice_number'];
      var registrants = response['data']['registrants'];
      var registrant = <String>[];
      for (var reg in registrants) {
        registrant.add(reg['registrant']);
      }
      var invoice_data = {
        'invoice_number': invoice_number,
        'event_id': pk,
        'peserta': registrant.join(", "),
        'jumlah_peserta': registrant.length,
      };
      return Invoice.fromMap(invoice_data);
    }

    if (response['status_code'] == 422) {
      var invoice_number = response['data']['invoice_number'];
      var invoice_data = {
        'invoice_number': invoice_number,
        'error_message': response['message']['en'],
      };
      return Invoice.fromMap(invoice_data);
    }
    // if (response['status_code'] == 500) {
    //   //var data = response['data'];
    //   return invoice;
    // }
    return invoice;
  }

  Future<dynamic> getStatusInvoice(String invoice_number) async {
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    //var data = {"payment_method_id": invoice_awal.paymentMethodId};
    var response = await ApiClient()
        .requestGet('/transaction/invoice/${invoice_number}/', header);
    if (response != null) {
      return response;
    }
    return null;
  }

  Future<Invoice> submitGenerateVAPaymentRegistrasi(
      Invoice invoice_awal) async {
    //transaction/invoice/{number}/payment-method/
    Invoice invoice = Invoice(invoiceNumber: "", eventId: 0);
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var data = {"payment_method_id": invoice_awal.paymentMethodId};
    var response = await ApiClient().requestPost(
        '/transaction/invoice/${invoice_awal.invoiceNumber.toString()}/payment-method/',
        data,
        header);
    //print(response);
    if (response['status_code'] == 201 || response['status_code'] == 200) {
      //print(response['data']);
      var tempInvoice = {
        'invoice_number': response['data']['invoice_number'],
        'va_no': response['data']['va_no'],
        'event_id': invoice_awal.eventId,
        'peserta': invoice_awal.peserta,
        'jumlah_peserta': invoice_awal.jumlahPeserta,
        'event_name': invoice_awal.eventName,
        'amount': response['data']['amount'],
        'status': 0,
        'payment_method_id': invoice_awal.paymentMethodId,
        'bank': response['data']['bank'],
      };
      return Invoice.fromMap(tempInvoice);
    }
    return invoice;
  }

  Future<bool> submitDeleteRegistrasi(String email, int idEvent) async {
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var data = {
      "email": [email]
    };
    print(data);
    //return false;
    var response = await ApiClient()
        .requestPost('/event/${idEvent}/registration-delete/', data, header);
    //print(response);
    if (response['status_code'] == 201 ||
        response['status_code'] == 200 ||
        response['status_code'] == 204) {
      //var data = response['data'];
      return true;
    }
    if (response['status_code'] == 500) {
      //var data = response['data'];
      return true;
    }
    return false;
  }

  Future<bool> submitDeleteMultipleRegistrasi(
      List<String> email, int idEvent) async {
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var data = {
      "email": email,
    };
    print(data);
    //return false;
    var response = await ApiClient()
        .requestPost('/event/${idEvent}/registration-delete/', data, header);
    //print(response);
    if (response['status_code'] == 201 ||
        response['status_code'] == 200 ||
        response['status_code'] == 204) {
      //var data = response['data'];
      return true;
    }
    if (response['status_code'] == 500) {
      //var data = response['data'];
      return true;
    }
    return false;
  }

  void setKonfirmRegistrasiMandiri(String val) {
    konfirmRegistrasiMandiri(val);
  }

  void setQrCodeScanResult(String? result) {
    qrCodeScanResult(result);
  }

  Future<Map<String, dynamic>?> submitAttendParticipant(String nonce) async {
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var response = await ApiClient().requestPost(
        '/event/attend/${nonce}/participant/',
        {"attendance_time": DateTime.now().toIso8601String()},
        header);
    //print("STATUS CODE ${response['status_code']}");
    //print(response['data']);
    if (response['status_code'] == 201) {
      var data = response['data'];
      return data;
    }
    return null;
  }

  Future<void> getListResources(int pk) async {
    ListResourcesEvent.clear();
    isLoading(true);
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var collection = await ApiClient()
        .requestGet("/event/${pk}/event-reference-list/", header);
    for (var item in collection) {
      ListResourcesEvent.add(Resources.fromJson(jsonEncode(item)));
    }
    isLoading(false);
    return;
  }

  Future<bool> submitCreateResources(int pk, dynamic data) async {
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var response = await ApiClient()
        .requestPost('/event/${pk}/event-reference-create/', data, header);
    //print(response['status_code']);
    if (response['status_code'] == 201) {
      print(response['data']);
      return true;
    }
    return false;
  }

  Future<bool> submitUpdateResources(int id, dynamic data) async {
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var response = await ApiClient()
        .patch('/event/${id}/event-reference-update/', data, header);
    //print(response['status_code']);
    if (response['status_code'] == 201) {
      print(response['data']);
      return true;
    }
    return false;
  }

  ///event/{id}/event-reference-delete/
  Future<bool> submitDeleteResources(int id) async {
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var response = await ApiClient()
        .delete('/event/${id}/event-reference-delete/', header);
    //print(response['status_code']);
    if (response['status_code'] == 200) {
      //print(response['data']);
      return true;
    }
    return false;
  }

  Future<List<ImageMedia>> getListImageGallery(int pk) async {
    EventTmcDetil result = EventTmcDetil();
    var resultList = <ImageMedia>[];
    var response =
        await ApiClient().requestGet("/event/${pk.toString()}/", null);
    if (response != null) {
      resultList.clear();
      result = EventTmcDetil.fromJson(jsonEncode(response));
      if (result.media_id!.isNotEmpty) {
        for (var id_image in result.media_id!) {
          String image_url = ApiClient().base_url +
              result.media_url![result.media_id!.indexOf(id_image)];
          var itemMedia = ImageMedia(
              pk: int.parse(id_image.toString()),
              display_name: "",
              image: image_url);
          resultList.add(itemMedia);
        }
      }
    }
    return resultList;
  }

  Future<bool> submitGalleryEvent(int pk, dynamic data) async {
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var response = await ApiClient()
        .requestPost('/event/${pk}/upload-media/', data, header);
    //print(response['status_code']);
    if (response['status_code'] == 201) {
      //print(response['data']);
      return true;
    }
    return false;
  }

  Future<bool> downloadSertifikatPeserta(int pk) async {
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var response = await ApiClient().requestGetImage(
        '/event/${pk.toString()}/download-certificate/', header);
    //print(base64Decode(response));
    if (response == null) {
      return false;
    }
    if (response.statusCode == 200) {
      imageSertifikat.clear();
      imageSertifikat.add(response.data);
      //print(base64Decode(response.data));
      return true;
    }

    return false;
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

  Future<bool> downloadExcelRegistrant(EventTmcDetil item) async {
    _requestPermission();
    SmartDialog.showLoading(msg: "Download...");
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var response = await ApiClient().requestPostBlob(
        '/event/${item.pk!.toString()}/export-registrant/', null, header);
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
        "${_randomNumber12.toString()}${item.title}partisipant-export.xlsx");

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

  Future<bool> downloadExcelHasilSurvey(EventTmcDetil item) async {
    _requestPermission();
    SmartDialog.showLoading(msg: "Download...");
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var response = await ApiClient().requestPostBlob(
        '/event/${item.pk!.toString()}/export-registrant/', null, header);
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
        "${_randomNumber12.toString()}${item.title}partisipant-export.xlsx");

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

  Future<void> getListSurvey(int pk) async {
    ListSurveyEvent.clear();
    isLoading(true);
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var collection = await ApiClient()
        .requestGet("/event/${pk.toString()}/survey-list/", header);
    for (var item in collection) {
      ListSurveyEvent.add(Survey.fromJson(jsonEncode(item)));
    }
    isLoading(false);
    return;
  }

  Future<bool> submitSetSurveyEvent(int pk, dynamic data) async {
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var response = await ApiClient()
        .requestPost('/event/${pk.toString()}/survey-set/', data, header);
    //print(response['status_code']);
    if (response['status_code'] == 201 || response['status_code'] == 200) {
      //print(response['data']);
      return true;
    }
    return false;
  }

  Future<bool> submitSendNotifikasi(int pk) async {
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    //print('/event/${pk.toString()}/survey-send/');
    var response = await ApiClient()
        .requestPost('/event/${pk.toString()}/survey-send/', null, header);
    if (response == null) {
      return false;
    }
    //print(response);
    if (response['status_code'] == 201 || response['status_code'] == 200) {
      //print(response['data']);
      return true;
    }
    return false;
  }

  Future<List<PaymentMethod>> getPaymentMethodList() async {
    var paymentMethods = <PaymentMethod>[];
    var response =
        await ApiClient().requestGet('/reference/payment-method/', null);
    if (response != null) {
      for (var item in response) {
        paymentMethods.add(PaymentMethod.fromMap(item));
      }
    }
    return paymentMethods;
  }

  Future<bool> closingEvent(int pk) async {
    //print("DATA ${data}");
    //return true;
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var data = {"is_done": true};

    ///event/{id}/set-done/
    var response = await ApiClient()
        .requestPost('/event/${pk.toString()}/set-done/', data, header);
    print(response);
    if (response['status_code'] == 200) {
      //var data = response['data'];
      //print("OKE");
      return true;
    }
    return false;
  }

  Future<bool> unclosingEvent(int pk) async {
    //print("DATA ${data}");
    //return true;
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var data = {"is_done": false};

    ///event/{id}/set-done/
    var response = await ApiClient()
        .requestPost('/event/${pk.toString()}/set-done/', data, header);
    print(response);
    if (response['status_code'] == 200) {
      //var data = response['data'];
      //print("OKE");
      return true;
    }
    return false;
  }
}
