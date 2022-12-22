import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tmcapp/client.dart';
import 'package:tmcapp/controller/BlogController.dart';
import 'package:tmcapp/controller/ChatController.dart';
import 'package:tmcapp/controller/CompanyController.dart';
import 'package:tmcapp/controller/EventController.dart';
import 'package:tmcapp/controller/ImageController.dart';
import 'package:tmcapp/model/event_tmc.dart';
import 'package:tmcapp/model/event_tmc_detil.dart';
import 'package:tmcapp/model/list_id.dart';

class SearchController extends GetxController {
  static SearchController get to => Get.find<SearchController>();
  //final isLoading = true.obs;
  final isActive = false.obs;
  final resourceModel = "".obs; //blog,event, chatuser, peserta, pic, dlll

  final blogController = Get.put(BlogController());
  final companyController = Get.put(CompanyController());
  final chatController = Get.put(ChatController());
  final imageController = Get.put(ImageController());
  final eventController = Get.put(EventController());
  final String youtubeAvatar =
      "https://cdn3.iconfinder.com/data/icons/2018-social-media-logotypes/1000/2018_social_media_popular_app_logo_youtube-512.png";

  var ListItem = <SearchItem>[].obs;

  void setSearchingRef(String value) async {
    ListItem.clear();
    resourceModel(value);
    isActive(false);
    if (value == "blog") {
      isActive(true);
      //await blogController.getListBlog();
      for (var item in blogController.ListBlog) {
        String image_url = ApiClient().base_url + item.main_image_url;
        if (item.youtube_id != "") {
          image_url = youtubeAvatar;
        }
        ListItem.add(SearchItem(
            avatar: item.main_image_url,
            id: item.pk.toString(),
            title: item.title,
            subtitle: item.summary));
      }
    }

    if (value == "event") {
      //await blogController.getListBlog();
      //print("BLOG");
      isActive(true);
      //await eventController.getListEvent();
      for (var item in eventController.ListEvent) {
        String image_url = ApiClient().base_url + item.mainImageUrl!;
        String subtitle =
            "${DateFormat(DateFormat.YEAR_MONTH_WEEKDAY_DAY, "id_ID").format(DateTime.parse(item.date!.toIso8601String()))} ${item.date!.toIso8601String().toString().substring(11, 16)}";
        ListItem.add(SearchItem(
            avatar: image_url,
            id: item.pk.toString(),
            title: item.title!,
            subtitle: subtitle));
      }
    }
  }
}
