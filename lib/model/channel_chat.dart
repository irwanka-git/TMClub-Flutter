class ChannelChat {
  var id = "";
  var title = "";
  var subtitle = "";
  var type = "";
  var image = "";
  var member = <String>[];
  var updateTime = "";
  var eventId = "";

  ChannelChat({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.image,
    required this.member,
    required this.updateTime,
    required this.eventId,
  });
}

class InboxCounter {
  var id = "";
  var inbox = 0;
  InboxCounter({required this.id, required this.inbox});
}
