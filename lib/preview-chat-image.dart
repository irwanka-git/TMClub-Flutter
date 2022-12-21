import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/controller/ChatController.dart';
import 'package:tmcapp/model/message.dart';
import 'package:tmcapp/model/user.dart';
import 'package:tmcapp/widget/image_widget.dart';

class PreviewImageChatScreen extends StatefulWidget {
  final ChatMessage refChatMessage;
  @override
  const PreviewImageChatScreen(this.refChatMessage);
  @override
  State<PreviewImageChatScreen> createState() => _PreviewImageChatScreen();
}

class _PreviewImageChatScreen extends State<PreviewImageChatScreen> {
  var image_url = "";
  var imaget_title = "";
  var sender = "";
  var waktu = "";
  var nama_pengirim = "";
  var chatUser = ChatUser("", "", "", "");
  ChatController chatController = ChatController.to;
  AuthController authController = AuthController.to;

  @override
  void initState() {
    // TODO: implement initState
    ChatMessage refChatMessage = widget.refChatMessage;
    image_url = refChatMessage.image;
    imaget_title = refChatMessage.message;
    sender = refChatMessage.uid;
    waktu = refChatMessage.creationTime;
    chatUser = chatController.findUserChat(sender);
    sender = authController.user.value.uid == sender ? "Anda" : chatUser.title;
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
                CircleImageNetwork(chatUser.avatar, 18, UniqueKey()),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: Get.width - 160,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sender,
                        style: const TextStyle(fontSize: 15),
                      ),
                      Text(
                        chatController
                            .getWaktuChat(widget.refChatMessage.creationTime),
                        style: const TextStyle(
                            fontSize: 14, color: CupertinoColors.systemGrey6),
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
                              image_url,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              imaget_title,
                              style:
                                  const TextStyle(color: CupertinoColors.white),
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
