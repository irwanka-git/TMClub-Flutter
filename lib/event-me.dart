// ignore_for_file: unnecessary_string_interpolations

import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';
import 'package:tmcapp/client.dart';
import 'package:tmcapp/controller/AppController.dart';
import 'package:tmcapp/controller/BottomTabController.dart';
import 'package:flutter/material.dart';
import 'package:tmcapp/controller/CompanyController.dart';
import 'package:tmcapp/controller/SearchController.dart';
import 'package:tmcapp/model/event_tmc.dart';
import 'package:tmcapp/widget/skeleton.dart';

import 'controller/AuthController.dart';
import 'controller/EventController.dart';

class EventMeScreen extends StatefulWidget {
  @override
  State<EventMeScreen> createState() => _EventMeScreenState();
}

class _EventMeScreenState extends State<EventMeScreen> {
  final bottomTabControl = BottomTabController.to;
  final eventController = EventController.to;
  final authController = AuthController.to;
  final SearchController searchController = SearchController.to;
  late ScrollController _scrollController;
  final Color _foregroundColor = Colors.white;
  final isLoading = true.obs;
  final base_url = ApiClient().base_url;
  var MyListEvent = <EventTmc>[].obs;

  TextEditingController _searchTextcontroller = TextEditingController();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    // TODO: implement initState
    // searchController.setSearchingRef("event");
    super.initState();
    //CompanyController.to.getListCompany();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      //companyController.getListCompany();
      await eventController.getListMyEvent();
      _searchTextcontroller.text = "";
      setState(() {
        MyListEvent(eventController.ListMyEvent);
      });
    });
  }

  void _onRefresh() async {
    // monitor network fetch
    isLoading.value = true;
    await eventController.getListMyEvent();
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    setState(() {
      isLoading.value = false;
      _searchTextcontroller.text = "";
      MyListEvent(eventController.ListMyEvent);
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
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: buildFloatingActionAdd(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(
          authController.user.value.role == "admin"
              ? "Managed events"
              : "Followed events",
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor: AppController.to.appBarColor.value,
        elevation: 1,
      ),
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
              child: FloatingActionButton(
                heroTag: "float_event",
                onPressed: () {
                  Get.toNamed('/event-create');
                },
                backgroundColor: CupertinoColors.white,
                elevation: 6,
                child: const Icon(
                  Icons.add,
                  color: CupertinoColors.activeOrange,
                  size: 26.0,
                ),
                mini: true,
              ),
            )));
  }

  CustomScrollView BuildListBody() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).canvasColor,
          stretch: true,
          pinned: true,
          leading: Container(),
          floating: true,
          toolbarHeight: 20.0 + kToolbarHeight,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: SizedBox(
              height: 45,
              child: Container(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: TextField(
                  controller: _searchTextcontroller,
                  onChanged: (text) {
                    if (text == "") {
                      setState(() {
                        MyListEvent(eventController.ListMyEvent);
                      });
                      return;
                    }
                    MyListEvent.value = eventController.ListMyEvent.where(
                        (p0) => p0.title!
                            .toLowerCase()
                            .contains(text.toLowerCase())).toList();
                  },
                  decoration: InputDecoration(
                      prefixIcon: Icon(CupertinoIcons.search),
                      contentPadding: EdgeInsets.only(top: 10),
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          _searchTextcontroller.clear();
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          setState(() {
                            MyListEvent(eventController.ListMyEvent);
                          });
                        },
                        icon: Icon(Icons.clear),
                      ),
                      hintText: 'Search'),
                ),
              ),
            ),
          ),
        ),
        Obx(() => Container(
              child: SliverList(
                delegate: eventController.isLoading.value == false
                    ? BuilderListCard(MyListEvent)
                    : BuilderListSkeletonCard(),
              ),
            )),
      ],
    );
  }

  SliverChildBuilderDelegate BuilderListSkeletonCard() {
    return SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SkeletonParagraph(
              style: SkeletonParagraphStyle(
                  lines: 2,
                  spacing: 5,
                  lineStyle: SkeletonLineStyle(
                    randomLength: false,
                    height: 15,
                    borderRadius: BorderRadius.circular(5),
                  )),
            ));
      },
      childCount: 8,
    );
  }

  SliverChildBuilderDelegate BuilderListCard(_listBlog) {
    return SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: CreateListItem(_listBlog[index], context));
        //child: CreateItemCard(_listBlog[index], context));
      },
      childCount: _listBlog.length,
    );
  }

  CreateListItem(EventTmc item, BuildContext context) {
    return GFListTile(
      onTap: () {
        eventController.openScreenItem(item.pk.toString());
      },
      title: Text(item.isFree! ? "(Free) ${item.title!}" : item.title!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
          )),
      subTitleText:
          "${DateFormat(DateFormat.YEAR_MONTH_WEEKDAY_DAY, "id_ID").format(DateTime.parse(item.date!.toIso8601String()))}",
      padding: EdgeInsets.symmetric(vertical: 8),
      margin: authController.user.value.role == "admin"
          ? EdgeInsets.only(left: 15, right: 5)
          : EdgeInsets.only(left: 15, right: 15),
      avatar: GFAvatar(
          radius: 25,
          backgroundColor: GFColors.LIGHT,
          backgroundImage: Image.network(base_url + item.mainImageUrl!).image),
      icon: Container(
          child: authController.user.value.role == "admin"
              ? PopupMenuButton(
                  onSelected: (_valueAction) {
                    // your logic
                    if (_valueAction == '/edit' || _valueAction == '/delete') {
                      SmartDialog.showLoading(msg: "Loading..");
                      eventController.getDetilEvent(item.pk!).then((value) => {
                            SmartDialog.dismiss(),
                            if (value.pk! > 0)
                              {
                                if (_valueAction == '/edit')
                                  {
                                    Get.toNamed('/event-edit',
                                        arguments: {'event': value})
                                  },
                                if (_valueAction == '/delete')
                                  {
                                    Get.defaultDialog(
                                        contentPadding:
                                            const EdgeInsets.all(20),
                                        title: "Confirmation",
                                        titlePadding: const EdgeInsets.only(
                                            top: 10, bottom: 0),
                                        middleText:
                                            "Are you sure you want to delete this event?",
                                        backgroundColor:
                                            CupertinoColors.darkBackgroundGray,
                                        titleStyle: const TextStyle(
                                            color: Colors.white, fontSize: 16),
                                        middleTextStyle: const TextStyle(
                                            color: Colors.white, fontSize: 14),
                                        textCancel: "Cancel",
                                        textConfirm: "Yes",
                                        cancelTextColor: Colors.white,
                                        confirmTextColor: Colors.white,
                                        buttonColor:
                                            CupertinoColors.activeOrange,
                                        onConfirm: () {
                                          eventController
                                              .deleteEvent(item.pk!)
                                              .then(
                                                (value) => {
                                                  Navigator.pop(
                                                      Get.overlayContext!),
                                                  if (value == true)
                                                    {
                                                      GFToast.showToast(
                                                          'Event Deleted Successfully!',
                                                          context,
                                                          trailing: const Icon(
                                                            Icons
                                                                .check_circle_outline,
                                                            color: GFColors
                                                                .SUCCESS,
                                                          ),
                                                          toastDuration: 5,
                                                          toastPosition:
                                                              GFToastPosition
                                                                  .BOTTOM,
                                                          toastBorderRadius:
                                                              5.0),
                                                      eventController
                                                          .getListMyEvent()
                                                    }
                                                  else
                                                    {
                                                      GFToast.showToast(
                                                          'Event Failed to Delete',
                                                          context,
                                                          trailing: const Icon(
                                                            Icons
                                                                .check_circle_outline,
                                                            color:
                                                                GFColors.DANGER,
                                                          ),
                                                          toastDuration: 5,
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
                                    'Failed Load Event',
                                    context,
                                    trailing: const Icon(
                                      Icons.error_outline,
                                      color: GFColors.WARNING,
                                    ),
                                    toastBorderRadius: 5.0),
                              }
                          });
                    }
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
              : Container()),
    );
  }
}
