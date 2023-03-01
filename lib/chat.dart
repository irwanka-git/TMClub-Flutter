import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:flutter/material.dart';
import 'package:tmcapp/controller/CompanyController.dart';
import 'package:tmcapp/widget/image_widget.dart';
import 'controller/ChatController.dart';
import 'model/channel_chat.dart';

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final authController = AuthController.to;
  final companyController = CompanyController.to;
  final chatController = Get.put(ChatController());
  late ScrollController _scrollController;
  final Color _foregroundColor = Colors.white;
  TextEditingController _searchTextcontroller = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    if (authController.user.value.uid != "") {
      companyController.getListCompany();
      chatController.listenMessageInbox(authController.user.value.uid);
      _searchTextcontroller.text = "";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final uidUser = authController.user.value.uid;
    final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
        .collection('chats')
        .where('uid', arrayContainsAny: [uidUser])
        .orderBy('type', descending: false)
        .orderBy('updateTime', descending: true)
        .snapshots();
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Something Wrong..."));
        }
        if (snapshot.hasData) {
          if (authController.user.value.isLogin == false) {
            return const Center(child: Text("You are not logged in yet..."));
          }
          chatController.clearChannelDisplay();
          // ignore: unrelated_type_equality_checks
          // print("XXX: ${authController.user.value.idCompany}");
          // print("ROLE: ${authController.user.value.role}");
          if (authController.user.value.role == "member" &&
              authController.user.value.idCompany == "null") {
            return const Center(child: Text("No Chat yet"));
          }
          _searchTextcontroller.text = "";
          chatController.getUserChat(snapshot.data!, uidUser).then((value) {
            chatController.generateChannelChat(snapshot.data!, uidUser,
                authController.user.value.role.toUpperCase());
            //adjus group chat event
            chatController.adjusmentGroupChat();
          });

          return Scaffold(
            body: BuildListChannel(),
          );
        }
        return const Center(child: Text("Loading..."));
        //GenerateListChannel(snapshot);
      },
    );
  }

  CustomScrollView BuildListChannel() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          centerTitle: true,
          backgroundColor: CupertinoColors.white,
          stretch: true,
          pinned: true,
          floating: true,
          toolbarHeight: 20.0 + kToolbarHeight,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: SizedBox(
              height: 45,
              child: Container(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: TextField(
                  onChanged: (text) {
                    print(text);
                    chatController.setChannelListView(text);
                  },
                  controller: _searchTextcontroller,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(CupertinoIcons.search),
                      contentPadding: EdgeInsets.only(top: 10),
                      border: OutlineInputBorder(),
                      hintText: 'Search Chat..'),
                ),
              ),
            ),
          ),
        ),
        Obx(() => Container(
              child: SliverList(
                delegate:
                    BuilderListChannelDelegate(chatController.channelListview),
              ),
            )),
      ],
    );
  }

  SliverChildBuilderDelegate BuilderListChannelDelegate(
      List<ChannelChat> channel) {
    return SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return Obx(() => Container(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: InkWell(
                onTap: () => {
                      print(channel[index].id),
                      Get.toNamed('/detil-chat',
                          arguments: {'chat': channel[index]})
                    },
                child: ListTile(
                  trailing: buildBadgeChannel(channel[index]),
                  title: Text(channel[index].title),
                  subtitle: Text(channel[index].subtitle,
                      overflow: TextOverflow.ellipsis),
                  leading:
                      CircleImageNetwork(channel[index].image, 24, UniqueKey()),
                ))));
      },
      semanticIndexCallback: (Widget widget, int localIndex) {
        if (localIndex.isEven) {
          return localIndex ~/ 2;
        }
        return null;
      },
      childCount: channel.length,
      addSemanticIndexes: true,
    );
  }

  Widget buildBadgeChannel(ChannelChat room) {
    int inboxCount = 0;
    String yesterday =
        DateFormat(DateFormat.YEAR_ABBR_MONTH_WEEKDAY_DAY, "id_ID")
            .format(DateTime.now().subtract(const Duration(days: 1)));
    String today =
        DateFormat(DateFormat.ABBR_MONTH_DAY, "id_ID").format(DateTime.now());
    String updateTime = DateFormat(DateFormat.ABBR_MONTH_DAY, "id_ID")
        .format(DateTime.parse(room.updateTime));
    if (chatController.inbox.containsKey(room.id)) {
      inboxCount = chatController.inbox[room.id]!.toInt();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          updateTime == today
              ? "Hari Ini"
              : updateTime == yesterday
                  ? "Hari Ini"
                  : updateTime,
          style: const TextStyle(
              fontSize: 10, color: CupertinoColors.inactiveGray),
        ),
        const SizedBox(
          height: 4,
        ),
        inboxCount > 0
            ? Badge(
                shape: BadgeShape.circle,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 5),
                badgeColor: Colors.redAccent,
                badgeContent: Text(inboxCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10)),
              )
            : const Text("")
      ],
    );
  }
}
