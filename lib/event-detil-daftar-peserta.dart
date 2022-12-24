import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';
import 'package:tmcapp/controller/AppController.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/controller/AkunController.dart';
import 'package:tmcapp/controller/EventController.dart';
import 'package:tmcapp/model/akun_firebase.dart';
import 'package:tmcapp/model/company.dart';
import 'package:tmcapp/model/event_tmc_detil.dart';
import 'package:tmcapp/model/registrant.dart';

class EventDetilDaftarPesertaScreen extends StatefulWidget {
  @override
  State<EventDetilDaftarPesertaScreen> createState() =>
      _EventDetilDaftarPesertaScreenState();
}

class _EventDetilDaftarPesertaScreenState
    extends State<EventDetilDaftarPesertaScreen> {
  final authController = AuthController.to;
  final AkunController akunController = AkunController.to;
  final EventController eventController = EventController.to;
  var ListPeserta = <Registrant>[].obs;
  var ListMember = <AkunFirebase>[].obs;
  var isLoading = true.obs;
  var searchTextFocus = false.obs;
  var isClosingEvent = false.obs;
  var emailPesertaPengganti = "".obs;
  final itemAcara = EventTmcDetil(pk: 0).obs;

  void _onRefresh() async {
    // monitor network fetch
    isLoading.value = true;
    //await CompanyController.to.getListCompany();
    await eventController.getListPeserta(itemAcara.value.pk!);
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    setState(() {
      ListPeserta(eventController.ListMyRegistrant);
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
    setState(() {
      itemAcara(Get.arguments['event']);
      isLoading.value = true;
    });

    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      //companyController.getListCompany();
      await eventController.getListPeserta(itemAcara.value.pk!);
      setState(() {
        ListPeserta(eventController.ListMyRegistrant);
        isLoading.value = false;
        _searchTextcontroller.text = "";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isLoading.value == false
                  ? Text(
                      "Participant (${ListPeserta.value.length})",
                      style: TextStyle(fontSize: 18),
                    )
                  : Container(),
              Text(
                "${itemAcara.value.title}",
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
          actions: [
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () async {
                    print(itemAcara.value.pk);
                    print("Export Excel");
                    await eventController
                        .downloadExcelRegistrant(itemAcara.value);
                  },
                  child: Icon(Icons.download_for_offline),
                )),
          ],
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
                        ListPeserta(eventController.ListMyRegistrant);
                      });
                      return;
                    }
                    ListPeserta.value = eventController.ListMyRegistrant.where(
                        (p0) =>
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
                            ListPeserta(eventController.ListMyRegistrant);
                          });
                        },
                        icon: Icon(Icons.clear),
                      ),
                      hintText: 'Search Participants/Companies'),
                ),
              ),
            ),
          ),
        ),
        Obx(() => Container(
              child: SliverList(
                delegate: isLoading.value == false
                    ? BuilderListCard(ListPeserta.value)
                    : BuilderListSkeletonCard(),
              ),
            )),
      ],
    );
  }

  SliverChildBuilderDelegate BuilderListCard(List<Registrant> _ListAkun) {
    List<Registrant> _listResult = _ListAkun;
    return SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return Container(
            child: GFListTile(
          onLongPress: isClosingEvent == false
              ? () {
                  print("HAPUS PESERTA");
                  // _listResult[index].attendance_time == ""
                  //     ? showModalHapusGantiPeserta(_listResult[index])
                  //     : null;
                }
              : null,
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            //print("TAP LIST");
            showDetilAkun(_listResult[index]);
          },
          title: Text(_listResult[index].displayName!,
              style: TextStyle(
                fontSize: 16,
              )),
          subTitleText: "${_listResult[index].companyName}",
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          margin: EdgeInsets.all(0),
          avatar: GFAvatar(
              radius: 20,
              backgroundImage:
                  Image.network(_listResult[index].photoUrl!).image),
          icon: _listResult[index].attendance_time == ""
              ? Icon(
                  CupertinoIcons.qrcode_viewfinder,
                  color: GFColors.LIGHT,
                )
              : Icon(
                  CupertinoIcons.qrcode_viewfinder,
                  color: CupertinoColors.activeGreen,
                ),
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

  void showDetilAkun(Registrant listResult) async {
    await Get.dialog(
      buildDetilAkun(listResult),
      barrierDismissible: true,
    );
  }

  Widget buildDetilAkun(Registrant item) {
    String attendTimeStatus = item.attendance_time != ""
        ? "${DateFormat(DateFormat.YEAR_ABBR_MONTH_WEEKDAY_DAY, "id_ID").format(DateTime.parse(item.attendance_time!))} ${item.attendance_time!.toString().substring(11, 16)}"
        : "Not Yet Attendance";
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
                    onTap: () {
                      AkunController.to.callWhatsappMe(item.phoneNumber);
                    },
                    expands: true,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.phone),
                        suffixIcon: IconButton(
                          onPressed: () {
                            AkunController.to.callWhatsappMe(item.phoneNumber);
                          },
                          icon: Icon(
                            Icons.whatsapp_outlined,
                            color: CupertinoColors.activeGreen,
                          ),
                        ),
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
                    initialValue: item.companyName!,
                    enabled: false,
                    readOnly: true,
                    color: Colors.red,
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  GFTextField(
                    maxLines: 3,
                    expands: true,
                    showCursor: false,
                    focusNode: FocusNode(),
                    decoration: const InputDecoration(
                        prefixIcon: Icon(CupertinoIcons.qrcode_viewfinder),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        labelText: "Time Attendance",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        border: OutlineInputBorder()),
                    initialValue: attendTimeStatus,
                    enabled: false,
                    readOnly: true,
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
                    color: GFColors.PRIMARY,
                  )
                ],
              ),
            ),
          ],
        ));
  }

  Widget buildHapusGantiPeserta(Registrant item) {
    String attendTimeStatus = item.attendance_time != ""
        ? "${DateFormat(DateFormat.YEAR_ABBR_MONTH_WEEKDAY_DAY, "id_ID").format(DateTime.parse(item.attendance_time!))} ${item.attendance_time!.toString().substring(11, 16)}"
        : "Participants Not Yet Attendance";
    return Container(
        decoration: BoxDecoration(color: Colors.transparent),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: Get.width * 0.88,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Participant Registration"),
                  SizedBox(
                    height: 20,
                  ),
                  GFListTile(
                    margin: EdgeInsets.all(0),
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    avatar: GFAvatar(
                      backgroundImage: Image.network(item.photoUrl!).image,
                      size: 30,
                    ),
                    titleText: item.displayName,
                    subTitleText: item.companyName,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  itemAcara.value.isFree == false ||
                          itemAcara.value.isFree == true
                      ? GFButton(
                          icon: Icon(
                            CupertinoIcons.trash,
                            color: GFColors.WHITE,
                            size: 16,
                          ),
                          text: "Delete Participant",
                          onPressed: () async {
                            Navigator.pop(Get.overlayContext!);
                            bool berhasil = false;
                            SmartDialog.showLoading(msg: "Delete...");
                            berhasil =
                                await eventController.submitDeleteRegistrasi(
                                    item.email!, itemAcara.value.pk!);
                            SmartDialog.dismiss();
                            if (berhasil == true) {
                              GFToast.showToast('Delete Success', context,
                                  trailing: const Icon(
                                    Icons.check_circle,
                                    color: GFColors.SUCCESS,
                                  ),
                                  toastDuration: 3,
                                  toastPosition: GFToastPosition.BOTTOM,
                                  toastBorderRadius: 5.0);
                              await eventController
                                  .getListPeserta(itemAcara.value.pk!);

                              // if failed,use refreshFailed()
                              setState(() {
                                ListPeserta(eventController.ListMyRegistrant);
                                isLoading.value = false;
                                _searchTextcontroller.text = "";
                              });
                            } else {
                              GFToast.showToast('Failded Delete', context,
                                  trailing: const Icon(
                                    Icons.error_outline,
                                    color: GFColors.DANGER,
                                  ),
                                  toastDuration: 3,
                                  toastPosition: GFToastPosition.BOTTOM,
                                  toastBorderRadius: 5.0);
                            }
                          },
                          blockButton: true,
                          color: GFColors.DANGER,
                        )
                      : Container(),
                  GFButton(
                    icon: Icon(
                      Icons.person_add_alt,
                      color: GFColors.WHITE,
                      size: 16,
                    ),
                    text: "Change Participant",
                    onPressed: () {
                      Navigator.pop(Get.overlayContext!);
                      showModalGantiPeserta(item);
                    },
                    blockButton: true,
                    color: CupertinoColors.activeGreen,
                  )
                ],
              ),
            ),
          ],
        ));
  }

  void showModalHapusGantiPeserta(Registrant listResult) async {
    await Get.dialog(
      buildHapusGantiPeserta(listResult),
      barrierDismissible: true,
    );
  }

  void showModalGantiPeserta(Registrant refItem) async {
    await AkunController.to.getListAkunMember();
    List<String> emailRegistrant =
        ListPeserta.value.map((item) => item.email!).toList();
    setState(() {
      ListMember.clear();
      emailPesertaPengganti("");
      for (var item in AkunController.to.ListAkun) {
        if (item.email != refItem.email &&
            emailRegistrant.contains(item.email) == false) {
          ListMember.value.add(item);
        }
      }
    });
    await Get.dialog(
      buildGantiPeserta(refItem),
      barrierDismissible: true,
    );
  }

  Widget buildGantiPeserta(Registrant refItem) {
    return Container(
        decoration: BoxDecoration(color: Colors.transparent),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: Get.width * 0.88,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Select Substitute Participant"),
                  SizedBox(
                    height: 20,
                  ),
                  DropdownSearch<AkunFirebase>(
                    itemAsString: (item) => item!.companyAsStringByName(),
                    onChanged: (value) => {
                      //print("TERPILIH: ${value!.pk}"),
                      setState(() {
                        emailPesertaPengganti(value?.email!.toString());
                      })
                    },
                    mode: Mode.DIALOG,
                    showSearchBox: true,
                    items: ListMember.value,
                    dropdownBuilder: _customDropDownUser,
                    popupItemBuilder: _customPopupItemUser,
                    dropdownSearchDecoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                        labelText: "Member",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GFButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: GFColors.WHITE,
                          size: 16,
                        ),
                        text: "Cancel",
                        onPressed: () {
                          Navigator.pop(Get.overlayContext!);
                          //showModalGantiPeserta(item);
                        },
                        color: CupertinoColors.darkBackgroundGray,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      GFButton(
                        icon: Icon(
                          Icons.save,
                          color: GFColors.WHITE,
                          size: 16,
                        ),
                        text: "Save",
                        onPressed: () async {
                          Navigator.pop(Get.overlayContext!);
                          //showModalGantiPeserta(item);
                          if (emailPesertaPengganti.value != "") {
                            print("Hapus ${refItem.email}");
                            bool berhasil = false;
                            bool berhasilTambah = false;
                            SmartDialog.showLoading(msg: "Change...");
                            berhasil =
                                await eventController.submitDeleteRegistrasi(
                                    refItem.email!, itemAcara.value.pk!);
                            if (berhasil == true) {
                              print("Tambah ${emailPesertaPengganti.value}");
                              var listEmail = [emailPesertaPengganti.value];
                              // berhasilTambah =
                              //     await eventController.submitRegistrasiByPIC(
                              //         itemAcara.value.pk!, listEmail);
                              print("Berhasil Ganti Peserta");
                              GFToast.showToast('Changed Success', context,
                                  trailing: const Icon(
                                    Icons.check_circle,
                                    color: GFColors.SUCCESS,
                                  ),
                                  toastDuration: 3,
                                  toastPosition: GFToastPosition.BOTTOM,
                                  toastBorderRadius: 5.0);
                              await eventController
                                  .getListPeserta(itemAcara.value.pk!);
                              // if failed,use refreshFailed()
                              setState(() {
                                ListPeserta(eventController.ListMyRegistrant);
                                isLoading.value = false;
                                _searchTextcontroller.text = "";
                              });
                            }
                            SmartDialog.dismiss();
                          }
                        },
                        color: CupertinoColors.activeGreen,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ));
  }

  Widget _customDropDownUser(BuildContext context, AkunFirebase? item) {
    return Container(
        margin: EdgeInsets.all(0),
        child: (item == null)
            ? const ListTile(
                contentPadding: EdgeInsets.all(0),
                title: Text("Search",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(235, 158, 158, 158))),
              )
            : ListTile(
                minLeadingWidth: 2,
                horizontalTitleGap: 8,
                leading: GFAvatar(
                  backgroundImage: Image.network(item.photoUrl!).image,
                  size: 25,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
                dense: true,
                visualDensity: VisualDensity(vertical: -3),
                title: Text(
                  item.displayName!,
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  item.companyName!,
                  style: TextStyle(fontSize: 12),
                ),
              ));
  }

  Widget _customPopupItemUser(
      BuildContext context, AkunFirebase item, bool isSelected) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: ListTile(
          minLeadingWidth: 2,
          horizontalTitleGap: 8,
          leading: GFAvatar(
            backgroundImage: Image.network(item.photoUrl!).image,
            size: 25,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
          dense: true,
          visualDensity: VisualDensity(vertical: -3),
          title: Text(
            item.displayName!,
            style: TextStyle(fontSize: 14),
          ),
          subtitle: Text(
            item.companyName!,
            style: TextStyle(fontSize: 12),
          ),
        ));
  }
}
