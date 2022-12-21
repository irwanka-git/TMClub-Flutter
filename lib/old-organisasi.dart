import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class OrganisasiScreen extends StatefulWidget {
  @override
  State<OrganisasiScreen> createState() => _OrganisasiScreenState();
}

class _OrganisasiScreenState extends State<OrganisasiScreen> {
  final organisasi_image_url1 =
      "https://storage.googleapis.com/glide-prod.appspot.com/uploads-v2/wACSf46UPaqe76K61UYL/pub/JLPiXByYroOIYEvRC0xM.png";
  final organisasi_image_url2 =
      "https://storage.googleapis.com/glide-prod.appspot.com/uploads-v2/wACSf46UPaqe76K61UYL/pub/Ow37LpSirRXiS6CIIgkM.png";

  final imageList = [
    "https://storage.googleapis.com/glide-prod.appspot.com/uploads-v2/wACSf46UPaqe76K61UYL/pub/JLPiXByYroOIYEvRC0xM.png",
    "https://storage.googleapis.com/glide-prod.appspot.com/uploads-v2/wACSf46UPaqe76K61UYL/pub/Ow37LpSirRXiS6CIIgkM.png",
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Organisasi"),
          backgroundColor: CupertinoColors.activeOrange,
          elevation: 1,
        ),
        backgroundColor: Theme.of(context).canvasColor,
        body: Container(
          height: Get.height,
          margin: const EdgeInsets.all(0),
          width: Get.width,
          child: PhotoViewGallery.builder(
            itemCount: imageList.length,
            scrollDirection: Axis.horizontal,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions.customChild(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    child: Image.network(
                      imageList[index],
                    ),
                  ),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 5,
                  basePosition: Alignment.center,
                  tightMode: true);
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: Theme.of(context).canvasColor,
            ),
            enableRotation: false,
            loadingBuilder: (context, event) => const Center(
              child: SizedBox(
                width: 30.0,
                height: 30.0,
                child: CircularProgressIndicator(
                  backgroundColor: CupertinoColors.activeOrange,
                ),
              ),
            ),
          ),
        ));
  }
}
