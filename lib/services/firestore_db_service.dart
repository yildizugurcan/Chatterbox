import 'package:flutter_lovers/models/konusma.dart';
import 'package:flutter_lovers/models/mesaj.dart';
import 'package:flutter_lovers/models/user.dart';
import 'package:flutter_lovers/services/database_base.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreDBService implements DBBase {
  final FirebaseFirestore _firebaseDB = FirebaseFirestore.instance;

  @override
  Future<bool> saveUser(User1 user) async {
    DocumentSnapshot _okunanUser =
        await FirebaseFirestore.instance.doc('users/${user.userID}').get();

    if (_okunanUser.data() == null) {
      await _firebaseDB.collection('users').doc(user.userID).set(user.toMap());
      return true;
    } else {
      return true;
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
        .limit(1)
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

  @override
  Future<List<User1>> getUserwithPagination(
      User1 enSonGetirilenUser, int getirilecekElemanSayisi) async {
    QuerySnapshot _querySnapshot;
    List<User1> _tumKullanicilar = [];

    if (enSonGetirilenUser == null) {
      _querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('userName')
          .limit(getirilecekElemanSayisi)
          .get();
    } else {
      _querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('userName')
          .startAfter([enSonGetirilenUser!.userName])
          .limit(getirilecekElemanSayisi)
          .get();

      await Future.delayed(Duration(seconds: 2));
    }
    for (DocumentSnapshot snap in _querySnapshot.docs) {
      User1 _tekUser = User1.fromMap(snap.data() as Map<String, dynamic>);
      _tumKullanicilar.add(_tekUser);
    }
    return _tumKullanicilar;
  }

  @override
  Future<List<Mesaj>> getMessageWithPagination(
      String currentUserID,
      String sohbetEdilenUserID,
      Mesaj? enSonGetirilenMesaj,
      int getirilecekElemanSayisi) async {
    QuerySnapshot _querySnapshot;
    List<Mesaj> _tumMesajlar = [];

    if (enSonGetirilenMesaj == null) {
      _querySnapshot = await FirebaseFirestore.instance
          .collection('konusmalar')
          .doc(currentUserID + '--' + sohbetEdilenUserID)
          .collection('mesajlar')
          .orderBy('date', descending: true)
          .limit(getirilecekElemanSayisi)
          .get();
    } else {
      _querySnapshot = await FirebaseFirestore.instance
          .collection('konusmalar')
          .doc(currentUserID + '--' + sohbetEdilenUserID)
          .collection('mesajlar')
          .orderBy('date', descending: true)
          .startAfter([enSonGetirilenMesaj.date])
          .limit(getirilecekElemanSayisi)
          .get();

      await Future.delayed(const Duration(seconds: 1));
    }
    for (DocumentSnapshot snap in _querySnapshot.docs) {
      Mesaj _tekMesaj = Mesaj.fromMap(snap.data() as Map<String, dynamic>);
      _tumMesajlar.add(_tekMesaj);
    }
    return _tumMesajlar;
  }

  Future<String> tokenGetir(String kime) async {
    DocumentSnapshot _token = await _firebaseDB.doc('tokens/' + kime).get();

    Map<String, dynamic>? tokenData = _token.data() as Map<String, dynamic>?;

    if (tokenData != null) {
      return tokenData["token"];
    } else {
      return "VarsayılanToken";
    }
  }
}
