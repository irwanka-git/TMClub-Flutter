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
import 'package:tmcapp/client.dart';
import 'package:tmcapp/controller/AppController.dart';
import 'package:tmcapp/controller/ImageController.dart';
import 'package:tmcapp/model/media.dart';
import 'package:tmcapp/preview-image.dart';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:tmcapp/widget/upload_image.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'controller/BlogController.dart';
import 'model/blog.dart';

class BlogEditArticleScreen extends StatefulWidget {
  @override
  State<BlogEditArticleScreen> createState() => _BlogEditArticleScreenState();
}

class _BlogEditArticleScreenState extends State<BlogEditArticleScreen> {
  final blogController = Get.put(BlogController());
  TextEditingController titleController = TextEditingController();
  TextEditingController summaryController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TextEditingController youtubeController = TextEditingController();
  final mainImageMedia = ImageMedia(pk: 0, display_name: "", image: "").obs;
  final imageController = Get.put(ImageController());
  final validYoutubdID = false.obs;
  final _youtubdID = "".obs;
  final FocusScopeNode _nodeFocus = FocusScopeNode();
  final String base_url = ApiClient().base_url;
  late BlogItemDetil blogEdit;

  @override
  void dispose() {
    _nodeFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    blogEdit = Get.arguments['blog'];
    titleController.text = blogEdit.title;
    summaryController.text = blogEdit.summary;
    contentController.text = blogEdit.content;
    youtubeController.text = "";
    if (blogEdit.youtube_id != "") {
      setState(() {
        _youtubdID.value = blogEdit.youtube_id;
        validYoutubdID.value = true;
      });
    }
    if (blogEdit.main_image > 0) {
      setState(() {
        mainImageMedia.value = ImageMedia(
            pk: blogEdit.main_image,
            display_name: "",
            image: base_url + blogEdit.main_image_url);
      });
    }

    imageController.clearNewAlbum();
    if (blogEdit.albums_url.isNotEmpty) {
      for (var idx in blogEdit.albums_id) {
        int index = blogEdit.albums_id.indexOf(idx);
        String imgx = blogEdit.albums_url[index];
        ImageMedia itemAlbum = ImageMedia(
            pk: idx,
            display_name: "Picture (${index + 1})",
            image: base_url + imgx);
        imageController.addItemNewAlbum(itemAlbum);
      }
    }
    imageController.resetUploadResult();
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
          title: Text("Edit Blog"),
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
                      if (validYoutubdID.value == true) {
                        return null;
                      }
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
                                    ),
                            ]),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          GFButton(
                            onPressed: () {
                              getImage(ImageSource.gallery, "image_main");
                            },
                            color: GFColors.DARK,
                            blockButton: true,
                            type: GFButtonType.outline,
                            icon: const Icon(
                              Icons.image,
                              size: 18,
                              color: GFColors.DARK,
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
                                                        loadingBuilder:
                                                            (BuildContext
                                                                    context,
                                                                Widget child,
                                                                ImageChunkEvent?
                                                                    loadingProgress) {
                                                          if (loadingProgress !=
                                                              null) {
                                                            return Container(
                                                              decoration:
                                                                  BoxDecoration(
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
                            color: GFColors.DARK,
                            type: GFButtonType.outline,
                            blockButton: true,
                            icon: const Icon(
                              Icons.add_a_photo_outlined,
                              size: 18,
                              color: GFColors.DARK,
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
                                    'Incomplete Article Filling!', context,
                                    trailing: const Icon(
                                      Icons.error_outline,
                                      color: GFColors.WARNING,
                                    ),
                                    toastBorderRadius: 5.0);
                              } else {
                                //_simpanProfilPengguna();
                                if (mainImageMedia.value.pk == 0 &&
                                    validYoutubdID.value == false) {
                                  GFToast.showToast(
                                      'Thumbnail Not Uploaded!', context,
                                      trailing: const Icon(
                                        Icons.error_outline,
                                        color: GFColors.WARNING,
                                      ),
                                      toastBorderRadius: 5.0);
                                } else {
                                  //sudah lengkap siap posting
                                  var youtubeId = validYoutubdID.value
                                      ? _youtubdID.value
                                      : "";
                                  var youtubeEmbeded = validYoutubdID.value
                                      ? blogController.generateYoutubeEmbed(
                                          _youtubdID.value)
                                      : "";
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
                                    "youtube_id": youtubeId,
                                    "youtube_embeded": youtubeEmbeded,
                                    "albums_id": albumId
                                  };

                                  SmartDialog.showLoading(
                                      msg: "Article Updates...");
                                  blogController
                                      .updateBlog(blogUpload, blogEdit.pk)
                                      .then((value) => {
                                            SmartDialog.dismiss(),
                                            if (value == true)
                                              {
                                                GFToast.showToast(
                                                    'Article Updated Successfully',
                                                    context,
                                                    trailing: const Icon(
                                                      Icons
                                                          .check_circle_outline,
                                                      color: GFColors.SUCCESS,
                                                    ),
                                                    toastDuration: 5,
                                                    toastBorderRadius: 5.0),
                                                Navigator.pop(context),
                                                blogController.getListBlog()
                                              }
                                            else
                                              {
                                                GFToast.showToast(
                                                    'Opps.. An error has occurred Article failed to save',
                                                    context,
                                                    trailing: const Icon(
                                                      Icons.dangerous,
                                                      color: GFColors.WHITE,
                                                    ),
                                                    backgroundColor:
                                                        GFColors.DANGER,
                                                    toastDuration: 5,
                                                    toastBorderRadius: 5.0),
                                              }
                                          });
                                }
                              }
                            },
                            text: "Save Article",
                            color: CupertinoColors.systemGreen,
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
