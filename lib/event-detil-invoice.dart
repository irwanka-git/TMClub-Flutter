// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/border/gf_border.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/getwidget.dart';
import 'package:tmcapp/controller/BottomTabController.dart';
import 'package:flutter/material.dart';
import 'package:tmcapp/controller/EventController.dart';
import 'package:tmcapp/controller/InvoiceController.dart';
import 'package:tmcapp/model/invoice.dart';
import 'package:clipboard/clipboard.dart';

class EventDetilInvoicePICScreen extends StatefulWidget {
  @override
  State<EventDetilInvoicePICScreen> createState() =>
      _EventDetilInvoicePICScreenState();
}

class _EventDetilInvoicePICScreenState
    extends State<EventDetilInvoicePICScreen> {
  final bottomTabControl = BottomTabController.to;
  late ScrollController _scrollController;
  final Color _foregroundColor = Colors.white;
  final invoice = Invoice().obs;
  final statusInvoiceDeskripsi = "".obs;
  final statusInvoice = "".obs;
  @override
  void initState() {
    // TODO: implement initState
    invoice(Get.arguments['invoice']);
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      //companyController.getListCompany();
      getStatusInvoice();
    });
  }

  Future<bool> _onWillPop() async {
    return false; //<-- SEE HERE
  }

  void getStatusInvoice() async {
    SmartDialog.showLoading(msg: "Check Invoice Status..");
    await EventController.to
        .getStatusInvoice(invoice.value.invoiceNumber!)
        .then((respon) {
      if (respon != null) {
        setState(() {
          statusInvoiceDeskripsi.value = respon['status_desc'];
          statusInvoice.value = respon['status'];
        });
      }
    });
    SmartDialog.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          backgroundColor: GFColors.LIGHT,
          body: Center(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GFCard(
                      content: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "INVOICE",
                            textScaleFactor: 1.2,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Divider(
                            height: 25,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Invoice Number"),
                              Text(
                                "${invoice.value.invoiceNumber}",
                                textScaleFactor: 1.1,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Bank"),
                              Text("${invoice.value.bank}",
                                  textScaleFactor: 1.1)
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: Get.width * 0.5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Virtual Account Number"),
                                    Text(
                                      "${invoice.value.vaNumber}",
                                      textScaleFactor: 1.2,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                width: Get.width * 0.2,
                                child: GFButton(
                                  size: GFSize.SMALL,
                                  onPressed: () {
                                    print("SALIN VA");
                                    FlutterClipboard.copy(
                                            invoice.value.vaNumber!)
                                        .then((value) => GFToast.showToast("Virtual Account Number has been copied", context, toastPosition: GFToastPosition.BOTTOM));
                                  },
                                  text: "Copy",
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: Get.width * 0.5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Total payment"),
                                    Text(
                                      "${CurrencyTextInputFormatter(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(invoice.value.amount.toString())}",
                                      textScaleFactor: 1.2,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                width: Get.width * 0.2,
                                child: GFButton(
                                  size: GFSize.SMALL,
                                  onPressed: () {
                                    print("SALIN NOMNIMAL");
                                    FlutterClipboard.copy(
                                            invoice.value.amount!.toString())
                                        .then((value) => GFToast.showToast("Total payment has been copied", context, toastPosition: GFToastPosition.BOTTOM));
                                  },
                                  text: "Copy",
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: Get.width * 0.5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Payment status"),
                                    Obx(() => Text(
                                          "${statusInvoiceDeskripsi.value}",
                                          textScaleFactor: 1,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ))
                                  ],
                                ),
                              ),
                              Container(
                                width: Get.width * 0.2,
                                child: GFButton(
                                  color: GFColors.LIGHT,
                                  textColor: GFColors.DARK,
                                  size: GFSize.SMALL,
                                  onPressed: () {
                                    print("Status Invoice..");
                                    getStatusInvoice();
                                  },
                                  text: "Cek",
                                ),
                              )
                            ],
                          ),
                          Divider(
                            height: 20,
                          ),
                          Container(
                            width: Get.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Invoice To:",
                                  style: TextStyle(fontWeight: FontWeight.w400),
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  "${invoice.value.companyName}",
                                  textScaleFactor: 1,
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  "${invoice.value.picName} \n${invoice.value.picEmail}",
                                  textScaleFactor: 1,
                                  style: TextStyle(fontWeight: FontWeight.w400),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          // ignore: sized_box_for_whitespace
                          Container(
                            width: Get.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Event:",
                                  style: TextStyle(fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  "${invoice.value.eventName}",
                                  textScaleFactor: 1,
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "${invoice.value.jumlahPeserta} Partisipant:",
                                  style: TextStyle(fontWeight: FontWeight.w400),
                                ),
                                invoice.value.jumlahPeserta! > 0 ? Text(
                                  "${invoice.value.peserta}",
                                  textScaleFactor: 0.95,
                                  style: TextStyle(fontWeight: FontWeight.w400),
                                ):Container()
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 0),
                   
                    Obx(() => statusInvoice.value == "101"
                        ? GFButton(
                            blockButton: true,
                            color: GFColors.DANGER,
                            onPressed: () async {
                              // Get.offNamed('/event');
                              showKonfirmBatalkanInvoice();
                            },
                            text: "Cancel Invoice",
                          )
                        : Container()),
                          GFButton(
                          blockButton: true,
                          onPressed: () {
                            Get.offNamed('/event');
                          },
                          text: "Back",
                        ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  void showKonfirmBatalkanInvoice() {
    Get.defaultDialog(
        contentPadding: const EdgeInsets.all(20),
        title: "Confirmation",
        titlePadding: const EdgeInsets.only(top: 10, bottom: 0),
        middleText: "Are you sure you want to cancel this invoice?",
        backgroundColor: GFColors.LIGHT,
        titleStyle: const TextStyle(color: Colors.black, fontSize: 16),
        middleTextStyle: const TextStyle(color: Colors.black, fontSize: 14),
        textCancel: "Close",
        textConfirm: "Yes",
        cancelTextColor: GFColors.DANGER,
        confirmTextColor: GFColors.LIGHT,
        buttonColor: GFColors.DANGER,
        onConfirm: () async {
          SmartDialog.showLoading(msg: "Cancel Invoice..");
          await InvoiceController.to
              .submitBatalkanInvoice(invoice.value.invoiceNumber!)
              .then((value) {
            SmartDialog.dismiss();
            if (value == true) {
              Get.offNamed('/event');
            }
          });
          SmartDialog.dismiss();
        },
        radius: 0);
  }
}
