import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_lovers/common_widget/platform_duyarli_alert.dart';
import 'package:flutter_lovers/common_widget/social_login_button.dart';
import 'package:flutter_lovers/viewmodel/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  TextEditingController? _controllerUserName;

  XFile? _profilFoto;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controllerUserName = TextEditingController();
  }

  @override
  void dispose() {
    _controllerUserName!.dispose();
    super.dispose();
  }

  void _kameradanFotoCek() async {
    var _yeniResim = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      Navigator.of(context).pop();
      _profilFoto = _yeniResim;
    });
  }

  void _galeridenResimSec() async {
    var _yeniResim = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      Navigator.of(context).pop();
      _profilFoto = _yeniResim;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserModel _userModel = Provider.of<UserModel>(context);
    if (_userModel.user != null) {
      _controllerUserName!.text = _userModel.user!.userName ?? '';
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Profil'),
          actions: [
            TextButton(
                onPressed: () => _cikisIcinOnayIste(context),
                child: const Text(
                  'Çıkış',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ))
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Container(
                              height: 170,
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.camera),
                                    title: const Text('Kameradan Çek'),
                                    onTap: () {
                                      _kameradanFotoCek();
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.image),
                                    title: const Text('Galeriden Seç'),
                                    onTap: () {
                                      _galeridenResimSec();
                                    },
                                  ),
                                ],
                              ),
                            );
                          });
                    },
                    child: CircleAvatar(
                      radius: 75,
                      backgroundImage: _profilFoto != null
                          ? Image.file(File(_profilFoto!.path)).image
                          : (_userModel.user != null &&
                                      _userModel.user!.profilURL != null
                                  ? NetworkImage(_userModel.user!.profilURL!)
                                  : const NetworkImage(
                                      'https://cdn-icons-png.flaticon.com/128/3135/3135715.png'))
                              as ImageProvider<Object>?,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      initialValue: _userModel.user!.email,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Emailiniz',
                        hintText: 'Email',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _controllerUserName,
                    decoration: const InputDecoration(
                      labelText: 'Kullanıcı Adınız',
                      hintText: 'UserName',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SocialLoginButton(
                      buttonText: 'Değişiklikleri Kaydet',
                      onPressed: () {
                        _userNameGuncelle(context);
                        _profilFotoGuncelle(context);
                      }),
                )
              ],
            ),
          ),
        ));
  }

  Future<bool> _cikisYap(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    bool sonuc = await _userModel.signOut();

    return sonuc;
  }

  Future _cikisIcinOnayIste(BuildContext context) async {
    final sonuc = await PlatformDuyarliAlertDialog(
      baslik: 'Emin Misiniz?',
      icerik: 'Çıkmak İstediğinizden Emin Misiniz?',
      anaButonYazisi: 'Evet',
      iptalButonYazisi: 'Vazgeç',
    ).goster(context);
    if (sonuc == true) {
      _cikisYap(context);
    }
  }

  void _userNameGuncelle(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    if (_userModel.user!.userName != _controllerUserName!.text) {
      var updateResult = await _userModel.updateUserName(
        _userModel.user!.userID ?? '',
        _controllerUserName!.text,
      );
      if (updateResult == true) {
        _userModel.user!.userName = _controllerUserName!.text;
        PlatformDuyarliAlertDialog(
                baslik: 'Başarılı',
                icerik: 'Username değiştirildi',
                anaButonYazisi: 'Tamam')
            .goster(context);
      } else {
        _controllerUserName!.text = _userModel.user!.userName ?? '';
        PlatformDuyarliAlertDialog(
                baslik: 'HATA',
                icerik:
                    'Username zaten kullanımda, farklı bir username deneyiniz',
                anaButonYazisi: 'Tamam')
            .goster(context);
      }
    }
  }

  void _profilFotoGuncelle(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);

    if (_profilFoto != null) {
      File file = File(_profilFoto!.path);
      var url = await _userModel.uploadFile(
        _userModel.user!.userID,
        'profil_foto',
        file,
      );

      if (url != null) {
        PlatformDuyarliAlertDialog(
                baslik: 'Başarılı',
                icerik: 'Profil Fotoğrafınız Güncellendi',
                anaButonYazisi: 'Tamam')
            .goster(context);
      }
    }
  }
}
