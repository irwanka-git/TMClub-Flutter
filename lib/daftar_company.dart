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
import 'package:tmcapp/controller/CompanyController.dart';
import 'package:tmcapp/model/company.dart';

class KelolaCompanyScreen extends StatefulWidget {
  @override
  State<KelolaCompanyScreen> createState() => _KelolaCompanyScreenState();
}

class _KelolaCompanyScreenState extends State<KelolaCompanyScreen> {
  final authController = AuthController.to;
  final CompanyController companyController = CompanyController.to;
  var ListCompany = <Company>[].obs;
  var isLoading = true.obs;
  var searchTextFocus = false.obs;

  void _onRefresh() async {
    // monitor network fetch
    isLoading.value = true;
    await companyController.getListCompany();
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    setState(() {
      ListCompany(companyController.ListCompany);
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
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      //companyController.getListCompany();
      await companyController.getListCompany();
      setState(() {
        ListCompany(companyController.ListCompany);
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
          title: Obx(() => ListCompany.value.length > 0
              ? Text("Company List (${ListCompany.value.length})")
              : Text("Company List")),
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
                        ListCompany(companyController.ListCompany);
                      });
                      return;
                    }
                    ListCompany.value = companyController.ListCompany.where(
                        (p0) => p0.displayName!
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
                            ListCompany(companyController.ListCompany);
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
                    ? BuilderListCard(ListCompany)
                    : BuilderListSkeletonCard(),
              ),
            )),
      ],
    );
  }

  SliverChildBuilderDelegate BuilderListCard(List<Company> _listCompany) {
    List<Company> _listResult = _listCompany;
    return SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return Container(
            child: GFListTile(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          title: Text(_listResult[index].displayName!,
              style: TextStyle(
                fontSize: 16,
              )),
          subTitleText: _listResult[index].city != ""
              ? _listResult[index].city
              : _listResult[index].address,
          padding: EdgeInsets.only(top: 2, left: 16, right: 5, bottom: 2),
          margin: authController.user.value.role == "admin"
              ? EdgeInsets.symmetric(vertical: 8)
              : EdgeInsets.symmetric(vertical: 4),
          avatar: Icon(
            CupertinoIcons.building_2_fill,
            size: 25,
            color: CupertinoColors.secondaryLabel,
          ),
          icon: authController.user.value.role == "superadmin"
              ? Container(
                  padding: EdgeInsets.all(0),
                  child: PopupMenuButton(
                    iconSize: 20,
                    onSelected: (_valueAction) async {
                      //print("PK : ${_listResult[index].pk}");
                      Company? cek = await companyController
                          .getCompanybyPK(int.parse(_listResult[index].pk!));
                      if (cek != null) {
                        if (_valueAction == "/edit") {
                          await Get.dialog(
                            buildFormCompany("update", cek),
                            barrierDismissible: false,
                          );
                        }
                        if (_valueAction == "/delete") {
                          Get.defaultDialog(
                              contentPadding: const EdgeInsets.all(20),
                              title: "Confirmation",
                              titlePadding:
                                  const EdgeInsets.only(top: 10, bottom: 0),
                              middleText:
                                  "Are you sure you want to delete this company data?",
                              backgroundColor: CupertinoColors.white,
                              titleStyle: const TextStyle(
                                  color: Colors.black, fontSize: 16),
                              middleTextStyle: const TextStyle(
                                  color: CupertinoColors.darkBackgroundGray,
                                  fontSize: 14),
                              confirm: GFButton(
                                onPressed: () {
                                  companyController.deleteCompany(cek.pk!).then(
                                        (value) => {
                                          if (value == true)
                                            {
                                              GFToast.showToast(
                                                  'Data Deleted Successfully',
                                                  context,
                                                  trailing: const Icon(
                                                    Icons.check_circle_outline,
                                                    color: GFColors.SUCCESS,
                                                  ),
                                                  toastDuration: 3,
                                                  toastBorderRadius: 5.0),
                                              companyController.getListCompany()
                                            }
                                          else
                                            {
                                              GFToast.showToast(
                                                  'Failed Delete', context,
                                                  trailing: const Icon(
                                                    Icons.check_circle_outline,
                                                    color: GFColors.DANGER,
                                                  ),
                                                  toastDuration: 3,
                                                  toastBorderRadius: 5.0),
                                            }
                                        },
                                      );

                                  Navigator.pop(Get.overlayContext!);
                                },
                                text: "Yes, Delete",
                                color: GFColors.DANGER,
                              ),
                              cancel: GFButton(
                                onPressed: () {
                                  Navigator.pop(Get.overlayContext!);
                                },
                                text: "Cancel",
                                color: GFColors.DARK,
                              ),
                              radius: 0);
                        }
                      } else {
                        GFToast.showToast(
                            'Opps.. Data Not Found',
                            context,
                            trailing: const Icon(
                              Icons.dangerous,
                              color: GFColors.WHITE,
                            ),
                            backgroundColor: GFColors.WARNING,
                            toastDuration: 3,
                            toastPosition: GFToastPosition.BOTTOM,
                            toastBorderRadius: 5.0);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return const [
                        PopupMenuItem(
                          child: GFListTile(
                            avatar: Icon(
                              Icons.edit_rounded,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.zero,
                            title: Text("Edit"),
                          ),
                          value: '/edit',
                        ),
                        PopupMenuItem(
                          child: GFListTile(
                            avatar: Icon(
                              CupertinoIcons.trash,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.zero,
                            title: Text("Delete"),
                          ),
                          value: '/delete',
                        ),
                      ];
                    },
                  ),
                )
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
              visible:
                  authController.user.value.role == "superadmin" ? true : false,
              child: FloatingActionButton(
                heroTag: "float_blog",
                onPressed: () async {
                  await Get.dialog(
                    buildFormCompany("create", Company()),
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

  Widget buildFormCompany(String action, Company item) {
    final displayNameController = TextEditingController();
    final addressNameController = TextEditingController();
    final cityNameController = TextEditingController();
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    if (action == "update") {
      displayNameController.text = item.displayName!;
      addressNameController.text = item.address!;
      cityNameController.text = item.city!;
    }
    final formKey = GlobalKey<FormState>();
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
                  children: [
                    Text(
                      action == "create"
                          ? "Please Complete Company Data"
                          : "Please Complete Company Data",
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
                        controller: displayNameController,
                        style: const TextStyle(fontSize: 13, height: 2),
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 15),
                            labelText: "Company name",
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
                          return null;
                        }),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                        controller: cityNameController,
                        style: const TextStyle(fontSize: 13, height: 2),
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 15),
                            labelText: "City",
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
                          return null;
                        }),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                        controller: addressNameController,
                        style: const TextStyle(fontSize: 13, height: 2),
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 15),
                            labelText: "Address",
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
                          return null;
                        }),
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
                              'Sorry, Company Data Information Not Complete!',
                              context,
                              trailing: const Icon(
                                Icons.error_outline,
                                color: GFColors.WARNING,
                              ),
                              toastPosition: GFToastPosition.TOP,
                              toastBorderRadius: 5.0);
                          return;
                        }
                        if (action == "create") {
                          var data = {
                            "display_name": displayNameController.text,
                            "address": addressNameController.text,
                            "city": cityNameController.text,
                            "main_image": 1,
                          };
                          SmartDialog.showLoading(
                              msg: "Save Company Data....");
                          await companyController
                              .postingCreate(data)
                              .then((value) => {
                                    SmartDialog.dismiss(),
                                    if (value == true)
                                      {
                                        Navigator.pop(context),
                                        GFToast.showToast(
                                            'Company Data Saved Successfully',
                                            context,
                                            trailing: const Icon(
                                              Icons.check_circle_outline,
                                              color: GFColors.SUCCESS,
                                            ),
                                            toastDuration: 3,
                                            toastPosition:
                                                GFToastPosition.BOTTOM,
                                            toastBorderRadius: 5.0),
                                        companyController.getListCompany()
                                      }
                                    else
                                      {
                                        GFToast.showToast(
                                            'Opps.. An error occurred. Data failed to save',
                                            context,
                                            trailing: const Icon(
                                              Icons.dangerous,
                                              color: GFColors.WHITE,
                                            ),
                                            backgroundColor: GFColors.DANGER,
                                            toastDuration: 3,
                                            toastPosition:
                                                GFToastPosition.BOTTOM,
                                            toastBorderRadius: 5.0),
                                      }
                                  });
                        }
                        if (action == "update") {
                          var data = {
                            "display_name": displayNameController.text,
                            "address": addressNameController.text,
                            "city": cityNameController.text,
                            "main_image": 1,
                          };
                          SmartDialog.showLoading(
                              msg: "Save Company Data....");
                          await companyController
                              .updateCompany(data, item.pk.toString())
                              .then((value) => {
                                    SmartDialog.dismiss(),
                                    if (value == true)
                                      {
                                        Navigator.pop(context),
                                        GFToast.showToast(
                                            'Company Data Saved Successfully',
                                            context,
                                            trailing: const Icon(
                                              Icons.check_circle_outline,
                                              color: GFColors.SUCCESS,
                                            ),
                                            toastDuration: 3,
                                            toastPosition:
                                                GFToastPosition.BOTTOM,
                                            toastBorderRadius: 5.0),
                                        companyController.getListCompany()
                                      }
                                    else
                                      {
                                        GFToast.showToast(
                                            'Opps.. An error occurred. Data failed to save',
                                            context,
                                            trailing: const Icon(
                                              Icons.dangerous,
                                              color: GFColors.WHITE,
                                            ),
                                            backgroundColor: GFColors.DANGER,
                                            toastDuration: 3,
                                            toastPosition:
                                                GFToastPosition.BOTTOM,
                                            toastBorderRadius: 5.0),
                                      }
                                  });
                        }
                      },
                      text: "Simpan",
                      icon: Icon(
                        Icons.save_outlined,
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

  void saveCompany() {}
}
