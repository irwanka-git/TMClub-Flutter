import 'dart:convert';

class Resources {
  int? pk;
  String? displayName;
  String? url;

  Resources({this.pk, this.displayName, this.url});

  @override
  String toString() {
    return 'Resources(pk: $pk, displayName: $displayName, url: $url)';
  }

  factory Resources.fromMap(Map<String, dynamic> data) => Resources(
        pk: data['pk'] as int?,
        displayName: data['display_name'] as String?,
        url: data['url'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'pk': pk,
        'display_name': displayName,
        'url': url,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Resources].
  factory Resources.fromJson(String data) {
    return Resources.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Resources] to a JSON string.
  String toJson() => json.encode(toMap());
}
