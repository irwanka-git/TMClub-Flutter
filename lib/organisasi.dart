import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/colors/gf_color.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:tmcapp/controller/AboutController.dart';

class OrganisasiScreen extends StatefulWidget {
  @override
  State<OrganisasiScreen> createState() => _OrganisasiScreenState();
}

class _OrganisasiScreenState extends State<OrganisasiScreen> {
  final imageList = <String>[].obs;
  final pageIndex = 0.obs;
  final onZooming = false.obs;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (var item in AboutController.to.currentAbout.value.organizations!) {
      imageList.add(item['image_url']);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                            return Center(
                              child: CircularProgressIndicator(
                                backgroundColor: GFColors.WARNING,
                                color: GFColors.WHITE,
                              ),
                            );
                          }
                          return child;
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
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
