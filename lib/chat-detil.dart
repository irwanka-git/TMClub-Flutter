import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:tmcapp/controller/AppController.dart';

import 'package:tmcapp/controller/ChatController.dart';
import 'package:tmcapp/controller/ImageController.dart';
import 'package:tmcapp/model/channel_chat.dart';
import 'package:tmcapp/model/message.dart';
import 'package:tmcapp/model/user.dart';
import 'package:tmcapp/preview-chat-image.dart';
import 'package:tmcapp/widget/button_style.dart';
import 'package:tmcapp/widget/chat_image_composer.dart';
import 'package:tmcapp/widget/image_widget.dart';
import 'package:bubble/bubble.dart';
import 'package:url_launcher/url_launcher.dart';

import 'controller/AuthController.dart';

enum ConfirmAction { Cancel, Accept }

class DetilChatScreen extends StatefulWidget {
  @override
  State<DetilChatScreen> createState() => _DetilChatScreenState();
}

class _DetilChatScreenState extends State<DetilChatScreen> {
  final authController = AuthController.to;
  final chatController = ChatController.to;
  final imageController = ImageController.to;
  ScrollController listScrollController = ScrollController();

  final textMessageController = TextEditingController();
  ChannelChat chat = ChannelChat(
      id: "",
      title: "",
      subtitle: "",
      type: "",
      updateTime: "",
      eventId: "",
      image: "",
      member: []);

  @override
  void initState() {
    // TODO: implement initState
    chat = Get.arguments['chat'];
    chatController.initChatRoom(chat.id);
    chatController.syncronizeReadInbox(chat.id, authController.user.value.uid);
    //initializeDateFormatting("id","");
    //Intl.defaultLocale = 'id';
    print(chat.member);
    chatController.syncronizeMemberChat(chat.id, authController.user.value.uid);
    super.initState();
  }

  static const styleDeleteSomebody = BubbleStyle(
    nip: BubbleNip.leftTop,
    color: Color.fromARGB(255, 210, 210, 210),
    //color: Color.fromRGBO(248, 119, 79, 1),
    elevation: 2,
    padding: BubbleEdges.symmetric(vertical: 5, horizontal: 10),
    margin: BubbleEdges.only(top: 8, right: 50, bottom: 4, left: 10),
    alignment: Alignment.topLeft,
  );

  static const styleDeleteMe = BubbleStyle(
    nip: BubbleNip.rightTop,
    color: Color.fromARGB(255, 210, 210, 210),
    elevation: 2,
    padding: BubbleEdges.symmetric(vertical: 5, horizontal: 10),
    margin: BubbleEdges.only(top: 8, left: 50, bottom: 8, right: 10),
    alignment: Alignment.topRight,
  );

  static const styleSomebody = BubbleStyle(
    nip: BubbleNip.leftTop,
    color: Color.fromRGBO(31, 44, 52, 1),
    //color: Color.fromRGBO(248, 119, 79, 1),
    elevation: 2,
    padding: BubbleEdges.symmetric(vertical: 5, horizontal: 10),
    margin: BubbleEdges.only(top: 8, right: 80, bottom: 8, left: 10),
    alignment: Alignment.topLeft,
  );

  static const styleMe = BubbleStyle(
    nip: BubbleNip.rightTop,
    color: Color.fromARGB(255, 50, 74, 89),
    elevation: 2,
    padding: BubbleEdges.symmetric(vertical: 5, horizontal: 10),
    margin: BubbleEdges.only(top: 8, left: 80, bottom: 8, right: 10),
    alignment: Alignment.topRight,
  );

  @override
  Color appBarColor = AppController.to.appBarColor.value;
  Widget build(BuildContext context) {
    String _userRole = authController.user.value.role;
    final Stream<QuerySnapshot> _messageStream = FirebaseFirestore.instance
        .collection('chats')
        .doc(chat.id)
        .collection('data')
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        titleSpacing: 10,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: SizedBox(
          width: Get.width - 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleImageNetwork(chat.image, 18, UniqueKey()),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: Get.width - 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.title,
                      style: const TextStyle(fontSize: 15),
                    ),
                    Text(
                      chat.subtitle,
                      style: const TextStyle(
                          fontSize: 14, color: CupertinoColors.systemGrey6),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        backgroundColor: appBarColor,
        // actions: [
        //   chat.type == "group"
        //       ? IconButton(
        //           icon: const Icon(CupertinoIcons.person_2_fill,
        //               color: Colors.white),
        //           onPressed: () => {
        //             Get.toNamed('/user-chat',
        //                   arguments: {'event_id': chat.id})
        //           },
        //         )
        //       : Container(),
        // ],
      ),
      backgroundColor: const Color.fromARGB(255, 210, 195, 168),
      body: Column(children: <Widget>[
        Expanded(
          child: Container(
            child: ClipRRect(
              child: StreamBuilder<QuerySnapshot>(
                stream: _messageStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Something Wrong..."));
                  }
                  // if (snapshot.connectionState == ConnectionState.waiting) {
                  //   return Container(
                  //             padding: EdgeInsets.all(20),
                  //             child: Center(
                  //                 child: Text("Loading....")));
                  // }
                  if (snapshot.hasData) {
                    var chatMessage = <ChatMessage>[];
                    var reverseChatMessage = <ChatMessage>[];

                    snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      if (document.id != "default") {
                        //print(DateTime.parse(data['creationTime']));
                        chatMessage.add(ChatMessage(
                            isMe: data['uid'] == authController.user.value.uid
                                ? true
                                : false,
                            type: chat.type,
                            id: document.id,
                            message: data['message'],
                            image: data['image'],
                            uid: data['uid'],
                            delete: data['delete'] ?? false,
                            user: ChatUser(data['uid'], "", "", ""),
                            creationTime: data['creationTime'],
                            refID: data['refID'],
                            tanggal: DateFormat(
                                    DateFormat.YEAR_ABBR_MONTH_WEEKDAY_DAY,
                                    "id_ID")
                                .format(DateTime.parse(data['creationTime'])),
                            jam: data['creationTime']
                                .toString()
                                .substring(11, 16)));
                      }
                    }).toList();

                    reverseChatMessage = List.from(chatMessage.reversed);

                    chatMessage.clear();
                    String iterUID = "";
                    var listUID = <String>[];
                    String stickyLabel = "";
                    String today = DateFormat(
                            DateFormat.YEAR_ABBR_MONTH_WEEKDAY_DAY, "id_ID")
                        .format(DateTime.now());
                    String yesterday = DateFormat(
                            DateFormat.YEAR_ABBR_MONTH_WEEKDAY_DAY, "id_ID")
                        .format(
                            DateTime.now().subtract(const Duration(days: 1)));

                    for (ChatMessage item in reverseChatMessage) {
                      if (iterUID != item.uid) {
                        listUID.add(item.uid);
                      }

                      if (stickyLabel == "") {
                        stickyLabel = item.tanggal;
                      }
                      if (stickyLabel != item.tanggal) {
                        chatMessage.add(ChatMessage(
                            isMe: false,
                            type: "sticky",
                            id: "",
                            message: stickyLabel == yesterday
                                ? "Kemarin"
                                : stickyLabel == today
                                    ? "Hari Ini"
                                    : stickyLabel,
                            image: "",
                            uid: "",
                            user: ChatUser("", "", "", ""),
                            creationTime: "",
                            delete: false,
                            refID: "",
                            tanggal: "",
                            jam: ""));
                        stickyLabel = item.tanggal;
                      }

                      chatMessage.add(item);
                    }
                    if (reverseChatMessage.isNotEmpty) {
                      chatMessage.add(ChatMessage(
                          isMe: false,
                          type: "sticky",
                          id: "",
                          message: stickyLabel == yesterday
                              ? "Kemarin"
                              : stickyLabel == today
                                  ? "Hari Ini"
                                  : stickyLabel,
                          image: "",
                          uid: "",
                          user: ChatUser("", "", "", ""),
                          creationTime: "",
                          refID: "",
                          delete: false,
                          tanggal: "",
                          jam: ""));
                    }

                    if (chat.type == "group") {
                      return FutureBuilder(
                        future: chatController.sinkronUserGroup(listUID),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot2) {
                          if (snapshot2.data != null) {
                            if (snapshot2.hasData) {
                              for (var i = 0; i < chatMessage.length; i++) {
                                if (chatMessage[i].type == chat.type) {
                                  var cek = chatController
                                      .findUserChat(chatMessage[i].uid);
                                  if (cek.title != "") {
                                    chatMessage[i].user = ChatUser(
                                        chatMessage[i].uid,
                                        cek.avatar,
                                        cek.title,
                                        cek.subtitle);
                                  }
                                }
                              }
                              return ListView.builder(
                                reverse: true,
                                padding: const EdgeInsets.only(top: 15.0),
                                itemCount: chatMessage.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return buildMessageItem(chatMessage[index]);
                                },
                              );
                            }
                          }
                          return Container(
                              padding: const EdgeInsets.all(20),
                              child: const Center(child: Text("")));
                        },
                      );
                    } else {
                      return ListView.builder(
                        controller: listScrollController,
                        reverse: true,
                        padding: const EdgeInsets.only(top: 15.0),
                        itemCount: chatMessage.length,
                        itemBuilder: (BuildContext context, int index) {
                          return buildMessageItem(chatMessage[index]);
                        },
                      );
                    }
                    //Date tanggal = DateTime.now().

                  }
                  return Container(
                      padding: const EdgeInsets.all(20),
                      child: const Center(child: Text("")));
                  //GenerateListChannel(snapshot);
                },
              ),
            ),
          ),
        ),
        _buildMessageComposer(context),
      ]),
    );
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      print('Could not launch $url');
    }
  }

  Widget buildMessageItem(ChatMessage refChatMessage) {
    chatController.syncronizeReadMessage(
        refChatMessage.id, authController.user.value.uid);

    if (refChatMessage.delete == true) {
      if (refChatMessage.isMe) {
        return Bubble(
          style: styleDeleteMe,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "~ Pesan ini telah dihapus",
                style: TextStyle(
                    color: Color.fromARGB(255, 160, 160, 160), fontSize: 13),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                refChatMessage.jam,
                style: const TextStyle(
                    color: Color.fromARGB(255, 160, 160, 160), fontSize: 10),
              )
            ],
          ),
        );
      }
      if (refChatMessage.isMe == false && refChatMessage.type == "personal") {
        return Bubble(
          style: styleDeleteSomebody,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "~ Pesan ini telah dihapus",
                style: TextStyle(
                    color: Color.fromARGB(255, 160, 160, 160), fontSize: 13),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                refChatMessage.jam,
                style: const TextStyle(
                    color: Color.fromARGB(255, 160, 160, 160), fontSize: 10),
              )
            ],
          ),
        );
      }

      if (refChatMessage.isMe == false && refChatMessage.type == "group") {
        return Bubble(
          style: styleDeleteSomebody,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                refChatMessage.user.subtitle == "admin"
                    ? "${refChatMessage.user.title} (Admin)"
                    : refChatMessage.user.title,
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: refChatMessage.user.subtitle == "admin"
                        ? const Color.fromARGB(255, 164, 148, 98)
                        : const Color.fromARGB(255, 93, 128, 105),
                    fontSize: 13),
              ),
              const SizedBox(
                height: 4,
              ),
              const Text(
                "~ Pesan ini telah dihapus",
                style: TextStyle(
                    color: Color.fromARGB(255, 160, 160, 160), fontSize: 13),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                refChatMessage.jam,
                style: const TextStyle(
                    color: Color.fromARGB(255, 160, 160, 160), fontSize: 10),
              )
            ],
          ),
        );
      }
    }

    if (refChatMessage.type == "sticky") {
      return Bubble(
        margin: const BubbleEdges.only(top: 10, bottom: 10),
        alignment: Alignment.center,
        color: const Color.fromRGBO(51, 62, 75, 1),
        child: Text(refChatMessage.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 10.0, color: CupertinoColors.systemGrey4)),
      );
    }
    if (refChatMessage.type == "group" && refChatMessage.isMe == false) {
      return Bubble(
        style: styleSomebody,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              refChatMessage.user.subtitle == "admin"
                  ? "${refChatMessage.user.title} (Admin)"
                  : refChatMessage.user.title,
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: refChatMessage.user.subtitle == "admin"
                      ? CupertinoColors.systemYellow
                      : const Color.fromARGB(255, 76, 198, 119),
                  fontSize: 13),
            ),
            CekIsImageChat(refChatMessage),
            SelectableLinkify(
              textScaleFactor: 1.0,
              linkStyle: const TextStyle(decoration: TextDecoration.none),
              style: const TextStyle(color: Colors.white),
              onOpen: (link) => {_launchInBrowser(Uri.parse(link.url))},
              text: refChatMessage.message,
              options: const LinkifyOptions(humanize: false),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              refChatMessage.jam,
              style: const TextStyle(
                  color: CupertinoColors.lightBackgroundGray, fontSize: 9),
            )
          ],
        ),
      );
    }

    if (refChatMessage.type != "group" && refChatMessage.isMe == false) {
      return Bubble(
        style: styleSomebody,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CekIsImageChat(refChatMessage),
            SelectableLinkify(
              textScaleFactor: 1.0,
              linkStyle: const TextStyle(decoration: TextDecoration.none),
              style: const TextStyle(color: Colors.white),
              onOpen: (link) => {_launchInBrowser(Uri.parse(link.url))},
              text: refChatMessage.message,
              options: const LinkifyOptions(humanize: false),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              refChatMessage.jam,
              style: const TextStyle(
                  color: CupertinoColors.lightBackgroundGray, fontSize: 9),
            )
          ],
        ),
      );
    }
    return InkWell(
        highlightColor: const Color.fromARGB(55, 47, 47, 55),
        onLongPress: (() {
          Get.defaultDialog(
              contentPadding: const EdgeInsets.all(20),
              title: "Confirmation",
              titlePadding: const EdgeInsets.only(top: 10, bottom: 0),
              middleText: "Yakin ingin hapus pesan?",
              backgroundColor: CupertinoColors.darkBackgroundGray,
              titleStyle: const TextStyle(color: Colors.white, fontSize: 16),
              middleTextStyle:
                  const TextStyle(color: Colors.white, fontSize: 14),
              textCancel: "Cancel",
              textConfirm: "Yes, Delete",
              cancelTextColor: Colors.white,
              confirmTextColor: Colors.white,
              buttonColor: CupertinoColors.activeOrange,
              onConfirm: () {
                chatController.deleteMessage(chat.id, refChatMessage.id);
                Navigator.pop(context);
              },
              radius: 0);
        }),
        child: Bubble(
          style: refChatMessage.isMe ? styleMe : styleSomebody,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CekIsImageChat(refChatMessage),

              SelectableLinkify(
                textScaleFactor: 1.0,
                linkStyle: const TextStyle(decoration: TextDecoration.none),
                style: const TextStyle(color: Colors.white),
                onOpen: (link) => {_launchInBrowser(Uri.parse(link.url))},
                text: refChatMessage.message,
                options: const LinkifyOptions(humanize: false),
              ),
              // Text(
              //   refChatMessage.message,
              //   style: TextStyle(color: CupertinoColors.white, fontSize: 16),
              // ),
              const SizedBox(
                height: 4,
              ),
              Text(
                refChatMessage.jam,
                style: const TextStyle(
                    color: CupertinoColors.lightBackgroundGray, fontSize: 9),
              )
            ],
          ),
        ));
  }

  Widget CekIsImageChat(ChatMessage refChatMessage) {
    if (refChatMessage.image != "") {
      return InkWell(
          highlightColor: const Color.fromARGB(55, 47, 47, 55),
          onTap: () {
            print(refChatMessage.image);
            showMaterialModalBottomSheet<String>(
              expand: false,
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => PreviewImageChatScreen(refChatMessage),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(5),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Image.network(
                  refChatMessage.image,
                  width: Get.width,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ));
    }
    return const SizedBox(
      height: 0,
    );
  }

  Container _buildMessageComposer(BuildContext _context) {
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(_context).padding.bottom),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
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
                  IconButton(
                      icon: const Icon(
                        CupertinoIcons.paperclip,
                        color: CupertinoColors.activeOrange,
                      ),
                      onPressed: () {
                        print("Ambil Gambar");
                        showMaterialModalBottomSheet<String>(
                          expand: false,
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => sheetPilihanAttach(context),
                        );
                      }),
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
                          style: const TextStyle(
                              color: CupertinoColors.darkBackgroundGray),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(2),
                            hintText: "Type your message",
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
                color: CupertinoColors.activeOrange, shape: BoxShape.circle),
            child: InkWell(
              child: const Icon(
                CupertinoIcons.paperplane,
                color: Colors.white,
                size: 25,
              ),
              onTap: () async {
                FocusScope.of(context).unfocus();
                if (textMessageController.text.trim().isNotEmpty) {
                  String message = textMessageController.text.trim();
                  String roomID = chat.id;
                  String chatID =
                      DateTime.now().millisecondsSinceEpoch.toString() +
                          "_" +
                          authController.user.value.uid +
                          "_" +
                          UniqueKey().toString();
                  var itemMessage = {
                    "creationTime": DateTime.now().toIso8601String(),
                    "image": "",
                    "delete": false,
                    "refID": "",
                    "uid": authController.user.value.uid,
                    "message": message,
                  };
                  textMessageController.text = "";
                  // var position =
                  //       _scrollcontroller.position.minScrollExtent;
                  //       print("Position: ${position}");
                  //   _scrollcontroller.jumpTo(position);

                  if (listScrollController.hasClients) {
                    final position =
                        listScrollController.position.minScrollExtent;
                    listScrollController.animateTo(
                      position,
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeOut,
                    );
                  }
                  await chatController
                      .sendMessage(roomID, chatID, itemMessage,
                          authController.user.value.uid)
                      .then((value) => () {
                            print("Pois: ${listScrollController.position}");
                            listScrollController.animateTo(
                              0,
                              duration: const Duration(seconds: 1),
                              curve: Curves.easeOut,
                            );
                          });
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget sheetPilihanAttach(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    return SingleChildScrollView(
      child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
              color: CupertinoColors.extraLightBackgroundGray,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
          child: Container(
            width: mediaQueryData.size.width,
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(children: [
              const SizedBox(
                height: 10,
              ),
              const Text("Pilih Gambar"),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    style: outlineButtonStyleOrange,
                    onPressed: () {
                      getImage(ImageSource.gallery);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        Icon(
                          Icons.image,
                          size: 18,
                          color: CupertinoColors.white,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            'Gallery',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  OutlinedButton(
                    style: outlineButtonStyleOrange,
                    onPressed: () {
                      getImage(ImageSource.camera);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: CupertinoColors.white,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            'Camera',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
            ]),
          )),
    );
  }

  getImage(ImageSource source) async {
    Navigator.pop(context);
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
      imageController.setchatID(chat.id);
      imageController.uploadToFirebaseStorage(_tempPath);
      showMaterialModalBottomSheet(
        expand: false,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => SingleChildScrollView(child: ImageChatComposer()),
      );
    }
  }
}
