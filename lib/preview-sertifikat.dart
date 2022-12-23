import 'dart:io';
import 'dart:typed_data';
import 'package:external_path/external_path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/colors/gf_color.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:getwidget/position/gf_toast_position.dart';
import 'package:getwidget/types/gf_button_type.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'dart:math';
import 'package:tmcapp/controller/AuthController.dart';

class PreviewSertifikatScreen extends StatefulWidget {
  final Uint8List refImage;
  final int id_event;
  @override
  const PreviewSertifikatScreen(this.refImage, this.id_event);
  @override
  State<PreviewSertifikatScreen> createState() => _PreviewSertifikatScreen();
}

class _PreviewSertifikatScreen extends State<PreviewSertifikatScreen> {
  final onZooming = false.obs;
  final authcontroller = AuthController.to;
  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();
    final info = statuses[Permission.storage].toString();
    print(info);
  }

  Future<void> openFile(String filePath) async {
    final _result = await OpenFile.open(filePath);
    print(_result.message);
  }

  @override
  Widget build(BuildContext context) {
    var photoViewController = PhotoViewController();
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
                        "Certificate",
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
                    padding: const EdgeInsets.all(15),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.memory(
                              widget.refImage,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Obx(() => onZooming.value == false
                                ? GFButton(
                                    onPressed: () async {
                                      String path_download = '';
                                      if (Platform.isIOS) {
                                        Directory appDocDir =
                                            await getApplicationDocumentsDirectory();
                                        path_download = appDocDir.path;
                                      } else {
                                        path_download = await ExternalPath
                                            .getExternalStoragePublicDirectory(
                                                ExternalPath
                                                    .DIRECTORY_DOWNLOADS);
                                      }

                                      Random random = Random();
                                      int _randomNumber12 =
                                          1000 + random.nextInt(8000);

                                      // This is the saved image path
                                      // You can use it to display the saved image later
                                      final downloadPathImage = path.join(
                                          path_download,
                                          "SERFITIKAT-${_randomNumber12.toString()}${authcontroller.user.value.displayName.replaceAll(" ", "")}-${widget.id_event}.png");

                                      // Downloading
                                      final imageFile = File(downloadPathImage);
                                      String savePath = "";
                                      await imageFile
                                          .writeAsBytes(widget.refImage)
                                          .then(
                                              (value) => savePath = value.path);

                                      if (savePath != "") {
                                        GFToast.showToast(
                                            'Download Certificate Success',
                                            context,
                                            trailing: const Icon(
                                              Icons.check_circle_outline,
                                              color: GFColors.SUCCESS,
                                            ),
                                            toastDuration: 3,
                                            toastPosition:
                                                GFToastPosition.BOTTOM,
                                            toastBorderRadius: 5.0);
                                        openFile(savePath);
                                      }
                                    },
                                    blockButton: true,
                                    type: GFButtonType.outline,
                                    color: GFColors.WHITE,
                                    textColor: GFColors.WHITE,
                                    text: "Simpan Sertifikat",
                                    icon: Icon(
                                      Icons.save,
                                      size: 16,
                                      color: GFColors.WHITE,
                                    ),
                                  )
                                : Container())
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
