// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:tmcapp/controller/AppController.dart';
import 'package:tmcapp/controller/BottomTabController.dart';
import 'package:flutter/material.dart';
import 'package:tmcapp/controller/EventController.dart';
import 'package:tmcapp/controller/InvoiceController.dart';
import 'package:tmcapp/model/invoice.dart';
import 'package:clipboard/clipboard.dart';

class InvoiceDetilScreen extends StatefulWidget {
  final Invoice invoice;
  @override
  // ignore: overridden_fields
  final Key key;

  const InvoiceDetilScreen({
    required this.invoice,
    required this.key,
  }) : super(key: key);

  @override
  State<InvoiceDetilScreen> createState() => _InvoiceDetilScreenState();
}

class _InvoiceDetilScreenState extends State<InvoiceDetilScreen> {
  final invoice = Invoice().obs;
  final statusInvoice = "".obs;
  @override
  void initState() {
    // TODO: implement initState
    invoice(widget.invoice);
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      //companyController.getListCompany();
      getStatusInvoice();
    });
  }

  Future<bool> _onWillPop() async {
    return true; //<-- SEE HERE
  }

  void getStatusInvoice() async {
    SmartDialog.showLoading(msg: "Check Invoice...");
    await EventController.to
        .getStatusInvoice(invoice.value.invoiceNumber!)
        .then((respon) {
      if (respon != null) {
        setState(() {
          statusInvoice.value = respon['status_desc'];
        });
      }
    });
    SmartDialog.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: GFColors.LIGHT,
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GFCard(
                  content: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                          Text("${invoice.value.bank}", textScaleFactor: 1.1)
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
                                  style: TextStyle(fontWeight: FontWeight.w600),
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
                                FlutterClipboard.copy(invoice.value.vaNumber!)
                                    .then((value) => print('copied'));
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
                                  style: TextStyle(fontWeight: FontWeight.w600),
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
                                    .then((value) => print('copied'));
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
                                      "${statusInvoice.value}",
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
                                print("Check Invoice Status");
                                getStatusInvoice();
                              },
                              text: "Check",
                            ),
                          )
                        ],
                      ),
                      Divider(
                        height: 20,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 0),
                GFButton(
                  blockButton: true,
                  onPressed: () {
                    Get.back();
                  },
                  text: "Kembali",
                ),
              ],
            ),
          ),
        ));
  }

  void showKonfirmBatalkanInvoice() {
    Get.defaultDialog(
        contentPadding: const EdgeInsets.all(20),
        title: "Confirmation",
        titlePadding: const EdgeInsets.only(top: 10, bottom: 0),
        middleText: "Are you sure you want to cancel this invoice?",
        backgroundColor: CupertinoColors.darkBackgroundGray,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 16),
        middleTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        textCancel: "Close",
        textConfirm: "Yes, Cancel Invoice",
        cancelTextColor: Colors.white,
        confirmTextColor: Colors.white,
        buttonColor: CupertinoColors.activeOrange,
        onConfirm: () async {
          SmartDialog.showLoading(msg: "Canceled Invoice..");
          await InvoiceController.to
              .submitBatalkanInvoice(invoice.value.invoiceNumber!)
              .then((value) {
            SmartDialog.dismiss();
            if (value == true) {}
          });
          SmartDialog.dismiss();
        },
        radius: 0);
  }
}
