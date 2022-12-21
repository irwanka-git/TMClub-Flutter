import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:tmcapp/controller/AkunController.dart';
import 'package:tmcapp/controller/AppController.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/model/akun_firebase.dart';
import 'package:tmcapp/widget/image_widget.dart';

class ProfilSayaScreen extends StatefulWidget {
  @override
  State<ProfilSayaScreen> createState() => _ProfilSayaScreenState();
}

class _ProfilSayaScreenState extends State<ProfilSayaScreen> {
  final authController = AuthController.to;
  final akunController = AkunController.to;
  final formKey = GlobalKey<FormState>();
  var akunSaya = AkunFirebase().obs;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController vaController = TextEditingController();

  Future<void> reloadData() async {
    SmartDialog.showLoading(msg: "Check Profile...");
    await authController
        .sinkronAccountMeServerToFirebase(authController.user.value)
        .then((value) async {
      await akunController.getMyAkun().then((value) {
        setState(() {
          akunSaya(value);
          print(akunSaya.value.transactionNumber);
          companyController.text = akunSaya.value.companyName!;
          vaController.text = akunSaya.value.transactionNumber!;
          nameController.text = akunSaya.value.displayName!;
          phoneController.text = akunSaya.value.phoneNumber != ""
              ? akunSaya.value.phoneNumber!
              : "+62";
        });
        //SmartDialog.dismiss();
      });
    });
    SmartDialog.dismiss();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      //akunController.getListAkun();
      await reloadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetX<AppController>(
      init: AppController(),
      initState: (_) {},
      builder: (_) {
        return Scaffold(
            appBar: AppBar(
              title: const Text("My profile"),
              backgroundColor: AppController.to.appBarColor.value,
              elevation: 1,
            ),
            backgroundColor: Theme.of(context).canvasColor,
            body: Padding(
              padding: const EdgeInsets.all(15.0),
              child: buildBodyPage(),
            ));
      },
    );
  }

  Widget buildBodyPage() {
    String _prefixPhone = "+62";
    return Container(
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              CircleImageNetwork(
                  authController.user.value.photoURL, 54, UniqueKey()),
              SizedBox(
                height: 25,
              ),
              Text(
                "Please Change User Data",
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 25,
              ),
              TextFormField(
                  readOnly: true,
                  enabled: false,
                  initialValue: authController.user.value.email,
                  style: const TextStyle(fontSize: 13, height: 2),
                  decoration: const InputDecoration(
                      fillColor: GFColors.DARK,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      labelText: "Email",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                      border: OutlineInputBorder()),
                  autocorrect: false,
                  validator: (_val) {
                    if (_val == "") {
                      return 'Required!';
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
                      labelText: "Full Name",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                      border: OutlineInputBorder()),
                  autocorrect: false,
                  validator: (_val) {
                    if (_val == "") {
                      return 'Required!';
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
                      labelText: "Phone Number (Whatsapp)",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                      border: OutlineInputBorder()),
                  autocorrect: false,
                  validator: (_val) {
                    if (_val == "" || _val.toString().length <= 4) {
                      return 'Required!';
                    }
                    return null;
                  }),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                  readOnly: true,
                  enabled: false,
                  controller: companyController,
                  style: const TextStyle(fontSize: 13, height: 2),
                  decoration: const InputDecoration(
                      fillColor: GFColors.DARK,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      labelText: "Company",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                      border: OutlineInputBorder()),
                  autocorrect: false,
                  validator: (_val) {
                    return null;
                  }),
              SizedBox(
                height: 30,
              ),
              TextFormField(
                  readOnly: true,
                  enabled: false,
                  controller: vaController,
                  style: const TextStyle(fontSize: 13, height: 2),
                  decoration: const InputDecoration(
                      fillColor: GFColors.DARK,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      labelText: "Virtual Account Number",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                      border: OutlineInputBorder()),
                  autocorrect: false,
                  validator: (_val) {
                     
                    return null;
                  }),
              SizedBox(
                height: 30,
              ),
              GFButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) {
                    GFToast.showToast(
                        'Sorry, All User Information Required!',
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
                      msg: "Save Profile...", backDismiss: false);
                  bool berhasil = false;
                  await akunController
                      .updateAkunSaya(nameController.text, phoneController.text)
                      .then((value) => berhasil = value);
                  SmartDialog.dismiss();
                  if (berhasil == true) {
                    GFToast.showToast('Profile Saved Successfully', context,
                        trailing: const Icon(
                          Icons.check_circle_outline,
                          color: GFColors.SUCCESS,
                        ),
                        toastDuration: 3,
                        toastPosition: GFToastPosition.BOTTOM,
                        toastBorderRadius: 5.0);

                    await authController.sinkronAccountMeServerToFirebase(
                        authController.user.value);
                    reloadData();
                    return;
                  } else {
                    GFToast.showToast('Failed to Save Data', context,
                        trailing: const Icon(
                          Icons.error_outline,
                          color: GFColors.DANGER,
                        ),
                        toastDuration: 3,
                        toastPosition: GFToastPosition.BOTTOM,
                        toastBorderRadius: 5.0);
                  }
                },
                text: "Save",
                color: CupertinoColors.activeGreen,
                blockButton: true,
                icon: const Icon(
                  Icons.save_outlined,
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
    );
  }
}
