// ignore_for_file: prefer_const_constructors

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';
import 'package:tmcapp/client.dart';
import 'package:tmcapp/controller/AppController.dart';
import 'package:tmcapp/controller/BottomTabController.dart';
import 'package:flutter/material.dart';
import 'package:tmcapp/controller/NotifikasiController.dart';
import 'package:tmcapp/model/event_tmc.dart';
import 'package:tmcapp/model/event_tmc_detil.dart';
import 'package:tmcapp/preview-image.dart';
import 'package:tmcapp/preview-sertifikat.dart';
import 'package:tmcapp/widget/form_attedance.dart';
import 'package:tmcapp/widget/form_qrcode.dart';
import 'package:tmcapp/widget/form_registrasi_mandiri.dart';
import 'package:tmcapp/widget/qrcode_viewer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'controller/AuthController.dart';
import 'controller/EventController.dart';

class EventDetilScreen extends StatefulWidget {
  @override
  State<EventDetilScreen> createState() => _EventDetilScreenState();
}

class _EventDetilScreenState extends State<EventDetilScreen> {
  final bottomTabControl = BottomTabController.to;
  final eventController = EventController.to;
  final authController = AuthController.to;

  late ScrollController _scrollController;
  final Color _foregroundColor = Colors.white;
  final isLoading = true.obs;
  final onCheckMyEvent = true.obs;
  final base_url = ApiClient().base_url;
  final itemAcara = EventTmcDetil().obs;
  final isMyEvent = false.obs;
  final myAttandanceTime = "".obs;

  final isRegistrationClose = false.obs;
  final isListAttendees = false.obs;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void cekIsMyEventRegistred() async {
    setState(() {
      onCheckMyEvent(true);
    });
    bool cekMyEvent = await eventController.cekIsMyEvent(itemAcara.value.pk!);

    setState(() {
      isMyEvent(cekMyEvent);
    });

    if (cekMyEvent == true) {
      await eventController
          .cekMyAttadanceEvent(itemAcara.value.pk!)
          .then((value) => setState(() {
                myAttandanceTime.value = value;
              }));
    }
    setState(() {
      onCheckMyEvent(false);
    });
  }

  void reloadDataEvent() async {
    await eventController.getDetilEvent(itemAcara.value.pk!).then((value) => {
          if (value != null)
            {
              cekIsMyEventRegistred(),
              setState(() {
                itemAcara(value);
                isRegistrationClose.value =
                    itemAcara.value.isRegistrationClose!;
                isListAttendees.value = itemAcara.value.isListAttendees!;
              }),
            }
          else
            {
              Get.snackbar('Opps.', "An Error Occurred, Event Not Found",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: CupertinoColors.systemYellow,
                  colorText: Colors.black),
              Navigator.of(Get.context!).pop()
            }
        });
  }

  void _onRefresh() async {
    // monitor network fetch
    isLoading.value = true;
    //eventController.getListEvent();
    reloadDataEvent();
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
  void initState() {
    // TODO: implement initState
    //eventController.getListEvent();
    setState(() {
      itemAcara(Get.arguments['event']);
      isRegistrationClose.value = itemAcara.value.isRegistrationClose!;
      isListAttendees.value = itemAcara.value.isListAttendees!;
    });
    cekIsMyEventRegistred();
    if (authController.user.value.email != itemAcara.value.owned_by_email) {
      if (isMyEvent.value == true) {
        eventController.getStatusMyAttendanceEvent(itemAcara.value.pk!);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color appBarColor = AppController.to.appBarColor.value;
    return Scaffold(
        backgroundColor: CupertinoColors.extraLightBackgroundGray,
        appBar: AppBar(
          titleSpacing: 0,
          title: Text(
            "${itemAcara.value.title!}",
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: appBarColor,
          elevation: 1,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: false,
            header: const MaterialClassicHeader(
              color: CupertinoColors.activeOrange,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: buildBody(),
          ),
        ));
  }

  Widget buildBody() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: SingleChildScrollView(
          child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GFCard(
                    margin: EdgeInsets.all(0),
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                    content: buildInformasiEvent(context),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  //MEMBER ADA COMPANY DAN STATUS CEK EVENT SELESAI
                  onCheckMyEvent.value == false &&
                          authController.user.value.role == "member"
                      ? GFCard(
                          margin: EdgeInsets.all(0),
                          padding: EdgeInsets.all(0),
                          content: buildActionPeserta(),
                        )
                      : onCheckMyEvent.value == true &&
                              authController.user.value.role == "member"
                          ? buildLoadingPanelCard()
                          : Container(),

                  onCheckMyEvent.value == false &&
                          authController.user.value.role == "PIC"
                      ? GFCard(
                          margin: EdgeInsets.all(0),
                          padding: EdgeInsets.all(0),
                          content: buildActionPIC(),
                        )
                      : onCheckMyEvent.value == true &&
                              authController.user.value.role == "PIC"
                          ? buildLoadingPanelCard()
                          : Container(),

                  onCheckMyEvent.value == false &&
                          authController.user.value.role == "admin"
                      ? GFCard(
                          margin: EdgeInsets.all(0),
                          padding: EdgeInsets.all(0),
                          content: buildActionAdmin(),
                        )
                      : onCheckMyEvent.value == true &&
                              authController.user.value.role == "admin"
                          ? buildLoadingPanelCard()
                          : Container(),
                ],
              ))),
    );
  }

  GFCard buildLoadingPanelCard() {
    return GFCard(
        margin: EdgeInsets.all(0),
        padding: EdgeInsets.all(0),
        content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: SkeletonParagraph(
              style: SkeletonParagraphStyle(
                  lines: 3,
                  spacing: 10,
                  lineStyle: SkeletonLineStyle(
                    randomLength: false,
                    height: 20,
                    borderRadius: BorderRadius.circular(5),
                  )),
            )));
  }

  Container buildActionPeserta() {
    return Container(
      width: Get.width,
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //FREE EVENT (PESERTA DAFTAR MANDIRI)
          itemAcara.value.isFree == true
              ? isMyEvent.value == false &&
                      itemAcara.value.isRegistrationClose == false
                  ? GFButton(
                      fullWidthButton: true,
                      color: CupertinoColors.activeOrange,
                      onPressed: () async {
                        if (AuthController.to.user.value.role == "member" &&
                            AuthController.to.user.value.idCompany == "null") {
                          NotifikasiController.to.notifikasiAktivasiMember();
                          return;
                        }
                        eventController.setKonfirmRegistrasiMandiri("");
                        await Get.dialog(
                            FormRegistrasiMandiri(
                              pk_event: itemAcara.value.pk!,
                              key: UniqueKey(),
                              width: Get.width,
                            ),
                            barrierDismissible: false);
                        if (eventController.konfirmRegistrasiMandiri ==
                            "berhasil") {
                          reloadDataEvent();
                        }
                      },
                      text: "Click To Register",
                      icon: Icon(
                        CupertinoIcons.plus_app,
                        color: Colors.white,
                        size: 18,
                      ),
                    )
                  : isMyEvent.value == false
                      ? GFButton(
                          fullWidthButton: true,
                          disabledTextColor: Colors.white,
                          color: CupertinoColors.activeOrange,
                          onPressed: null,
                          text: "Registration Closed",
                          icon: Icon(
                            CupertinoIcons.nosign,
                            color: Colors.white,
                            size: 18,
                          ),
                        )
                      : Container()
              : Container(),

          isMyEvent.value == false && itemAcara.value.isFree == false
              ? Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Participant Registration Can Only Be Done by Company PIC",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: CupertinoColors.separator),
                  ))
              : Container(),

          isMyEvent.value == true
              ? Column(
                  children: [
                    GFButton(
                      fullWidthButton: true,
                      type: GFButtonType.outline,
                      color: GFColors.FOCUS,
                      onPressed: myAttandanceTime.value != ""
                          ? () {
                              var attendancerecord = {
                                'attend_time': myAttandanceTime.value,
                                'date_event': itemAcara.value.date!.toString(),
                                "event": itemAcara.value.title
                              };
                              print(attendancerecord);
                              //return;
                              Get.dialog(
                                  FormAttedanceResult(
                                      key: UniqueKey(),
                                      result: attendancerecord,
                                      width: Get.width),
                                  barrierDismissible: true);
                            }
                          : itemAcara.value.isListAttendees == true &&
                                  myAttandanceTime.value == ""
                              ? () async {
                                  eventController.setQrCodeScanResult("");
                                  await Get.dialog(QRViewScreen(),
                                      barrierDismissible: true);
                                  print("QRCODE VIEW DITUTUP");
                                  if (eventController.qrCodeScanResult.value !=
                                      "") {
                                    Map<String, dynamic>? attendance;
                                    SmartDialog.showLoading(
                                        msg: "Attendance...");
                                    EventTmcDetil cekAcara =
                                        await eventController
                                            .getDetilEvent(itemAcara.value.pk!);
                                    if (cekAcara.isListAttendees! == true) {
                                      await eventController
                                          .submitAttendParticipant(
                                              eventController
                                                  .qrCodeScanResult.value)
                                          .then((value) => attendance = value);
                                      await Future.delayed(
                                          const Duration(milliseconds: 600));
                                      SmartDialog.dismiss();
                                      print(attendance);
                                      if (attendance != null) {
                                        await Get.dialog(
                                            FormAttedanceResult(
                                                key: UniqueKey(),
                                                result: attendance,
                                                width: Get.width),
                                            barrierDismissible: true);
                                        reloadDataEvent();
                                      } else {
                                        GFToast.showToast(
                                            'An Invalid QrCode Error Occurred!',
                                            context,
                                            trailing: const Icon(
                                              Icons.dangerous,
                                              color: GFColors.DANGER,
                                            ),
                                            toastDuration: 3,
                                            toastPosition:
                                                GFToastPosition.BOTTOM,
                                            toastBorderRadius: 5.0);
                                      }
                                    } else {
                                      SmartDialog.dismiss();
                                      reloadDataEvent();
                                      GFToast.showToast(
                                          'Sorry, Attendance Has Been Closed!',
                                          context,
                                          trailing: const Icon(
                                            Icons.dangerous,
                                            color: GFColors.DANGER,
                                          ),
                                          toastDuration: 3,
                                          toastPosition: GFToastPosition.BOTTOM,
                                          toastBorderRadius: 5.0);
                                    }
                                  }
                                }
                              : null,
                      text: myAttandanceTime.value != ""
                          ? "You've Done Attendance"
                          : itemAcara.value.isListAttendees == false
                              ? "Attendance Closed"
                              : "Take Attendance",
                      icon: Icon(
                        itemAcara.value.isListAttendees == false
                            ? CupertinoIcons.qrcode_viewfinder
                            : CupertinoIcons.qrcode_viewfinder,
                        color: GFColors.FOCUS,
                        size: 18,
                      ),
                    ),
                    GFButton(
                      fullWidthButton: true,
                      type: GFButtonType.outline,
                      color: GFColors.DARK,
                      onPressed: () {
                        print("BUKA SCREEN Resouce");
                        // /event-detil-resources
                        Get.toNamed('/event-detil-resources',
                            arguments: {'event': itemAcara.value});
                      },
                      text: "Resources",
                      icon: Icon(
                        CupertinoIcons.paperclip,
                        color: GFColors.DARK,
                        size: 18,
                      ),
                    ),
                    GFButton(
                      type: GFButtonType.outline,
                      color: GFColors.FOCUS,
                      fullWidthButton: true,
                      onPressed: () {
                        print("SHROCUT GALLERY");
                        Get.toNamed('/event-detil-gallery',
                            arguments: {'event': itemAcara.value});
                      },
                      text: "Gallery Photo",
                      icon: Icon(
                        CupertinoIcons.photo_on_rectangle,
                        color: GFColors.FOCUS,
                        size: 18,
                      ),
                    ),
                    GFButton(
                      type: GFButtonType.outline,
                      color: GFColors.FOCUS,
                      fullWidthButton: true,
                      onPressed: () {
                        print("LIST FORM SURVEY");
                        Get.toNamed('/event-detil-survey',
                            arguments: {'event': itemAcara.value});
                      },
                      text: "Survey",
                      icon: Icon(
                        CupertinoIcons.checkmark_rectangle,
                        color: GFColors.FOCUS,
                        size: 18,
                      ),
                    ),
                    GFButton(
                      type: GFButtonType.outline,
                      color: GFColors.FOCUS,
                      fullWidthButton: true,
                      onPressed: () {
                        print("SHROCUT FORM SURVEY");
                        downloadSertifikatPeserta();
                      },
                      text: "Certificate",
                      icon: Icon(
                        CupertinoIcons.checkmark_seal,
                        color: GFColors.FOCUS,
                        size: 18,
                      ),
                    ),
                    // GFButton(
                    //   type: GFButtonType.outline,
                    //   color: GFColors.FOCUS,
                    //   fullWidthButton: true,
                    //   onPressed: () {
                    //     print("SHROCUT CHAT ADMIN");
                    //   },
                    //   text: "Chat Group",
                    //   icon: Icon(
                    //     CupertinoIcons.bubble_left,
                    //     color: GFColors.FOCUS,
                    //     size: 18,
                    //   ),
                    // ),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }

  Container buildActionPIC() {
    return Container(
      width: Get.width,
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //FREE EVENT (PESERTA DAFTAR MANDIRI)
          itemAcara.value.isFree == false
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    itemAcara.value.isRegistrationClose == true
                        ? Container(
                            margin: EdgeInsets.all(10),
                            child: Center(
                              child: Text(
                                  "Participant Registration Session Closed!"),
                            ),
                          )
                        : Container(),
                    GFButton(
                      fullWidthButton: true,
                      color: itemAcara.value.isRegistrationClose == false
                          ? CupertinoColors.activeBlue
                          : GFColors.DARK,
                      onPressed: () async {
                        print("ID EVENT ${itemAcara.value.pk}");
                        Get.toNamed('/event-detil-registrasi-pic',
                            arguments: {'id_event': itemAcara.value.pk});
                      },
                      text: itemAcara.value.isRegistrationClose == false
                          ? "Participant Registration"
                          : "Registered Participants",
                      icon: Icon(
                        CupertinoIcons.person_3,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                )
              : Container(),

          itemAcara.value.isFree == true
              ? Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Participant Registration Can Only Be Do by Company Members",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: CupertinoColors.separator),
                  ))
              : Container(),
        ],
      ),
    );
  }

  Container buildActionAdmin() {
    return Container(
      width: Get.width,
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GFListTile(
            margin: EdgeInsets.all(0),
            padding: EdgeInsets.only(bottom: 10),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        "Registration Status (${itemAcara.value.isRegistrationClose == true ? 'Close' : 'Open'})"),
                    itemAcara.value.isRegistrationClose == false
                        ? Icon(Icons.lock_open_outlined,
                            size: 20, color: Colors.green)
                        : Icon(Icons.lock_outline,
                            size: 20, color: Colors.grey),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        "Attendance Status (${itemAcara.value.isListAttendees == false ? 'Close' : 'Open'})"),
                    itemAcara.value.isListAttendees == true
                        ? Icon(Icons.lock_open_outlined,
                            size: 20, color: Colors.green)
                        : Icon(Icons.lock_outline, size: 20, color: Colors.grey)
                  ],
                )
              ],
            ),
          ),
          Divider(
            color: CupertinoColors.lightBackgroundGray,
            height: 15,
          ),
          SizedBox(
            height: 5,
          ),
          GFButton(
            fullWidthButton: true,
            type: GFButtonType.outline,
            color: GFColors.DARK,
            onPressed: () {
              showMaterialModalBottomSheet(
                expand: false,
                context: this.context,
                backgroundColor: Colors.transparent,
                builder: (context) => SingleChildScrollView(
                    child: Container(
                  child: buildFormSetting(),
                )),
              );
            },
            text: "Settings",
            icon: Icon(
              CupertinoIcons.gear,
              color: GFColors.DARK,
              size: 18,
            ),
          ),
          itemAcara.value.isListAttendees == true
              ? GFButton(
                  fullWidthButton: true,
                  type: GFButtonType.outline,
                  color: GFColors.DARK,
                  onPressed: () async {
                    SmartDialog.showLoading(msg: "Loading QRCode...");
                    String qrcodeImage = await eventController
                        .getQRCodeAbsensi(itemAcara.value.pk!);
                    await Future.delayed(const Duration(milliseconds: 600));
                    SmartDialog.dismiss();
                    await Get.dialog(
                        FormQrCode(
                          qrcode_image_source:
                              ApiClient().base_url + qrcodeImage,
                          key: UniqueKey(),
                          width: Get.width,
                        ),
                        barrierDismissible: true);
                  },
                  text: "QRCode",
                  icon: Icon(
                    CupertinoIcons.qrcode,
                    color: GFColors.DARK,
                    size: 18,
                  ),
                )
              : GFButton(
                  fullWidthButton: true,
                  type: GFButtonType.outline,
                  color: GFColors.DARK,
                  onPressed: null,
                  text: "Attendance Closed",
                  icon: Icon(
                    CupertinoIcons.qrcode,
                    color: GFColors.DARK,
                    size: 18,
                  ),
                ),
          GFButton(
            fullWidthButton: true,
            type: GFButtonType.outline,
            color: GFColors.DARK,
            onPressed: () {
              print("BUKA SCREEN PESERTA");
              Get.toNamed('/event-detil-daftar-peserta',
                  arguments: {'event': itemAcara.value});
            },
            text: "Participant",
            icon: Icon(
              CupertinoIcons.person_3,
              color: GFColors.DARK,
              size: 18,
            ),
          ),
          GFButton(
            fullWidthButton: true,
            type: GFButtonType.outline,
            color: GFColors.DARK,
            onPressed: () {
              print("BUKA SCREEN Resouce");
              // /event-detil-resources
              Get.toNamed('/event-detil-resources',
                  arguments: {'event': itemAcara.value});
            },
            text: "Resources",
            icon: Icon(
              CupertinoIcons.paperclip,
              color: GFColors.DARK,
              size: 18,
            ),
          ),
          GFButton(
            fullWidthButton: true,
            type: GFButtonType.outline,
            color: GFColors.DARK,
            onPressed: () {
              Get.toNamed('/event-detil-gallery',
                  arguments: {'event': itemAcara.value});
            },
            text: "Gallery Photo",
            icon: Icon(
              CupertinoIcons.photo_on_rectangle,
              color: GFColors.DARK,
              size: 18,
            ),
          ),
          GFButton(
            fullWidthButton: true,
            type: GFButtonType.outline,
            color: GFColors.DARK,
            onPressed: () {
              print("BUKA SCREEN SURVEY");
              Get.toNamed('/event-detil-survey',
                  arguments: {'event': itemAcara.value});
            },
            text: "Survey",
            icon: Icon(
              CupertinoIcons.checkmark_rectangle,
              color: GFColors.DARK,
              size: 18,
            ),
          ),
          // GFButton(
          //   fullWidthButton: true,
          //   type: GFButtonType.outline,
          //   color: GFColors.DARK,
          //   onPressed: () {
          //     print("SHROCUT CHAT ADMIN");
          //   },
          //   text: "Chat Group",
          //   icon: Icon(
          //     CupertinoIcons.bubble_left,
          //     color: GFColors.DARK,
          //     size: 18,
          //   ),
          // ),
        ],
      ),
    );
  }

  Container buildInformasiEvent(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            itemAcara.value.title!,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(
            height: 8,
          ),
          GFListTile(
            margin: EdgeInsets.all(0),
            padding: EdgeInsets.all(0),
            avatar: Icon(
              CupertinoIcons.calendar_today,
              size: 24,
            ),
            title: Text(itemAcara.value.venue!),
            subTitle: Text(
                "${DateFormat(DateFormat.YEAR_MONTH_WEEKDAY_DAY, "id_ID").format(DateTime.parse(itemAcara.value.date!.toIso8601String()))} ${itemAcara.value.date!.toIso8601String().toString().substring(11, 16)}"),
          ),
          const SizedBox(
            height: 15,
          ),
          Stack(
            children: <Widget>[
              GFImageOverlay(
                height: 200,
                boxFit: BoxFit.cover,
                image: Image.network(
                  ApiClient().base_url + itemAcara.value.mainImageUrl!,
                ).image,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0), BlendMode.darken),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          //Text(item.content),
          const Text(
            "Description ",
            style:
                TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 13),
          ),
          const SizedBox(
            height: 5,
          ),
          SelectableLinkify(
            textScaleFactor: 1.0,
            linkStyle: const TextStyle(decoration: TextDecoration.none),
            style: const TextStyle(color: CupertinoColors.label),
            onOpen: (link) => {_launchInBrowser(Uri.parse(link.url))},
            text: itemAcara.value.description!,
            options: const LinkifyOptions(humanize: false),
          ),
          const SizedBox(
            height: 15,
          ),
          itemAcara.value.isFree == false
              ? GFListTile(
                  color: GFColors.FOCUS,
                  margin: EdgeInsets.all(0),
                  padding: EdgeInsets.all(10),
                  avatar: Icon(
                    CupertinoIcons.money_dollar,
                    color: GFColors.LIGHT,
                    size: 24,
                  ),
                  title: Text(
                    "Price",
                    style: TextStyle(color: GFColors.LIGHT, fontSize: 14),
                  ),
                  subTitle: Text(
                    "${CurrencyTextInputFormatter(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(itemAcara.value.price.toString())}/Participant",
                    style: TextStyle(fontSize: 16, color: GFColors.LIGHT),
                  ))
              : GFListTile(
                  color: CupertinoColors.activeGreen,
                  margin: EdgeInsets.all(0),
                  padding: EdgeInsets.all(10),
                  avatar: Icon(
                    CupertinoIcons.money_dollar,
                    color: GFColors.WHITE,
                    size: 24,
                  ),
                  title: Text(
                    "Price",
                    style: TextStyle(color: GFColors.WHITE, fontSize: 14),
                  ),
                  subTitle: Text(
                    "Free",
                    style: TextStyle(fontSize: 16, color: GFColors.WHITE),
                  )),
        ],
      ),
    );
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      print('Could not launch $url');
    }
  }

  Widget buildFormSetting() {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    return AnimatedPadding(
        duration: kThemeAnimationDuration,
        padding: mediaQueryData.viewInsets,
        child: Obx(() => ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15)),
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: const BoxDecoration(color: CupertinoColors.white),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Settings",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    Divider(
                      color: CupertinoColors.lightBackgroundGray,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Open Registration"),
                        GFToggle(
                          onChanged: (val) {
                            val == true
                                ? setState(() {
                                    isRegistrationClose.value = false;
                                  })
                                : setState(() {
                                    isRegistrationClose.value = true;
                                  });
                          },
                          enabledTrackColor: CupertinoColors.activeGreen,
                          value: isRegistrationClose.value ? false : true,
                          type: GFToggleType.ios,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Open Attendance"),
                        GFToggle(
                          onChanged: (val) {
                            val == false
                                ? setState(() {
                                    isListAttendees.value = false;
                                  })
                                : setState(() {
                                    isListAttendees.value = true;
                                  });
                          },
                          value: isListAttendees.value ? true : false,
                          enabledTrackColor: CupertinoColors.activeGreen,
                          type: GFToggleType.ios,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GFButton(
                      disabledColor: CupertinoColors.systemGrey3,
                      disabledTextColor: Colors.white,
                      fullWidthButton: true,
                      color: CupertinoColors.activeGreen,
                      onPressed: () {
                        savePengaturanEvent();
                      },
                      text: "Save",
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
            )));
  }

  //ACTION FOR ADMIN
  void savePengaturanEvent() {
    var eventUpload = {
      "title": itemAcara.value.title,
      "venue": itemAcara.value.venue,
      "date": itemAcara.value.date!.toIso8601String(),
      "main_image": itemAcara.value.mainImage,
      "description": itemAcara.value.description,
      "is_free": itemAcara.value.isFree,
      "is_registration_close": isRegistrationClose.value,
      "is_list_attendees": isListAttendees.value,
      "price": itemAcara.value.price
    };
    print(eventUpload);
    SmartDialog.showLoading(msg: "Update...");
    eventController
        .updateEvent(eventUpload, itemAcara.value.pk!)
        .then((value) => {
              SmartDialog.dismiss(),
              if (value == true)
                {
                  GFToast.showToast('Update Success!', context,
                      trailing: const Icon(
                        Icons.check_circle,
                        color: GFColors.SUCCESS,
                      ),
                      toastDuration: 3,
                      toastPosition: GFToastPosition.TOP,
                      toastBorderRadius: 5.0),
                  Navigator.pop(context),
                  reloadDataEvent()
                },
              if (value == false)
                {
                  GFToast.showToast('Opps Something Wrong!', context,
                      trailing: const Icon(
                        Icons.dangerous,
                        color: GFColors.DANGER,
                      ),
                      toastDuration: 3,
                      toastPosition: GFToastPosition.BOTTOM,
                      toastBorderRadius: 5.0)
                },
            });
  }

  void downloadSertifikatPeserta() async {
    SmartDialog.showLoading(msg: "Checking...");
    await eventController
        .downloadSertifikatPeserta(itemAcara.value.pk!)
        .then((value) {
      SmartDialog.dismiss();
      if (value == true) {
        //Get.defaultDialog(title: )
        showMaterialModalBottomSheet<String>(
          expand: false,
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => PreviewSertifikatScreen(
              eventController.imageSertifikat[0], itemAcara.value.pk!),
        );
      } else {
        GFToast.showToast('Certificate Not Available!', context,
            trailing: const Icon(
              Icons.error_outline,
              color: GFColors.WARNING,
            ),
            toastDuration: 3,
            toastPosition: GFToastPosition.BOTTOM,
            toastBorderRadius: 5.0);
      }
    });
  }
}
