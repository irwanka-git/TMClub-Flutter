// ignore_for_file: prefer_const_constructors, unrelated_type_equality_checks

import 'dart:convert';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';
import 'package:tmcapp/client.dart';
import 'package:tmcapp/controller/AkunController.dart';
import 'package:tmcapp/controller/AppController.dart';
import 'package:tmcapp/controller/BottomTabController.dart';
import 'package:flutter/material.dart';
import 'package:tmcapp/controller/CompanyController.dart';
import 'package:tmcapp/model/akun_firebase.dart';
import 'package:tmcapp/model/event_tmc.dart';
import 'package:tmcapp/model/event_tmc_detil.dart';
import 'package:tmcapp/model/invoice.dart';
import 'package:tmcapp/model/payment_method.dart';
import 'package:tmcapp/model/registrant.dart';
import 'package:tmcapp/widget/skeleton.dart';

import 'controller/AuthController.dart';
import 'controller/EventController.dart';

class EventDetilRegistrasiPICScreen extends StatefulWidget {
  @override
  State<EventDetilRegistrasiPICScreen> createState() =>
      _EventDetilRegistrasiPICScreen();
}

class _EventDetilRegistrasiPICScreen
    extends State<EventDetilRegistrasiPICScreen> {
  final bottomTabControl = BottomTabController.to;
  final eventController = EventController.to;
  final akunController = AkunController.to;
  final authController = AuthController.to;

  late ScrollController _scrollController;
  final Color _foregroundColor = Colors.white;
  final isLoading = true.obs;
  final base_url = ApiClient().base_url;
  final id_event = 0.obs;
  final itemAcara = EventTmcDetil(pk: 0).obs;
  TextEditingController _searchRegistrantTextcontroller =
      TextEditingController();
  TextEditingController _searchMemberTextcontroller = TextEditingController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  var MyRegistrant = <Registrant>[].obs;
  var MyRegistrantDisplay = <Registrant>[].obs;
  var ListMember = <AkunFirebase>[].obs;
  final requireSaveAction = false.obs;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    //eventController.getListEvent();
    setState(() {
      id_event(Get.arguments['id_event']);
    });

    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      //companyController.getListCompany();
      reloadMyRegistrant();
      await akunController.getListAkunMember();

      setState(() {
        ListMember(akunController.ListAkun);
      });
    });
  }

  void reloadMyRegistrant() async {
    await eventController.getDetilEvent(id_event.value).then(((value) {
      //print("GET ACARA");
      //print(jsonEncode(value));
      setState(() {
        itemAcara(value);
      });
    }));

    setState(() {
      requireSaveAction(false);
    });
    //print(jsonEncode(itemAcara.value));
    await eventController.getListMyRegistrant(itemAcara.value.pk!);
    _searchRegistrantTextcontroller.text = "";
    print("RELOAD PESERTA");
    setState(() {
      MyRegistrant.clear();
      MyRegistrant.addAll(eventController.ListMyRegistrant);
      MyRegistrantDisplay(MyRegistrant);
      requireSaveAction(false);
    });
  }

  void _onRefresh() async {
    // monitor network fetch
    isLoading.value = true;
    //eventController.getListEvent();
    reloadMyRegistrant();
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

  @override
  Widget build(BuildContext context) {
    Color appBarColor = AppController.to.appBarColor.value;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Participant Registration (${eventController.ListMyRegistrant.value.length})",
              style: TextStyle(fontSize: 14),
            ),
            Obx(() => Text(
                  itemAcara.value.title != null
                      ? "${itemAcara.value.title}"
                      : "",
                  style: TextStyle(fontSize: 16),
                )),
          ],
        ),
        backgroundColor: appBarColor,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: const MaterialClassicHeader(
            color: CupertinoColors.activeOrange,
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: BuildListBody(),
        ),
      ),
    );
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
          toolbarHeight: kToolbarHeight + 15,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Container(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: TextField(
                      controller: _searchRegistrantTextcontroller,
                      onChanged: (text) {
                        if (text == "") {
                          setState(() {
                            //ListAkun(akunController.ListAkun);
                            MyRegistrantDisplay(MyRegistrant);
                          });
                          return;
                        }
                        setState(() {
                          MyRegistrantDisplay.value = MyRegistrant.where((p0) =>
                              p0.displayName!
                                  .toLowerCase()
                                  .contains(text.toLowerCase())).toList();
                        });
                      },
                      decoration: InputDecoration(
                          prefixIcon: Icon(CupertinoIcons.search),
                          contentPadding: EdgeInsets.only(top: 10),
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              _searchRegistrantTextcontroller.clear();
                              setState(() {
                                //ListAkun(akunController.ListAkun);
                                MyRegistrantDisplay(MyRegistrant);
                              });
                            },
                            icon: Icon(Icons.clear),
                          ),
                          hintText: 'Search'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        itemAcara.value.isRegistrationClose == false
            ? SliverAppBar(
                centerTitle: true,
                backgroundColor: Theme.of(context).canvasColor,
                stretch: true,
                pinned: true,
                leading: Container(),
                floating: true,
                toolbarHeight: kToolbarHeight,
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Container(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: itemAcara.value.isRegistrationClose == false
                          ? GFButton(
                              onPressed: () {
                                showModalSelectPeserta();
                              },
                              blockButton: true,
                              icon: Icon(
                                CupertinoIcons.add,
                                size: 16,
                                color: GFColors.WHITE,
                              ),
                              color: CupertinoColors.activeGreen,
                              text: "Add Participant",
                            )
                          : Container(),
                    )),
              )
            : SliverAppBar(toolbarHeight: 0),
        Obx(() => Container(
              child: SliverList(
                delegate: eventController.isLoading.value == false
                    ? BuilderListCard(MyRegistrantDisplay)
                    : BuilderListSkeletonCard(),
              ),
            )),
        requireSaveAction.value == true
            ? SliverAppBar(
                centerTitle: true,
                backgroundColor: Theme.of(context).canvasColor,
                stretch: true,
                pinned: true,
                leading: Container(),
                floating: true,
                toolbarHeight: 120.0 + kToolbarHeight,
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Container(
                        padding:
                            const EdgeInsets.only(left: 15, right: 15, top: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            itemAcara.value.isRegistrationClose == false
                                ? GFButton(
                                    onPressed: () {
                                      showKonfirmSubmitPendaftaran();
                                    },
                                    blockButton: true,
                                    icon: Icon(
                                      CupertinoIcons.paperplane,
                                      size: 16,
                                      color: GFColors.WHITE,
                                    ),
                                    color: CupertinoColors.activeBlue,
                                    child: Text(
                                        "Participant Registration (${MyRegistrant.value.where((element) => element.isRegistrant == false).length})"),
                                  )
                                : Container(),
                          ],
                        ))),
              )
            : SliverAppBar(toolbarHeight: 0),
      ],
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

  SliverChildBuilderDelegate BuilderListCard(List<Registrant> items) {
    return SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return Obx(() => Container(
                child: GFListTile(
              onTap: () {
                showModalInformasiAkun(items[index]);
              },
              title: Text(items[index].displayName!,
                  style: TextStyle(
                    fontSize: 16,
                  )),
              subTitleText: "${items[index].email}",
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              margin: EdgeInsets.all(0),
              avatar: GFAvatar(
                  radius: 20,
                  backgroundImage: Image.network(items[index].photoUrl!).image),
              icon: authController.user.value.role == "PIC" &&
                      itemAcara.value.isRegistrationClose == false &&
                      items[index].isRegistrant == false
                  // && statusBayarPeserta==false DELETE REGISTRANT
                  ? GFIconButton(
                      iconSize: 20,
                      color: Colors.transparent,
                      icon: Icon(
                        Icons.close,
                        color: CupertinoColors.darkBackgroundGray,
                      ),
                      onPressed: () {
                        setState(() {
                          MyRegistrant.value.remove(items[index]);
                          MyRegistrantDisplay(MyRegistrant);
                        });
                        print("MyRegistrant: ${MyRegistrant.value.length}");
                        print(
                            "ListMyRegistrant: ${eventController.ListMyRegistrant.value.length}");

                        if (MyRegistrant.value.length !=
                            eventController.ListMyRegistrant.value.length) {
                          setState(() {
                            requireSaveAction(true);
                          });
                        } else {
                          setState(() {
                            requireSaveAction(false);
                          });
                        }
                        //showKonfirmDelete(_listResult[index]);
                      })
                  : Container(),
            )));
      },
      childCount: items.length,
    );
  }

  void showModalSelectPeserta() {
    var ListSelectMember = <AkunFirebase>[];
    List<String> emailRegistrant =
        MyRegistrant.value.map((item) => item.email!).toList();

    for (var item in ListMember) {
      if (emailRegistrant.contains(item.email!) == false) {
        ListSelectMember.add(item);
      }
    }

    _searchMemberTextcontroller.clear();
    final ListMemberBottomSheet = <AkunFirebase>[].obs;
    setState(() {
      ListMemberBottomSheet.clear();
      ListMemberBottomSheet.addAll(ListSelectMember);
    });

    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
              padding: EdgeInsets.only(
                  top: 20,
                  right: 20,
                  left: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 8.0),
                  TextField(
                    controller: _searchMemberTextcontroller,
                    onChanged: (text) {
                      if (text == "") {
                        setState(() {
                          ListMemberBottomSheet.clear();
                          ListMemberBottomSheet.addAll(ListSelectMember);
                        });
                        return;
                      }
                      setState(() {
                        ListMemberBottomSheet.value = ListSelectMember.where(
                            (p0) => p0.displayName!
                                .toLowerCase()
                                .contains(text.toLowerCase())).toList();
                      });
                      // ListAkun.value = akunController.ListAkun.where((p0) => p0
                      //     .displayName!
                      //     .toLowerCase()
                      //     .contains(text.toLowerCase())).toList();
                    },
                    decoration: InputDecoration(
                        prefixIcon: Icon(CupertinoIcons.search),
                        contentPadding: EdgeInsets.only(top: 10),
                        border: OutlineInputBorder(),
                        hintText: 'Search'),
                  ),
                  SingleChildScrollView(
                    child: Container(
                      constraints: BoxConstraints(maxHeight: Get.height * 0.4),
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Column(children: [
                        Expanded(
                          flex: 2,
                          child: Obx(() => ListView.builder(
                              itemCount: ListMemberBottomSheet.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GFListTile(
                                  title: Text(
                                      ListMemberBottomSheet[index].displayName!,
                                      style: TextStyle(
                                        fontSize: 16,
                                      )),
                                  subTitleText:
                                      "${ListMemberBottomSheet[index].email}",
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 8),
                                  margin: EdgeInsets.all(0),
                                  avatar: GFAvatar(
                                      radius: 20,
                                      backgroundImage: Image.network(
                                              ListMemberBottomSheet[index]
                                                  .photoUrl!)
                                          .image),
                                  onTap: () {
                                    //print(ListMemberBottomSheet[index].email);
                                    if (emailRegistrant.contains(
                                            ListMemberBottomSheet[index]
                                                .email) ==
                                        false) {
                                      print(ListMemberBottomSheet[index].email);
                                      setState(() {
                                        Registrant newRegistrant = Registrant(
                                            email: ListMemberBottomSheet[index]
                                                .email,
                                            displayName:
                                                ListMemberBottomSheet[index]
                                                    .displayName,
                                            phoneNumber:
                                                ListMemberBottomSheet[index]
                                                    .phoneNumber,
                                            isRegistrant: false,
                                            photoUrl:
                                                ListMemberBottomSheet[index]
                                                    .photoUrl,
                                            companyId:
                                                ListMemberBottomSheet[index]
                                                    .idCompany,
                                            companyName:
                                                ListMemberBottomSheet[index]
                                                    .companyName);
                                        MyRegistrant.value.add(newRegistrant);
                                        ListSelectMember.remove(
                                            ListMemberBottomSheet[index]);
                                        ListMemberBottomSheet.remove(
                                            ListMemberBottomSheet[index]);
                                        MyRegistrantDisplay(MyRegistrant);
                                        requireSaveAction(true);
                                      });
                                    }
                                    Navigator.of(Get.context!).pop();
                                  },
                                );
                              })),
                        )
                      ]),
                    ),
                  )
                ],
              ),
            ));
  }

  void showModalInformasiAkun(Registrant item) async {
    await Get.dialog(
      buildDetilAkun(item),
      barrierDismissible: true,
    );
  }

  Future<void> showKonfirmSubmitPendaftaran() async {
    String nomor_va = "";
    SmartDialog.showLoading(msg: "Mohon Tunggu...", backDismiss: false);
    await AkunController.to.getMyNumberVA().then((value) => nomor_va = value);
    if (nomor_va == "") {
      SmartDialog.dismiss();
      GFToast.showToast(
          'Your Payment Virtual Account Number is not yet available, Please Contact the Administrator!',
          context,
          trailing: const Icon(
            Icons.error_outline,
            color: GFColors.WARNING,
          ),
          toastDuration: 5,
          toastPosition: GFToastPosition.BOTTOM,
          toastBorderRadius: 5.0);
      return;
    }
    var listPaymentMethod = <PaymentMethod>[];
    await eventController.getPaymentMethodList().then((value) {
      for (var item in value) {
        listPaymentMethod.add(item);
      }
    });

    if (listPaymentMethod.isEmpty) {
      SmartDialog.dismiss();
      GFToast.showToast(
          'Payment method is not yet available, Please Contact Administrator!', context,
          trailing: const Icon(
            Icons.error_outline,
            color: GFColors.WARNING,
          ),
          toastDuration: 5,
          toastPosition: GFToastPosition.BOTTOM,
          toastBorderRadius: 5.0);
      return;
    }

    int pesertaLama = MyRegistrant.value
        .where((element) => element.isRegistrant == true)
        .length;
    int pesertaBaru = MyRegistrant.value
        .where((element) => element.isRegistrant == false)
        .length;
    var newRegistrar = MyRegistrant.value
        .where((element) => element.isRegistrant == false)
        .toList();
    List<String> emailRegistarBaru =
        newRegistrar.map((item) => item.email!).toList();
    SmartDialog.dismiss();
    await Get.dialog(
      buildKonfirmRegistrasiPayment(emailRegistarBaru, listPaymentMethod),
      barrierDismissible: true,
    );
  }

  Widget buildDetilAkun(Registrant item) {
    return Container(
        decoration: BoxDecoration(color: Colors.transparent),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: Get.width * 0.88,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Account Information",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Divider(
                    color: CupertinoColors.lightBackgroundGray,
                  ),
                  GFAvatar(
                    backgroundImage: Image.network(item.photoUrl!).image,
                    radius: 40,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GFTextField(
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                        labelText: "Full Name",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        border: OutlineInputBorder()),
                    initialValue: item.displayName!,
                    enabled: false,
                    readOnly: true,
                    color: Colors.red,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GFTextField(
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                        labelText: "Email",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        border: OutlineInputBorder()),
                    initialValue: item.email!,
                    enabled: false,
                    readOnly: true,
                    color: Colors.red,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GFTextField(
                    expands: true,
                    decoration: InputDecoration(
                        prefixIcon: item.phoneNumber != ""
                            ? IconButton(
                                onPressed: () {
                                  AkunController.to
                                      .callWhatsappMe(item.phoneNumber);
                                },
                                icon: Icon(
                                  Icons.whatsapp_outlined,
                                  color: CupertinoColors.activeGreen,
                                ),
                              )
                            : Icon(Icons.phone),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                        labelText: "Phone Number / Whatsapp",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        border: OutlineInputBorder()),
                    initialValue:
                        item.phoneNumber != "" ? item.phoneNumber : "-",
                    enabled: false,
                    readOnly: true,
                    color: Colors.red,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GFTextField(
                    maxLines: 3,
                    expands: true,
                    showCursor: false,
                    focusNode: FocusNode(),
                    decoration: const InputDecoration(
                        prefixIcon: Icon(CupertinoIcons.building_2_fill),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        labelText: "Company",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        border: OutlineInputBorder()),
                    initialValue: item.companyName,
                    enabled: false,
                    readOnly: true,
                    color: Colors.red,
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  GFButton(
                    text: "Close",
                    onPressed: () {
                      Navigator.pop(Get.overlayContext!);
                    },
                    blockButton: true,
                    color: GFColors.LIGHT,
                    textColor: GFColors.DARK,
                  )
                ],
              ),
            ),
          ],
        ));
  }

  Widget buildKonfirmRegistrasiPayment(
      List<String> emailRegistrasi, List<PaymentMethod> listPaymentMethod) {
    final formKey = GlobalKey<FormState>();
    final idPaymentMethodRef = 0.obs;
    var itemsPaymentMethods = listPaymentMethod
        .map((item) => DropdownMenuItem(
              value: item.id,
              child: Text(
                "${item.id} - ${item.desc!}",
                style: TextStyle(fontSize: 15),
              ),
            ))
        .toList();
    return Container(
        decoration: BoxDecoration(color: Colors.transparent),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: Get.width * 0.88,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Confirmation of Participant Registration",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Divider(
                      height: 15,
                      color: CupertinoColors.lightBackgroundGray,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GFBorder(
                        color: CupertinoColors.separator,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Number of participants"),
                                Text("${emailRegistrasi.length}"),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Fees / Participants"),
                                Text(
                                    "${CurrencyTextInputFormatter(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(itemAcara.value.price!.toString())}"),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total cost"),
                                Text(
                                  "${CurrencyTextInputFormatter(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format((itemAcara.value.price! * emailRegistrasi.length).toString())}",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            )
                          ],
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    DropdownSearch<PaymentMethod>(
                      validator: (_val) {
                        if (_val == null) {
                          return 'Required!';
                        }
                        return null;
                      },
                      itemAsString: (item) => item!.paymentAsStringByName(),
                      onChanged: (value) => {
                        print("TERPILIH: ${value!.id}"),
                        setState(() {
                          idPaymentMethodRef.value = value.id!;
                        })
                      },
                      mode: Mode.BOTTOM_SHEET,
                      showSearchBox: true,
                      items: listPaymentMethod,
                      dropdownBuilder: _customDropDownPayment,
                      popupItemBuilder: _customPopupItemPayment,
                      dropdownSearchDecoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 15),
                          labelText: "Payment Destination Bank",
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 14),
                          labelStyle:
                              TextStyle(color: Colors.grey, fontSize: 13),
                          border: OutlineInputBorder()),
                      showFavoriteItems: true,
                      searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      )),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GFButton(
                      disabledColor: CupertinoColors.systemGrey3,
                      disabledTextColor: Colors.white,
                      fullWidthButton: true,
                      color: GFColors.PRIMARY,
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) {
                          GFToast.showToast(
                              'Opps, Destination Bank Not Selected!', context,
                              trailing: const Icon(
                                Icons.error_outline,
                                color: GFColors.WARNING,
                              ),
                              toastPosition: GFToastPosition.BOTTOM,
                              toastBorderRadius: 5.0);
                          return;
                        } else {
                          print(idPaymentMethodRef.value);
                          print(jsonEncode(emailRegistrasi));
                          print(itemAcara.value.pk);
                          Invoice invoice = Invoice(
                            invoiceNumber: "",
                          );
                          SmartDialog.showLoading(
                              msg: "Processing...", backDismiss: false);
                          await eventController
                              .submitGetInvoiceNumberRegistrasiByPIC(
                                  itemAcara.value.pk!, emailRegistrasi)
                              .then((invoiceResult1) async {
                            if (invoiceResult1.invoiceNumber != "") {
                              var invData = {
                                'invoice_number': invoiceResult1.invoiceNumber,
                                'va_no': "",
                                'event_id': itemAcara.value.pk!,
                                'event_name': itemAcara.value.title,
                                'amount': 0,
                                'peserta': invoiceResult1.peserta,
                                'jumlah_peserta': invoiceResult1.jumlahPeserta,
                                'status': 0,
                                'payment_method_id': idPaymentMethodRef.value,
                                'bank': "",
                              };
                              print(invData);
                              var invoiceAwal = Invoice.fromMap(invData);
                              //String nomor_va_transaksi = "";
                              await eventController
                                  .submitGenerateVAPaymentRegistrasi(
                                      invoiceAwal)
                                  .then((invoiceResult2) {
                                print(jsonEncode(invoiceResult2));
                                SmartDialog.dismiss();
                                if (invoiceResult2.invoiceNumber == "") {
                                  eventController
                                      .submitDeleteMultipleRegistrasi(
                                          emailRegistrasi, itemAcara.value.pk!);
                                  GFToast.showToast(
                                      'Opps, Registration Failed!',
                                      context,
                                      trailing: const Icon(
                                        Icons.error_outline,
                                        color: GFColors.WARNING,
                                      ),
                                      toastPosition: GFToastPosition.BOTTOM,
                                      toastBorderRadius: 5.0);
                                  return;
                                } else {
                                  var datainvoiceFinal = {
                                    'invoice_number':
                                        invoiceResult2.invoiceNumber,
                                    'va_no': invoiceResult2.vaNumber,
                                    'event_id': invoiceResult2.eventId,
                                    'amount': invoiceResult2.amount,
                                    'status': 0,
                                    'payment_method_id':
                                        invoiceResult2.paymentMethodId,
                                    'bank': invoiceResult2.bank,
                                    'event_name': invoiceResult2.eventName,
                                    'peserta': invoiceResult1.peserta,
                                    'jumlah_peserta':
                                        invoiceResult1.jumlahPeserta,
                                    'company_name':
                                        authController.user.value.companyName,
                                    'pic_name':
                                        authController.user.value.displayName,
                                    'pic_email':
                                        authController.user.value.email,
                                  };
                                  Invoice invoiceFinal =
                                      Invoice.fromMap(datainvoiceFinal);

                                  GFToast.showToast(
                                      'Registration Successful, Please Make Payment According To Invoice',
                                      context,
                                      trailing: const Icon(
                                        Icons.check_circle_outline,
                                        color: GFColors.SUCCESS,
                                      ),
                                      toastPosition: GFToastPosition.BOTTOM,
                                      toastBorderRadius: 5.0);
                                  Get.offAllNamed('/event-detil-invoice',
                                      arguments: {'invoice': invoiceFinal});
                                  return;
                                }
                              });
                            } else {
                              SmartDialog.dismiss();
                              GFToast.showToast(
                                  'Opps, Registration Failed!', context,
                                  trailing: const Icon(
                                    Icons.error_outline,
                                    color: GFColors.WARNING,
                                  ),
                                  toastPosition: GFToastPosition.BOTTOM,
                                  toastBorderRadius: 5.0);
                              return;
                            }
                          });
                        }
                      },
                      text: "Proceed to Payment",
                      icon: Icon(
                        CupertinoIcons.right_chevron,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    )
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Widget _customDropDownPayment(BuildContext context, PaymentMethod? item) {
    return Container(
        margin: EdgeInsets.all(0),
        child: (item == null)
            ? const ListTile(
                contentPadding: EdgeInsets.all(0),
                title: Text("Payment Destination Bank..",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(235, 158, 158, 158))),
              )
            : ListTile(
                minLeadingWidth: 2,
                horizontalTitleGap: 8,
                leading: Icon(CupertinoIcons.creditcard),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
                dense: true,
                visualDensity: VisualDensity(vertical: -3),
                title: Text(
                  item.desc!,
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  item.prefix!,
                  style: TextStyle(fontSize: 12),
                ),
              ));
  }

  Widget _customPopupItemPayment(
      BuildContext context, PaymentMethod item, bool isSelected) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: ListTile(
          minLeadingWidth: 2,
          horizontalTitleGap: 8,
          leading: Icon(CupertinoIcons.creditcard),
          contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
          dense: true,
          visualDensity: VisualDensity(vertical: -3),
          title: Text(
            item.desc!,
            style: TextStyle(fontSize: 14),
          ),
          subtitle: Text(
            item.prefix!,
            style: TextStyle(fontSize: 12),
          ),
        ));
  }
}
