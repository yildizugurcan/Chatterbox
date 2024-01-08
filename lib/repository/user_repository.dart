import 'dart:io';
import 'package:flutter_lovers/locatior.dart';
import 'package:flutter_lovers/models/konusma.dart';
import 'package:flutter_lovers/models/mesaj.dart';
import 'package:flutter_lovers/models/user.dart';
import 'package:flutter_lovers/services/auth_base.dart';
import 'package:flutter_lovers/services/fake_auth_service.dart';
import 'package:flutter_lovers/services/firebase_auth_service.dart';
import 'package:flutter_lovers/services/firebase_storage_service.dart';
import 'package:flutter_lovers/services/firestore_db_service.dart';

enum AppMode { DEBUG, RELEASE }

class UserRepository implements AuthBase {
  FirebaseAuthService _firebaseAuthService = locator<FirebaseAuthService>();
  FakeAuthenticationService _fakeAuthenticationService =
      locator<FakeAuthenticationService>();
  FireStoreDBService _fireStoreDBService = locator<FireStoreDBService>();
  FirebaseStorageService _firebaseStorageService =
      locator<FirebaseStorageService>();

  AppMode appMode = AppMode.RELEASE; // DEBUG = fake AUTH    RELASE = FİREBASE

  List<User1>? tumKullaniciListesi = [];

  @override
  Future<User1?> currentUser() async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.currentUser();
    } else {
      User1? _user = await _firebaseAuthService.currentUser();
      return await _fireStoreDBService.readUser(_user!.userID!);
    }
  }

  @override
  Future<User1?> signInAnonymously() async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.signInAnonymously();
    } else {
      return await _firebaseAuthService.signInAnonymously();
    }
  }

  @override
  Future<bool> signOut() async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.signOut();
    } else {
      return await _firebaseAuthService.signOut();
    }
  }

  @override
  Future<User1?> signInWithGoogle() async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.signInWithGoogle();
    } else {
      User1? _user = await _firebaseAuthService.signInWithGoogle();

      bool _sonuc = await _fireStoreDBService.saveUser(_user!);
      if (_sonuc) {
        return await _fireStoreDBService.readUser(_user.userID!);
      } else
        return null;
    }
  }

  @override
  Future<User1?> createUserWithEmailandPassword(
      String email, String sifre) async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.createUserWithEmailandPassword(
          email, sifre);
    } else {
      User1? _user = await _firebaseAuthService.createUserWithEmailandPassword(
          email, sifre);
      bool _sonuc = await _fireStoreDBService.saveUser(_user!);
      if (_sonuc) {
        return await _fireStoreDBService.readUser(_user.userID!);
      } else
        return null;
    }
  }

  @override
  Future<User1?> signInWithEmailandPassword(String email, String sifre) async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.signInWithEmailandPassword(
          email, sifre);
    } else {
      User1? _user =
          await _firebaseAuthService.signInWithEmailandPassword(email, sifre);

      return await _fireStoreDBService.readUser(_user!.userID!);
    }
  }

  Future<bool> updateUserName(String userID, String yeniUserName) async {
    if (appMode == AppMode.DEBUG) {
      return false;
    } else {
      return await _fireStoreDBService.updateUserName(userID, yeniUserName);
    }
  }

  Future<String> uploadFile(
      String userID, String fileType, File profilFoto) async {
    if (appMode == AppMode.DEBUG) {
      return 'dosya_indirme_linki';
    } else {
      var profilFotoURL = await _firebaseStorageService.uploadFile(
          userID, fileType, profilFoto);

      await _fireStoreDBService.updateProfilFoto(userID, profilFotoURL);

      return profilFotoURL;
    }
  }

  Stream<List<Mesaj>> getMessages(
      String currentUserID, String sohbetEdilenUserID) {
    if (appMode == AppMode.DEBUG) {
      return Stream.empty();
    } else {
      return _fireStoreDBService.getMessages(currentUserID, sohbetEdilenUserID);
    }
  }

  Future<bool> saveMessage(Mesaj kaydedilecekMesaj) async {
    if (appMode == AppMode.DEBUG) {
      return true;
    } else {
      return _fireStoreDBService.saveMessage(kaydedilecekMesaj);
    }
  }

  Future<List<Konusma>> getAllConversations(String userID) async {
    if (appMode == AppMode.DEBUG) {
      return [];
    } else {
      var konusmaListesi =
          await _fireStoreDBService.getAllConversations(userID);

      for (var oankiKonusma in konusmaListesi) {
        var userListesindekiKullanici =
            listedeUserBul(oankiKonusma.kimle_konusuyor!);

        if (userListesindekiKullanici != null) {
          oankiKonusma.konusulanUserName = userListesindekiKullanici.userName;
          oankiKonusma.konusulanUserProfilURL =
              userListesindekiKullanici.profilURL;
        } else {
          var _veritabanindanOkunanUser =
              await _fireStoreDBService.readUser(oankiKonusma.kimle_konusuyor!);
          oankiKonusma.konusulanUserName = _veritabanindanOkunanUser.userName;
          oankiKonusma.konusulanUserProfilURL =
              _veritabanindanOkunanUser.profilURL;
        }
      }
      return konusmaListesi;
    }
  }

  User1? listedeUserBul(String userID) {
    for (int i = 0; i < tumKullaniciListesi!.length; i++) {
      if (tumKullaniciListesi![i].userID == userID) {
        return tumKullaniciListesi![i];
      }
    }

    return null;
  }

  Future<List<User1>> getUserwithPagination(
      User1? enSonGetirilenUser, int getirilecekElemanSayisi) async {
    try {
      enSonGetirilenUser ??= User1.nullUser;

      List<User1> _userList = await _fireStoreDBService.getUserwithPagination(
          enSonGetirilenUser!, getirilecekElemanSayisi);
      tumKullaniciListesi!.addAll(_userList);

      return _userList;
    } catch (e) {
      return [];
    }
  }

  Future<List<Mesaj>> getMessageWithPagination(
      String currentUserID,
      String sohbetEdilenUserID,
      Mesaj? enSonGetirilenMesaj,
      int getirilecekElemanSayisi) async {
    try {
      return await _fireStoreDBService.getMessageWithPagination(currentUserID,
          sohbetEdilenUserID, enSonGetirilenMesaj, getirilecekElemanSayisi);
    } catch (e) {
      return [];
    }
  }
}
