// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:tmcapp/client.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/controller/BottomTabController.dart';
import 'package:tmcapp/controller/SearchController.dart';
import 'package:tmcapp/model/blog.dart';

class BlogController extends GetxController {
  var ListBlog = <BlogItem>[].obs;
  static BlogController get to => Get.find<BlogController>();
  final bottomTabController  = BottomTabController.to;
  final authController = AuthController.to;
  final isLoading = false.obs;

  Future<void> getListBlog() async {
    //print("BTNBNT: ${bottomTabController.bottomTabControl.index}");
    await authController
        .sinkronAccountMeServerToFirebase(authController.user.value);
    ListBlog.clear();
    isLoading(true);
    var response = await ApiClient().requestGet("/blog", null);
    if (response == null) {
      isLoading(false);
      return;
    }
    for (var blog in response) {
      BlogItem item = BlogItem(
          pk: blog['pk'],
          title: blog['title'],
          summary: blog['summary'],
          youtube_id: blog['youtube_id'],
          main_image_url:
              ApiClient().base_url + blog['main_image_url'].toString());
      ListBlog.add(item);
    }

    if(BottomTabController.to.bottomTabControl.index==0){
      SearchController.to.setSearchingRef("blog");
    }
    isLoading(false);
    return;
  }

  Future<void> reloadListBlog() async {
    ListBlog.clear();
    var response = await ApiClient().requestGet("/blog", null);
    for (var blog in response) {
      BlogItem item = BlogItem(
          pk: blog['pk'],
          title: blog['title'],
          summary: blog['summary'],
          youtube_id: blog['youtube_id'],
          main_image_url:
              ApiClient().base_url + blog['main_image_url'].toString());
      ListBlog.add(item);
    }
    return;
  }

  Future<void> openScreenItem(String id) async {
    SmartDialog.showLoading(msg: "Loading..");
    await getBlogDetilbyPK(id).then((value) => {
          SmartDialog.dismiss(),
          if (value != null)
            {
              Get.toNamed('/detil-blog', arguments: {'blog': value})
            }
          else
            {
              Get.snackbar('Opps.', "Terjadi Kesalahan, Blog Tidak Ditemukan",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: CupertinoColors.systemYellow,
                  colorText: Colors.black)
            }
        });
    return;
  }

  String getYoutubeVideoId(String url) {
    RegExp regExp = RegExp(
      r'.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/)|(?:(?:watch)?\?v(?:i)?=|\&v(?:i)?=))([^#\&\?]*).*',
      caseSensitive: false,
      multiLine: false,
    );
    final match = regExp.firstMatch(url)?.group(1); // <- This is the fix
    String? str = match;
    if (str != null) {
      return str;
    } else {
      return "";
    }
  }

  String generateYoutubeEmbed(String youtube_id) {
    //String youtube_id = getYoutubeVideoId(url)!.toString();
    return '<iframe width="560" height="315" src="https://www.youtube.com/embed/$youtube_id" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>';
  }

  Future<bool> postingCreateBlog(Map<String, dynamic> data) async {
    dynamic headers = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    //print(data);
    var response = await ApiClient().requestPost('/blog/', data, headers);
    //print(response['status_code']);
    if (response['status_code'] == 201) {
      var data = response['data'];
      return true;
    }
    return false;
  }

  Future<bool> updateBlog(Map<String, dynamic> data, int pk) async {
    //print(data);
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var response = await ApiClient().patch('/blog/$pk/', data, header);
    if (response['status_code'] == 200) {
      //var data = response['data'];
      return true;
    }
    return false;
  }

  //DELETE BLOG
  Future<bool> deleteBlog(int pk) async {
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var response = await ApiClient().delete('/blog/$pk/', header);
    //print(response['status_code']);
    if (response['status_code'] == 200 ||
        response['status_code'] == 201 ||
        response['status_code'] == 204) {
      return true;
    }
    return false;
  }

  Future<BlogItemDetil?> getBlogDetilbyPK(String pk) async {
    var resultBlogItem = BlogItemDetil(
        pk: 0,
        title: "",
        summary: "",
        main_image: "",
        main_image_url: "",
        content: "",
        youtube_id: "",
        youtube_embeded: "",
        albums_url: [],
        albums_id: []);
    var response = await ApiClient().requestGet("/blog/$pk/", null);
    if (response != null) {
      resultBlogItem = BlogItemDetil.fromJson(response);
      return resultBlogItem;
    }
    return null;
  }

  Future<dynamic> getYoutubeMetaData(String youtube_id) async {
    String url =
        "https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=${youtube_id}&format=json";
    //print(url);
    var response = await ApiClient().requestGetXURL(url, null);
    //print(response);
    if (response != null && response != "ERROR") {
      return response;
    }
    return null;
  }
}
