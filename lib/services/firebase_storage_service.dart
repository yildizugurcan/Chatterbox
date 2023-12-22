import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_lovers/services/storage_base.dart';

class FirebaseStorageService implements StorageBase {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  Reference? _storageReference;

  @override
  Future<String> uploadFile(
      String userID, String fileType, File yuklenecekDosya) async {
    try {
      _storageReference = _firebaseStorage
          .ref()
          .child(userID)
          .child(fileType)
          .child('profil_foto.png');
      var uploadTask = _storageReference!.putFile(yuklenecekDosya);

      await uploadTask.whenComplete(() {});
      var url = await _storageReference!.getDownloadURL();

      return url;
    } catch (e) {
      return '';
    }
  }
}
