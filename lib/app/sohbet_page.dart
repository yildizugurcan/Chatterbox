import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lovers/models/mesaj.dart';
import 'package:flutter_lovers/models/user.dart';
import 'package:flutter_lovers/viewmodel/user_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SohbetPage extends StatefulWidget {
  final User1? currentUser;
  final User1? sohbetEdilenUser;

  const SohbetPage(
      {super.key, required this.currentUser, required this.sohbetEdilenUser});

  @override
  State<SohbetPage> createState() => _SohbetPageState();
}

class _SohbetPageState extends State<SohbetPage> {
  ScrollController _scrollController = ScrollController();

  var _mesajController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    User1 _currentUser = widget.currentUser!;
    User1 _sohbetEdilenUser = widget.sohbetEdilenUser!;
    final _userModel = Provider.of<UserModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sohbet'),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder<List<Mesaj>>(
              stream: _userModel.getMessages(
                  _currentUser.userID!, _sohbetEdilenUser.userID!),
              builder: (context, streamMesajlarListesi) {
                if (!streamMesajlarListesi.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                List<Mesaj> tumMesajlar = streamMesajlarListesi.data!;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: tumMesajlar!.length,
                  itemBuilder: (context, index) {
                    return _konusmaBalonuOlustur(tumMesajlar[index]);
                  },
                );
              },
            )),
            Container(
              padding: const EdgeInsets.only(bottom: 8, left: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _mesajController,
                      cursorColor: Colors.blueGrey,
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Mesajınızı Yazın',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),
                    child: FloatingActionButton(
                      elevation: 0,
                      backgroundColor: Colors.purple,
                      child: const Icon(
                        Icons.navigation,
                        size: 35,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        if (_mesajController.text.trim().length > 0) {
                          Mesaj _kaydedilecekMesaj = Mesaj(
                            kimden: _currentUser.userID!,
                            kime: _sohbetEdilenUser.userID!,
                            bendenMi: true,
                            mesaj: _mesajController.text,
                          );
                          var sonuc =
                              await _userModel.saveMessage(_kaydedilecekMesaj);
                          if (sonuc) {
                            _mesajController.clear();
                            _scrollController.animateTo(0.0,
                                duration: const Duration(milliseconds: 100),
                                curve: Curves.easeOut);
                          }
                        }
                      },
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _konusmaBalonuOlustur(Mesaj oankiMesaj) {
    Color _gelenMesajRenk = Colors.orange;
    Color _gidenMesajRenk = Theme.of(context).primaryColor;

    var _saatDakikaDegeri = '';
    try {
      _saatDakikaDegeri = _saatDakikaGoster(oankiMesaj.date ?? Timestamp(1, 1));
    } catch (e) {}

    var _benimMesajimMi = oankiMesaj.bendenMi;

    if (_benimMesajimMi) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: _gidenMesajRenk,
                    ),
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.all(4),
                    child: Text(
                      oankiMesaj.mesaj,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Text(_saatDakikaDegeri),
              ],
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.withAlpha(40),
                  backgroundImage:
                      NetworkImage(widget.sohbetEdilenUser!.profilURL!),
                ),
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: _gelenMesajRenk,
                    ),
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.all(4),
                    child: Text(
                      oankiMesaj.mesaj,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Text(_saatDakikaDegeri),
              ],
            )
          ],
        ),
      );
    }
  }

  String _saatDakikaGoster(Timestamp date) {
    var _formatter = DateFormat.Hm();
    var _formatlanmisTarih = _formatter.format(date.toDate());
    return _formatlanmisTarih;
  }
}
