import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';
import 'package:tmcapp/controller/AppController.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/controller/AkunController.dart';
import 'package:tmcapp/controller/CompanyController.dart';
import 'package:tmcapp/model/akun_firebase.dart';
import 'package:tmcapp/model/company.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'controller/InvoiceController.dart';
import 'model/invoice.dart';

class InvoiceListScreen extends StatefulWidget {
  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  final invoiceController = InvoiceController.to;
  var ListInvoice = <Invoice>[].obs;
  var isLoading = true.obs;
  var searchTextFocus = false.obs;

  Future<void> reloadData() async {
    await invoiceController.getListInvoice().then((value) {
      setState(() {
        ListInvoice(invoiceController.ListInvoice);
        _searchTextcontroller.text = "";
        isLoading.value = false;
      });
    });
    return;
  }

  void _onRefresh() async {
    // monitor network fetch
    setState(() {
      isLoading.value = true;
    });
    //await CompanyController.to.getListCompany();
    await reloadData();
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    setState(() {
      isLoading.value = false;
    });
    _refreshController.refreshCompleted();
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

  TextEditingController _searchTextcontroller = TextEditingController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      //akunController.getListInvoice();
      await invoiceController.getListStatusInvoice().then((value) async {
        await reloadData();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Obx(() => Text(
                "Invoice (${ListInvoice.value.length})",
                style: TextStyle(fontSize: 18),
              )),
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
          child: BuildListBody(),
        ));
  }

  CustomScrollView BuildListBody() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).canvasColor,
          stretch: true,
          pinned: true,
          leading: Container(),
          floating: true,
          toolbarHeight: 20.0 + kToolbarHeight,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: SizedBox(
              height: 45,
              child: Container(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: TextField(
                  onTap: () {
                    setState(() {
                      searchTextFocus.value == true;
                    });
                  },
                  controller: _searchTextcontroller,
                  onChanged: (text) {
                    if (text == "") {
                      setState(() {
                        ListInvoice(invoiceController.ListInvoice);
                      });
                      return;
                    }
                    ListInvoice.value = invoiceController.ListInvoice.where(
                        (p0) =>
                            p0.invoiceNumber!
                                .toLowerCase()
                                .contains(text.toLowerCase()) ||
                            p0.amount!
                                .toString()
                                .toLowerCase()
                                .contains(text.toLowerCase())).toList();
                  },
                  decoration: InputDecoration(
                      prefixIcon: Icon(CupertinoIcons.search),
                      contentPadding: EdgeInsets.only(top: 10),
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          _searchTextcontroller.clear();
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          setState(() {
                            ListInvoice(invoiceController.ListInvoice);
                          });
                        },
                        icon: Icon(Icons.clear),
                      ),
                      hintText: 'Find Invoice Number'),
                ),
              ),
            ),
          ),
        ),
        Obx(() => Container(
              child: SliverList(
                delegate: invoiceController.isLoading.value == false
                    ? BuilderListCard(ListInvoice.value)
                    : BuilderListSkeletonCard(),
              ),
            )),
      ],
    );
  }

  SliverChildBuilderDelegate BuilderListCard(List<Invoice> _ListInvoice) {
    List<Invoice> _listResult = _ListInvoice;
    return SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        var amount = CurrencyTextInputFormatter(
                locale: 'id', symbol: 'Rp. ', decimalDigits: 0)
            .format(_listResult[index].amount.toString());
        var status = invoiceController.ListStatusInvoice.firstWhere(
            (element) => element.id == _listResult[index].status).displayName!;
        return Container(
            child: GFListTile(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            print("TAP LIST");
            showDetilInvoice(_listResult[index]);
          },
          title: Text("Number: ${_listResult[index].invoiceNumber!}",
              style: TextStyle(
                fontSize: 16,
              )),
          subTitleText: "Status: ${status} \nAmount: ${amount}",
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          margin: EdgeInsets.all(0),
        ));
      },
      childCount: _listResult.length,
    );
  }

  SliverChildBuilderDelegate BuilderListSkeletonCard() {
    return SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SkeletonParagraph(
              style: SkeletonParagraphStyle(
                  lines: 2,
                  spacing: 5,
                  lineStyle: SkeletonLineStyle(
                    randomLength: false,
                    height: 15,
                    borderRadius: BorderRadius.circular(5),
                  )),
            ));
      },
      childCount: 8,
    );
  }

  void showDetilInvoice(Invoice invoice) async {
    print(invoice.invoiceNumber);
    SmartDialog.showLoading(msg: "Check Invoice...");
    await invoiceController
        .getDetilInvoice(invoice.invoiceNumber!)
        .then((value) async {
      SmartDialog.dismiss();
      await Get.dialog(
        buildDetilInvoice(value),
        barrierDismissible: true,
      );
    });
    SmartDialog.dismiss();
  }

  Widget buildDetilInvoice(Invoice invoice) {
    var statusInvoice = "".obs;
    var status = invoiceController.ListStatusInvoice.firstWhere(
        (element) => element.id == invoice.status).displayName!;
    statusInvoice.value = status;

    return Container(
      decoration: BoxDecoration(color: Colors.transparent),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: Get.width * 0.9,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
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
                          "${invoice.invoiceNumber}",
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
                        Text("${invoice.bank}", textScaleFactor: 1.1)
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
                                "${invoice.vaNumber}",
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
                              FlutterClipboard.copy(invoice.vaNumber!)
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
                                "${CurrencyTextInputFormatter(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(invoice.amount.toString())}",
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
                              FlutterClipboard.copy(invoice.amount!.toString())
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ))
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      height: 20,
                    ),
                  ],
                ),
                SizedBox(height: 0),
                invoice.status == 101
                    ? GFButton(
                        blockButton: true,
                        color: GFColors.DANGER,
                        onPressed: () {
                          showKonfirmBatalkanInvoice(invoice);
                        },
                        text: "Cancel Invoice",
                      )
                    : Container(),
                GFButton(
                  blockButton: true,
                  onPressed: () {
                    Get.back();
                  },
                  text: "Close",
                ),
                
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showKonfirmBatalkanInvoice(Invoice invoice) {
    Get.defaultDialog(
        contentPadding: const EdgeInsets.all(20),
        title: "Confirmation",
        titlePadding: const EdgeInsets.only(top: 10, bottom: 0),
        middleText: "Yakin ingin Batalkan Invoice ini?",
        backgroundColor: GFColors.LIGHT,
        titleStyle: const TextStyle(color: Colors.black, fontSize: 16),
        middleTextStyle: const TextStyle(color: Colors.black, fontSize: 14),
        textCancel: "Close",
        textConfirm: "Ya, Batalkan",
        cancelTextColor: GFColors.DANGER,
        confirmTextColor: GFColors.LIGHT,
        buttonColor: GFColors.DANGER,
        onConfirm: () async {
          SmartDialog.showLoading(msg: "Batalkan Invoice..");
          await InvoiceController.to
              .submitBatalkanInvoice(invoice.invoiceNumber!)
              .then((value) {
            SmartDialog.dismiss();
            Navigator.of(Get.overlayContext!).pop();
            Get.back();
            reloadData();
            if (value == true) {
              GFToast.showToast('Invoice Berhasil Dibatalkan', context,
                  trailing: const Icon(
                    Icons.check_circle_outline,
                    color: GFColors.SUCCESS,
                  ),
                  toastPosition: GFToastPosition.BOTTOM,
                  toastDuration: 3,
                  toastBorderRadius: 5.0);
            }
          });
          SmartDialog.dismiss();
        },
        radius: 0);
  }
}
