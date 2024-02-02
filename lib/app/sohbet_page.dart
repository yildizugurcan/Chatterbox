import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lovers/models/mesaj.dart';
import 'package:flutter_lovers/viewmodel/chat_view_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SohbetPage extends StatefulWidget {
  @override
  State<SohbetPage> createState() => _SohbetPageState();
}

class _SohbetPageState extends State<SohbetPage> {
  ScrollController _scrollController = new ScrollController();
  var _mesajController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    final _chatModel = Provider.of<ChatViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sohbet'),
      ),
      body: _chatModel.state == ChatViewState.Busy
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Column(
                children: [
                  _buildMesajListesi(),
                  _buildYeniMesajGir(),
                ],
              ),
            ),
    );
  }

  Widget _buildMesajListesi() {
    return Consumer<ChatViewModel>(
      builder: (context, chatModel, child) {
        return Expanded(
          child: ListView.builder(
            controller: _scrollController,
            reverse: true,
            itemCount: chatModel.hasMoreLoading
                ? chatModel.mesajlarListesi!.length + 1
                : chatModel.mesajlarListesi!.length,
            itemBuilder: (context, index) {
              if (chatModel.hasMoreLoading &&
                  chatModel.mesajlarListesi!.length == index) {
                return _yeniElemanlarYukleniyorIndicator();
              } else {
                return _konusmaBalonuOlustur(chatModel.mesajlarListesi![index]);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildYeniMesajGir() {
    final _chatModel = Provider.of<ChatViewModel>(context);

    return Container(
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
                Icons.send_rounded,
                size: 35,
                color: Colors.white,
              ),
              onPressed: () async {
                if (_mesajController.text.trim().length > 0) {
                  Mesaj _kaydedilecekMesaj = Mesaj(
                    kimden: _chatModel.currentUser!.userID!,
                    kime: _chatModel.sohbetEdilenUser!.userID!,
                    bendenMi: true,
                    mesaj: _mesajController.text,
                  );
                  var sonuc = await _chatModel.saveMessage(
                      _kaydedilecekMesaj, _chatModel.currentUser!);
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
    );
  }

  Widget _konusmaBalonuOlustur(Mesaj oankiMesaj) {
    Color _gelenMesajRenk = Colors.orange;
    Color _gidenMesajRenk = Theme.of(context).primaryColor;
    final _chatModel = Provider.of<ChatViewModel>(context);

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
                      NetworkImage(_chatModel.sohbetEdilenUser!.profilURL!),
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

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      eskiMesajlariGetir();
    }
  }

  void eskiMesajlariGetir() async {
    final _chatModel = Provider.of<ChatViewModel>(context, listen: false);
    if (_isLoading == false) {
      _isLoading = true;

      await _chatModel.dahaFazlaMesajGetir();
      _isLoading = false;
    }
  }

  _yeniElemanlarYukleniyorIndicator() {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
