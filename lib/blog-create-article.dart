import 'dart:io';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:tmcapp/controller/AppController.dart';
import 'package:tmcapp/controller/ImageController.dart';
import 'package:tmcapp/model/media.dart';
import 'package:tmcapp/preview-image.dart';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:tmcapp/widget/upload_image.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'controller/BlogController.dart';

class BlogCreateArticleScreen extends StatefulWidget {
  @override
  State<BlogCreateArticleScreen> createState() =>
      _BlogCreateArticleScreenState();
}

class _BlogCreateArticleScreenState extends State<BlogCreateArticleScreen> {
  final blogController = Get.put(BlogController());
  TextEditingController titleController = TextEditingController();
  TextEditingController summaryController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  final mainImageMedia = ImageMedia(pk: 0, display_name: "", image: "").obs;
  final imageController = Get.put(ImageController());
  final FocusScopeNode _nodeFocus = FocusScopeNode();

  @override
  void dispose() {
    _nodeFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    titleController.text = "";
    summaryController.text = "";
    contentController.text = "";
    imageController.resetUploadResult();
    imageController.clearNewAlbum();
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
          title: const Text("Create New Article"),
          backgroundColor: appBarColor,
          elevation: 1,
        ),
        backgroundColor: Theme.of(context).canvasColor,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
              child: Form(
            key: formKey,
            child: Column(
              children: [
                //title
                const Text("Please Fill in the following Blog/Article Form!"),
                const Divider(
                  color: CupertinoColors.separator,
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                    controller: titleController,
                    minLines: 2,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 13, height: 2),
                    decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        labelText: "Title",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        border: OutlineInputBorder()),
                    autocorrect: false,
                    validator: (_val) {
                      if (_val == "") {
                        return 'Required Filled!';
                      }
                      return null;
                    }),
                //summary
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                    controller: summaryController,
                    style: const TextStyle(fontSize: 13, height: 2),
                    decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                        labelText: "Summary",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        border: OutlineInputBorder()),
                    autocorrect: false,
                    validator: (_val) {
                      if (_val == "") {
                        return 'Required Filled!';
                      }
                      return null;
                    }),
                const SizedBox(height: 15),
                TextFormField(
                    controller: contentController,
                    maxLines: 10,
                    minLines: 2,
                    style: const TextStyle(fontSize: 13, height: 2),
                    decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                        labelText: "Content",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        border: OutlineInputBorder()),
                    autocorrect: false,
                    validator: (_val) {
                      if (_val == "") {
                        return 'Required Filled!';
                      }
                      return null;
                    }),
                const SizedBox(
                  height: 15,
                ),
                Obx(() => Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Thumbnail:"),
                          const SizedBox(
                            height: 8,
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4)),
                              border: Border.all(
                                  width: 1, color: CupertinoColors.systemGrey4),
                              shape: BoxShape.rectangle,
                            ),
                            child: Stack(children: <Widget>[
                              mainImageMedia.value.pk == 0
                                  ? Image.asset(
                                      "assets/images/image-placeholder.png",
                                      width: Get.width,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    )
                                  : InkWell(
                                      highlightColor:
                                          CupertinoColors.darkBackgroundGray,
                                      onLongPress: () {
                                        Get.defaultDialog(
                                            contentPadding:
                                                const EdgeInsets.all(20),
                                            title: "Confirmation",
                                            titlePadding: const EdgeInsets.only(
                                                top: 10, bottom: 0),
                                            middleText:
                                                "Are you sure you want to delete the image?",
                                            backgroundColor: CupertinoColors
                                                .darkBackgroundGray,
                                            titleStyle: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                            middleTextStyle: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14),
                                            textCancel: "Cancel",
                                            textConfirm: "Yes, Delete",
                                            cancelTextColor: Colors.white,
                                            confirmTextColor: Colors.white,
                                            buttonColor:
                                                CupertinoColors.activeOrange,
                                            onConfirm: () {
                                              mainImageMedia(ImageMedia(
                                                  pk: 0,
                                                  display_name: "",
                                                  image: ""));
                                              Navigator.pop(context);
                                            },
                                            radius: 0);
                                      },
                                      onTap: () {
                                        showMaterialModalBottomSheet<String>(
                                          expand: false,
                                          context: context,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) =>
                                              PreviewImageScreen(
                                                  mainImageMedia.value.image),
                                        );
                                      },
                                      child: Image.network(
                                        mainImageMedia.value.image,
                                        width: Get.width,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                            ]),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          GFButton(
                            onPressed: () {
                              getImage(ImageSource.gallery, "image_main");
                            },
                            color: GFColors.PRIMARY,
                            blockButton: true,
                            type: GFButtonType.outline,
                            icon: const Icon(
                              Icons.image,
                              size: 18,
                              color: GFColors.PRIMARY,
                            ),
                            text: "Upload Thumbnail",
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text("Album:"),
                          const SizedBox(
                            height: 6,
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
                                              onLongPress: () {
                                                Get.defaultDialog(
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            20),
                                                    title: "Confirmation",
                                                    titlePadding:
                                                        const EdgeInsets.only(
                                                            top: 10, bottom: 0),
                                                    middleText:
                                                        "Are you sure you want to delete the image?",
                                                    backgroundColor:
                                                        CupertinoColors
                                                            .darkBackgroundGray,
                                                    titleStyle: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16),
                                                    middleTextStyle:
                                                        const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14),
                                                    textCancel: "Cancel",
                                                    textConfirm: "Yes, Delete",
                                                    cancelTextColor:
                                                        Colors.white,
                                                    confirmTextColor:
                                                        Colors.white,
                                                    buttonColor: CupertinoColors
                                                        .activeOrange,
                                                    onConfirm: () {
                                                      int index =
                                                          imageController
                                                              .newAlbum.value
                                                              .indexOf(item);
                                                      imageController
                                                          .removeItemNewAlbumOnIndex(
                                                              index);
                                                      Navigator.pop(context);
                                                    },
                                                    radius: 0);
                                              },
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
                                                      ),
                                                      Positioned(
                                                        // The Positioned widget is used to position the text inside the Stack widget
                                                        bottom: 0,
                                                        child: Container(
                                                          // We use this Container to create a black box that wraps the white text so that the user can read the text even when the image is white
                                                          width: Get.width,
                                                          color: Colors.black54,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          child: Text(
                                                            "Picture (${imageController.newAlbum.value.indexOf(item) + 1})",
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 10),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              )),
                          GFButton(
                            onPressed: () {
                              getImage(ImageSource.gallery, "album_id");
                            },
                            color: GFColors.PRIMARY,
                            blockButton: true,
                            type: GFButtonType.outline,
                            icon: const Icon(
                              Icons.add_a_photo_outlined,
                              size: 18,
                              color: GFColors.PRIMARY,
                            ),
                            text: "Tambah Album",
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Divider(
                            color: CupertinoColors.separator,
                          ),
                          GFButton(
                            onPressed: () {
                              if (!formKey.currentState!.validate()) {
                                GFToast.showToast(
                                    'Incomplete Blog Filling!', context,
                                    trailing: const Icon(
                                      Icons.error_outline,
                                      color: GFColors.WARNING,
                                    ),
                                    toastBorderRadius: 5.0);
                              } else {
                                //_simpanProfilPengguna();
                                if (mainImageMedia.value.pk == 0) {
                                  GFToast.showToast(
                                      'Thumbnail Not Uploaded!', context,
                                      trailing: const Icon(
                                        Icons.error_outline,
                                        color: GFColors.WARNING,
                                      ),
                                      toastBorderRadius: 5.0);
                                } else {
                                  //sudah lengkap siap posting

                                  var albumId = [];
                                  for (var itemAlbum
                                      in imageController.newAlbum.value) {
                                    albumId.add(itemAlbum.pk);
                                  }
                                  var blogUpload = {
                                    "title": titleController.text.trim(),
                                    "summary":
                                        summaryController.text.toString(),
                                    "main_image": mainImageMedia.value.pk,
                                    "content": contentController.text.trim(),
                                    "youtube_id": "",
                                    "youtube_embeded": "",
                                    "albums_id": albumId
                                  };

                                  SmartDialog.showLoading(
                                      msg: "Submit Article...");
                                  blogController
                                      .postingCreateBlog(blogUpload)
                                      .then((value) => {
                                            SmartDialog.dismiss(),
                                            if (value == true)
                                              {
                                                GFToast.showToast(
                                                    'Article Submitted Successfully',
                                                    context,
                                                    trailing: const Icon(
                                                      Icons
                                                          .check_circle_outline,
                                                      color: GFColors.SUCCESS,
                                                    ),
                                                    toastDuration: 5,
                                                    toastBorderRadius: 5.0),
                                                blogController.getListBlog(),
                                                Navigator.pop(context)
                                              }
                                            else
                                              {
                                                Get.snackbar('Opps.',
                                                   "An error occurred, the article failed to submit",
                                                    snackPosition:
                                                        SnackPosition.BOTTOM,
                                                    backgroundColor:
                                                        CupertinoColors
                                                            .systemYellow,
                                                    colorText: Colors.black)
                                              }
                                          });
                                }
                              }
                            },
                            text: "Submit Article",
                            color: CupertinoColors.activeGreen,
                            blockButton: true,
                            icon: const Icon(
                              CupertinoIcons.paperplane,
                              color: GFColors.WHITE,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ))
              ],
            ),
          )),
        ));
  }

  getImage(ImageSource source, String destination) async {
    final ImagePicker _picker = ImagePicker();
    //File image = await  _picker.pickImage(source: source, );
    final XFile? image = await _picker.pickImage(
        source: source,
        maxHeight: 800,
        maxWidth: 800,
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
        future.then((void value) => {
              if (destination == "image_main")
                {
                  if (imageController.uploadResult.value.pk > 0)
                    {
                      mainImageMedia(imageController.uploadResult.value),
                      imageController.resetUploadResult()
                    },
                },
              if (destination == "album_id")
                {
                  if (imageController.uploadResult.value.pk > 0)
                    {
                      imageController
                          .addItemNewAlbum(imageController.uploadResult.value),
                      imageController.resetUploadResult()
                    },
                }
            });
      }

      _showModal();
    }
  }
}
