// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tmcapp/client.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'dart:developer' as developer;

import 'package:tmcapp/model/invoice.dart';
import 'package:tmcapp/model/status_invoice.dart';

class InvoiceController extends GetxController {
  static InvoiceController get to => Get.find<InvoiceController>();
  final ListInvoice = <Invoice>[].obs;
  final ListStatusInvoice = <StatusInvoice>[].obs;
  final isLoading = false.obs;

  Future<void> getListStatusInvoice() async {
    ListStatusInvoice.clear();
    isLoading.value = true;
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${AuthController.to.user.value.token}'
    };
    var response2 =
        await ApiClient().requestGet("/reference/status-invoice/", header);
    if (response2 != null) {
      for (var item in response2) {
        ListStatusInvoice.add(StatusInvoice.fromMap(item));
      }
    }
    isLoading.value = false;

    return;
  }

  Future<Invoice> getDetilInvoice(String invoice_number) async {
    var invoice = Invoice();
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${AuthController.to.user.value.token}'
    };
    var response = await ApiClient()
        .requestGet("/transaction/invoice/${invoice_number}/", header);
    //print(response);
    if (response != null) {
      //       {
      //   "number": "I8w8",
      //   "amount": 10000,
      //   "status": "2",
      //   "status_desc": "'Payment Sukses",
      //   "payment_channel": "402",
      //   "payment_channel_desc": "Permata",
      //   "payment_date": "2022-09-02T06:35:43.227000Z",
      //   "no_va": "8985052353463475"
      // }
      var tempInvoice = {
        'invoice_number': response['number'],
        'va_no': response['no_va'],
        'amount': response['amount'],
        'status': int.parse(response['status']),
        'bank': response['payment_channel_desc'],
      };
      print(tempInvoice);
      invoice = Invoice.fromMap(tempInvoice);
    }
    return invoice;
  }

  Future<Invoice> getMoreDetilInvoice(String invoice_number) async {
    var invoice = Invoice();
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${AuthController.to.user.value.token}'
    };
    var response = await ApiClient()
        .requestGet("/transaction/invoice/${invoice_number}/", header);
    //print(response);
    if (response != null) {
      String paymentDate = response['payment_date'] != null
        ? "${DateFormat(DateFormat.YEAR_ABBR_MONTH_WEEKDAY_DAY, "en_EN").format(DateTime.parse(response['payment_date']))} ${response['payment_date'].toString().substring(11, 16)}"
        : "";
      var tempInvoice = {
        'invoice_number': response['number'],
        'va_no': response['no_va'],
        'amount': response['amount'],
        'status': int.parse(response['status']),
        'status_desc': response['status_desc'],
        'bank': response['payment_channel_desc'],
        'payment_channel_desc': response['payment_channel_desc'],
        'payment_date': response['payment_date'] !="" ? paymentDate :"",
        "items": response['items']
      };
      //print(tempInvoice);
      invoice = Invoice.fromMap(tempInvoice);
    }
    return invoice;
  }

  Future<void> getListInvoice() async {
    ListInvoice.clear();
    isLoading.value = true;
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${AuthController.to.user.value.token}'
    };
    var response2 =
        await ApiClient().requestGet("/transaction/invoice/", header);
    if (response2 != null) {
      for (var item in response2) {
        var itemInvoice = {
          "invoice_number": item['number'],
          "amount": item['amount'],
          "status": int.parse(item['status']),
        };
        if (item['status'] != "102") {
          ListInvoice.add(Invoice.fromMap(itemInvoice));
        }
      }
    }
    isLoading.value = false;
    return;
  }

  Future<bool> submitBatalkanInvoice(String invoice_number) async {
    ListInvoice.clear();
    isLoading.value = true;
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${AuthController.to.user.value.token}'
    };
    var response2 = await ApiClient().requestPost(
        "/transaction/invoice/${invoice_number}/cancle/", null, header);
    print(response2);
    if (response2 != null) {
      return true;
    }
    isLoading.value = false;
    return false;
  }
}
