import 'dart:convert';

import 'package:tmcapp/model/event_tmc.dart';

class EventTmcDetil {
  int? pk;
  String? title;
  DateTime? date;
  String? venue;
  int? mainImage;
  String? mainImageUrl;
  String? description;
  bool? isFree;
  bool? isRegistrationClose;
  bool? isListAttendees;
  int? price;
  List<dynamic>? adminActivity;
  DateTime? createdAt;
  String? owned_by_email;
  List<dynamic>? media_id;
  List<dynamic>? media_url;
  List<dynamic>? surveys_id;

  EventTmcDetil({
    this.pk,
    this.title,
    this.date,
    this.venue,
    this.mainImage,
    this.mainImageUrl,
    this.description,
    this.isFree,
    this.isRegistrationClose,
    this.isListAttendees,
    this.price,
    this.adminActivity,
    this.createdAt,
    this.owned_by_email,
    this.media_id,
    this.media_url,
    this.surveys_id,
  });

  factory EventTmcDetil.fromMap(Map<String, dynamic> data) => EventTmcDetil(
        pk: data['pk'] as int?,
        title: data['title'] as String?,
        date: data['date'] == null
            ? null
            : DateTime.parse(data['date'] as String),
        venue: data['venue'] as String?,
        owned_by_email: data['owned_by_email'] as String?,
        mainImage: data['main_image'] as int?,
        mainImageUrl: data['main_image_url'] as String?,
        description: data['description'] as String?,
        isFree: data['is_free'] as bool?,
        isRegistrationClose: data['is_registration_close'] as bool?,
        isListAttendees: data['is_list_attendees'] as bool?,
        price: data['price'] as int?,
        adminActivity: data['admin_activity'] as List<dynamic>?,
        media_id: data['media_id'] as List<dynamic>?,
        media_url: data['media_url'] as List<dynamic>?,
        surveys_id: data['surveys_id'] as List<dynamic>?,
        createdAt: data['created_at'] == null
            ? null
            : DateTime.parse(data['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'pk': pk,
        'title': title,
        'date': date?.toIso8601String(),
        'venue': venue,
        'main_image': mainImage,
        'main_image_url': mainImageUrl,
        'description': description,
        'is_free': isFree,
        'owned_by_email': owned_by_email,
        'is_registration_close': isRegistrationClose,
        'is_list_attendees': isListAttendees,
        'price': price,
        'admin_activity': adminActivity,
        'media_id': media_id,
        'media_url': media_url,
        'surveys_id': surveys_id,
        'created_at': createdAt?.toIso8601String(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [EventTmcDetil].
  factory EventTmcDetil.fromJson(String data) {
    return EventTmcDetil.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [EventTmcDetil] to a JSON string.
  String toJson() => json.encode(toMap());

  EventTmc convertToEventListItem() {
    return EventTmc(
        pk: this.pk!,
        title: this.title,
        date: this.date,
        venue: this.venue,
        mainImageUrl: this.mainImageUrl,
        description: this.description,
        isFree: this.isFree);
  }
}
