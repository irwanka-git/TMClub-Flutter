// ignore_for_file: use_key_in_widget_constructors

import 'package:tmcapp/controller/AuthController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmcapp/controller/ChatController.dart';
import '../controller/ImageController.dart';

class ImageChatComposer extends StatefulWidget {
  // final String image_path;
  // final Key key;

  // ImageChatComposer({
  //   required this.key,
  //   required this.image_path,
  // }) : super(key: key);

  @override
  State<ImageChatComposer> createState() => _ImageChatComposerState();
}

class _ImageChatComposerState extends State<ImageChatComposer> {
  final authController = AuthController.to;
  final chatController = ChatController.to;
  final imageController = ImageController.to;
  final textMessageController = TextEditingController();
  var statusUpload = "".obs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    return AnimatedPadding(
        duration: kThemeAnimationDuration,
        padding: mediaQueryData.viewInsets,
        child: Obx(() => Container(
            child: imageController.onUpload.value == false &&
                    imageController.onCompelete.value == true &&
                    imageController.resultDownload.value != "error" &&
                    imageController.resultDownload.value != ""
                ? _buildSendImageComposer(mediaQueryData, context)
                : Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                        color: CupertinoColors.extraLightBackgroundGray),
                    child: Column(
                      children: const [
                        SizedBox(
                          height: 10,
                        ),
                        Center(child: CircularProgressIndicator()),
                        SizedBox(
                          height: 20,
                        ),
                        Center(child: Text("Gambar sedang di upload...")),
                      ],
                    ),
                  ))));
  }

  Widget _buildSendImageComposer(
      MediaQueryData mediaQueryData, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration:
          const BoxDecoration(color: CupertinoColors.extraLightBackgroundGray),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2.0),
              child: Obx(() => Image.network(
                    imageController.resultDownload.value,
                    fit: BoxFit.fitWidth,
                  )),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: const [
                        BoxShadow(
                            offset: Offset(0, 1),
                            blurRadius: 5,
                            color: Colors.black12)
                      ],
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: Get.width,
                              maxWidth: Get.width,
                              minHeight: 25.0,
                              maxHeight: Get.height,
                            ),
                            child: Scrollbar(
                              child: TextField(
                                cursorColor: CupertinoColors.activeOrange,
                                keyboardType: TextInputType.multiline,
                                controller: textMessageController,
                                maxLines: null,
                                autofocus: true,
                                style: const TextStyle(
                                    color: CupertinoColors.darkBackgroundGray),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(2),
                                  hintText: "Tambahkan Keterangan",
                                  hintStyle: TextStyle(
                                    color: CupertinoColors.placeholderText,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: const BoxDecoration(
                      color: CupertinoColors.activeOrange,
                      shape: BoxShape.circle),
                  child: InkWell(
                    child: const Icon(
                      CupertinoIcons.paperplane,
                      color: Colors.white,
                      size: 25,
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      String message = textMessageController.text.trim();
                      String roomID = imageController.chatID.value;
                      String chatID =
                          DateTime.now().millisecondsSinceEpoch.toString() +
                              "_" +
                              authController.user.value.uid +
                              "_" +
                              UniqueKey().toString();
                      var itemMessage = {
                        "creationTime": DateTime.now().toIso8601String(),
                        "image": imageController.resultDownload.value,
                        "delete": false,
                        "refID": "",
                        "uid": authController.user.value.uid,
                        "message": message,
                      };

                      textMessageController.text = "";

                      await chatController
                          .sendMessage(roomID, chatID, itemMessage,
                              authController.user.value.uid)
                          .then((value) => () {
                                if (value == true) {}
                              });
                    },
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
