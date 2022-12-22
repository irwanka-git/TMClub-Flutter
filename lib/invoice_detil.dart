import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';
import 'package:tmcapp/controller/AppController.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/controller/AkunController.dart';
import 'package:tmcapp/controller/CompanyController.dart';
import 'package:tmcapp/controller/InvoiceController.dart';
import 'package:tmcapp/model/akun_firebase.dart';
import 'package:tmcapp/model/company.dart';

import 'model/invoice.dart';

class InvoiceDetilScreenView extends StatefulWidget {
  @override
  State<InvoiceDetilScreenView> createState() => _InvoiceDetilScreenViewState();
}

class _InvoiceDetilScreenViewState extends State<InvoiceDetilScreenView> {
  final authController = AuthController.to;
  final AkunController akunController = AkunController.to;
  final InvoiceController invoiceController = InvoiceController.to;
  var isLoading = true.obs;
  var invoiceNumber = "".obs;
  var CompanySelected = null.obs;
  var emailController = TextEditingController();
  final invoice = Invoice().obs;
  var itemsInvoice = [].obs;

  Future<void> reloadData() async {
    setState(() {
      isLoading(true);
    });
    await invoiceController
        .getMoreDetilInvoice(invoiceNumber.value)
        .then((value) {
      print(value.amount);
      invoice(value);
      isLoading(false);
      _refreshController.refreshCompleted();
    });
  }

  void _onRefresh() async {
    // monitor network fetch
    isLoading.value = true;
    //await CompanyController.to.getListCompany();
    print("RELOAD DATA");
    await reloadData();
    await Future.delayed(const Duration(milliseconds: 1000));
    isLoading.value = false;
  }

  void _onLoading() async {
    // monitor network fetch
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      invoiceNumber(Get.arguments['invoice_number']);
      isLoading(true);
    });
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      //akunController.getListAkun();
      await reloadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Obx(() => Text("Invoice : ${invoiceNumber.value}")),
          backgroundColor: AppController.to.appBarColor.value,
          elevation: 1,
        ),
        backgroundColor: Theme.of(context).canvasColor,
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: const MaterialClassicHeader(
            color: CupertinoColors.activeOrange,
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: buildBody(),
        ));
  }

  Widget buildBody() {
    return Container(
      padding: EdgeInsets.all(5),
      child: Obx(() => isLoading.value == false
          ? Container(
              child: Column(
                children: [
                  GFCard(
                    elevation: 4,
                    content: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Invoice Number"),
                            Text(
                              "${invoice.value.invoiceNumber}",
                              textScaleFactor: 1.5,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            )
                          ],
                        ),
                        invoice.value.paymentChannelDesc != ""
                            ? Container(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Payment Method"),
                                        Text(
                                          "${invoice.value.paymentChannelDesc}",
                                          textScaleFactor: 1.0,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Status"),
                            Text(
                              "${invoice.value.statusDescription}",
                              textScaleFactor: 1.0,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            )
                          ],
                        ),
                        invoice.value.paymentDate != ""
                            ? Container(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Payment Date"),
                                        Text(
                                          "${invoice.value.paymentDate}",
                                          textScaleFactor: 1.0,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  GFCard(
                    padding: EdgeInsets.all(4),
                    elevation: 4,
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          child: Text(
                            "Peserta: ",
                            style: TextStyle(),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ListView.separated(
                            shrinkWrap: true,
                            physics:
                                NeverScrollableScrollPhysics(), //tambahkan ini
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const SizedBox(
                                      height: 10,
                                    ),
                            itemCount: invoice.value.items.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GFListTile(
                                padding: EdgeInsets.all(0),
                                icon: Text("#${index + 1}"),
                                margin: EdgeInsets.only(
                                    left: 0, top: 0,right: 8),
                                title: Text(
                                    invoice.value.items[index]
                                        ['registrant_name'],
                                    textScaleFactor: 0.96),
                                subTitle: Container(
                                    child: Text(
                                        invoice.value.items[index]
                                            ['event_name'],
                                        textScaleFactor: 0.85)),
                              );
                            }),
                        SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          : Container()),
    );
  }
}
