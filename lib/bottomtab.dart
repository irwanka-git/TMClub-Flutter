import 'package:badges/badges.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/controller/BlogController.dart';
import 'package:tmcapp/controller/BottomTabController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:tmcapp/controller/CompanyController.dart';
import 'package:tmcapp/controller/EventController.dart';
import 'package:tmcapp/controller/NotifikasiController.dart';
import 'package:tmcapp/controller/SearchController.dart';
import 'package:tmcapp/notification.dart';
import 'blog.dart';
import 'controller/ChatController.dart';
import 'event.dart';
import 'chat.dart';
import 'about.dart';

class BottomTabScreen extends StatefulWidget {
  @override
  State<BottomTabScreen> createState() => _BottomTabScreenState();
}

class _BottomTabScreenState extends State<BottomTabScreen> {
  //final user = FirebaseAuth.instance.currentUser!;
  //final tabControl = Get.put(BottomTabController());
  final authController = AuthController.to;
  final tabControl = BottomTabController.to;
  final companyController = CompanyController.to;
  final chatController = ChatController.to;
  final searchController = SearchController.to;

  @override
  void initState() {
    // TODO: implement initState
    print("Init Firebase Auth");
    authController.initFirebase();
    print("Cek user Login");
    authController.cekUserLogin();
    print("Ambil List Company");
    companyController.getListCompany();
    super.initState();
  }

  void _goToTabBottom(int index) {
    tabControl.bottomTabControl.jumpToTab(index);
    tabControl.bottomTabControl.notifyListeners();
  }

  List<Widget> _buildScreens() {
    return [
      HomeScreen(),
      EventScreen(),
      ChatScreen(),
      NotificationScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
          icon: const Icon(CupertinoIcons.home),
          title: ("Home"),
          activeColorPrimary: CupertinoColors.activeOrange,
          inactiveColorPrimary: CupertinoColors.systemGrey,
          iconSize: 20),
      PersistentBottomNavBarItem(
          icon: const Icon(CupertinoIcons.calendar),
          title: ("Event"),
          activeColorPrimary: CupertinoColors.activeOrange,
          inactiveColorPrimary: CupertinoColors.systemGrey,
          iconSize: 20),
      PersistentBottomNavBarItem(
          icon: Obx(() => Badge(
                badgeContent: Text('${tabControl.countInboxItem.value}',
                    style: const TextStyle(color: Colors.white, fontSize: 10)),
                showBadge: tabControl.countInboxItem.value > 0 ? true : false,
                badgeColor: Colors.redAccent,
                elevation: 0,
                shape: BadgeShape.circle,
                position: const BadgePosition(top: -1, start: 18),
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                child: const Icon(CupertinoIcons.chat_bubble),
              )),
          title: ("Chat"),
          activeColorPrimary: CupertinoColors.activeOrange,
          inactiveColorPrimary: CupertinoColors.systemGrey,
          iconSize: 20),
      PersistentBottomNavBarItem(
          icon: Obx(() => Badge(
                badgeContent: Text('${tabControl.countNotificationItem.value}',
                    style: const TextStyle(color: Colors.white, fontSize: 10)),
                showBadge:
                    tabControl.countNotificationItem.value > 0 ? true : false,
                badgeColor: Colors.redAccent,
                elevation: 0,
                shape: BadgeShape.circle,
                position: const BadgePosition(top: -1, start: 18),
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                child: const Icon(CupertinoIcons.bell),
              )),
          title: ("Notification"),
          activeColorPrimary: CupertinoColors.activeOrange,
          inactiveColorPrimary: CupertinoColors.systemGrey,
          iconSize: 20),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: tabControl.bottomTabControl,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineInSafeArea: true,
      onItemSelected: (index) {
        //blog
        if (index == 0) {
          searchController.setSearchingRef("blog");
        }
        //event
        if (index == 1) {
          searchController.setSearchingRef("event");
        }

        if (index == 2) {
          searchController.setSearchingRef("");
          setState(() {
            tabControl.bottomTabControl.index = 2;
          });
        }

        if (index == 3) {
          setState(() {
            tabControl.bottomTabControl.index = 3;
          });
          searchController.setSearchingRef("");
          NotifikasiController.to.getNotifikasiCountUnreadSurvey();
        }
      },
      backgroundColor: Colors.white, // Default is Colors.white.
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset:
          true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
      stateManagement: true, // Default is true.
      hideNavigationBarWhenKeyboardShows:
          true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
      decoration: const NavBarDecoration(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(10), bottom: Radius.zero),
        colorBehindNavBar: Colors.white,
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: const ItemAnimationProperties(
        // Navigation Bar's items animation properties.
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: const ScreenTransitionAnimation(
        // Screen transition animation on change of selected tab.
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle:
          NavBarStyle.simple, // Choose the nav bar style with this property.
    );
  }
}
