import 'dart:convert';

class NotificationItem {
  int? id;
  String? title;
  String? summary;
  String? contentTypeModel;
  int? objectId;
  dynamic? button;
  bool? isRead;

  NotificationItem({
    this.id,
    this.title,
    this.summary,
    this.contentTypeModel,
    this.objectId,
    this.button,
    this.isRead,
  });

  factory NotificationItem.fromMap(Map<String, dynamic> data) => NotificationItem(
        id: data['id'] ?? 0,
        title: data['title'] ?? "",
        summary: data['summary'] ?? "",
        contentTypeModel: data['content_type_model'] ?? "",
        objectId: data['object_id'] ?? 0,
        button: data['button'] ?? {},
        isRead: data['is_read'] ?? false,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'summary': summary,
        'content_type_model': contentTypeModel,
        'object_id': objectId,
        'button': button,
        'is_read': isRead,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Notification].
  factory NotificationItem.fromJson(String data) {
    return NotificationItem.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Notification] to a JSON string.
  String toJson() => json.encode(toMap());
}
