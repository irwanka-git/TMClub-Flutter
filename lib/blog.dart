import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tmcapp/controller/BottomTabController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:tmcapp/controller/CompanyController.dart';
import 'package:tmcapp/controller/EventController.dart';
import 'package:tmcapp/controller/ImageController.dart';
import 'package:tmcapp/controller/BlogController.dart';
import 'package:tmcapp/controller/SearchController.dart';
import 'package:tmcapp/widget/speed_dial.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'controller/AuthController.dart';
import 'controller/ChatController.dart';
import 'model/blog.dart';
import 'widget/skeleton.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CompanyController companyController = CompanyController.to;
  final BlogController blogController = BlogController.to;
  final AuthController authController = AuthController.to;
  final EventController eventController = EventController.to;
  final ChatController chatController = ChatController.to;
  final ImageController imageController = ImageController.to;
  final SearchController searchController = SearchController.to;
  final bottomTab = BottomTabController.to;

  var onLoadingNetwork = true.obs;
  late ScrollController _scrollController;
  var ListBlog = <BlogItem>[].obs;
  var isLoading = true.obs;
  void _onRefresh() async {
    // monitor network fetch
    isLoading.value = true;
    blogController.getListBlog();
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    setState(() {
      isLoading.value = false;
    });
    _refreshController.refreshCompleted();
    //isLoading.value = false;
  }

  void _onLoading() async {
    // monitor network fetch
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading.value = false;
    blogController.getListBlog();
    searchController.setSearchingRef("blog");
    //searchController.setSearchingRef("blog");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: CupertinoColors.lightBackgroundGray,
      floatingActionButton: buildFloatingActionAdd(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: const MaterialClassicHeader(
            color: CupertinoColors.activeOrange,
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: BuildListBody(),
        ),
      ),
    );
  }

  Padding buildFloatingActionAdd() {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Obx(() => Visibility(
            visible: authController.user.value.role == "admin" ? true : false,
            child: SpeedDial(
              child: const Icon(Icons.add),
              speedDialChildren: <SpeedDialChild>[
                SpeedDialChild(
                  child: const Icon(CupertinoIcons.play_circle),
                  foregroundColor: Colors.red,
                  backgroundColor: Colors.white,
                  label: 'Link Youtube',
                  onPressed: () {
                    Get.toNamed('/blog-create-youtube');
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.newspaper),
                  backgroundColor: Colors.white,
                  foregroundColor: GFColors.FOCUS,
                  label: 'Artikel / Blog',
                  onPressed: () {
                    Get.toNamed('/blog-create-article');
                  },
                ),
              ],
              openForegroundColor: Colors.white,
              closedForegroundColor: CupertinoColors.activeOrange,
              openBackgroundColor: CupertinoColors.activeOrange,
              closedBackgroundColor: Colors.white,
            ))));
  }
  //       Get.toNamed('/blog-create');

  CustomScrollView BuildListBody() {
    return CustomScrollView(
      slivers: [
        Obx(() => Container(
              child: SliverList(
                delegate: blogController.isLoading.value == false
                    ? BuilderListCard(blogController.ListBlog)
                    : BuilderListSkeletonCard(),
              ),
            )),
      ],
    );
  }

  // ignore: non_constant_identifier_names
  SliverChildBuilderDelegate BuilderListSkeletonCard() {
    return SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const CardSkeleton(),
            ));
      },
      childCount: 5,
    );
  }

  // ignore: non_constant_identifier_names
  SliverChildBuilderDelegate BuilderListCard(_listBlog) {
    return SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: CreateItemCard(_listBlog[index], context));
      },
      childCount: _listBlog.length,
    );
  }

  GestureDetector CreateItemCard(BlogItem item, BuildContext context) {
    return GestureDetector(
      onTap: () {
        blogController.openScreenItem(item.pk.toString());
      },
      child: GFCard(
        elevation: 5,
        boxFit: BoxFit.cover,
        titlePosition: GFPosition.start,
        image: Image.network(
          item.main_image_url,
          height: 200,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        showImage: true,
        padding: EdgeInsets.zero,
        title: GFListTile(
            titleText:
                item.youtube_id != "" ? "Youtube: ${item.title}" : item.title,
            subTitleText: item.summary,
            padding: const EdgeInsets.only(left: 8),
            icon: Obx(() => Container(
                  child: authController.user.value.role == "admin"
                      ? PopupMenuButton(
                          onSelected: (_valueAction) {
                            // your logic
                            if (_valueAction == '/edit' ||
                                _valueAction == '/delete') {
                              SmartDialog.showLoading(msg: "Loading..");
                              blogController
                                  .getBlogDetilbyPK(item.pk.toString())
                                  .then((value) => {
                                        SmartDialog.dismiss(),
                                        if (value != null)
                                          {
                                            if (_valueAction == '/edit')
                                              {
                                                if (value.youtube_id == "")
                                                  {
                                                    Get.toNamed(
                                                        '/blog-edit-article',
                                                        arguments: {
                                                          'blog': value
                                                        })
                                                  }
                                                else
                                                  {
                                                    Get.toNamed(
                                                        '/blog-edit-youtube',
                                                        arguments: {
                                                          'blog': value
                                                        })
                                                  }
                                              },
                                            if (_valueAction == '/delete')
                                              {
                                                Get.defaultDialog(
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            20),
                                                    title: "Confirmation",
                                                    titlePadding:
                                                        const EdgeInsets.only(
                                                            top: 10, bottom: 0),
                                                    middleText:
                                                        "Are you sure you want to delete this ${value.youtube_id != "" ? "Youtube Link" : "Article"}?",
                                                    backgroundColor:
                                                        CupertinoColors
                                                            .lightBackgroundGray,
                                                    titleStyle: const TextStyle(
                                                        color: CupertinoColors.darkBackgroundGray,
                                                        fontSize: 16),
                                                    middleTextStyle:
                                                        const TextStyle(
                                                            color: CupertinoColors.darkBackgroundGray,
                                                            fontSize: 14),
                                                    textCancel: "Cancel",
                                                    textConfirm: "Yes, Delete",
                                                    cancelTextColor:
                                                        CupertinoColors.darkBackgroundGray,
                                                    confirmTextColor:
                                                        Colors.white,
                                                    buttonColor: CupertinoColors
                                                        .systemRed,
                                                    onConfirm: () {
                                                      blogController
                                                          .deleteBlog(item.pk)
                                                          .then(
                                                            (value) => {
                                                              Navigator.pop(Get
                                                                  .overlayContext!),
                                                              if (value == true)
                                                                {
                                                                  GFToast.showToast(
                                                                      'Delete Success',
                                                                      context,
                                                                      toastPosition:
                                                                          GFToastPosition
                                                                              .BOTTOM,
                                                                      trailing:
                                                                          const Icon(
                                                                        Icons
                                                                            .check_circle_outline,
                                                                        color: GFColors
                                                                            .SUCCESS,
                                                                      ),
                                                                      toastDuration:
                                                                          5,
                                                                      toastBorderRadius:
                                                                          5.0),
                                                                  blogController
                                                                      .getListBlog()
                                                                }
                                                              else
                                                                {
                                                                  GFToast.showToast(
                                                                      'Delete Failed',
                                                                      context,
                                                                      trailing:
                                                                          const Icon(
                                                                        Icons
                                                                            .check_circle_outline,
                                                                        color: GFColors
                                                                            .DANGER,
                                                                      ),
                                                                      toastPosition:
                                                                          GFToastPosition
                                                                              .BOTTOM,
                                                                      toastDuration:
                                                                          5,
                                                                      toastBorderRadius:
                                                                          5.0),
                                                                }
                                                            },
                                                          );
                                                    },
                                                    radius: 0),
                                              }
                                          }
                                        else
                                          {
                                            GFToast.showToast(
                                                'Terjadi Kesalahan, Blog tidak ditemukan',
                                                context,
                                                toastPosition:
                                                    GFToastPosition.BOTTOM,
                                                trailing: const Icon(
                                                  Icons.error_outline,
                                                  color: GFColors.WARNING,
                                                ),
                                                toastBorderRadius: 5.0),
                                          }
                                      });
                            }
                            // if(value=='/edit'){
                            //   Get.toNamed('/detil-blog', arguments: {'blog': item});
                            // }
                          },
                          itemBuilder: (BuildContext bc) {
                            return const [
                              PopupMenuItem(
                                child: GFListTile(
                                  avatar: Icon(
                                    Icons.edit_rounded,
                                    size: 20,
                                  ),
                                  padding: EdgeInsets.zero,
                                  margin: EdgeInsets.zero,
                                  title: Text("Edit"),
                                ),
                                value: '/edit',
                              ),
                              PopupMenuItem(
                                child: GFListTile(
                                  avatar: Icon(
                                    Icons.delete_rounded,
                                    size: 20,
                                  ),
                                  padding: EdgeInsets.zero,
                                  margin: EdgeInsets.zero,
                                  title: Text("Hapus"),
                                ),
                                value: '/delete',
                              ),
                            ];
                          },
                        )
                      : Container(),
                )),
            margin: const EdgeInsets.only(top: 10, bottom: 10)),
      ),
    );
  }
}
