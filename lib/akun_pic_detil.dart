// ignore_for_file: prefer_const_constructors

import 'package:dropdown_search/dropdown_search.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';
import 'package:tmcapp/controller/AppController.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/controller/AkunController.dart';
import 'package:tmcapp/controller/CompanyController.dart';
import 'package:tmcapp/model/akun_firebase.dart';
import 'package:tmcapp/model/company.dart';

class KelolaPICDetilScreen extends StatefulWidget {
  @override
  State<KelolaPICDetilScreen> createState() => _KelolaPICDetilScreenState();
}

class _KelolaPICDetilScreenState extends State<KelolaPICDetilScreen> {
  final authController = AuthController.to;
  final AkunController akunController = AkunController.to;
  var ListAkun = <AkunFirebase>[].obs;
  var ListAkunMember = <AkunFirebase>[].obs;
  var isLoading = true.obs;
  var searchTextFocus = false.obs;
  var addEmail = "".obs;
  var addCompany = "".obs;
  var CompanySelected = null.obs;
  var nameCompanyRef = "".obs;
  var idCompanyRef = "".obs;

  var emailController = TextEditingController();
  var nomorVAController = TextEditingController();
  CompanyController companyController = CompanyController.to;

  void _onRefresh() async {
    // monitor network fetch
    isLoading.value = true;
    //await CompanyController.to.getListCompany();
    await akunController.getListAkunPIC();
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    setState(() {
      ListAkun(akunController.ListAkun);
      isLoading.value = false;
      _searchTextcontroller.text = "";
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
    // setState(() {
    //   idCompanyRef(Get.arguments['idCompany']);
    //   nameCompanyRef(CompanyController.to.getCompanyName(idCompanyRef.value));
    // });
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      //akunController.getListAkun();
      await akunController.getListAkunPIC();
      setState(() {
        ListAkun(akunController.ListAkun);
        isLoading(false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: buildFloatingActionAdd(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: AppBar(
          title: Obx(() => Text("PIC account (${ListAkun.value.length})")),
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
                        ListAkun(akunController.ListAkun);
                      });
                      return;
                    }
                    ListAkun.value = akunController.ListAkun.where((p0) =>
                        p0.displayName!
                            .toLowerCase()
                            .contains(text.toLowerCase()) ||
                        p0.companyName!
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
                            ListAkun(akunController.ListAkun);
                          });
                        },
                        icon: Icon(Icons.clear),
                      ),
                      hintText: 'Find User/Company'),
                ),
              ),
            ),
          ),
        ),
        Obx(() => Container(
              child: SliverList(
                delegate: isLoading.value == false
                    ? BuilderListCard(ListAkun.value)
                    : BuilderListSkeletonCard(),
              ),
            )),
      ],
    );
  }

  SliverChildBuilderDelegate BuilderListCard(List<AkunFirebase> _ListAkun) {
    List<AkunFirebase> _listResult = _ListAkun;
    return SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return Container(
            child: GFListTile(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            print("TAP LIST");
            showDetilAkun(_listResult[index]);
          },
          title: Text(_listResult[index].displayName!,
              style: TextStyle(
                fontSize: 16,
              )),
          subTitleText: "${_listResult[index].companyName}",
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          margin: EdgeInsets.all(0),
          avatar: GFAvatar(
              radius: 20,
              backgroundImage:
                  Image.network(_listResult[index].photoUrl!).image),
          icon: authController.user.value.role == "admin" ||
                  authController.user.value.role == "superadmin"
              ? generatePopMenuAction(_listResult[index])
              : Container(),
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

  Padding buildFloatingActionAdd() {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Obx(() => Visibility(
              visible: authController.user.value.role == "superadmin" ||
                      authController.user.value.role == "admin"
                  ? true
                  : false,
              child: FloatingActionButton(
                heroTag: "float_blog",
                onPressed: () async {
                  // var temp = await akunController.generateListMemberNonCompany();
                  // setState(() {
                  //   ListAkunMember(temp);
                  // });
                  emailController.text = "";
                  await Get.dialog(
                    buildFormPIC(),
                    barrierDismissible: false,
                  );
                },
                backgroundColor: CupertinoColors.white,
                elevation: 6,
                child: const Icon(
                  Icons.add,
                  color: CupertinoColors.activeOrange,
                  size: 26.0,
                ),
                mini: true,
              ),
            )));
  }

  Widget buildFormPIC() {
    final formKey = GlobalKey<FormState>();
    companyController.getListCompany();
    nomorVAController.text = "";
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
                    Obx(() => Text(
                          "Invite Akun PIC \n${nameCompanyRef.value}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        )),
                    Divider(
                      color: CupertinoColors.lightBackgroundGray,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    DropdownSearch<Company>(
                      itemAsString: (item) => item!.companyAsStringByName(),
                      onChanged: (value) => {
                        print("TERPILIH: ${value!.pk}"),
                        setState(() {
                          idCompanyRef.value = value.pk.toString();
                        })
                      },
                      mode: Mode.DIALOG,
                      showSearchBox: true,
                      items: companyController.ListCompany.value,
                      dropdownBuilder: _customDropDownCompany,
                      popupItemBuilder: _customPopupItemCompany,
                      dropdownSearchDecoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                          labelText: "Company",
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
                    TextFormField(
                        controller: emailController,
                        style: const TextStyle(fontSize: 13, height: 2),
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 15),
                            labelText: "Email PIC",
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 14),
                            labelStyle:
                                TextStyle(color: Colors.grey, fontSize: 13),
                            border: OutlineInputBorder()),
                        autocorrect: false,
                        validator: (_val) {
                          if (_val == "") {
                            return 'Required Filled!';
                          }
                          if (EmailValidator.validate(_val!) == false) {
                            return 'Invalid Email Address';
                          }
                          return null;
                        }),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                        readOnly: false,
                        controller: nomorVAController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          MaskTextInputFormatter(
                              mask: '##########',
                              filter: {"#": RegExp(r'[0-9]')},
                              type: MaskAutoCompletionType.lazy)
                        ],
                        style: const TextStyle(fontSize: 13, height: 2),
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 15),
                            labelText: "Nomor Virtual Account (VA)",
                            helperText: "Enter 10 Digit Virtual Account Number",
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 14),
                            labelStyle:
                                TextStyle(color: Colors.grey, fontSize: 13),
                            border: OutlineInputBorder()),
                        autocorrect: false,
                        validator: (_val) {
                          if (_val!.length > 0 && _val.length < 10) {
                            return 'VA number must be 10 Digits!';
                          }
                          return null;
                        }),
                    SizedBox(
                      height: 20,
                    ),
                    GFButton(
                      fullWidthButton: true,
                      color: GFColors.LIGHT,
                      textColor: GFColors.DARK,
                      onPressed: () {
                        Navigator.pop(Get.overlayContext!);
                      },
                      text: "Cancel",
                    ),
                    GFButton(
                      disabledColor: CupertinoColors.systemGrey3,
                      disabledTextColor: Colors.white,
                      fullWidthButton: true,
                      color: GFColors.PRIMARY,
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) {
                          GFToast.showToast(
                              'Sorry, the data form is not complete yet!',
                              context,
                              trailing: const Icon(
                                Icons.error_outline,
                                color: GFColors.WARNING,
                              ),
                              toastPosition: GFToastPosition.BOTTOM,
                              toastBorderRadius: 5.0);
                          return;
                        }
                        if (emailController.text != "" &&
                            idCompanyRef.value != "") {
                          SmartDialog.showLoading(msg: "Adding PIC...");
                          bool statusUpdate = false;
                          //update company akun dulu ya
                          // await akunController
                          //     .submitInviteMemberByEmail(
                          //         addEmail.value, addCompany.value)
                          //     .then((value) => statusCompany = value);

                          await akunController
                              .submitInvitePICByEmail(emailController.text,
                                  idCompanyRef.value, nomorVAController.text)
                              .then((value) => statusUpdate = value);
                          if (statusUpdate == true) {
                            var statusUpdateVA = false;
                            if (nomorVAController.text.length == 0) {
                              statusUpdateVA = true;
                            } else {
                              await akunController
                                  .updateNomorVA(
                                      emailController.text,
                                      idCompanyRef.value,
                                      nomorVAController.text)
                                  .then((value) => statusUpdateVA = value);
                            }
                            if (statusUpdateVA == true) {
                              bool statusFirebaseCompany = false;
                              bool statusFirebaseRole = false;
                              await akunController
                                  .updateCompanyFirebase(
                                      emailController.text, idCompanyRef.value)
                                  .then((value) => statusFirebaseRole = value);
                              await akunController
                                  .updateRoleFirebase(
                                      emailController.text, "PIC")
                                  .then((value) => statusFirebaseRole = value);
                              GFToast.showToast(
                                  'PIC Added Successfully', context,
                                  trailing: const Icon(
                                    Icons.check_circle_outline,
                                    color: GFColors.SUCCESS,
                                  ),
                                  toastDuration: 3,
                                  toastPosition: GFToastPosition.BOTTOM,
                                  toastBorderRadius: 5.0);
                              _onRefresh();
                            }
                          } else {
                            GFToast.showToast(
                                'Invalid Email, Failed to Add PIC', context,
                                trailing: const Icon(
                                  Icons.error_outline,
                                  color: GFColors.DANGER,
                                ),
                                toastDuration: 3,
                                toastPosition: GFToastPosition.BOTTOM,
                                toastBorderRadius: 5.0);
                          }

                          Navigator.of(Get.context!).pop();
                          SmartDialog.dismiss();
                        } else {
                          GFToast.showToast(
                              'PIC and Company Email Required', context,
                              trailing: const Icon(
                                Icons.error_outline,
                                color: GFColors.WARNING,
                              ),
                              toastDuration: 3,
                              toastPosition: GFToastPosition.BOTTOM,
                              toastBorderRadius: 5.0);
                        }
                      },
                      text: "Add As PIC",
                      icon: Icon(
                        Icons.add,
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

  void showKonfirmDelete(AkunFirebase item) async {
    await Get.defaultDialog(
        contentPadding: const EdgeInsets.all(20),
        title: "Confirmation",
        titlePadding: const EdgeInsets.only(top: 10, bottom: 0),
        middleText:
            "Are you sure you want to remove the account\n${item.displayName}\nfrom the PIC list",
        backgroundColor: CupertinoColors.white,
        titleStyle: const TextStyle(color: Colors.black, fontSize: 16),
        middleTextStyle: const TextStyle(
            color: CupertinoColors.darkBackgroundGray, fontSize: 14),
        textCancel: "Cancel",
        textConfirm: "Yes, Delete",
        buttonColor: GFColors.DANGER,
        cancelTextColor: GFColors.DANGER,
        confirmTextColor: GFColors.WHITE,
        onConfirm: () async {
          Navigator.of(Get.overlayContext!).pop();
          SmartDialog.showLoading(msg: "Delete PIC...");
          akunController.submitRevokePIC(item.email!, item.idCompany!).then(
                (value) async => {
                  SmartDialog.dismiss(),
                  if (value == true)
                    {
                      await akunController.updateRoleCompanyFirebase(
                          item.email!, "member", item.idCompany!),
                      GFToast.showToast(
                          'Account Successfully Removed from PIC List', context,
                          trailing: const Icon(
                            Icons.check_circle_outline,
                            color: GFColors.SUCCESS,
                          ),
                          toastPosition: GFToastPosition.BOTTOM,
                          toastDuration: 3,
                          toastBorderRadius: 5.0),
                      akunController.getListAkunPIC()
                    }
                  else
                    {
                      GFToast.showToast('Failed to Remove!', context,
                          trailing: const Icon(
                            Icons.check_circle_outline,
                            color: GFColors.DANGER,
                          ),
                          toastDuration: 3,
                          toastBorderRadius: 5.0),
                    }
                },
              );
        },
        radius: 0);
  }

  Widget _customDropDownCompany(BuildContext context, Company? item) {
    return Container(
        margin: EdgeInsets.all(0),
        child: (item == null)
            ? const ListTile(
                contentPadding: EdgeInsets.all(0),
                title: Text("Search Company",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(235, 158, 158, 158))),
              )
            : ListTile(
                minLeadingWidth: 2,
                horizontalTitleGap: 8,
                leading: Icon(CupertinoIcons.building_2_fill),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
                dense: true,
                visualDensity: VisualDensity(vertical: -3),
                title: Text(
                  item.displayName!,
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  item.city!,
                  style: TextStyle(fontSize: 12),
                ),
              ));
  }

  Widget _customPopupItemCompany(
      BuildContext context, Company item, bool isSelected) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: ListTile(
          minLeadingWidth: 2,
          horizontalTitleGap: 8,
          leading: Icon(CupertinoIcons.building_2_fill),
          contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
          dense: true,
          visualDensity: VisualDensity(vertical: -3),
          title: Text(
            item.displayName!,
            style: TextStyle(fontSize: 14),
          ),
          subtitle: Text(
            item.city!,
            style: TextStyle(fontSize: 12),
          ),
        ));
  }

  void showDetilAkun(AkunFirebase listResult) async {
    await Get.dialog(
      buildDetilAkun(listResult),
      barrierDismissible: true,
    );
  }

  Widget buildDetilAkun(AkunFirebase item) {
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
                        labelText: "Full name",
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
                        labelText: "Mobile Number / Whatsapp",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        border: OutlineInputBorder()),
                    initialValue: item.phoneNumber != ""
                        ? item.phoneNumber
                        : "Belum Diisi",
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
                    initialValue:
                        CompanyController.to.getCompanyName(item.idCompany!),
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
                  )
                ],
              ),
            ),
          ],
        ));
  }

  Widget generatePopMenuAction(AkunFirebase akun) {
    return PopupMenuButton(onSelected: (_valueAction) {
      if (_valueAction == "/delete") {
        print("TAP DELETE");
        showKonfirmDelete(akun);
      }
      if (_valueAction == "/update-va") {
        print("UPDATE VA");
        showKonfirmUpdateVA(akun);
      }
    }, itemBuilder: (BuildContext bc) {
      return const [
        PopupMenuItem(
          child: GFListTile(
            avatar: Icon(
              Icons.credit_card,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            title: Text(
              "Nomor VA",
              textScaleFactor: 0.89,
            ),
          ),
          value: '/update-va',
        ),
        PopupMenuItem(
          child: GFListTile(
            avatar: Icon(
              Icons.delete_rounded,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            title: Text(
              "Hapus PIC",
              textScaleFactor: 0.89,
            ),
          ),
          value: '/delete',
        ),
      ];
    });
  }

  Widget buildFormUpdateVA(AkunFirebase akun) {
    final formKey = GlobalKey<FormState>();
    //companyController.getListCompany();
    nomorVAController.text = "";
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
                      "Update Nomor Virtual Account (VA) Pembayaran PIC",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    Divider(
                      color: CupertinoColors.lightBackgroundGray,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                        readOnly: true,
                        initialValue: akun.email,
                        style: const TextStyle(fontSize: 13, height: 2),
                        decoration: const InputDecoration(
                            prefixIcon: Icon(
                              CupertinoIcons.person,
                              size: 16,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 15),
                            labelText: "Email PIC",
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 14),
                            labelStyle:
                                TextStyle(color: Colors.grey, fontSize: 13),
                            border: OutlineInputBorder()),
                        autocorrect: false,
                        validator: (_val) {
                          return null;
                        }),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                        readOnly: true,
                        initialValue: akun.companyName,
                        style: const TextStyle(fontSize: 13, height: 2),
                        decoration: const InputDecoration(
                            prefixIcon: Icon(
                              CupertinoIcons.building_2_fill,
                              size: 16,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 15),
                            labelText: "Company",
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 14),
                            labelStyle:
                                TextStyle(color: Colors.grey, fontSize: 13),
                            border: OutlineInputBorder()),
                        autocorrect: false,
                        validator: (_val) {
                          return null;
                        }),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                        readOnly: false,
                        controller: nomorVAController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          MaskTextInputFormatter(
                              mask: '##########',
                              filter: {"#": RegExp(r'[0-9]')},
                              type: MaskAutoCompletionType.lazy)
                        ],
                        style: const TextStyle(fontSize: 13, height: 2),
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 15),
                            labelText: "Nomor Virtual Account (VA)",
                            helperText: "Enter 10 Digit Virtual Account Number",
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 14),
                            labelStyle:
                                TextStyle(color: Colors.grey, fontSize: 13),
                            border: OutlineInputBorder()),
                        autocorrect: false,
                        validator: (_val) {
                          if (_val!.length < 10) {
                            return 'VA number must be 10 Digits!';
                          }
                          return null;
                        }),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GFButton(
                      fullWidthButton: true,
                      color: GFColors.LIGHT,
                      textColor: GFColors.DARK,
                      onPressed: () {
                        Navigator.pop(Get.overlayContext!);
                      },
                      text: "Cancel",
                    ),
                    GFButton(
                      disabledColor: CupertinoColors.systemGrey3,
                      disabledTextColor: Colors.white,
                      fullWidthButton: true,
                      color: GFColors.PRIMARY,
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) {
                          GFToast.showToast(
                              'Sorry, the data form is not complete yet!',
                              context,
                              trailing: const Icon(
                                Icons.error_outline,
                                color: GFColors.WARNING,
                              ),
                              toastPosition: GFToastPosition.BOTTOM,
                              toastBorderRadius: 5.0);
                          return;
                        }
                        if (akun.email != "" &&
                            akun.idCompany != "" &&
                            nomorVAController.text != "") {
                          SmartDialog.showLoading(
                              msg: "Updated VA Nomor PIC...");
                          bool statusUpdate = false;
                          await akunController
                              .updateNomorVA(akun.email!, akun.idCompany!,
                                  nomorVAController.text)
                              .then((value) => statusUpdate = value);
                          Navigator.of(Get.context!).pop();
                          SmartDialog.dismiss();
                          if (statusUpdate == false) {
                            GFToast.showToast(
                                'Failed Update!',
                                context,
                                trailing: const Icon(
                                  Icons.error_outline,
                                  color: GFColors.WARNING,
                                ),
                                toastDuration: 3,
                                toastPosition: GFToastPosition.BOTTOM,
                                toastBorderRadius: 5.0);
                            return;
                          }
                          GFToast.showToast(
                              'VA Number : ${akunController.updateValueNomorVA} \nsaved successfully!',
                              context,
                              trailing: const Icon(
                                Icons.check_circle_outline,
                                color: GFColors.SUCCESS,
                              ),
                              toastDuration: 5,
                              toastPosition: GFToastPosition.BOTTOM,
                              toastBorderRadius: 5.0);
                        }
                      },
                      text:"VA Number Update",
                      icon: Icon(
                        Icons.save,
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

  void showKonfirmUpdateVA(AkunFirebase akun) async {
    await Get.dialog(
      buildFormUpdateVA(akun),
      barrierDismissible: false,
    );
  }
}
