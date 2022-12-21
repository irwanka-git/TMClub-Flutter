import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PreviewImageScreen extends StatefulWidget {
  final String refImage;
  @override
  const PreviewImageScreen(this.refImage);
  @override
  State<PreviewImageScreen> createState() => _PreviewImageScreen();
}

class _PreviewImageScreen extends State<PreviewImageScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leadingWidth: 40,
          titleSpacing: 10,
          title: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: Get.width - 160,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "View Image",
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          backgroundColor: CupertinoColors.darkBackgroundGray,
          elevation: 0,
        ),
        backgroundColor: CupertinoColors.darkBackgroundGray,
        body: Container(
          height: Get.height,
          margin: const EdgeInsets.all(0),
          width: Get.width,
          child: PhotoViewGallery.builder(
            itemCount: 1,
            scrollDirection: Axis.horizontal,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions.customChild(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              widget.refImage,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  heroAttributes: const PhotoViewHeroAttributes(
                    tag: "someTag",
                    transitionOnUserGestures: true,
                  ),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 5,
                  basePosition: Alignment.center,
                  tightMode: true);
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(
              color: CupertinoColors.darkBackgroundGray,
            ),
            enableRotation: false,
            loadingBuilder: (context, event) => Center(
              child: Container(
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
        ));
  }
}
