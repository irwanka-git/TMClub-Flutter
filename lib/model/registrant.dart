import 'dart:convert';

class Registrant {
  String? email;
  String? displayName;
  String? photoUrl;
  bool? isRegistrant;
  String? companyId;
  String? companyName;
  String? phoneNumber;
  String? attendance_time;

  Registrant({
    this.email,
    this.displayName,
    this.photoUrl,
    this.isRegistrant,
    this.companyId,
    this.companyName,
    this.phoneNumber,
    this.attendance_time,
  });

  @override
  String toString() {
    return 'Registrant(email: $email, displayName: $displayName, photoUrl: $photoUrl, isRegistrant: $isRegistrant, companyId: $companyId, companyName: $companyName, phoneNumber: $phoneNumber)';
  }

  factory Registrant.fromMap(Map<String, dynamic> data) => Registrant(
        email: data['email'] as String?,
        displayName: data['displayName'] as String?,
        photoUrl: data['photoURL'] as String?,
        isRegistrant:
            data['isRegistrant'] != null ? data['isRegistrant'] : true as bool?,
        companyId: data['companyID'] as String?,
        companyName: data['companyName'] as String?,
        phoneNumber: data['phoneNumber'] as String?,
        attendance_time: data['attendance_time'] != null
            ? data['attendance_time']
            : "" as String?,
      );

  Map<String, dynamic> toMap() => {
        'email': email,
        'displayName': displayName,
        'photoURL': photoUrl,
        'isRegistrant': isRegistrant,
        'companyID': companyId,
        'companyName': companyName,
        'phoneNumber': phoneNumber,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Registrant].
  factory Registrant.fromJson(String data) {
    return Registrant.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Registrant] to a JSON string.
  String toJson() => json.encode(toMap());
}
