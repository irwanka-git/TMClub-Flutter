import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/colors/gf_color.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PreviewGalleryScreen extends StatefulWidget {
  final int initialPage;
  final List<String> imageList;
  final List<String> titleList;
  @override
  // ignore: overridden_fields
  final Key key;

  const PreviewGalleryScreen({
    required this.key,
    required this.initialPage,
    required this.imageList,
    required this.titleList,
  }) : super(key: key);
  @override
  State<PreviewGalleryScreen> createState() => _PreviewGalleryState();
}

class _PreviewGalleryState extends State<PreviewGalleryScreen> {
  final pageIndex = 0.obs;
  final onZooming = false.obs;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final imageList = widget.imageList;
    final titleList = widget.titleList;
    pageIndex.value = widget.initialPage;
    var photoViewController = PhotoViewController();
    final pageController = PageController(initialPage: pageIndex.value);
    return Scaffold(
        appBar: AppBar(
          title: Obx(() => Text(
              "${(pageIndex.value + 1).toString()} of ${imageList.length.toString()}")),
          backgroundColor: GFColors.DARK,
          elevation: 0,
        ),
        body: PhotoViewGallery.builder(
          onPageChanged: ((index) {
            pageIndex.value = index;
          }),
          pageController: pageController,
          itemCount: imageList.length,
          scrollDirection: Axis.horizontal,
          scaleStateChangedCallback: (val) {
            if (val.isScaleStateZooming == true) {
              onZooming.value = true;
            } else {
              onZooming.value = false;
            }
          },
          builder: (context, index) {
            return PhotoViewGalleryPageOptions.customChild(
                controller: photoViewController,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        imageList[index],
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress != null) {
                            return Container(
                              decoration: BoxDecoration(color: GFColors.LIGHT),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  backgroundColor: GFColors.LIGHT,
                                  color: CupertinoColors.inactiveGray,
                                ),
                              ),
                            );
                          }
                          return child;
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Obx(() => Text(
                            onZooming.value == false
                                ? "${titleList[index]}"
                                : "",
                            style: TextStyle(color: GFColors.WHITE),
                          ))
                    ],
                  ),
                ),
                minScale: PhotoViewComputedScale.covered,
                maxScale: PhotoViewComputedScale.covered * 5,
                basePosition: Alignment.center,
                tightMode: true);
          },
          enableRotation: false,
        ));
  }
}
