import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class User1 {
  final String? userID;
  String? email;
  String? userName;
  String? profilURL;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? seviye;

  User1({required this.userID, required this.email});

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'email': email,
      'userName': userName ??
          email!.substring(0, email!.indexOf('@')) + randomSayiUret(),
      'profilURL': profilURL ??
          'https://cdn-icons-png.flaticon.com/128/3135/3135715.png',
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
      'seviye': seviye ?? 1,
    };
  }

  User1.fromMap(Map<String, dynamic> map)
      : userID = map['userID'],
        email = map['email'],
        userName = map['userName'],
        profilURL = map['profilURL'],
        createdAt = (map['createdAt'] as Timestamp).toDate(),
        updatedAt = (map['updatedAt'] as Timestamp).toDate(),
        seviye = map['seviye'];

  User1.idveResim({required this.userID, required this.profilURL});

  @override
  String toString() {
    return 'User1{userID: $userID,email: $email,userName: $userName,profilURL: $profilURL, createdAt: $createdAt, updatedAt: $updatedAt,seviye: $seviye}';
  }

  String randomSayiUret() {
    int rastgeleSayi = Random().nextInt(999999);
    return rastgeleSayi.toString();
  }
}
