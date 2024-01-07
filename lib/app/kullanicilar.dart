import 'package:flutter/material.dart';
import 'package:flutter_lovers/app/sohbet_page.dart';
import 'package:flutter_lovers/viewmodel/all_users_view_model.dart';
import 'package:flutter_lovers/viewmodel/chat_view_model.dart';
import 'package:flutter_lovers/viewmodel/user_model.dart';
import 'package:provider/provider.dart';

class KullanicilarPage extends StatefulWidget {
  const KullanicilarPage({super.key});

  @override
  State<KullanicilarPage> createState() => _KullanicilarPageState();
}

class _KullanicilarPageState extends State<KullanicilarPage> {
  bool _isLoading = false;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _scrollController.addListener(_listeScrollListener);
  }

  @override
  Widget build(BuildContext context) {
    final _tumKullanicilarViewModel =
        Provider.of<AllUserViewModel>(context, listen: true);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Kullanıcılar'),
        ),
        body: Consumer<AllUserViewModel>(
          builder: (context, model, child) {
            if (model.state == AllUserViewState.Busy) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (model.state == AllUserViewState.Loaded) {
              return RefreshIndicator(
                onRefresh: model.refresh,
                child: ListView.builder(
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    if (model.kullanicilarListesi!.length == 1) {
                      return _kullaniciYokUI();
                    } else if (model.hasMoreLoading &&
                        index == model.kullanicilarListesi!.length) {
                      return _yeniElemanlarYukleniyorIndicator();
                    } else {
                      return _userListeELemanOlustur(index);
                    }
                  },
                  itemCount: model.hasMoreLoading
                      ? model.kullanicilarListesi!.length + 1
                      : model.kullanicilarListesi!.length,
                ),
              );
            } else {
              return Container();
            }
          },
        ));
  }

  Widget _kullaniciYokUI() {
    final _kullanicilarModel =
        Provider.of<AllUserViewModel>(context, listen: false);
    return RefreshIndicator(
      onRefresh: _kullanicilarModel.refresh,
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
                Icons.supervised_user_circle,
                color: Theme.of(context).primaryColor,
                size: 120,
              ),
              const Text(
                'Henüz Kullanıcı Yok',
                style: TextStyle(fontSize: 36),
              )
            ],
          )),
        ),
      ),
    );
  }

  Widget _userListeELemanOlustur(int index) {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    final _tumKullanicilarViewModel =
        Provider.of<AllUserViewModel>(context, listen: false);

    if (index < _tumKullanicilarViewModel.kullanicilarListesi!.length) {
      var _oankiUser = _tumKullanicilarViewModel.kullanicilarListesi![index];

      return GestureDetector(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (context) => ChatViewModel(
                    currentUser: _userModel.user, sohbetEdilenUser: _oankiUser),
                child: SohbetPage(),
              ),
            ),
          );
        },
        child: Card(
          child: ListTile(
            title: Text(_oankiUser.userName!),
            subtitle: Text(_oankiUser.email!),
            leading: CircleAvatar(
              backgroundColor: Colors.grey.withAlpha(40),
              backgroundImage: NetworkImage(_oankiUser.profilURL!),
            ),
          ),
        ),
      );
    } else {
      return Container();
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

  void dahaFazlaKullaniciGetir() async {
    if (_isLoading == false) {
      _isLoading = true;
      final _tumKullanicilarViewModel =
          Provider.of<AllUserViewModel>(context, listen: false);

      await _tumKullanicilarViewModel.dahaFazlaKullaniciGetir();
      _isLoading = false;
    }
  }

  void _listeScrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      dahaFazlaKullaniciGetir();
    }
  }
}
