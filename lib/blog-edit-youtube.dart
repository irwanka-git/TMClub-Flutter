import 'dart:io';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:tmcapp/controller/AppController.dart';
import 'package:tmcapp/controller/ImageController.dart';
import 'package:tmcapp/model/blog.dart';
import 'package:tmcapp/model/media.dart';
import 'package:tmcapp/preview-image.dart';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:tmcapp/widget/upload_image.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'controller/BlogController.dart';

class BlogEditYoutubeScreen extends StatefulWidget {
  @override
  State<BlogEditYoutubeScreen> createState() => _BlogEditYoutubeScreenState();
}

class _BlogEditYoutubeScreenState extends State<BlogEditYoutubeScreen> {
  final blogController = Get.put(BlogController());
  TextEditingController titleController = TextEditingController();
  TextEditingController summaryController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TextEditingController youtubeController = TextEditingController();
  final mainImageMedia = ImageMedia(pk: 1, display_name: "", image: "").obs;
  final imageController = Get.put(ImageController());
  final validYoutubdID = false.obs;
  final _youtubdID = "".obs;
  final FocusScopeNode _nodeFocus = FocusScopeNode();
  final YTIFrame = YoutubePlayerIFrame().obs;
  late BlogItemDetil itemEdit;
  @override
  void dispose() {
    _nodeFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    itemEdit = Get.arguments['blog'];
    // TODO: implement initState
    imageController.resetUploadResult();
    imageController.clearNewAlbum();
    setState(() {
      titleController.text = itemEdit.title;
      summaryController.text = itemEdit.summary;
      contentController.text = itemEdit.content;
      youtubeController.text = "https://youtu.be/${itemEdit.youtube_id}";
      YTIFrame.value = generateYTIFrameDefault(itemEdit.youtube_id);
      validYoutubdID(true);
      _youtubdID.value = itemEdit.youtube_id;
      mainImageMedia.value = ImageMedia(
          pk: itemEdit.main_image,
          display_name: "thubnail_youtube",
          image: itemEdit.main_image_url);
    });
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
          title: const Text("Edit Tautan Video Youtube"),
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
                const Text("Silahkan Isi Tautan Video Youtube"),
                const Divider(
                  color: CupertinoColors.separator,
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                    controller: youtubeController,
                    onFieldSubmitted: (value) {
                      generateYotubeID(value);
                      return;
                    },
                    style: const TextStyle(fontSize: 13, height: 2),
                    decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                        labelText: "Link Youtube (Tautan Video Youtube)",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        border: OutlineInputBorder()),
                    autocorrect: false,
                    validator: (_val) {
                      return null;
                    }),
                Obx(() => Container(
                      child: validYoutubdID.value == true
                          ? Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: YTIFrame.value,
                            )
                          : Container(),
                    )),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                    controller: titleController,
                    style: const TextStyle(fontSize: 13, height: 2),
                    minLines: 2,
                    maxLines: 2,
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
                        labelText: "Description",
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
                GFButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) {
                      GFToast.showToast('Incomplete Form !', context,
                          trailing: const Icon(
                            Icons.error_outline,
                            color: GFColors.WARNING,
                          ),
                          toastBorderRadius: 5.0);
                    } else {
                      //_simpanProfilPengguna();
                      if (validYoutubdID.value == false) {
                        GFToast.showToast('Invalid Youtube Link!', context,
                            trailing: const Icon(
                              Icons.error_outline,
                              color: GFColors.WARNING,
                            ),
                            toastBorderRadius: 5.0);
                      } else {
                        //sudah lengkap siap posting
                        var youtubeId =
                            validYoutubdID.value ? _youtubdID.value : "";
                        var youtubeEmbeded = validYoutubdID.value
                            ? blogController
                                .generateYoutubeEmbed(_youtubdID.value)
                            : "";
                        var blogUpload = {
                          "title": titleController.text.trim(),
                          "summary": summaryController.text.trim(),
                          "main_image": mainImageMedia.value.pk,
                          "content": contentController.text.trim(),
                          "youtube_id": youtubeId,
                          "youtube_embeded": youtubeEmbeded,
                          "albums_id": []
                        };

                        SmartDialog.showLoading(
                            msg: "Simpan Tautan Youtube...");
                        blogController
                            .updateBlog(blogUpload, itemEdit.pk)
                            .then((value) => {
                                  SmartDialog.dismiss(),
                                  if (value == true)
                                    {
                                      GFToast.showToast(
                                          'Saved successfully',
                                          context,
                                          trailing: const Icon(
                                            Icons.check_circle_outline,
                                            color: GFColors.SUCCESS,
                                          ),
                                          toastDuration: 3,
                                          toastPosition: GFToastPosition.BOTTOM,
                                          toastBorderRadius: 5.0),
                                      blogController.getListBlog(),
                                      Navigator.pop(context)
                                    }
                                  else
                                    {
                                      GFToast.showToast(
                                          'Failed Saved',
                                          context,
                                          trailing: const Icon(
                                            Icons.error_outline,
                                            color: GFColors.DANGER,
                                          ),
                                          toastDuration: 3,
                                          toastPosition: GFToastPosition.BOTTOM,
                                          toastBorderRadius: 5.0),
                                    }
                                });
                      }
                    }
                  },
                  text: "Save Youtube Link",
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
          )),
        ));
  }

  Future<YoutubePlayerIFrame> generateYTIFrame(String youtubdID) async {
    SmartDialog.showLoading(msg: "Check Youtube...");
    var metadata = await blogController.getYoutubeMetaData(youtubdID);

    if (metadata != null) {
      titleController.text = metadata['title'];
      summaryController.text = metadata['author_name'];
      //print(metadata['thumbnail_url']);
      if (metadata['thumbnail_url'] != "") {
        String thumbail_url = metadata['thumbnail_url'];
        String imageBase64 =
            await ImageController.to.getBase64ImageUrl(thumbail_url);
        //print(imageBase64);
        var _extension = extension(thumbail_url).replaceAll(".", "") == "png"
            ? "png"
            : "jpeg";
        //String base64ImageRender = baseimage;
        String base64ImageUpload = "data:image/$_extension;base64,$imageBase64";
        var uploadImage = {
          "display_name": DateTime.now().toIso8601String().substring(0, 19),
          "image_base64": base64ImageUpload
        };
        //print(uploadImage);
        bool uploadThumbail =
            await imageController.uploadImageBase64(uploadImage);
        if (uploadThumbail == true) {
          setState(() {
            mainImageMedia.value = ImageMedia(
                pk: imageController.uploadResult.value.pk,
                display_name: imageController.uploadResult.value.display_name,
                image: imageController.uploadResult.value.image);
          });
          //print(image);
        }
      }
      SmartDialog.dismiss();
      var ytController = YoutubePlayerController(
        initialVideoId: youtubdID,
        params: const YoutubePlayerParams(
          showControls: true,
          enableCaption: false,
          autoPlay: false,
          mute: true,
          showVideoAnnotations: false,
          showFullscreenButton: true,
        ),
      );
      return YoutubePlayerIFrame(
        controller: ytController,
      );
    }

    return YoutubePlayerIFrame(
      controller: null,
    );
  }

  YoutubePlayerIFrame generateYTIFrameDefault(String youtubdID) {
    var ytController = YoutubePlayerController(
      initialVideoId: youtubdID,
      params: const YoutubePlayerParams(
        showControls: true,
        enableCaption: false,
        autoPlay: false,
        mute: true,
        showVideoAnnotations: false,
        showFullscreenButton: true,
      ),
    );
    return YoutubePlayerIFrame(
      controller: ytController,
    );
  }

  void generateYotubeID(String value) async {
    if (value != "") {
      String urlYoutube = value;
      String youtubeId = blogController.getYoutubeVideoId(urlYoutube);
      if (youtubeId != "") {
        print("YTID: $youtubeId");
        YoutubePlayerIFrame YTF = await generateYTIFrame(youtubeId);
        if (YTF.controller != null) {
          setState(() {
            validYoutubdID.value = true;
            _youtubdID.value = youtubeId;
            YTIFrame(YTF);
          });
        } else {
          setState(() {
            validYoutubdID.value = false;
            _youtubdID.value = "";
            //YTIFrame(YTF);
          });
          GFToast.showToast('Youtube Invalid', Get.context!,
              trailing: const Icon(
                Icons.error_outline,
                color: GFColors.WARNING,
              ),
              toastPosition: GFToastPosition.BOTTOM,
              toastBorderRadius: 5.0);
        }
      }

      return;
    } else {
      validYoutubdID(false);
      setState(() {
        validYoutubdID.value = false;
        _youtubdID.value = "";
        YTIFrame(YoutubePlayerIFrame());
      });
    }
  }
}
