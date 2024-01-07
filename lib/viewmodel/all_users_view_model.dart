import 'package:flutter/material.dart';
import 'package:flutter_lovers/locatior.dart';
import 'package:flutter_lovers/models/user.dart';
import 'package:flutter_lovers/repository/user_repository.dart';

enum AllUserViewState { Idle, Loaded, Busy }

class AllUserViewModel with ChangeNotifier {
  AllUserViewState _state = AllUserViewState.Idle;
  List<User1>? _tumKullanicilar;
  User1? _enSonGetirilenUser;
  static final sayfaBasinaGonderiSayisi = 10;
  bool _hasMore = true;

  bool get hasMoreLoading => _hasMore;

  UserRepository _userRepository = locator<UserRepository>();
  List<User1>? get kullanicilarListesi => _tumKullanicilar;

  AllUserViewState get state => _state;

  set state(AllUserViewState value) {
    _state = value;
    notifyListeners();
  }

  AllUserViewModel() {
    _tumKullanicilar = [];
    _enSonGetirilenUser = null;
    getUserwithPagination(_enSonGetirilenUser, false);
  }

  getUserwithPagination(
      User1? enSonGetirilenUser, bool yeniElemanlarGetiriliyor) async {
    if (_tumKullanicilar!.length > 0) {
      _enSonGetirilenUser = _tumKullanicilar!.last;
    }

    if (yeniElemanlarGetiriliyor) {
    } else {
      state = AllUserViewState.Busy;
    }

    var yeniListe = await _userRepository.getUserwithPagination(
        _enSonGetirilenUser, sayfaBasinaGonderiSayisi);

    if (yeniListe.length < sayfaBasinaGonderiSayisi) {
      _hasMore = false;
    }

    yeniListe.forEach((usr) {
    });

    _tumKullanicilar!.addAll(yeniListe);

    state = AllUserViewState.Loaded;
  }

  Future<void> dahaFazlaKullaniciGetir() async {
    if (_hasMore)
      getUserwithPagination(_enSonGetirilenUser, true);
    else
    await Future.delayed(const Duration(seconds: 4));
  }

  Future<Null> refresh() async {
    _hasMore = true;
    _enSonGetirilenUser = null;
    _tumKullanicilar = [];
    getUserwithPagination(_enSonGetirilenUser, true);
  }
}
