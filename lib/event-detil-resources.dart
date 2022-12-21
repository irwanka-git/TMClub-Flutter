import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';
import 'package:tmcapp/controller/AppController.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/controller/EventController.dart';
import 'package:tmcapp/model/event_tmc_detil.dart';
import 'package:tmcapp/model/resources.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetilResourcesScreen extends StatefulWidget {
  @override
  State<EventDetilResourcesScreen> createState() =>
      _EventDetilResourcesScreenState();
}

class _EventDetilResourcesScreenState extends State<EventDetilResourcesScreen> {
  final authController = AuthController.to;
  //final AkunController akunController = AkunController.to;
  final EventController eventController = EventController.to;
  var ListResources = <Resources>[].obs;
  var isLoading = true.obs;
  var searchTextFocus = false.obs;
  final itemAcara = EventTmcDetil(pk: 0).obs;

  Future<void> getDataResource() async {
    await eventController.getListResources(itemAcara.value.pk!);
    //setState(() {
    ListResources.value = eventController.ListResourcesEvent;
    _searchTextcontroller.text = "";
    // });
    isLoading.value = false;
    return;
  }

  void _onRefresh() async {
    // monitor network fetch
    isLoading.value = true;
    //await CompanyController.to.getListCompany();
    await getDataResource();
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    isLoading.value = false;
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

  TextEditingController _searchTextcontroller = TextEditingController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    setState(() {
      itemAcara(Get.arguments['event']);
      isLoading.value = true;
    });

    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      //companyController.getListCompany();
      await getDataResource();
      isLoading.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: buildFloatingActionAdd(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: AppBar(
          titleSpacing: 0,
          title: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isLoading.value == false
                      ? Text(
                          "Resources / Materi (${ListResources.value.length})",
                          style: TextStyle(fontSize: 18),
                        )
                      : Container(),
                  Text(
                    "${itemAcara.value.title}",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              )),
          backgroundColor: AppController.to.appBarColor.value,
          elevation: 1,
        ),
        backgroundColor: Theme.of(context).canvasColor,
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: const MaterialClassicHeader(
            color: CupertinoColors.activeOrange,
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: BuildListBody(),
        ));
  }

  Padding buildFloatingActionAdd() {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Obx(() => Visibility(
              visible: authController.user.value.role == "admin" ? true : false,
              child: FloatingActionButton(
                heroTag: "float_blog",
                onPressed: () async {
                  showModalResources("create", Resources());
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

  void showModalResources(String action, Resources item) {
    final _textDisplayNameController = TextEditingController();
    final _textURLController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    if (action == "create") {
      _textURLController.text = "";
      _textDisplayNameController.text = "";
    }
    if (action == "update") {
      _textURLController.text = item.url!;
      _textDisplayNameController.text = item.displayName!;
    }

    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (_context) => Padding(
              padding: EdgeInsets.only(
                  top: 30,
                  right: 20,
                  left: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 30),
              child: Container(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 10.0),
                      Text("Please Fill in Data Resources"),
                      SizedBox(height: 20.0),
                      TextFormField(
                          controller: _textDisplayNameController,
                          style: const TextStyle(fontSize: 13, height: 2),
                          decoration: const InputDecoration(
                              prefixIcon: Icon(CupertinoIcons.doc_plaintext),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              labelText: "Document Name",
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
                      SizedBox(height: 20.0),
                      TextFormField(
                          minLines: 1,
                          maxLines: 4,
                          controller: _textURLController,
                          style: const TextStyle(fontSize: 13, height: 2),
                          decoration: const InputDecoration(
                              prefixIcon: Icon(CupertinoIcons.link),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              labelText: "Link",
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
                            bool _validURL = Uri.parse(_val!).isAbsolute;
                            if (_validURL == false) {
                              return 'URL / Link Tidak Valid';
                            }
                            return null;
                          }),
                      SizedBox(height: 30.0),
                      GFButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) {
                            GFToast.showToast(
                                'Sorry, the data resources are not complete!',
                                context,
                                trailing: const Icon(
                                  Icons.error_outline,
                                  color: GFColors.WARNING,
                                ),
                                toastPosition: GFToastPosition.BOTTOM,
                                toastBorderRadius: 5.0);
                            return;
                          }
                          Navigator.pop(context);
                          var data = {
                            "display_name": _textDisplayNameController.text,
                            "url": _textURLController.text,
                          };

                          if (action == "create") {
                            SmartDialog.showLoading(
                                msg: "Add Resources...");
                            bool result =
                                await eventController.submitCreateResources(
                                    itemAcara.value.pk!, data);
                            SmartDialog.dismiss();
                            if (result == true) {
                              GFToast.showToast(
                                  'Create Resources Success!', context,
                                  trailing: const Icon(
                                    Icons.check_circle,
                                    color: GFColors.SUCCESS,
                                  ),
                                  toastPosition: GFToastPosition.BOTTOM,
                                  toastBorderRadius: 5.0);
                              getDataResource();
                            } else {
                              GFToast.showToast(
                                  'Failed!', context,
                                  trailing: const Icon(
                                    Icons.error_outline,
                                    color: GFColors.DANGER,
                                  ),
                                  toastPosition: GFToastPosition.BOTTOM,
                                  toastBorderRadius: 5.0);
                            }
                          }
                          if (action == "update") {
                            SmartDialog.showLoading(msg: "Updates Resources...");
                            bool result =
                                await eventController.submitUpdateResources(
                              item.pk!,
                              data,
                            );
                            SmartDialog.dismiss();
                            if (result == true) {
                              int index = ListResources.indexOf(item);
                              GFToast.showToast(
                                  'Updates Success', context,
                                  trailing: const Icon(
                                    Icons.check_circle,
                                    color: GFColors.SUCCESS,
                                  ),
                                  toastPosition: GFToastPosition.BOTTOM,
                                  toastBorderRadius: 5.0);
                              // ListResources.value[index].displayName=data['display_name'];
                              // ListResources.value[index].url =data['url'];
                              getDataResource();
                            } else {
                              GFToast.showToast(
                                  'Failed', context,
                                  trailing: const Icon(
                                    Icons.error_outline,
                                    color: GFColors.DANGER,
                                  ),
                                  toastPosition: GFToastPosition.BOTTOM,
                                  toastBorderRadius: 5.0);
                            }
                          }
                        },
                        blockButton: true,
                        icon: Icon(
                          CupertinoIcons.paperplane,
                          size: 16,
                          color: GFColors.WHITE,
                        ),
                        color: CupertinoColors.activeGreen,
                        text: "Save",
                      ),
                      SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ));
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
                  onTap: () {
                    setState(() {
                      searchTextFocus.value == true;
                    });
                  },
                  controller: _searchTextcontroller,
                  onChanged: (text) {
                    if (text == "") {
                      setState(() {
                        ListResources(eventController.ListResourcesEvent);
                      });
                      return;
                    }
                    ListResources.value =
                        eventController.ListResourcesEvent.where((p0) => p0
                            .displayName!
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
                            ListResources(eventController.ListResourcesEvent);
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
                delegate: isLoading.value == false
                    ? BuilderListCard(ListResources)
                    : BuilderListSkeletonCard(),
              ),
            )),
      ],
    );
  }

  SliverChildBuilderDelegate BuilderListCard(List<Resources> _ListResources) {
    List<Resources> _listResult = _ListResources;
    return SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return Container(
            child: GFListTile(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            print("TAP LIST");
            _launchInBrowser(Uri.parse(_listResult[index].url!));
            //showDetilAkun(_listResult[index]);
          },
          title: Text(_listResult[index].displayName!,
              style: TextStyle(
                fontSize: 16,
              )),
          subTitleText: displayURL(_listResult[index].url!),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          margin: EdgeInsets.all(0),
          avatar: Icon(
            CupertinoIcons.doc_plaintext,
            size: 30,
          ),
          icon: Container(
              child: authController.user.value.role == "admin"
                  ? PopupMenuButton(
                      onSelected: (_valueAction) {
                        // your logic
                        if (_valueAction == '/edit') {
                          showModalResources(
                              "update",
                              Resources(
                                pk: _listResult[index].pk!,
                                displayName: _listResult[index].displayName!,
                                url: _listResult[index].url!,
                              ));
                        }
                        if (_valueAction == '/delete') {
                          showKonfirmDelete(_listResult[index]);
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
        ));
      },
      childCount: _listResult.length,
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

  String displayURL(String urlSource) {
    final uri = Uri.parse(urlSource).host;
    return uri;
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      print('Could not launch $url');
    }
  }

  void showKonfirmDelete(Resources item) async {
    await Get.defaultDialog(
        contentPadding: const EdgeInsets.all(20),
        title: "Confirmation",
        titlePadding: const EdgeInsets.only(top: 10, bottom: 0),
        middleText: "Are you sure you want to delete resources \n[${item.displayName}]",
        backgroundColor: CupertinoColors.white,
        titleStyle: const TextStyle(color: Colors.black, fontSize: 16),
        middleTextStyle: const TextStyle(
            color: CupertinoColors.darkBackgroundGray, fontSize: 14),
        textCancel: "Cancel",
        textConfirm: "Yes, Delete",
        buttonColor: GFColors.DANGER,
        cancelTextColor: GFColors.DANGER,
        confirmTextColor: GFColors.WHITE,
        onConfirm: () async {
          Navigator.of(Get.overlayContext!).pop();
          SmartDialog.showLoading(msg: "Deleted Resources...");
          bool result = await eventController.submitDeleteResources(item.pk!);
          SmartDialog.dismiss();
          if (result) {
            getDataResource();
            GFToast.showToast('Deleted Success!', context,
                trailing: const Icon(
                  Icons.check_circle,
                  color: GFColors.SUCCESS,
                ),
                toastPosition: GFToastPosition.BOTTOM,
                toastBorderRadius: 5.0);
          } else {
            GFToast.showToast('Failed!', context,
                trailing: const Icon(
                  Icons.error_outline,
                  color: GFColors.DANGER,
                ),
                toastPosition: GFToastPosition.BOTTOM,
                toastBorderRadius: 5.0);
          }
        },
        radius: 0);
  }
}
