import 'dart:convert';

class PaymentMethod {
  int? id;
  String? prefix;
  String? desc;

  PaymentMethod({this.id, this.prefix, this.desc});

  factory PaymentMethod.fromMap(Map<String, dynamic> data) => PaymentMethod(
        id: data['id'] ?? 0,
        prefix: data['prefix'] ?? "",
        desc: data['desc'] ?? "",
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'prefix': prefix,
        'desc': desc,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [PaymentMethod].
  factory PaymentMethod.fromJson(String data) {
    return PaymentMethod.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [PaymentMethod] to a JSON string.
  String toJson() => json.encode(toMap());
  String paymentAsStringByName() {
    return '${this.prefix} - ${this.desc}';
  }
}
