class ChannelChat {
  var id = "";
  var title = "";
  var subtitle = "";
  var type = "";
  var image = "";
  var member = <String>[];
  var updateTime = "";

  ChannelChat({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.image,
    required this.member,
    required this.updateTime,
  });
}

class InboxCounter {
  var id = "";
  var inbox = 0;
  InboxCounter({required this.id, required this.inbox});
}
