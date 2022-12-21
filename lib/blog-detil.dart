import 'package:flutter/cupertino.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:tmcapp/client.dart';
import 'package:tmcapp/controller/AppController.dart';
import 'package:tmcapp/preview-image.dart';
import 'package:tmcapp/widget/preview_gallery.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'controller/BlogController.dart';
import 'model/blog.dart';

class BlogDetilScreen extends StatefulWidget {
  @override
  State<BlogDetilScreen> createState() => _BlogDetilScreenState();
}

class _BlogDetilScreenState extends State<BlogDetilScreen> {
  final blogController = Get.put(BlogController());
  final FocusScopeNode _nodeFocus = FocusScopeNode();
  late BlogItemDetil item;
  List<String> listImage = [];
  List<String> listTitleImage = [];

  @override
  void dispose() {
    _nodeFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    item = Get.arguments['blog'];
    // TODO: implement initState
    if (item.albums_url.isNotEmpty) {
      for (var image in item.albums_url) {
        listImage.add(ApiClient().base_url + image.toString());
        listTitleImage.add("");
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    //print(blogController.getYoutubeVideoId("https://youtu.be/GjI0GSvmcSU"));
    YoutubePlayerController _youtubePlayercontroller;
    Color appBarColor = AppController.to.appBarColor.value;
    return Scaffold(
        appBar: AppBar(
          title: Text(item.title),
          backgroundColor: appBarColor,
          elevation: 1,
        ),
        backgroundColor: CupertinoColors.systemBackground,
        body: Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(item.summary),
              const SizedBox(
                height: 15,
              ),
              item.youtube_id != ""
                  ? Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: YoutubePlayerIFrame(
                        controller: YoutubePlayerController(
                          initialVideoId: item.youtube_id,
                          params: const YoutubePlayerParams(
                            showControls: true,
                            enableCaption: false,
                            autoPlay: false,
                            mute: true,
                            showVideoAnnotations: false,
                            showFullscreenButton: true,
                          ),
                        ),
                      ),
                    )
                  : Container(),
              item.youtube_id == ""
                  ? InkWell(
                      onTap: () {
                        showMaterialModalBottomSheet<String>(
                          expand: false,
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => PreviewImageScreen(
                              ApiClient().base_url + item.main_image_url),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4)),
                          border: Border.all(
                              width: 1, color: CupertinoColors.systemGrey4),
                          shape: BoxShape.rectangle,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3.0),
                          child: Stack(
                            children: <Widget>[
                              Image.network(
                                ApiClient().base_url + item.main_image_url,
                                fit: BoxFit.cover,
                                width: Get.width,
                                height: 200,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container(),
              SizedBox(
                height: item.youtube_id != "" ? 0 : 15,
              ),
              //Text(item.content),
              SelectableLinkify(
                textScaleFactor: 1.0,
                linkStyle: const TextStyle(decoration: TextDecoration.none),
                style:
                    const TextStyle(color: CupertinoColors.label, fontSize: 15),
                onOpen: (link) => {_launchInBrowser(Uri.parse(link.url))},
                text: item.content,
                options: const LinkifyOptions(humanize: false),
              ),
              const SizedBox(
                height: 15,
              ),
              listImage.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          "Gallery Photo: ",
                          textScaleFactor: 1,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        GFCarousel(
                          enableInfiniteScroll: false,
                          enlargeMainPage: true,
                          viewportFraction: 1.0,
                          items: listImage.map(
                            (image) {
                              //print(item.albums_url.indexOf(image));
                              return Container(
                                margin: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    showMaterialModalBottomSheet<String>(
                                      expand: false,
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) =>
                                          PreviewGalleryScreen(
                                              key: UniqueKey(),
                                              initialPage:
                                                  listImage.indexOf(image),
                                              imageList: listImage,
                                              titleList: listTitleImage),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(3.0)),
                                    child: Image.network(image, loadingBuilder:
                                        (BuildContext context, Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress != null) {
                                        return Container(
                                          decoration: BoxDecoration(
                                              color: GFColors.LIGHT),
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              backgroundColor: GFColors.WHITE,
                                              color: GFColors.PRIMARY,
                                            ),
                                          ),
                                        );
                                      }
                                      return child;
                                    }, fit: BoxFit.cover, width: 1000.0),
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                          onPageChanged: (index) {
                            setState(() {
                              index;
                            });
                          },
                        ),
                      ],
                    )
                  : Container()
            ],
          )),
        ));
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
