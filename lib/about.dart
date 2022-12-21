import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:tmcapp/controller/AboutController.dart';
import 'package:tmcapp/controller/AppController.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/controller/BottomTabController.dart';
import 'package:flutter/material.dart';
import 'package:tmcapp/controller/EventController.dart';
import 'package:tmcapp/model/media.dart';
import 'package:tmcapp/model/resources.dart';
import 'package:tmcapp/preview-image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'controller/ImageController.dart';

class AboutScreen extends StatefulWidget {
  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final bottomTabControl = BottomTabController.to;
  final imageController = Get.put(ImageController());
  final aboutController = AboutController.to;
  late ScrollController _scrollController;
  final Color _foregroundColor = Colors.white;
  final htmlData = "".obs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      SmartDialog.showLoading(msg: "Loading..");
      await aboutController.getListAbout();
      htmlData.value = aboutController.currentAbout.value.description!;
      imageController.clearNewAlbum();
      for (var item in aboutController.currentAbout.value.organizations!) {
        //annualDirectoryController
        imageController.addItemNewAlbum(ImageMedia(
            pk: 0,
            display_name: item['display_name'],
            image: item['image_url']));
      }
      aboutController.clearItemAnnualDirectories();
      for (var item in aboutController.currentAbout.value.annualDirectories!) {
        //annualDirectoryController
        //print(item);
        aboutController.addItemAnnualDirectories(Resources(
            pk: 0, displayName: item['display_name'], url: item['url']));
      }
      SmartDialog.dismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: buildFloatingActionAdd(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: AppBar(
          titleSpacing: 0,
          title: Text(
            "About TMClub",
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: AppController.to.appBarColor.value,
          elevation: 1,
        ),
        backgroundColor: Colors.grey.shade50,
        body: aboutController.isLoading == true
            ? Container()
            : Container(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Obx(() => aboutController.currentAbout.value.id == 0
                      ? Container()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              aboutController.currentAbout.value.md!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Html(
                              data: htmlData.value,
                              style: {
                                "tr": Style(
                                    padding: EdgeInsets.all(4),
                                    border: Border.all(
                                        color: GFColors.DARK, width: 0.3))
                              },
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            const Text(
                              "Annual Directory",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            Obx(() => Container(
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: aboutController
                                          .annualdirectories.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return GFListTile(
                                          onTap: () {
                                            _launchInBrowser(Uri.parse(
                                                aboutController
                                                    .annualdirectories[index]
                                                    .url!));
                                          },
                                          title: Text(
                                              aboutController
                                                  .annualdirectories[index]
                                                  .displayName!,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: CupertinoColors.link)),
                                          subTitleText:
                                              "${aboutController.annualdirectories[index].url}",
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 8),
                                          margin: EdgeInsets.all(0),
                                          avatar: Icon(
                                            Icons.link_outlined,
                                            size: 20,
                                          ),
                                        );
                                      }),
                                )),
                            SizedBox(
                              height: 15,
                            ),
                            const Text(
                              "Organizational Structure",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Obx(() => Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(4)),
                                    border: Border.all(
                                        width: 1,
                                        color: CupertinoColors.systemGrey4),
                                    shape: BoxShape.rectangle,
                                  ),
                                  child: CarouselSlider(
                                    options: CarouselOptions(
                                      autoPlay: false,
                                      aspectRatio: 2,
                                      enableInfiniteScroll: false,
                                      enlargeCenterPage: true,
                                    ),
                                    items: imageController.newAlbum.value
                                        .map((item) => Container(
                                              child: InkWell(
                                                highlightColor: CupertinoColors
                                                    .darkBackgroundGray,
                                                onTap: () {
                                                  showMaterialModalBottomSheet<
                                                      String>(
                                                    expand: false,
                                                    context: context,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    builder: (context) =>
                                                        PreviewImageScreen(
                                                            item.image),
                                                  );
                                                },
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.all(3.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            3.0),
                                                    child: Stack(
                                                      children: <Widget>[
                                                        Image.network(
                                                          item.image,
                                                          fit: BoxFit.cover,
                                                          width: 1000,
                                                          loadingBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  Widget child,
                                                                  ImageChunkEvent?
                                                                      loadingProgress) {
                                                            if (loadingProgress !=
                                                                null) {
                                                              return Container(
                                                                decoration: BoxDecoration(
                                                                    color: GFColors
                                                                        .LIGHT),
                                                                child:
                                                                    const Center(
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    backgroundColor:
                                                                        GFColors
                                                                            .LIGHT,
                                                                    color: CupertinoColors
                                                                        .inactiveGray,
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                            return child;
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                )),
                                SizedBox(height: 10,)
                          ],
                        )),
                )));
  }

  Padding buildFloatingActionAdd() {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Obx(() => Visibility(
              visible: AuthController.to.user.value.role == "admin" ||
                      AuthController.to.user.value.role == "superadmin"
                  ? true
                  : false,
              child: FloatingActionButton(
                heroTag: "float_about",
                onPressed: () {
                  Get.offNamed('/about-edit');
                },
                backgroundColor: CupertinoColors.white,
                elevation: 6,
                child: const Icon(
                  Icons.edit,
                  color: CupertinoColors.activeGreen,
                  size: 26.0,
                ),
                mini: true,
              ),
            )));
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      print('Could not launch $url');
    }
  }
}
