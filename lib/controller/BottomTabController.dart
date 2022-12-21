import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class BottomTabController extends GetxController {
  final bottomTabControl = PersistentTabController(initialIndex: 0);
  final countInboxItem = 0.obs;
  final countNotificationItem = 0.obs;
  setcountInbox(int _val) {
    countInboxItem(_val);
  }

  setcountNotificationItem(int _val) {
    countNotificationItem(_val);
  }

  static BottomTabController get to => Get.find<BottomTabController>();
}
