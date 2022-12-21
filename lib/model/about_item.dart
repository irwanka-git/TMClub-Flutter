import 'dart:convert';

class AboutItem {
  int? id;
  String? md;
  String? description;
  List<dynamic>? organizations;
  List<dynamic>? annualDirectories;

  AboutItem({this.id, this.md, this.description, this.organizations, this.annualDirectories});

  factory AboutItem.fromMap(Map<String, dynamic> data) => AboutItem(
        id: data['id'] as int?,
        md: data['md'] as String?,
        description: data['description'] as String?,
        organizations: data['organizations'] as List<dynamic>?,
        annualDirectories: data['annual_directories'] as List<dynamic>?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'md': md,
        'description': description,
        'organizations': organizations,
        'annual_directories': annualDirectories,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [AboutItem].
  factory AboutItem.fromJson(String data) {
    return AboutItem.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [AboutItem] to a JSON string.
  String toJson() => json.encode(toMap());
}
