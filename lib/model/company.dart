import 'dart:convert';

class Company {
  String? pk;
  String? displayName;
  String? address;
  String? mainImageUrl;
  String? city;

  Company(
      {this.pk, this.displayName, this.address, this.mainImageUrl, this.city});

  factory Company.fromMap(Map<String, dynamic> data) => Company(
        pk: data['pk'].toString() as String?,
        displayName: data['display_name'] as String?,
        address: data['address'] as String?,
        mainImageUrl: data['main_image_url'] as String?,
        city: data['city'] != null ? data['city'] as String? : "",
      );

  Map<String, dynamic> toMap() => {
        'pk': pk,
        'display_name': displayName,
        'address': address,
        'main_image_url': mainImageUrl,
        'city': city,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Company].
  factory Company.fromJson(String data) {
    return Company.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Company] to a JSON string.
  String toJson() => json.encode(toMap());

  String companyAsStringByName() {
    return '#${this.pk} ${this.displayName}';
  }
}
