import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_lovers/locatior.dart';
import 'package:flutter_lovers/models/konusma.dart';
import 'package:flutter_lovers/models/mesaj.dart';
import 'package:flutter_lovers/models/user.dart';
import 'package:flutter_lovers/repository/user_repository.dart';
import 'package:flutter_lovers/services/auth_base.dart';

enum ViewState { Idle, Busy }

class UserModel with ChangeNotifier implements AuthBase {
  late ViewState _state;

  UserRepository _userRepository = locator<UserRepository>();
  User1? _user;
  User1? get user => _user;

  String? emailHataMesaji;
  String? sifreHataMesaji;

  ViewState get state => _state;

  set state(ViewState value) {
    _state = value;
    notifyListeners();
  }

  UserModel() {
    currentUser();
  }

  @override
  Future<User1?> currentUser() async {
    try {
      state = ViewState.Busy;
      _user = (await _userRepository.currentUser())!;
      return _user;
    } catch (e) {
      return null;
    } finally {
      state = ViewState.Idle;
    }
  }

  @override
  Future<User1?> signInAnonymously() async {
    try {
      state = ViewState.Busy;
      _user = await _userRepository.signInAnonymously();
      return _user;
    } catch (e) {
      return null;
    } finally {
      state = ViewState.Idle;
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      state = ViewState.Busy;
      bool sonuc = await _userRepository.signOut();
      _user = null;
      return sonuc;
    } catch (e) {
      return false;
    } finally {
      state = ViewState.Idle;
    }
  }

  @override
  Future<User1?> signInWithGoogle() async {
    try {
      state = ViewState.Busy;
      _user = await _userRepository.signInWithGoogle();
      return _user;
    } catch (e) {
      return null;
    } finally {
      state = ViewState.Idle;
    }
  }



  @override
  Future<User1?> createUserWithEmailandPassword(
      String email, String sifre) async {
    if (_emailSifreKontrol(email, sifre)) {
      try {
        state = ViewState.Busy;
        _user =
            await _userRepository.createUserWithEmailandPassword(email, sifre);

        return _user;
      } finally {
        state = ViewState.Idle;
      }
    } else {
      return null;
    }
  }

  @override
  Future<User1?> signInWithEmailandPassword(String email, String sifre) async {
    try {
      if (_emailSifreKontrol(email, sifre)) {
        state = ViewState.Busy;
        _user = await _userRepository.signInWithEmailandPassword(email, sifre);

        return _user;
      } else {
        return null;
      }
    } finally {
      state = ViewState.Idle;
    }
  }

  bool _emailSifreKontrol(String email, String sifre) {
    var sonuc = true;

    if (sifre.length < 6) {
      sifreHataMesaji = 'En az 6 karakter olmalı';
      sonuc = false;
    } else {
      sifreHataMesaji = null;
    }

    if (!email.contains('@')) {
      emailHataMesaji = 'Geçersiz email adresi';
      sonuc = false;
    } else {
      emailHataMesaji = null;
    }

    return sonuc;
  }

  Future<bool> updateUserName(String userID, String yeniUserName) async {
    var sonuc = await _userRepository.updateUserName(userID, yeniUserName);
    if (sonuc) {
      _user!.userName = yeniUserName;
    }
    return sonuc;
  }

  Future<String> uploadFile(
      String? userID, String fileType, File profilFoto) async {
    var indirmeLinki =
        await _userRepository.uploadFile(userID!, fileType, profilFoto);
    return indirmeLinki;
  }

  Stream<List<Mesaj>> getMessages(
      String currentUserID, String sohbetEdilenUserID) {
    return _userRepository.getMessages(currentUserID, sohbetEdilenUserID);
  }

  Future<List<Konusma>> getAllConversations(String userID) async {
    return await _userRepository.getAllConversations(userID);
  }

  Future<List<User1>> getUserwithPagination(
      User1 enSonGetirilenUser, int getirilecekElemanSayisi) async {
    return await _userRepository.getUserwithPagination(
        enSonGetirilenUser, getirilecekElemanSayisi);
  }
}
