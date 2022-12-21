import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';
import 'package:tmcapp/controller/AppController.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/controller/EventController.dart';
import 'package:tmcapp/controller/ImageController.dart';
import 'package:tmcapp/model/event_tmc_detil.dart';
import 'package:tmcapp/model/media.dart';
import 'package:path/path.dart';
import 'package:tmcapp/widget/preview_gallery.dart';
import 'package:tmcapp/widget/upload_image.dart';

class EventDetilGalleryScreen extends StatefulWidget {
  @override
  State<EventDetilGalleryScreen> createState() =>
      _EventDetilGalleryScreenState();
}

class _EventDetilGalleryScreenState extends State<EventDetilGalleryScreen> {
  final authController = AuthController.to;
  //final AkunController akunController = AkunController.to;
  final EventController eventController = EventController.to;
  var ListImage = <ImageMedia>[].obs;
  var isLoading = true.obs;
  var searchTextFocus = false.obs;
  final itemAcara = EventTmcDetil(pk: 0).obs;
  final imageController = ImageController.to;

  Future<void> getListImageGallery() async {
    //isLoading.value  = true;
    isLoading.value = true;
    await eventController
        .getListImageGallery(itemAcara.value.pk!)
        .then((value) {
      if (value.isNotEmpty) {
        ListImage.clear();
      }
      for (var itemMedia in value) {
        ListImage.add(itemMedia);
      }
    });

    //isLoading.value  = false;
    return;
  }

  void _onRefresh() async {
    // monitor network fetch
    //await CompanyController.to.getListCompany();
    await getListImageGallery();
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
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

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    setState(() {
      itemAcara(Get.arguments['event']);
    });
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      //companyController.getListCompany();
      await getListImageGallery();
      isLoading.value = false;
    });
    super.initState();
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
                          "Gallery Photo (${ListImage.value.length})",
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

  Widget BuildListBody() {
    return Container(
      child: Obx(() => Container(
            width: Get.width,
            //height: double.infinity,
            padding: EdgeInsets.all(10),
            child: isLoading.value == false
                ? GridView.builder(
                    reverse: false,
                    scrollDirection: Axis.vertical,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3),
                    itemBuilder: (_, index) => buildImageCard(ListImage[index]),
                    itemCount: ListImage.length,
                  )
                : GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3),
                    itemBuilder: (_, index) => buildLoadingCard(),
                    itemCount: 3,
                  ),
          )),
    );
  }

  Widget buildImageCard(ImageMedia item) {
    return InkWell(
      onTap: () {
        showMaterialModalBottomSheet<String>(
          expand: false,
          context: Get.context!,
          backgroundColor: Colors.transparent,
          builder: (context) => PreviewGalleryScreen(
              key: UniqueKey(),
              initialPage: ListImage.indexOf(item),
              imageList: ListImage.map((element) => element.image).toList(),
              titleList:
                  ListImage.map((element) => element.display_name).toList()),
        );
      },
      onLongPress: () {
        authController.user.value.role == "admin"
            ? showKonfirmDelete(item)
            : null;
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(2.0),
            child: Image.network(item.image,
                width: double.infinity,
                fit: BoxFit.cover, loadingBuilder: (BuildContext context,
                    Widget child, ImageChunkEvent? loadingProgress) {
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
            })),
      ),
    );
  }

  Widget buildLoadingCard() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: SkeletonAvatar(
        style: SkeletonAvatarStyle(
            shape: BoxShape.rectangle,
            width: Get.width / 3,
            height: Get.width / 3),
      ),
    );
  }

  Visibility buildFloatingActionAdd() {
    return Visibility(
      visible: authController.user.value.role == "admin" ? true : false,
      child: Wrap(
          direction: Axis.horizontal, //use vertical to show  on vertical axis
          children: [
            Container(
                margin: EdgeInsets.all(5),
                child: FloatingActionButton(
                  mini: true,
                  heroTag: "float_gallery",
                  onPressed: () async {
                    //action code for button 2
                    await getImage(ImageSource.gallery);
                  },
                  backgroundColor: CupertinoColors.activeOrange,
                  child: Icon(Icons.image),
                )),
            Container(
                margin: EdgeInsets.all(5),
                child: FloatingActionButton(
                  mini: true,
                  heroTag: "float_camera",
                  onPressed: () async {
                    //action code for button 2
                    await getImage(ImageSource.camera);
                  },
                  backgroundColor: CupertinoColors.activeBlue,
                  child: Icon(Icons.camera_alt),
                ))
          ]),
    );
  }

  getImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    //File image = await  _picker.pickImage(source: source, );
    final XFile? image = await _picker.pickImage(
        source: source,
        maxHeight: 1000,
        maxWidth: 1000,
        preferredCameraDevice: CameraDevice.rear);
    if (image != null) {
      //Navigator.pop(context);
      var _tempPath = image.path; //File(image!.path);
      print("PATH GAMBARNYA $_tempPath");
      List<int> imageBytes = File(_tempPath).readAsBytesSync();
      String baseimage = base64Encode(imageBytes);
      var _extension =
          extension(_tempPath).replaceAll(".", "") == "png" ? "png" : "jpeg";
      String base64ImageRender = baseimage;
      String base64ImageUpload =
          "data:image/$_extension;base64,$base64ImageRender";
      //print(base64Image.length);
      Uint8List bytes = const Base64Codec().decode(base64ImageRender);
      imageController
          .setUploadResult(ImageMedia(pk: 0, display_name: "", image: ""));
      void _showModal() {
        Future<void> future = showMaterialModalBottomSheet(
          expand: false,
          context: this.context,
          backgroundColor: Colors.transparent,
          builder: (context) => SingleChildScrollView(
              child: Container(
            child: ImageUploaderBase64(
              key: UniqueKey(),
              base64ImageRender: base64ImageRender,
              base64ImageUpload: base64ImageUpload,
            ),
          )),
        );
        future.then((void value) async {
          ImageMedia resultImage = imageController.getUploadResult();
          //ListImage.add(resultImage);
          if (resultImage.pk == 0) {
            return;
          }
          var media_id = <int>[];
          for (var n in ListImage) {
            media_id.add(n.pk);
          }
          media_id.add(resultImage.pk);
          var data_upload = {"media_id": media_id};
          bool berhasil = false;
          SmartDialog.showLoading(msg: "Updates Gallery...");
          await eventController
              .submitGalleryEvent(itemAcara.value.pk!, data_upload)
              .then((value) {
            berhasil = value;
          });
          if (berhasil == true) {
            ListImage.add(ImageMedia(
                pk: resultImage.pk,
                display_name: "",
                image: resultImage.image));
            GFToast.showToast(
                'Success Add Photo!', Get.context!,
                trailing: const Icon(
                  Icons.check_circle,
                  color: GFColors.SUCCESS,
                ),
                toastPosition: GFToastPosition.TOP,
                toastBorderRadius: 5.0);
          } else {
            GFToast.showToast(
                'Failed!', Get.context!,
                trailing: const Icon(
                  Icons.error_outline,
                  color: GFColors.DANGER,
                ),
                toastPosition: GFToastPosition.TOP,
                toastBorderRadius: 5.0);
          }
          SmartDialog.dismiss();
        });
      }

      _showModal();
    }
  }

  void showKonfirmDelete(ImageMedia item) async {
    await Get.defaultDialog(
        contentPadding: const EdgeInsets.all(20),
        title: "Confirmation",
        titlePadding: const EdgeInsets.only(top: 10, bottom: 0),
        middleText: "Are you sure you want to delete this image?",
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
          SmartDialog.showLoading(msg: "Delete Image...");
          var media_id = <int>[];
          for (var n in ListImage) {
            media_id.add(n.pk);
          }
          media_id.remove(item.pk);
          var data_upload = {"media_id": media_id};
          bool berhasil = false;
          //SmartDialog.showLoading(msg: "Perbarui Gallery...");
          await eventController
              .submitGalleryEvent(itemAcara.value.pk!, data_upload)
              .then((value) {
            berhasil = value;
          });

          SmartDialog.dismiss();
          if (berhasil == true) {
            //getDataResource();
            int indexHapus =
                ListImage.indexWhere((element) => element.pk == item.pk);
            if (indexHapus > -1) {
              ListImage.removeAt(indexHapus);
            }
            GFToast.showToast('Gambar Berhasil Dihapus!', Get.context!,
                trailing: const Icon(
                  Icons.check_circle,
                  color: GFColors.SUCCESS,
                ),
                toastPosition: GFToastPosition.BOTTOM,
                toastBorderRadius: 5.0);
          } else {
            GFToast.showToast('Gagal Hapus Gambar!', Get.context!,
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
