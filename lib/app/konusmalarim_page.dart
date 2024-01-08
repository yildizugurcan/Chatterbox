import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lovers/app/sohbet_page.dart';
import 'package:flutter_lovers/models/konusma.dart';
import 'package:flutter_lovers/models/user.dart';
import 'package:flutter_lovers/viewmodel/chat_view_model.dart';
import 'package:flutter_lovers/viewmodel/user_model.dart';
import 'package:provider/provider.dart';

class KonusmalarimPage extends StatefulWidget {
  const KonusmalarimPage({super.key});

  @override
  State<KonusmalarimPage> createState() => _KonusmalarimPageState();
}

class _KonusmalarimPageState extends State<KonusmalarimPage> {
  @override
  Widget build(BuildContext context) {
    UserModel _userModel = Provider.of<UserModel>(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Konuşmalarım'),
        ),
        body: FutureBuilder<List<Konusma>?>(
            future: _userModel.getAllConversations(_userModel.user!.userID!),
            builder: ((context, konusmaListesi) {
              if (!konusmaListesi.hasData || konusmaListesi.data == null) {
                return const Center(
                  child: Text("Veri yok veya null."),
                );
              } else {
                var tumKonusmalar = konusmaListesi.data;

                if (tumKonusmalar!.length > 0) {
                  return RefreshIndicator(
                    onRefresh: _konusmalarimListesiniYenile,
                    child: ListView.builder(
                      itemCount: tumKonusmalar!.length,
                      itemBuilder: (context, index) {
                        var oankiKonusma = tumKonusmalar[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(
                                builder: (context) => ChangeNotifierProvider(
                                  create: (context) => ChatViewModel(
                                      currentUser: _userModel.user,
                                      sohbetEdilenUser: User1.idveResim(
                                          userID: oankiKonusma.kimle_konusuyor,
                                          profilURL: oankiKonusma
                                              .konusulanUserProfilURL)),
                                  child: SohbetPage(),
                                ),
                              ),
                            );
                          },
                          child: ListTile(
                            title: Text(oankiKonusma.konusulanUserName!),
                            subtitle: Text(oankiKonusma.son_yollanan_mesaj!),
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey.withAlpha(40),
                              backgroundImage: NetworkImage(
                                  oankiKonusma.konusulanUserProfilURL!),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return RefreshIndicator(
                    onRefresh: _konusmalarimListesiniYenile,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height - 150,
                        child: Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat,
                              color: Theme.of(context).primaryColor,
                              size: 120,
                            ),
                            const Text(
                              'Henüz Konuşma Yapılmamış',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 36),
                            )
                          ],
                        )),
                      ),
                    ),
                  );
                }
              }
            })));
  }

  void _konusmalarimiGetir() async {
    final _userModel = Provider.of<UserModel>(context);
    var konusmalarim = await FirebaseFirestore.instance
        .collection('konusmalar')
        .where('konusma_sahibi', isEqualTo: _userModel.user!.userID)
        .orderBy('olusturulma_tarihi', descending: true)
        .get();
   
    for (var konusma in konusmalarim.docs) {
    }
  }

  Future<Null> _konusmalarimListesiniYenile() async {
    setState(() {});
    await Future.delayed(const Duration(seconds: 1));
    return null;
  }
}
