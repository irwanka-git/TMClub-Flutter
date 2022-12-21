import 'dart:convert';

class EventTmc {
  int? pk;
  String? title;
  DateTime? date;
  String? venue;
  String? mainImageUrl;
  String? description;
  bool? isFree;

  EventTmc({
    this.pk,
    this.title,
    this.date,
    this.venue,
    this.mainImageUrl,
    this.description,
    this.isFree,
  });

  factory EventTmc.fromMap(Map<String, dynamic> data) => EventTmc(
        pk: data['pk'] as int?,
        title: data['title'] as String?,
        date: data['date'] == null
            ? null
            : DateTime.parse(data['date'] as String),
        venue: data['venue'] as String?,
        mainImageUrl: data['main_image_url'] as String?,
        description: data['description'] as String?,
        isFree: data['is_free'] as bool?,
      );

  Map<String, dynamic> toMap() => {
        'pk': pk,
        'title': title,
        'date': date?.toIso8601String(),
        'venue': venue,
        'main_image_url': mainImageUrl,
        'description': description,
        'is_free': isFree,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [EventTmc].
  factory EventTmc.fromJson(String data) {
    return EventTmc.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [EventTmc] to a JSON string.
  String toJson() => json.encode(toMap());
}
