// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:getwidget/getwidget.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/controller/CompanyController.dart';
import 'package:tmcapp/controller/EventController.dart';
import 'package:tmcapp/model/list_id.dart';

import 'image_widget.dart';

class FormRegistrasiMandiri extends StatefulWidget {
  final int pk_event;
  final double width;
  @override
  // ignore: overridden_fields
  final Key key;

  const FormRegistrasiMandiri({
    required this.key,
    required this.pk_event,
    required this.width,
  }) : super(key: key);
  @override
  _FormRegistrasiMandiriState createState() => _FormRegistrasiMandiriState();
}

class _FormRegistrasiMandiriState extends State<FormRegistrasiMandiri> {
  final CompanyController companyController = CompanyController.to;
  final AuthController auc = AuthController.to;
  final EventController eventController = EventController.to;
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final idCompany = "".obs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.transparent),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: widget.width * 0.88,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleImageNetwork(auc.user.value.photoURL, 54, UniqueKey()),
                  SizedBox(
                    height: 25,
                  ),
                  Text(
                    "Participant Registration Confirmation",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  GFListTile(
                    padding: EdgeInsets.only(bottom: 10, left: 8, right: 8),
                    margin: EdgeInsets.all(3),
                    avatar: Icon(CupertinoIcons.mail),
                    title: Text(
                      "Participant Email",
                      style: TextStyle(
                          fontSize: 12, color: CupertinoColors.secondaryLabel),
                    ),
                    subTitle: Text(auc.user.value.email),
                  ),
                  GFListTile(
                    padding: EdgeInsets.only(bottom: 10, left: 8, right: 8),
                    margin: EdgeInsets.all(3),
                    avatar: Icon(CupertinoIcons.person),
                    title: Text(
                     "Participant Name",
                      style: TextStyle(
                          fontSize: 12, color: CupertinoColors.secondaryLabel),
                    ),
                    subTitle: Text(auc.user.value.displayName),
                  ),
                  GFListTile(
                    padding: EdgeInsets.only(bottom: 10, left: 8, right: 8),
                    margin: EdgeInsets.all(3),
                    avatar: Icon(CupertinoIcons.building_2_fill),
                    title: Text(
                      "Company",
                      style: TextStyle(
                          fontSize: 12, color: CupertinoColors.secondaryLabel),
                    ),
                    subTitle: Text(companyController
                        .getCompanyName(auc.user.value.idCompany)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Before registering participants. \nMake sure your data is correct",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  GFButton(
                    onPressed: () async {
                      bool isOpenRegistrasi = false;
                      SmartDialog.showLoading(msg: "Check Event Status...");
                      await eventController
                          .getDetilEvent(widget.pk_event)
                          .then((value) => {
                                if (value.isRegistrationClose == false)
                                  {
                                    isOpenRegistrasi = true,
                                  }
                              });
                      SmartDialog.dismiss();
                      if (isOpenRegistrasi == false) {
                        GFToast.showToast(
                            'Sorry, Registration is Closed!', context,
                            trailing: const Icon(
                              Icons.error_outline,
                              color: GFColors.WARNING,
                            ),
                            toastPosition: GFToastPosition.BOTTOM,
                            toastBorderRadius: 5.0);
                        eventController.setKonfirmRegistrasiMandiri("close");
                        Navigator.of(Get.context!).pop();
                        return;
                      }
                      SmartDialog.showLoading(
                          msg: "Participant Registration...", backDismiss: false);
                      eventController
                          .submitRegistrasiMandiri(widget.pk_event)
                          .then((value) => {
                                SmartDialog.dismiss(),
                                if (value == true)
                                  {
                                    eventController.setKonfirmRegistrasiMandiri(
                                        "berhasil"),
                                    Navigator.of(Get.context!).pop(),
                                    GFToast.showToast(
                                        'Pendaftaran Berhasil!', context,
                                        trailing: const Icon(
                                          CupertinoIcons.check_mark_circled,
                                          color: GFColors.SUCCESS,
                                        ),
                                        toastPosition: GFToastPosition.BOTTOM,
                                        toastBorderRadius: 5.0),
                                  }
                                else
                                  {
                                    GFToast.showToast(
                                        'Participant Registration Failed!', context,
                                        trailing: const Icon(
                                          Icons.error_outline,
                                          color: GFColors.WARNING,
                                        ),
                                        toastPosition: GFToastPosition.BOTTOM,
                                        toastBorderRadius: 5.0),
                                    eventController
                                        .setKonfirmRegistrasiMandiri("gagal"),
                                  }
                              });
                    },
                    text: "Submit Registration",
                    color: CupertinoColors.activeOrange,
                    blockButton: true,
                    icon: const Icon(
                      CupertinoIcons.paperplane,
                      color: GFColors.WHITE,
                      size: 18,
                    ),
                  ),
                  GFButton(
                    onPressed: () {
                      Navigator.of(Get.context!).pop();
                    },
                    fullWidthButton: true,
                    color: GFColors.DARK,
                    icon: Icon(
                      CupertinoIcons.arrow_left,
                      color: GFColors.LIGHT,
                      size: 18,
                    ),
                    textColor: GFColors.LIGHT,
                    text: "Cancel",
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _customDropDown(BuildContext context, ListID? item) {
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
                  item.title,
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  item.subtitle,
                  style: TextStyle(fontSize: 12),
                ),
              ));
  }

  Widget _customPopupItem(BuildContext context, ListID item, bool isSelected) {
    print(isSelected);
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: CupertinoColors.separator, width: 1)),
          color: Colors.transparent,
        ),
        child: ListTile(
          minLeadingWidth: 2,
          horizontalTitleGap: 8,
          leading: Icon(CupertinoIcons.building_2_fill),
          contentPadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
          dense: true,
          visualDensity: VisualDensity(vertical: -3),
          title: Text(
            item.title,
            style: TextStyle(fontSize: 14),
          ),
          subtitle: Text(
            item.subtitle,
            style: TextStyle(fontSize: 12),
          ),
        ));
  }
}
