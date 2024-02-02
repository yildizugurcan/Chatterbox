import 'package:flutter_lovers/models/mesaj.dart';
import 'package:flutter_lovers/models/user.dart';
import 'package:flutter_lovers/tokens.dart';
import 'package:http/http.dart' as http;

class BildirimGondermeServis {
  Future<bool> bildirimGonder(
      Mesaj gonderilecekBildirim, User1 gonderenUser, String token) async {
    Map<String, String> headers = {
      'Authorization': 'Bearer ${Tokens().firebaseKey}',
      'User-Agent': 'PostmanRuntime/7.36.1',
      'Accept': '*/*',
      'Accept-Encoding': 'gzip, deflate, br',
      'Connection': 'keep-alive',
      'Content-Type': 'application/json'
    };

    String json =
        '{ "message" : { "token" : "$token","notification" : { "title": "Chatterbox Bildirim", "body" : "Yeni Mesaj" }, "data" : { "body" : "${gonderilecekBildirim.mesaj}", "title" : "${gonderenUser.userName} yeni mesaj", "profilURL" : "${gonderenUser.profilURL}", "gonderenUserID" : "${gonderenUser.userID}" } } }';
    print(gonderenUser.profilURL);
    Uri endUri = Uri.parse(Tokens().endURL);

    http.Response response =
        await http.post(endUri, headers: headers, body: json);

    if (response.statusCode == 200) {
    } else {}
    throw Exception('Bildirim gönderme işlemi başarısız.');
  }
}
