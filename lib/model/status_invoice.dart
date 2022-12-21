import 'dart:convert';

class StatusInvoice {
  int? id;
  String? displayName;

  StatusInvoice({this.id, this.displayName});

  factory StatusInvoice.fromMap(Map<String, dynamic> data) => StatusInvoice(
        id: data['id'] as int?,
        displayName: data['display_name'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'display_name': displayName,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [StatusInvoice].
  factory StatusInvoice.fromJson(String data) {
    return StatusInvoice.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [StatusInvoice] to a JSON string.
  String toJson() => json.encode(toMap());
}
