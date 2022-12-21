import 'package:tmcapp/model/user.dart';

class ChatMessage {
  var id = "";
  var message = "";
  var image = "";
  var uid = "";
  var user = ChatUser("", "", "", "");
  var creationTime = "";
  var tanggal = "";
  var jam = "";
  var refID = "";
  bool isMe = false;
  bool delete = false;
  var type = ""; //personal, //group, //sticky

  ChatMessage({
    required this.id,
    required this.message,
    required this.image,
    required this.uid,
    required this.creationTime,
    required this.refID,
    required this.tanggal,
    required this.jam,
    required this.type,
    required this.isMe,
    required this.user,
    required this.delete,
  });
}
