// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tmcapp/controller/AkunController.dart';
import 'package:tmcapp/controller/AuthController.dart';
import 'package:tmcapp/controller/BottomTabController.dart';
import 'package:tmcapp/controller/CompanyController.dart';
import 'package:tmcapp/controller/EventController.dart';
import 'package:tmcapp/model/channel_chat.dart';
import 'package:tmcapp/model/event_tmc.dart';
import 'package:tmcapp/model/user.dart';
import 'package:tmcapp/client.dart';

class ChatController extends GetxController {
  static ChatController get to => Get.find<ChatController>();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<ChannelChat> channel = <ChannelChat>[].obs;
  List<ChannelChat> channelListview = <ChannelChat>[].obs;
  List<ChatUser> user = <ChatUser>[].obs;
  Map<String, int> inbox = {"": 0}.obs;
  final companyController = CompanyController.to;
  final btControler = BottomTabController.to;
  final evtController = EventController.to;
  final authController = AuthController.to;

  final String default_avatar =
      "https://firebasestorage.googleapis.com/v0/b/tmcevent-project.appspot.com/o/default-avatar.png?alt=media&token=bfab603d-855d-41e8-8e81-de9890d6b5a9";
  final String default_group_chat =
      "https://firebasestorage.googleapis.com/v0/b/tmcevent-project.appspot.com/o/default-group.png?alt=media&token=44ffe146-3a3e-4ca6-95eb-521b07722b9f";
  final String default_group_pic =
      "https://firebasestorage.googleapis.com/v0/b/tmcevent-project.appspot.com/o/6387947.png?alt=media&token=065e7447-1097-4a22-8eed-4c28c405da07";
  void clearChannelDisplay() {
    channel.clear();
  }

  void generateChannelChat(
      QuerySnapshot<Object?> snapshotData, String uid_user, String role) async {
    //print("GENERATE CHANEL");
    channel.clear();
    channelListview.clear();

    if (role == "ADMIN" || role == "PIC") {
      CekGroupChatPICForCurrentUser();
    }
    for (var document in snapshotData.docs) {
      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
      String _uid_other = "";
      List<String> member = List<String>.from(data['uid']);
      //print(member);
      if (data['type'] == 'personal' && data['empty'] == false) {
        for (var _uid in data['uid']) {
          if (_uid != uid_user) {
            _uid_other = _uid;
          }
        }
        //print(_uid_other);
        ChatUser __user = findUserChat(_uid_other);
        channel.add(ChannelChat(
            id: document.id,
            title: __user.title,
            subtitle: __user.subtitle,
            type: data['type'],
            member: member,
            eventId: data['eventId'] == null || data['eventId'] == 0
                ? ""
                : data['eventId'],
            updateTime: data["updateTime"],
            image: __user.avatar));
      }

      if (data['type'] == "group") {
        channel.add(ChannelChat(
            id: document.id,
            title: data['title'],
            subtitle: data['subtitle'],
            type: data['type'],
            eventId: data['eventId'] == null || data['eventId'] == 0
                ? ""
                : data['eventId'],
            member: member,
            updateTime: data["updateTime"],
            image: data['image']));
      }
    }
    setChannelListView("");
  }

  void setChannelListView(String keyword) {
    channelListview.clear();
    if (keyword == "") {
      channelListview.addAll(channel);
    } else {
      channelListview.addAll(channel
          .where((p0) => p0.title.toLowerCase().contains(keyword.toLowerCase()))
          .toList());
    }
  }

  Future<List> getListEmailAdmin() async {
    var emailList = <String>[];
    await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: "admin")
        .get()
        .then((QuerySnapshot querySnapshot) {
      //print(querySnapshot.docs);
      for (var _data in querySnapshot.docs) {
        //print("USER ___: ${_data['displayName']}");
        emailList.add(_data['email']);
      }
    });
    return emailList;
  }

  Future<List> getListEmailPIC() async {
    var emailList = <String>[];
    await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: "PIC")
        .get()
        .then((QuerySnapshot querySnapshot) {
      print(querySnapshot.docs);
      for (var _data in querySnapshot.docs) {
        print("USER ___: ${_data['displayName']}");
        emailList.add(_data['email']);
      }
    });
    return emailList;
  }

  Future<bool> getUserChat(
      QuerySnapshot<Object?> snapshotData, String uid_user) async {
    var uid_list = <String>[];
    for (var document in snapshotData.docs) {
      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
      if (data['type'] == 'personal') {
        for (var _uid in data['uid']) {
          if (!uid_list.contains(_uid) && _uid != uid_user) {
            uid_list.add(_uid);
          }
        }
      }
    }
    user.clear();
    print(uid_list);
    if (uid_list.length > 0) {
      //var akunController = ;
      print("CEK USER BY UID LIST");
      uid_list.forEach((uid) {
        //print(AkunController.to.ListAllAkun);

        int index_cari = AkunController.to.ListAllAkun
            .indexWhere((element) => element.uid == uid);
        print(AkunController.to.ListAllAkun[index_cari].companyName);
        if (index_cari > -1) {
          user.add(ChatUser(
              AkunController.to.ListAllAkun[index_cari].uid!,
              AkunController.to.ListAllAkun[index_cari].photoUrl!,
              AkunController.to.ListAllAkun[index_cari].displayName!
                  .toUpperCase(),
              AkunController.to.ListAllAkun[index_cari].companyName! +
                  " (" +
                  AkunController.to.ListAllAkun[index_cari].role! +
                  ")"));
        }
      });

      //print(uid_list);
      // await FirebaseFirestore.instance
      //     .collection('users')
      //     .where('uid', whereIn: uid_list)
      //     .get()
      //     .then((QuerySnapshot querySnapshot) {
      //   print(querySnapshot.docs);
      //   for (var _data in querySnapshot.docs) {
      //     print("USER ___: ${_data['displayName']}");
      //     user.add(ChatUser(
      //         _data['uid'],
      //         _data['photoURL'],
      //         _data['displayName'].toString().toUpperCase(),
      //         _data['companyName'] + " (" + _data['role'] + ")"));
      //   }
      // });
    }
    return Future.value(true);
  }

  Future<bool> sinkronUserGroup(List<String> listUID) async {
    for (String _uid in listUID) {
      if (indexAvatar(_uid) == -1) {
        await FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: _uid)
            .limit(1)
            .get()
            .then((QuerySnapshot querySnapshot) {
          for (var _data in querySnapshot.docs) {
            //print("USER: ${_data['displayName']}");
            //print("Infor User Ditambahkan ${_uid}");
            user.add(ChatUser(_data['uid'], _data['photoURL'],
                _data['displayName'], _data['role']));
          }
        });
      } else {
        //print("Infor User Sudah Ada ${_uid}");
      }
    }
    return Future.value(true);
  }

  int indexAvatar(String _uid) {
    final index = user.indexWhere((element) => element.uid == _uid);
    if (index >= 0) {
      return index;
    } else {
      return -1;
    }
  }

  ChatUser findUserChat(String _uid) {
    final index = user.indexWhere((element) => element.uid == _uid);
    if (index >= 0) {
      return user[index];
    }
    //print("INDES USER ${index}");
    return ChatUser("", default_avatar, "", "");
  }

  Future<bool> initChatPersonal(String uid1, String uid2) async {
    String chat_id = "chat_${uid1}_$uid2";

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chat_id)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        print('Sudah Ready');
        return Future.value(true);
      } else {
        print('Buat Baru');
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(chat_id)
            .set(
              {
                "uid": [uid1, uid2],
                "title": "",
                "subtitle": "",
                "image": "",
                "type": "personal",
                "empty": true,
                "creationTime": DateTime.now().toIso8601String(),
                "updateTime": DateTime.now().toIso8601String(),
              },
              SetOptions(merge: true),
            )
            .then((value) => () {
                  return Future.value(true);
                })
            .catchError((error) => print("Failed to merge data: $error"));
      }
    });
    return Future.value(true);
  }

  Future<bool> initChatRoom(String idChannel) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(idChannel)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        print('Document Exist!');
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(idChannel)
            .collection('data')
            .limit(1)
            .get()
            .then((QuerySnapshot querySnapshot) async {
          if (querySnapshot.docs.isEmpty) {
            //print('Buat Doc Baru Default');
            await FirebaseFirestore.instance
                .collection('chats')
                .doc(idChannel)
                .collection('data')
                .doc('default')
                .set(
                  {
                    "uid": "",
                    "message": "",
                    "image": "",
                    "creationTime": DateTime.now().toIso8601String(),
                  },
                  SetOptions(merge: true),
                )
                .then((value) => () {
                      return Future.value(true);
                    })
                .catchError((error) => print("Failed to merge data: $error"));
          } else {
            //print('Collection Ready Siap Ditarik Data nya');
            return Future.value(true);
          }
        });
      } else {
        return Future.value(false);
      }
    });
    return Future.value(true);
  }

  Future<bool> sendMessage(
      String roomID, String chatID, dynamic itemMessage, String userID) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(roomID)
        .collection("data")
        .doc(chatID)
        .set(
          itemMessage,
          SetOptions(merge: true),
        )
        .then((value) async {
      print("Update wkatu room $roomID");
      await FirebaseFirestore.instance.collection('chats').doc(roomID).set(
        {'updateTime': DateTime.now().toIso8601String(), 'empty': false},
        SetOptions(merge: true),
      ).then((value) {
        syncronizeMessageInbox(roomID, chatID, userID);
        return Future.value(true);
      });
    }).catchError((error) => () {
              return Future.value(false);
            });
    return Future.value(false);
  }

  Future<bool> deleteMessage(String roomID, String chatID) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(roomID)
        .collection("data")
        .doc(chatID)
        .update({"delete": true});
    return Future.value(false);
  }

  void syncronizeMessageInbox(
      String roomID, String chatID, String userID) async {
    final refInbox = FirebaseFirestore.instance.collection('inbox');
    ChannelChat cek = channel.firstWhere((element) => element.id == roomID);
    var arrayUserReceive = cek.id.isNotEmpty ? cek.member : <String>[];
    arrayUserReceive.remove(userID);
    await refInbox.add({
      "roomID": roomID,
      "chatID": chatID,
      "user": arrayUserReceive,
      "creationTime": FieldValue.serverTimestamp()
    });
  }

  void syncronizeReadInbox(String roomID, String userID) async {
    final refInbox = FirebaseFirestore.instance.collection('inbox');
    await refInbox
        .where('roomID', isEqualTo: roomID)
        .where('user', arrayContains: userID)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var element in querySnapshot.docs) {
        refInbox.doc(element.id).update({
          "user": FieldValue.arrayRemove([userID])
        });
      }
    });
  }

  void syncronizeReadMessage(String chatID, String userID) async {
    final refInbox = FirebaseFirestore.instance.collection('inbox');

    await refInbox
        .where('chatID', isEqualTo: chatID)
        .where('user', arrayContains: userID)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var element in querySnapshot.docs) {
        refInbox.doc(element.id).update({
          "user": FieldValue.arrayRemove([userID])
        });
        print("READ $chatID");
      }
    });
  }

  void CekGroupChatEventForCurrentUser(String id_event, String title) async {
    bool exist = false;
    String chat_id = "chat_event_" + id_event;
    for (var item in channel) {
      if (item.id == chat_id) {
        exist = true;
      }
    }
    if (exist == false) {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chat_id)
          .get()
          .then((DocumentSnapshot documentSnapshot) async {
        if (documentSnapshot.exists) {
          print("Sinkroniasi Member Group");
          final refRoom =
              FirebaseFirestore.instance.collection('chats').doc(chat_id);
          await refRoom.update({
            "uid": FieldValue.arrayUnion([authController.user.value.uid])
          });
        } else {
          print("Buat Chat Group dulu ya");
          await FirebaseFirestore.instance
              .collection('chats')
              .doc(chat_id)
              .set(
                {
                  "uid": [],
                  "title": title,
                  "subtitle": "Group Chat Event",
                  "image": default_group_chat,
                  "eventId": id_event,
                  "type": "group",
                  "empty": false,
                  "creationTime": DateTime.now().toIso8601String(),
                  "updateTime": DateTime.now().toIso8601String(),
                },
                SetOptions(merge: true),
              )
              .then((value) => () {
                    return Future.value(true);
                  })
              .catchError((error) => print("Failed to merge data: $error"));
        }
      });
    }
  }

  void CekGroupChatPICForCurrentUser() async {
    bool exist = false;
    String chat_id = "chat_group_pic";
    for (var item in channel) {
      if (item.id == chat_id) {
        exist = true;
      }
    }
    if (exist == false) {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chat_id)
          .get()
          .then((DocumentSnapshot documentSnapshot) async {
        if (documentSnapshot.exists) {
          print("Sinkroniasi Member Group PIC");
          final refRoom =
              FirebaseFirestore.instance.collection('chats').doc(chat_id);
          await refRoom.update({
            "uid": FieldValue.arrayUnion([authController.user.value.uid])
          });
        } else {
          print("Buat Chat Group dulu ya");
          await FirebaseFirestore.instance
              .collection('chats')
              .doc(chat_id)
              .set(
                {
                  "uid": [],
                  "title": "Group Admin dan PIC",
                  "subtitle": "Sarana Komunikasi Admin dan PIC",
                  "image": default_group_pic,
                  "eventId": 0,
                  "type": "group",
                  "empty": false,
                  "creationTime": DateTime.now().toIso8601String(),
                  "updateTime": DateTime.now().toIso8601String(),
                },
                SetOptions(merge: true),
              )
              .then((value) => () {
                    return Future.value(true);
                  })
              .catchError((error) => print("Failed to merge data: $error"));
        }
      });
    }
  }

  void adjusmentGroupChat() async {
    //get list event
    print("GET LIST MY EVENT");
    dynamic header = {
      HttpHeaders.authorizationHeader:
          'Token ${authController.user.value.token}'
    };
    var collection;
    if (authController.user.value.role == "admin") {
      collection = await ApiClient().requestGet("/event/myevent/", header);
      if (collection == null) {
        return;
      }
      for (var item in collection) {
        var id_event = item['pk'];
        var title = item['title'];
        CekGroupChatEventForCurrentUser(id_event.toString(), title);
      }
    }
    if (authController.user.value.role == "member" ||
        authController.user.value.role == "PIC") {
      collection =
          await ApiClient().requestGet("/event/my-registered-event/", header);
      if (collection == null) {
        return;
      }
      for (var item in collection) {
        var id_event = item['event_id'];
        var title = item['title'];
        //ListMyEvent.add(temp);
        CekGroupChatEventForCurrentUser(id_event.toString(), title);
      }
    }

    if (collection == null) {
      return;
    }

    return;
  }

  void listenMessageInbox(String userID) {
    print("CEK INBOX ${userID}");
    final Stream<QuerySnapshot> _inboxStream = FirebaseFirestore.instance
        .collection('inbox')
        .where('user', arrayContains: userID)
        .snapshots();

    _inboxStream.listen((querySnapshot) {
      print("CEK INBOX ${userID}");
      inbox.clear();
      int countInbox = 0;
      for (var doc in querySnapshot.docs) {
        //print("documentID: ${doc.id}");
        Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;

        if (inbox.containsKey(data['roomID'])) {
          print("roomID: ${data['roomID']}");
          int currentInbox = inbox[data['roomID']]!;
          inbox.update(data['roomID'], (value) => currentInbox + 1);
        } else {
          inbox.addAll({data['roomID']: 1});
        }
        countInbox++;
        //print("chatID: ${data['chatID']}");
        //print("user: ${data['user']}");
      }
      btControler.setcountInbox(countInbox);
      //print(inbox);
    }); //
  }

  void syncronizeMemberChat(String roomID, String userID) async {
    ChannelChat cek = channel.firstWhere((element) => element.id == roomID);
    if (cek.member.contains(userID) == false) {
      final refRoom =
          FirebaseFirestore.instance.collection('chats').doc(roomID);
      await refRoom.update({
        "uid": FieldValue.arrayUnion([userID])
      });
    }
  }

  String getWaktuChat(String _datetime) {
    String tanggal = DateFormat(DateFormat.YEAR_ABBR_MONTH_WEEKDAY_DAY, "id_ID")
        .format(DateTime.parse(_datetime));
    String today = DateFormat(DateFormat.YEAR_ABBR_MONTH_WEEKDAY_DAY, "id_ID")
        .format(DateTime.now());
    String yesterday =
        DateFormat(DateFormat.YEAR_ABBR_MONTH_WEEKDAY_DAY, "id_ID")
            .format(DateTime.now().subtract(const Duration(days: 1)));
    if (tanggal == today) {
      return "Hari Ini, ${_datetime.toString().substring(11, 16)}";
    }
    if (tanggal == yesterday) {
      return "Kemarin, ${_datetime.toString().substring(11, 16)}";
    }
    return "$tanggal, ${_datetime.toString().substring(11, 16)}";
  }

  // void syncronizeChannelInbox(String userID) async{
  //     final refInbox = FirebaseFirestore.instance.collection('inbox');
  //     await refInbox.where('user',arrayContains: userID)
  //           .get()
  //           .then((value) => null)
  // }

}
