import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tmcapp/controller/AppController.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:flutter/material.dart';
import 'package:tmcapp/controller/CompanyController.dart';
import 'package:tmcapp/widget/image_widget.dart';

import 'controller/ChatController.dart';
import 'model/channel_chat.dart';

class UserChatScreen extends StatefulWidget {
  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final authController = AuthController.to;
  final chatController = ChatController.to;
  final companyController = CompanyController.to;
  final String role = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _usersStream;
    if (authController.user.value.role == "admin") {
      _usersStream = FirebaseFirestore.instance
          .collection('users')
          .where('role', isNotEqualTo: "admin")
          .snapshots();
    } else {
      _usersStream = FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: "admin")
          .orderBy('displayName', descending: false)
          .snapshots();
    }
    Color appBarColor = AppController.to.appBarColor.value;
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        elevation: 1,
        titleSpacing: 10,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(authController.user.value.role == "admin"
            ? "Chat Peserta"
            : "Chat Admin"),
        backgroundColor: appBarColor,
        automaticallyImplyLeading: true,
      ),
      backgroundColor: Theme.of(context).canvasColor,
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: _usersStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("Something Wrong..."));
            }
            if (snapshot.hasData) {
              if (authController.user.value.isLogin == false) {
                return const Center(child: Text("Anda Belum Login..."));
              }
              return GenerateListUser(snapshot);
            }
            return const Center(child: Text("Loading..."));
            //GenerateListChannel(snapshot);
          },
        ),
      ),
    );
  }

  ListView GenerateListUser(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 10),
      children: snapshot.data!.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        //print(document.id);
        return InkWell(
          onTap: () async {
            String currentUid = authController.user.value.uid;
            String userUid = data['uid'];
            String uid1 = "";
            String uid2 = "";
            if (currentUid.compareTo(userUid) >= 0) {
              uid1 = currentUid;
              uid2 = userUid;
            } else {
              uid1 = userUid;
              uid2 = currentUid;
            }
            ChannelChat tempChannel;
            await chatController.initChatPersonal(uid1, uid2).then((value) => {
                  if (value == true)
                    {
                      tempChannel = ChannelChat(
                          updateTime: "",
                          id: "chat_${uid1}_$uid2",
                          title:
                              "${data['displayName'].toString().toUpperCase()}",
                          subtitle: companyController
                              .getCompanyName(data['idCompany']),
                          type: "personal",
                          member: [uid1, uid2],
                          image: data['photoURL']),
                      //print("Buka Room Chat"),
                      Get.toNamed('/detil-chat',
                          arguments: {'chat': tempChannel}),
                    }
                });
          },
          child: ListTile(
            title: Text("${data['displayName'].toString().toUpperCase()}"),
            subtitle: Text(companyController.getCompanyName(data['idCompany'])),
            leading: CircleImageNetwork(data['photoURL'], 24, UniqueKey()),
          ),
        );
      }).toList(),
    );
  }
}
