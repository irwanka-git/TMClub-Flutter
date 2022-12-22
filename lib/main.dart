import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:tmcapp/about.dart';
import 'package:tmcapp/about_edit.dart';
import 'package:tmcapp/akun_member.dart';
import 'package:tmcapp/akun_member_detil.dart';
import 'package:tmcapp/akun_pic.dart';
import 'package:tmcapp/akun_pic_detil.dart';
import 'package:tmcapp/blog-create-article.dart';
import 'package:tmcapp/blog-create-youtube.dart';
import 'package:tmcapp/blog-edit-youtube.dart';
import 'package:tmcapp/controller/AboutController.dart';
import 'package:tmcapp/controller/AkunController.dart';
import 'package:tmcapp/controller/AppController.dart';
import 'package:tmcapp/controller/InvoiceController.dart';
import 'package:tmcapp/controller/NotifikasiController.dart';
import 'package:tmcapp/controller/SearchController.dart';
import 'package:tmcapp/controller/SurveyController.dart';
import 'package:tmcapp/event-create.dart';
import 'package:tmcapp/event-detil-daftar-peserta.dart';
import 'package:tmcapp/event-detil-gallery.dart';
import 'package:tmcapp/event-detil-invoice.dart';
import 'package:tmcapp/event-detil-registrasi-pic.dart';
import 'package:tmcapp/event-detil-survey.dart';
import 'package:tmcapp/event-detil.dart';
import 'package:tmcapp/event-edit.dart';
import 'package:tmcapp/event-me.dart';
import 'package:tmcapp/invoice-list-detil.dart';
import 'package:tmcapp/invoice_detil.dart';
import 'package:tmcapp/kelola-survey-input.dart';
import 'package:tmcapp/kelola-survey-preview.dart';
import 'package:tmcapp/kelola-survey-result.dart';
import 'package:tmcapp/kelola-survey-send.dart';
import 'package:tmcapp/model/survey.dart';
import 'package:tmcapp/nav-drawer.dart';
import 'package:tmcapp/profil-saya.dart';
import 'package:tmcapp/search.dart';
import 'akun_admin.dart';
import 'blog-create.dart';
import 'blog-detil.dart';
import 'blog-edit-article.dart';
import 'bottomtab.dart';
import 'chat-detil.dart';
import 'chat-user.dart';
import 'controller/AuthController.dart';
import 'controller/BlogController.dart';
import 'controller/BottomTabController.dart';
import 'controller/ChatController.dart';
import 'controller/CompanyController.dart';
import 'controller/EventController.dart';
import 'controller/ImageController.dart';
import 'daftar_company.dart';
import 'event-detil-resources.dart';
import 'invoice-list.dart';
import 'kelola-survey-draft.dart';
import 'kelola-survey.dart';
import 'organisasi.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    print("Load Controller");
    Get.put<AppController>(AppController());
    Get.put<BottomTabController>(BottomTabController());
    Get.put<AuthController>(AuthController());
    Get.put<CompanyController>(CompanyController());
    Get.put<BlogController>(BlogController());
    Get.put<ImageController>(ImageController());
    Get.put<EventController>(EventController());
    Get.put<ChatController>(ChatController());
    Get.put<AkunController>(AkunController());
    Get.put<SurveyController>(SurveyController());
    Get.put<NotifikasiController>(NotifikasiController());
    Get.put<InvoiceController>(InvoiceController());
    Get.put<AboutController>(AboutController());
    //fungsi awal
    print("Selesai Loading Semua Controller");
  }
}

void main() async {
  const oneSec = Duration(seconds: 30);
  Timer.periodic(oneSec, (Timer timer) async {
    // This statement will be printed after every one second
    NotifikasiController.to.getNotifikasiCountUnreadSurvey();
  });

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  ControllerBinding().dependencies();
  //await initializeDateFormatting('id_ID', null);
  runApp(GetMaterialApp(
    navigatorKey: navigatorKey,
    title: "TMC Event",
    navigatorObservers: [FlutterSmartDialog.observer],
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    localizationsDelegates: const [
      GlobalWidgetsLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    builder: FlutterSmartDialog.init(),
    getPages: [
      GetPage(
          name: '/',
          page: () => CreateNavigationDrawer(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/about',
          page: () => AboutScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/about-edit',
          page: () => AboutEditScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/organisasi',
          page: () => OrganisasiScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/detil-blog',
          page: () => BlogDetilScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/blog-edit-youtube',
          page: () => BlogEditYoutubeScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/blog-edit-article',
          page: () => BlogEditArticleScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/blog-create-youtube',
          page: () => BlogCreateYoutubeScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/blog-create-article',
          page: () => BlogCreateArticleScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/event-create',
          page: () => EventCreateScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/event-edit',
          page: () => EventEditScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/event-me',
          page: () => EventMeScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/event-detil',
          page: () => EventDetilScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/event-detil-registrasi-pic',
          page: () => EventDetilRegistrasiPICScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/event-detil-invoice',
          page: () => EventDetilInvoicePICScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/event-detil-daftar-peserta',
          page: () => EventDetilDaftarPesertaScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/event-detil-resources',
          page: () => EventDetilResourcesScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/event-detil-survey',
          page: () => EventDetilSurveyScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/event-result-survey',
          page: () => KelolaSurveyResultScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/event-detil-gallery',
          page: () => EventDetilGalleryScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/detil-chat',
          page: () => DetilChatScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/user-chat',
          page: () => UserChatScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/profil-saya',
          page: () => ProfilSayaScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/daftar-company',
          page: () => KelolaCompanyScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/akun-admin',
          page: () => KelolaAdminScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/akun-pic',
          page: () => KelolaPICDetilScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/akun-member',
          page: () => KelolaMemberScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/invoice',
          page: () => InvoiceListScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/invoice-detil',
          page: () => InvoiceDetilScreenView(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/kelola-survey',
          page: () => KelolaSurveyScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/kelola-survey-draft',
          page: () => KelolaSurveyDraftScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/kelola-survey-preview',
          page: () => KelolaSurveyPreviewScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/kelola-survey-input',
          page: () => KelolaSurveyJawabScreen(),
          transition: Transition.fadeIn),
      GetPage(
          name: '/kelola-survey-send',
          page: () => KelolaSurveySendScreen(),
          transition: Transition.fadeIn),
    ],
  ));
}

class CreateNavigationDrawer extends StatelessWidget {
  final appController = Get.put(AppController());
  final authController = Get.put(AuthController());
  final tabControl = Get.put(BottomTabController());
  final blogController = Get.put(BlogController());
  final companyController = Get.put(CompanyController());
  final chatController = Get.put(ChatController());
  final imageController = Get.put(ImageController());
  final eventController = Get.put(EventController());
  final searchController = Get.put(SearchController());
  final akunController = Get.put(AkunController());
  final surveyController = Get.put(SurveyController());
  final notifikasiController = Get.put(NotifikasiController());
  final invoiceController = Get.put(InvoiceController());
  final aboutController = Get.put(AboutController());

  @override
  Widget build(BuildContext context) {
    print("Loading Controller");
    final GlobalKey<ScaffoldState> _scaffoldKey =
        new GlobalKey<ScaffoldState>();
    String AppTitle = "Toyota Manufacturer Club (TMClub)";

    return GetX<AppController>(
      init: AppController(),
      initState: (_) {},
      builder: (_) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: GFAppBar(
            elevation: 1,
            centerTitle: true,
            searchBar: false,
            backgroundColor: appController.appBarColor.value,
            searchBarColorTheme: CupertinoColors.white,
            actions: [
              Obx(() => searchController.isActive.value
                  ? GFIconButton(
                      icon: Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      onPressed: () async => {
                        showSearch(
                            context: context,
                            // delegate to customize the search bar
                            delegate: CustomSearchDelegate(
                                lookupController: searchController))
                      },
                      type: GFButtonType.transparent,
                    )
                  : Container())
            ],
            leading: GFIconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () => _scaffoldKey.currentState!.openDrawer(),
              type: GFButtonType.transparent,
            ),
            title: Text(
              AppTitle,
              style: TextStyle(fontSize: 18),
            ),
          ),
          drawer: DrawerWidget(),
          body: BottomTabScreen(),
        );
      },
    );
  }
}
