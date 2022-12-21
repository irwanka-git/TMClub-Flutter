import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tmcapp/client.dart';
import 'package:tmcapp/controller/BottomTabController.dart';
import 'package:flutter/material.dart';
import 'package:tmcapp/controller/SearchController.dart';
import 'package:tmcapp/model/event_tmc.dart';
import 'package:tmcapp/widget/skeleton.dart';
import 'controller/AuthController.dart';
import 'controller/EventController.dart';

class EventScreen extends StatefulWidget {
  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final bottomTabControl = BottomTabController.to;
  final eventController = EventController.to;
  final authController = AuthController.to;
  final SearchController searchController = SearchController.to;
  late ScrollController _scrollController;
  final Color _foregroundColor = Colors.white;
  final isLoading = true.obs;
  final base_url = ApiClient().base_url;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    // TODO: implement initState
    eventController.getListEvent();
    // searchController.setSearchingRef("event");
    super.initState();
  }

  void _onRefresh() async {
    // monitor network fetch
    isLoading.value = true;
    eventController.getListEvent();
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    setState(() {
      isLoading.value = false;
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
      //backgroundColor: CupertinoColors.lightBackgroundGray,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
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

  CustomScrollView BuildListBody() {
    return CustomScrollView(
      slivers: [
        authController.user.value.role == "admin" ||
                authController.user.value.role == "member"
            ? SliverAppBar(
                backgroundColor: Theme.of(context).canvasColor,
                stretch: false,
                pinned: true,
                centerTitle: false,
                toolbarHeight: kToolbarHeight + 10,
                title: Container(
                  margin: EdgeInsets.only(top: 0, bottom: 0),
                  child: Row(
                    children: [
                      GFButton(
                          shape: GFButtonShape.pills,
                          type: GFButtonType.solid,
                          color: GFColors.LIGHT,
                          size: GFSize.MEDIUM,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          icon: const Icon(
                            CupertinoIcons.calendar,
                            size: 18,
                            color: GFColors.DARK,
                          ),
                          textColor: GFColors.DARK,
                          text: "My Event ",
                          onPressed: () {
                            Get.toNamed('/event-me');
                          }),
                    ],
                  ),
                ),
              )
            : SliverAppBar(
                backgroundColor: Theme.of(context).canvasColor,
                toolbarHeight: 0,
              ),
        Obx(() => Container(
              child: SliverList(
                delegate: eventController.isLoading.value == false
                    ? BuilderListCard(eventController.ListEvent)
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
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const CardSkeleton(),
            ));
      },
      childCount: 5,
    );
  }

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

  GestureDetector CreateItemCard(EventTmc item, BuildContext context) {
    return GestureDetector(
      onTap: () {
        eventController.openScreenItem(item.pk.toString());
      },
      child: GFCard(
        elevation: 5,
        boxFit: BoxFit.cover,
        titlePosition: GFPosition.start,
        padding: EdgeInsets.zero,
        showImage: true,
        content: GFImageOverlay(
          height: 200,
          child: item.isFree == true
              ? Center(
                  child: Container(
                    width: 100,
                    height: 35,
                    padding: const EdgeInsets.all(0),
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(200, 28, 208, 31),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    child: SizedBox(
                      width: Get.width * 0.2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "Free",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Container(),
          boxFit: BoxFit.cover,
          image: Image.network(
            base_url + item.mainImageUrl!,
          ).image,
          colorFilter:
              ColorFilter.mode(Colors.black.withOpacity(0), BlendMode.darken),
        ),
        // image: Image.network(
        //   base_url + item.mainImageUrl!,
        //   height: 200,
        //   width: MediaQuery.of(context).size.width,
        //   fit: BoxFit.cover,
        // ),
        title: GFListTile(
            title: Text(
              item.title!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subTitle: Container(
              margin: const EdgeInsets.only(top: 5),
              child: GFListTile(
                margin: EdgeInsets.all(0),
                padding: EdgeInsets.all(0),
                avatar: Icon(
                  CupertinoIcons.calendar_today,
                  size: 24,
                ),
                title: Text(item.venue!),
                subTitle: Text(
                    "${DateFormat(DateFormat.YEAR_MONTH_WEEKDAY_DAY, "id_ID").format(DateTime.parse(item.date!.toIso8601String()))} ${item.date!.toIso8601String().toString().substring(11, 16)}"),
              ),
            ),
            padding: const EdgeInsets.only(left: 8),
            margin: const EdgeInsets.only(top: 10, bottom: 10)),
      ),
    );
  }
}
