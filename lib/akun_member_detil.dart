import 'package:dropdown_search/dropdown_search.dart';
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
import 'package:tmcapp/model/akun_firebase.dart';
import 'package:tmcapp/model/company.dart';

class KelolaMemberDetilScreen extends StatefulWidget {
  @override
  State<KelolaMemberDetilScreen> createState() =>
      _KelolaMemberDetilScreenState();
}

class _KelolaMemberDetilScreenState extends State<KelolaMemberDetilScreen> {
  final authController = AuthController.to;
  final AkunController akunController = AkunController.to;
  var ListAkun = <AkunFirebase>[].obs;
  var ListAkunMember = <AkunFirebase>[].obs;
  var isLoading = true.obs;
  var searchTextFocus = false.obs;
  var addEmail = "".obs;
  var addCompany = "".obs;
  var CompanySelected = null.obs;
  var idCompanyRef = "".obs;
  var nameCompanyRef = "".obs;
  void _onRefresh() async {
    // monitor network fetch
    isLoading.value = true;
    //await CompanyController.to.getListCompany();
    await akunController.getListAkunMember();
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
    setState(() {
      idCompanyRef(Get.arguments['idCompany']);
      nameCompanyRef(CompanyController.to.getCompanyName(idCompanyRef.value));
    });
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      //akunController.getListAkun();
      await akunController.getListAkunMember();
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
          title: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(
                        "Akun Member (${ListAkun.value.length})",
                        style: TextStyle(fontSize: 18),
                      )),
                  Text(
                    "${nameCompanyRef.value}",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
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
                        ListAkun(akunController.ListAkun);
                      });
                      return;
                    }
                    ListAkun.value = akunController.ListAkun.where((p0) => p0
                        .displayName!
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
                      hintText: 'Search'),
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
          subTitleText: "${_listResult[index].email}",
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          margin: EdgeInsets.all(0),
          avatar: GFAvatar(
              radius: 20,
              backgroundImage:
                  Image.network(_listResult[index].photoUrl!).image),
          icon: authController.user.value.role == "admin" ||
                  authController.user.value.role == "superadmin"
              ? GFIconButton(
                  iconSize: 20,
                  color: Colors.transparent,
                  icon: Icon(
                    CupertinoIcons.trash,
                    color: CupertinoColors.darkBackgroundGray,
                  ),
                  onPressed: () {
                    print("TAP DELETE");
                    showKonfirmDelete(_listResult[index]);
                  })
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
              visible: authController.user.value.role == "PIC" ? true : false,
              child: FloatingActionButton(
                heroTag: "float_blog",
                onPressed: () async {
                  var temp = await akunController.generateListAkun("member");
                  setState(() {
                    ListAkunMember(temp);
                  });
                  await Get.dialog(
                    buildFormMember(),
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

  Widget buildFormMember() {
    final formKey = GlobalKey<FormState>();
    setState(() {
      addEmail.value = "";
    });
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
                          "Invite Akun Member \n${nameCompanyRef.value}",
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
                    SizedBox(
                      height: 25,
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
                        if (addEmail.value != "" && idCompanyRef.value != "") {
                          SmartDialog.showLoading(msg: "Add Member.....");
                          bool statusCompany = false;
                          bool statusUpdate = false;
                          //update company akun dulu ya
                          await akunController
                              .submitInviteMemberByEmail(
                                  addEmail.value, idCompanyRef.value)
                              .then((value) => statusCompany = value);
                          if (statusCompany == true) {
                            bool statusFirebaseCompany = false;
                            bool statusFirebaseRole = false;
                            await akunController
                                .updateRoleCompanyFirebase(addEmail.value,
                                    "member", idCompanyRef.value)
                                .then((value) => statusFirebaseRole = value);
                            GFToast.showToast(
                                'Menambahkan MemberMember Successfully added', context,
                                trailing: const Icon(
                                  Icons.check_circle_outline,
                                  color: GFColors.SUCCESS,
                                ),
                                toastDuration: 3,
                                toastPosition: GFToastPosition.BOTTOM,
                                toastBorderRadius: 5.0);
                            akunController.getListAkunMember();
                          } else {
                            GFToast.showToast(
                                'Failed Add Member..', context,
                                trailing: const Icon(
                                  Icons.check_circle_outline,
                                  color: GFColors.DANGER,
                                ),
                                toastDuration: 3,
                                toastBorderRadius: 5.0);
                          }

                          Navigator.of(Get.context!).pop();
                          SmartDialog.dismiss();
                        }
                      },
                      text: "Add As Member",
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
            "Are you sure you want to remove \n ${item.displayName} from Company Member",
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
          SmartDialog.showLoading(msg: "Remove Account...");
          akunController.submitRevokeMember(item.email!, item.idCompany!).then(
                (value) async => {
                  SmartDialog.dismiss(),
                  if (value == true)
                    {
                      await akunController.updateRoleCompanyFirebase(
                          item.email!, "member", ""),
                      GFToast.showToast(
                          'Account Successfully Removed from Company Member List',
                          context,
                          trailing: const Icon(
                            Icons.check_circle_outline,
                            color: GFColors.SUCCESS,
                          ),
                          toastPosition: GFToastPosition.BOTTOM,
                          toastDuration: 3,
                          toastBorderRadius: 5.0),
                      //akunController.getListAkunPIC(idCompanyRef.value)
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
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.phone),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                        labelText: "Mobile Number / Whatsapp",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        border: OutlineInputBorder()),
                    initialValue:
                        item.phoneNumber != "" ? item.phoneNumber : "",
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
}
