import 'package:flutter_lovers/models/konusma.dart';
import 'package:flutter_lovers/models/mesaj.dart';
import 'package:flutter_lovers/models/user.dart';
import 'package:flutter_lovers/services/database_base.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreDBService implements DBBase {
  final FirebaseFirestore _firebaseDB = FirebaseFirestore.instance;

  @override
  Future<bool> saveUser(User1 user) async {
    await _firebaseDB.collection('users').doc(user.userID).set(user.toMap());

    DocumentSnapshot _okunanUser =
        await FirebaseFirestore.instance.doc('users/${user.userID}').get();

    Map<String, dynamic>? _okunanUserBilgileriMap =
        _okunanUser.data() as Map<String, dynamic>?;

    if (_okunanUserBilgileriMap != null) {
      // User1 _okunanUserBilgileriNesne = User1.fromMap(_okunanUserBilgileriMap);
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<User1> readUser(String userID) async {
    DocumentSnapshot _okunanUser =
        await _firebaseDB.collection('users').doc(userID).get();

    if (_okunanUser.exists) {
      Map<String, dynamic>? _okunanUserBilgileriMap =
          _okunanUser.data() as Map<String, dynamic>?;

      if (_okunanUserBilgileriMap != null) {
        User1 _okunanUserNesnesi = User1.fromMap(_okunanUserBilgileriMap);
        return _okunanUserNesnesi;
      } else {
        throw Exception("Firebase'dan alınan veri boş.");
      }
    } else {
      throw Exception("Belirtilen kullanıcı ID'sine sahip belge bulunamadı.");
    }
  }

  @override
  Future<bool> updateUserName(String userID, String yeniUserName) async {
    var users = await _firebaseDB
        .collection('users')
        .where('userName', isEqualTo: yeniUserName)
        .get();
    if (users.docs.length >= 1) {
      return false;
    } else {
      await _firebaseDB
          .collection('users')
          .doc(userID)
          .update({'userName': yeniUserName});
      return true;
    }
  }

  @override
  Future<bool> updateProfilFoto(String userID, String profilFotoURL) async {
    await _firebaseDB
        .collection('users')
        .doc(userID)
        .update({'profilURL': profilFotoURL});
    return true;
  }

  @override
  Future<List<User1>?> getAllUser() async {
    QuerySnapshot querySnapShot = await _firebaseDB.collection('users').get();

    List<User1> tumKullaniciListesi = [];
    for (DocumentSnapshot tekUser in querySnapShot.docs) {
      Map<String, dynamic>? userData = tekUser.data() as Map<String, dynamic>?;

      if (userData != null) {
        User1 _tekUser = User1.fromMap(userData);
        tumKullaniciListesi.add(_tekUser);
      }
    }

    return tumKullaniciListesi;
  }

  @override
  Future<List<Konusma>> getAllConversations(String userID) async {
    QuerySnapshot querySnapshot = await _firebaseDB
        .collection('konusmalar')
        .where('konusma_sahibi', isEqualTo: userID)
        .orderBy('olusturulma_tarihi', descending: true)
        .get();

    List<Konusma> tumKonusmalar = [];
    for (DocumentSnapshot tekKonusma in querySnapshot.docs) {
      var data = tekKonusma.data();
      if (data is Map<String, dynamic>) {
        Konusma _tekKonusma = Konusma.fromMap(data);
        tumKonusmalar.add(_tekKonusma);
      } else {}
    }

    return tumKonusmalar;
  }

  @override
  Stream<List<Mesaj>> getMessages(
      String currentUserID, String sohbetEdilenUserID) {
    var snapShot = _firebaseDB
        .collection('konusmalar')
        .doc(currentUserID + '--' + sohbetEdilenUserID)
        .collection('mesajlar')
        .orderBy('date', descending: true)
        .snapshots();
    return snapShot.map((mesajListesi) =>
        mesajListesi.docs.map((mesaj) => Mesaj.fromMap(mesaj.data())).toList());
  }

  Future<bool> saveMessage(Mesaj kaydedilecekMesaj) async {
    var _mesajID = _firebaseDB.collection('konusmalar').doc().id;
    var _myDocumentID =
        kaydedilecekMesaj.kimden + '--' + kaydedilecekMesaj.kime;
    var _receiverDocumentID =
        kaydedilecekMesaj.kime + '--' + kaydedilecekMesaj.kimden;

    var _kaydedilecekMesajMapYapisi = kaydedilecekMesaj.toMap();

    await _firebaseDB
        .collection('konusmalar')
        .doc(_myDocumentID)
        .collection('mesajlar')
        .doc(_mesajID)
        .set(_kaydedilecekMesajMapYapisi);

    await _firebaseDB.collection('konusmalar').doc(_myDocumentID).set({
      'konusma_sahibi': kaydedilecekMesaj.kimden,
      'kimle_konusuyor': kaydedilecekMesaj.kime,
      'son_yollanan_mesaj': kaydedilecekMesaj.mesaj,
      'konusma_goruldu': false,
      'olusturulma_tarihi': FieldValue.serverTimestamp(),
    });

    _kaydedilecekMesajMapYapisi.update('bendenMi', (deger) => false);

    await _firebaseDB
        .collection('konusmalar')
        .doc(_receiverDocumentID)
        .collection('mesajlar')
        .doc(_mesajID)
        .set(_kaydedilecekMesajMapYapisi);

    await _firebaseDB.collection('konusmalar').doc(_receiverDocumentID).set({
      'konusma_sahibi': kaydedilecekMesaj.kime,
      'kimle_konusuyor': kaydedilecekMesaj.kimden,
      'son_yollanan_mesaj': kaydedilecekMesaj.mesaj,
      'konusma_goruldu': false,
      'olusturulma_tarihi': FieldValue.serverTimestamp(),
    });

    return true;
  }

  @override
  Future<DateTime> saatiGoster(String userID) async {
    await _firebaseDB.collection('server').doc(userID).set({
      'saat': FieldValue.serverTimestamp(),
    });

    var okunanMap =
        (await _firebaseDB.collection('server').doc(userID).get()).data();

    if (okunanMap == null || okunanMap['saat'] == null) {
      return DateTime.now();
    }

    Timestamp okunanTarih = okunanMap['saat'];
    return okunanTarih.toDate();
  }
}
