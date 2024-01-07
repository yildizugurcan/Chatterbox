import 'package:flutter_lovers/models/konusma.dart';
import 'package:flutter_lovers/models/mesaj.dart';
import 'package:flutter_lovers/models/user.dart';

abstract class DBBase {
  Future<bool> saveUser(User1 user);
  Future<User1> readUser(String userID);
  Future<bool> updateUserName(String userID, String yeniUserName);
  Future<bool> updateProfilFoto(String userID, String profilFotoURL);
  Future<List<User1>> getUserwithPagination(
      User1 enSonGetirilenUser, int getirilecekElemanSayisi);

  Future<List<Konusma>> getAllConversations(String userID);
  Stream<List<Mesaj>> getMessages(String currentUserID, String konusulanUserID);
  Future<bool> saveMessage(Mesaj kaydedilecekMesaj);
  Future<DateTime> saatiGoster(String userID);
}
