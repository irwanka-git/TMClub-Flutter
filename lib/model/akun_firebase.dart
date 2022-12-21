import 'dart:convert';

class AkunFirebase {
  String? displayName;
  String? email;
  String? idCompany;
  String? companyName;
  String? photoUrl;
  String? role;
  String? uid;
  String? phoneNumber;
  String? transactionNumber;

  AkunFirebase({
    this.displayName,
    this.email,
    this.idCompany,
    this.photoUrl,
    this.role,
    this.uid,
    this.phoneNumber,
    this.companyName,
    this.transactionNumber,
  });

  factory AkunFirebase.fromMap(Map<String, dynamic> data) => AkunFirebase(
        displayName: data['displayName'] as String?,
        email: data['email'] as String?,
        idCompany: data['idCompany'] as String?,
        photoUrl: data['photoURL'] as String?,
        role: data['role'] as String?,
        uid: data['uid'] as String?,
        transactionNumber: data['transaction_number'] != null
            ? data['transaction_number']
            : "" as String?,
        phoneNumber:
            data['nomorTelepon'] != null ? data['nomorTelepon'] : "" as String?,
      );

  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        'email': email,
        'idCompany': idCompany,
        'photoURL': photoUrl,
        'role': role,
        'uid': uid,
        'phoneNumber': phoneNumber,
        'transactionNumber': transactionNumber,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [AkunFirebase].
  factory AkunFirebase.fromJson(String data) {
    return AkunFirebase.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [AkunFirebase] to a JSON string.
  String toJson() => json.encode(toMap());

  String companyAsStringByName() {
    return '#${this.displayName} ${this.email} ${this.companyName}';
  }
}
