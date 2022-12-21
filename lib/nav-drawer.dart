import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/colors/gf_color.dart';
import 'package:getwidget/components/badge/gf_badge.dart';
import 'package:getwidget/getwidget.dart';
import 'package:tmcapp/controller/AppController.dart';
import 'package:tmcapp/controller/EventController.dart';

import 'controller/AuthController.dart';
import 'controller/BlogController.dart';
import 'controller/BottomTabController.dart';
import 'controller/ChatController.dart';
import 'controller/CompanyController.dart';
import 'controller/ImageController.dart';

class DrawerWidget extends StatefulWidget {
  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final authController = AuthController.to;
  final tabControl = BottomTabController.to;
  final companyController = CompanyController.to;
  final chatController = ChatController.to;
  final appController = AppController.to;

  @override
  void initState() {
    // TODO: implement initState
    print("INIT DRAWER MENU");

    super.initState();
  }

  Widget generateChip() {
    return authController.user.value.role != "member" &&
            authController.user.value.uid != ""
        ? Chip(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(5),
                    bottomRight: Radius.circular(5))),
            visualDensity: VisualDensity(vertical: -2),
            labelPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            labelStyle: TextStyle(color: Colors.white),
            label: Text(
              authController.user.value.role == "superadmin"
                  ? "Super Admin"
                  : authController.user.value.role == "admin"
                      ? "Admin TMClub"
                      : "PIC account",
            ),
            backgroundColor: authController.user.value.role == "superadmin"
                ? Color.fromARGB(255, 197, 4, 20)
                : Color.fromARGB(255, 17, 131, 142),
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    Color bgDrawer = Color.fromARGB(255, 241, 144, 8);
    if (authController.user.value.isLogin == true) {
      if (authController.user.value.role == "superadmin") {
        bgDrawer = CupertinoColors.activeBlue;
      }
    }
    double widthDrawer = MediaQuery.of(context).size.width * 0.75;
    return SizedBox(
      width: widthDrawer,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 15, bottom: 10),
              decoration: BoxDecoration(
                color: appController.appBarColor.value,
              ),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                        width: Get.width,
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: Row(children: [generateChip()])),
                    authController.user.value.uid == ""
                        ? GFAvatar(
                            radius: 50,
                            backgroundImage:
                                AssetImage('assets/images/default-avatar.png'),
                          )
                        : GFAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(
                                authController.user.value.photoURL),
                          ),
                    const SizedBox(
                      height: 15,
                    ),
                    Obx(() => Container(
                          child: authController.user.value.uid != ""
                              ? Column(
                                  children: [
                                    Text(
                                      authController.user.value.displayName,
                                      style: const TextStyle(
                                          color: CupertinoColors.white),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      authController.user.value.companyName,
                                      style: const TextStyle(
                                          color: CupertinoColors.white,
                                          fontSize: 13),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                  ],
                                )
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                          primary: Colors.white,
                                          onPrimary: CupertinoColors.systemBlue)
                                      .copyWith(
                                          elevation:
                                              ButtonStyleButton.allOrNull(0.0)),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    authController.signin(context);
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const <Widget>[
                                        Image(
                                          image: AssetImage(
                                              "assets/images/google_logo.png"),
                                          height: 10.0,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Text(
                                            'Sign in with Google',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                        ))
                  ],
                ),
              ),
            ),
            _drawerItem(
                icon: CupertinoIcons.square_grid_3x2,
                text: 'About TMClub',
                onTap: () => {Navigator.pop(context), Get.toNamed('/about')}),
            authController.user.value.isLogin == true
                ? _drawerItem(
                    icon: CupertinoIcons.person,
                    text: 'My Profile',
                    onTap: () =>
                        {Navigator.pop(context), Get.toNamed('/profil-saya')})
                : Container(),
            authController.user.value.isLogin == true &&
                    (authController.user.value.role == "superadmin" ||
                        authController.user.value.role == "admin")
                ? _drawerItem(
                    icon: CupertinoIcons.building_2_fill,
                    text: 'Company List',
                    onTap: () => {
                          Navigator.pop(context),
                          Get.toNamed('/daftar-company')
                        })
                : Container(),
            authController.user.value.isLogin == true &&
                    (authController.user.value.role == "superadmin" ||
                        authController.user.value.role == "admin")
                ? _drawerItem(
                    icon: CupertinoIcons.checkmark_rectangle,
                    text: 'Manage Surveys',
                    onTap: () =>
                        {Navigator.pop(context), Get.toNamed('/kelola-survey')})
                : Container(),
            authController.user.value.isLogin == true &&
                    authController.user.value.role == "superadmin"
                ? _drawerItem(
                    icon: CupertinoIcons.person_2,
                    text: 'Admin Account',
                    onTap: () =>
                        {Navigator.pop(context), Get.toNamed('/akun-admin')})
                : Container(),
            authController.user.value.isLogin == true &&
                    (authController.user.value.role == "superadmin" ||
                        authController.user.value.role == "admin")
                ? _drawerItem(
                    icon: CupertinoIcons.person_2,
                    text: 'PIC Account',
                    onTap: () =>
                        {Navigator.pop(context), Get.toNamed('/akun-pic')})
                : Container(),
            authController.user.value.isLogin == true &&
                    (authController.user.value.role == "PIC" ||
                        authController.user.value.role == "superadmin" ||
                        authController.user.value.role == "admin")
                ? _drawerItem(
                    icon: CupertinoIcons.person_2,
                    text: 'Member Account',
                    onTap: () =>
                        {Navigator.pop(context), Get.toNamed('/akun-member')})
                : Container(),
            authController.user.value.isLogin == true &&
                    (authController.user.value.role == "PIC")
                ? _drawerItem(
                    icon: CupertinoIcons.creditcard,
                    text: 'Invoice',
                    onTap: () =>
                        {Navigator.pop(context), Get.toNamed('/invoice')})
                : Container(),
            authController.user.value.isLogin == true
                ? _drawerItem(
                    icon: CupertinoIcons.square_arrow_left,
                    text: 'Logout',
                    onTap: () => {
                          Navigator.pop(context),
                          tabControl.bottomTabControl.notifyListeners(),
                          authController.signout(context),
                          setState(() {
                            tabControl.bottomTabControl.index = 0;
                            tabControl.setcountInbox(0);
                          })
                        })
                : Container(),
          ],
        ),
      ),
    );
  }
}

Widget _drawerHeader() {
  return Container(
    child: const UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        color: CupertinoColors.activeOrange,
      ),
      currentAccountPicture: ClipOval(
          child: Image(
              image: AssetImage('assets/images/default-avatar.png'),
              fit: BoxFit.cover)),
      accountName: Text('Masuk'),
      accountEmail: Text(''),
    ),
  );
}

Widget _drawerItem({IconData? icon, String? text, GestureTapCallback? onTap}) {
  return ListTile(
    title: Row(
      children: <Widget>[
        Icon(icon),
        Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: Text(
            text!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
    onTap: onTap,
  );
}
