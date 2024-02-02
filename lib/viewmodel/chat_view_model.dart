import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_lovers/locatior.dart';
import 'package:flutter_lovers/models/mesaj.dart';
import 'package:flutter_lovers/models/user.dart';
import 'package:flutter_lovers/repository/user_repository.dart';

enum ChatViewState { Idle, Loaded, Busy }

class ChatViewModel with ChangeNotifier {
  List<Mesaj>? _tumMesajlar;
  ChatViewState _state = ChatViewState.Idle;
  static final sayfaBasinaGonderiSayisi = 10;
  UserRepository _userRepository = locator<UserRepository>();

  final User1? currentUser;
  final User1? sohbetEdilenUser;
  Mesaj? _enSonGetirilenMesaj;
  Mesaj? _listeyeEklenenIlkMesaj;
  bool _hasMore = true;
  bool _yeniMesajDinleListener = false;

  bool get hasMoreLoading => _hasMore;
  StreamSubscription? _streamSubscription;

  ChatViewModel({required this.currentUser, required this.sohbetEdilenUser}) {
    _tumMesajlar = [];
    getMessageWithPagination(false);
  }
  List<Mesaj>? get mesajlarListesi => _tumMesajlar;

  ChatViewState get state => _state;

  set state(ChatViewState value) {
    _state = value;
    notifyListeners();
  }

  @override
  dispose() {
    _streamSubscription!.cancel();
    super.dispose();
  }

  Future<bool> saveMessage(Mesaj kaydedilecekMesaj,User1 currentUser) async {
    return await _userRepository.saveMessage(kaydedilecekMesaj, currentUser);
  }

  void getMessageWithPagination(bool yeniMesajlarGetiriliyor) async {
    if (_tumMesajlar!.length > 0) {
      _enSonGetirilenMesaj = _tumMesajlar!.last;
    }

    if (!yeniMesajlarGetiriliyor) state = ChatViewState.Busy;

    var getirilenMesajlar = await _userRepository.getMessageWithPagination(
        currentUser!.userID!,
        sohbetEdilenUser!.userID!,
        _enSonGetirilenMesaj,
        sayfaBasinaGonderiSayisi);

    if (getirilenMesajlar.length < sayfaBasinaGonderiSayisi) {
      _hasMore = false;
    }
/* 
    getirilenMesajlar
        .forEach((msj) => print("GETİRİLEN MESAJLAR  : " + msj.mesaj)); */

    _tumMesajlar!.addAll(getirilenMesajlar);

    if (_tumMesajlar!.length > 0) {
      _listeyeEklenenIlkMesaj = _tumMesajlar!.first;
    }

    state = ChatViewState.Loaded;

    if (_yeniMesajDinleListener == false) {
      _yeniMesajDinleListener = true;
      yeniMesajListenerAta();
    }
  }

  Future<void> dahaFazlaMesajGetir() async {
    if (_hasMore)
      getMessageWithPagination(true);
    else
      await Future.delayed(const Duration(seconds: 4));
  }

  void yeniMesajListenerAta() {
    _streamSubscription = _userRepository
        .getMessages(currentUser!.userID!, sohbetEdilenUser!.userID!)
        .listen((anlikData) {
      if (anlikData.isNotEmpty) {
        if (anlikData[0].date != null) {
          if (_listeyeEklenenIlkMesaj == null) {
            _tumMesajlar!.insert(0, anlikData[0]);
          } else if (_listeyeEklenenIlkMesaj!.date!.millisecondsSinceEpoch !=
              anlikData[0].date!.millisecondsSinceEpoch) {
            _tumMesajlar!.insert(0, anlikData[0]);
          }
        }
        state = ChatViewState.Loaded;
      }
    });
  }
}
