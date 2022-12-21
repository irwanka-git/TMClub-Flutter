// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:getwidget/getwidget.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/controller/CompanyController.dart';
import 'package:tmcapp/model/company.dart';
import 'package:tmcapp/model/list_id.dart';

import 'image_widget.dart';

class FormAkunField extends StatefulWidget {
  final double height;
  final double width;
  final User userTemp;
  @override
  // ignore: overridden_fields
  final Key key;

  const FormAkunField({
    required this.key,
    required this.userTemp,
    required this.height,
    required this.width,
  }) : super(key: key);
  @override
  _FormAkunFieldState createState() => _FormAkunFieldState();
}

class _FormAkunFieldState extends State<FormAkunField> {
  final CompanyController companyController = CompanyController.to;
  final AuthController auc = AuthController.to;
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final idCompany = "".obs;

  @override
  void initState() {
    // TODO: implement initState
    //companyController.getListCompany();
    nameController.text = widget.userTemp.displayName!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String _prefixPhone = "+62";
    phoneController.text = _prefixPhone;
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
                children: [
                  CircleImageNetwork(
                      widget.userTemp.photoURL!, 54, UniqueKey()),
                  SizedBox(
                    height: 25,
                  ),
                  Text(
                    "Please register an account",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  TextFormField(
                      readOnly: true,
                      enabled: false,
                      initialValue: widget.userTemp.email,
                      style: const TextStyle(fontSize: 13, height: 2),
                      decoration: const InputDecoration(
                          fillColor: GFColors.DARK,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                          labelText: "Email",
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
                  TextFormField(
                      controller: nameController,
                      style: const TextStyle(fontSize: 13, height: 2),
                      decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                          labelText: "Full name",
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
                  TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        MaskTextInputFormatter(
                            mask: '${_prefixPhone}###########',
                            filter: {"#": RegExp(r'[0-9]')},
                            type: MaskAutoCompletionType.lazy)
                      ],
                      controller: phoneController,
                      style: const TextStyle(fontSize: 13, height: 2),
                      decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                          labelText: "Mobile Number - Whatsapp",
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 14),
                          labelStyle:
                              TextStyle(color: Colors.grey, fontSize: 13),
                          border: OutlineInputBorder()),
                      autocorrect: false,
                      validator: (_val) {
                        if (_val == "" || _val!.length <= 4) {
                          return 'Required Filled!';
                        }
                        return null;
                      }),
                  SizedBox(
                    height: 25,
                  ),
                  const Text(
                    "Before registering an account. \nMake sure the data you fill is correct",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  GFButton(
                    onPressed: () async {
                      print(nameController.text);
                      print(phoneController.text);
                      //return;
                      if (!formKey.currentState!.validate()) {
                        GFToast.showToast(
                            'Sorry, All User Data Information is Required!',
                            context,
                            trailing: const Icon(
                              Icons.error_outline,
                              color: GFColors.WARNING,
                            ),
                            toastPosition: GFToastPosition.BOTTOM,
                            toastBorderRadius: 5.0);
                        return;
                      }
                      SmartDialog.showLoading(
                          msg: "Register Account...", backDismiss: false);
                      await auc
                          .submitRegistrasiAkun(widget.userTemp,
                              nameController.text, phoneController.text)
                          .then((value) => {
                                SmartDialog.dismiss(),
                                if (value == true)
                                  {
                                    auc.setKonfirmRegistrasiAkun(true),
                                    Navigator.of(Get.context!).pop(),
                                  }
                                else
                                  {
                                    GFToast.showToast(
                                        'Opps, An Error Occurred While Sending Data!',
                                        context,
                                        trailing: const Icon(
                                          Icons.error_outline,
                                          color: GFColors.WARNING,
                                        ),
                                        toastPosition: GFToastPosition.BOTTOM,
                                        toastBorderRadius: 5.0),
                                  }
                              });
                    },
                    text: "Register Account",
                    color: CupertinoColors.activeOrange,
                    blockButton: true,
                    icon: const Icon(
                      CupertinoIcons.paperplane,
                      color: GFColors.WHITE,
                      size: 18,
                    ),
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

  Widget _customDropDown(BuildContext context, Company? item) {
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
                  item.address!,
                  style: TextStyle(fontSize: 12),
                ),
              ));
  }

  Widget _customPopupItem(BuildContext context, Company item, bool isSelected) {
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
            item.displayName!,
            style: TextStyle(fontSize: 14),
          ),
          subtitle: Text(
            item.address!,
            style: TextStyle(fontSize: 12),
          ),
        ));
  }
}
