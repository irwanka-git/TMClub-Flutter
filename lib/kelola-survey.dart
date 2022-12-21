import 'package:dropdown_search/dropdown_search.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';
import 'package:tmcapp/controller/AppController.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/controller/AkunController.dart';
import 'package:tmcapp/controller/CompanyController.dart';
import 'package:tmcapp/controller/SurveyController.dart';
import 'package:tmcapp/model/akun_firebase.dart';
import 'package:tmcapp/model/company.dart';
import 'package:tmcapp/model/survey.dart';

class KelolaSurveyScreen extends StatefulWidget {
  @override
  State<KelolaSurveyScreen> createState() => _KelolaSurveyScreenState();
}

class _KelolaSurveyScreenState extends State<KelolaSurveyScreen> {
  final authController = AuthController.to;
  final surveyController = SurveyController.to;
  var ListSurvey = <Survey>[].obs;
  var isLoading = true.obs;
  var searchTextFocus = false.obs;
  var addEmail = "".obs;
  var addCompany = "".obs;
  var CompanySelected = null.obs;
  var nameCompanyRef = "".obs;
  var idCompanyRef = "".obs;

  var emailController = TextEditingController();
  CompanyController companyController = CompanyController.to;

  void _onRefresh() async {
    // monitor network fetch
    isLoading.value = true;
    //await CompanyController.to.getListCompany();
    await surveyController.getListSurvey();
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    setState(() {
      ListSurvey(surveyController.ListSurvey);
      isLoading.value = false;
      _searchTextcontroller.text = "";
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

  TextEditingController _searchTextcontroller = TextEditingController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // setState(() {
    //   idCompanyRef(Get.arguments['idCompany']);
    //   nameCompanyRef(CompanyController.to.getCompanyName(idCompanyRef.value));
    // });
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      //akunController.getListSurvey();
      await surveyController.getListSurvey();
      setState(() {
        ListSurvey(surveyController.ListSurvey);
        isLoading(false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: buildFloatingActionAdd(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: AppBar(
          title:
              Obx(() => Text("Survey (${surveyController.ListSurvey.length})")),
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
                        ListSurvey(surveyController.ListSurvey);
                      });
                      return;
                    }
                    ListSurvey.value = surveyController.ListSurvey.where((p0) =>
                        p0.title!.toLowerCase().contains(text.toLowerCase()) ||
                        p0.description!
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
                            ListSurvey(surveyController.ListSurvey);
                          });
                        },
                        icon: Icon(Icons.clear),
                      ),
                      hintText: 'Search..'),
                ),
              ),
            ),
          ),
        ),
        Obx(() => Container(
              child: SliverList(
                delegate: isLoading.value == false
                    ? BuilderListCard(ListSurvey.value)
                    : BuilderListSkeletonCard(),
              ),
            )),
      ],
    );
  }

  SliverChildBuilderDelegate BuilderListCard(List<Survey> _ListSurvey) {
    List<Survey> _listResult = _ListSurvey;
    return SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return Container(
            child: GFListTile(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            print("TAP LIST ${_listResult[index].id}");
            if (_listResult[index].id == 0) {
              Get.toNamed('/kelola-survey-draft', arguments: {
                "surveyID": _listResult[index].draftID,
                "isDraft": _listResult[index].isDraft,
                "itemSurvey": _listResult[index]
              });
            } else {
              surveyController.generatePreviewFormSurvey(
                  _listResult[index], false);
            }
          },
          title: Text(_listResult[index].title!,
              textScaleFactor: 1.1,
              style:
                  TextStyle(fontWeight: FontWeight.w600, color: GFColors.DARK)),
          description: Text(
            "${_listResult[index].description}",
            textScaleFactor: 0.96,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          margin: EdgeInsets.all(0),
          avatar: _listResult[index].isDraft == false
              ? Icon(
                  CupertinoIcons.checkmark_rectangle,
                  size: 25,
                )
              : Icon(
                  Icons.lock_clock,
                  size: 25,
                ),
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

  Padding buildFloatingActionAdd() {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Obx(() => Visibility(
              visible: authController.user.value.role == "superadmin" ||
                      authController.user.value.role == "admin"
                  ? true
                  : false,
              child: FloatingActionButton(
                heroTag: "float_survey",
                onPressed: () async {
                  showModalInitSurvey();
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

  void showModalInitSurvey() {
    final _titleController = TextEditingController();
    final _deskrispiController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    _titleController.text = "";
    _deskrispiController.text = "";

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
                      Text("Please Complete the Survey Information"),
                      SizedBox(height: 20.0),
                      TextFormField(
                          minLines: 1,
                          maxLines: 4,
                          controller: _titleController,
                          style: const TextStyle(fontSize: 13, height: 2),
                          decoration: const InputDecoration(
                              prefixIcon: Icon(CupertinoIcons.doc_plaintext),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              labelText: "Survey Name",
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                              labelStyle:
                                  TextStyle(color: Colors.grey, fontSize: 13),
                              border: OutlineInputBorder()),
                          autocorrect: false,
                          validator: (_val) {
                            if (_val == "") {
                              return 'Required!';
                            }
                            return null;
                          }),
                      SizedBox(height: 20.0),
                      TextFormField(
                          minLines: 1,
                          maxLines: 6,
                          controller: _deskrispiController,
                          style: const TextStyle(fontSize: 13, height: 2),
                          decoration: const InputDecoration(
                              prefixIcon: Icon(CupertinoIcons.info_circle),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              labelText: "Description",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              labelStyle:
                                  TextStyle(color: Colors.grey, fontSize: 13),
                              border: OutlineInputBorder()),
                          autocorrect: false,
                          validator: (_val) {
                            if (_val == "") {
                              return 'Required!';
                            }
                            return null;
                          }),
                      SizedBox(height: 30.0),
                      GFButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) {
                            GFToast.showToast(
                                'Sorry, Survey Information Not Complete!',
                                context,
                                trailing: const Icon(
                                  Icons.error_outline,
                                  color: GFColors.WARNING,
                                ),
                                toastPosition: GFToastPosition.BOTTOM,
                                toastBorderRadius: 5.0);
                            return;
                          }
                          String draftID =
                              "${surveyController.generateRandomString(10)}${DateTime.now().millisecondsSinceEpoch}";
                          var data = {
                            "id": 0,
                            "title": _titleController.text,
                            "description": _deskrispiController.text,
                            "draft": true,
                            "draftID": draftID,
                            "createBy": authController.user.value.uid
                          };
                          Navigator.pop(context);
                          SmartDialog.showLoading(
                              msg: "Creating Survey Forms...");
                          bool result = false;
                          await surveyController
                              .generateInitSurvey(draftID, data)
                              .then((value) => result = value);
                          SmartDialog.dismiss();
                          if (result == true) {
                            await surveyController.getListSurvey();
                            Get.toNamed('/kelola-survey-draft', arguments: {
                              "surveyID": draftID,
                              "isDraft": true,
                              "itemSurvey": Survey.fromMap(data)
                            });
                          } else {
                            GFToast.showToast(
                                'Failed to Create Survey Form!', context,
                                trailing: const Icon(
                                  Icons.error_outline,
                                  color: GFColors.WARNING,
                                ),
                                toastPosition: GFToastPosition.BOTTOM,
                                toastBorderRadius: 5.0);
                          }
                        },
                        blockButton: true,
                        icon: Icon(
                          CupertinoIcons.plus_app,
                          size: 16,
                          color: GFColors.WHITE,
                        ),
                        color: CupertinoColors.activeGreen,
                        text: "Create New Survey",
                      ),
                      SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ));
  }
}
