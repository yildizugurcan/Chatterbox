import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lovers/app/hata_exception.dart';
import 'package:flutter_lovers/common_widget/platform_duyarli_alert.dart';
import 'package:flutter_lovers/common_widget/social_login_button.dart';
import 'package:flutter_lovers/models/user.dart';
import 'package:flutter_lovers/viewmodel/user_model.dart';
import 'package:provider/provider.dart';

enum FormType { Register, Login }

class EmailveSifreLoginPage extends StatefulWidget {
  const EmailveSifreLoginPage({super.key});

  @override
  State<EmailveSifreLoginPage> createState() => _EmailveSifreLoginPageState();
}

class _EmailveSifreLoginPageState extends State<EmailveSifreLoginPage> {
  late String _email, _sifre;
  late String _buttonText, _linkText;
  var _formType = FormType.Login;

  final _formKey = GlobalKey<FormState>();

  void _formSubmit() async {
    _formKey.currentState!.save();
    final _userModel = Provider.of<UserModel>(context, listen: false);

    if (_formType == FormType.Login) {
      try {
        User1? _girisYapanUser =
            await _userModel.signInWithEmailandPassword(_email, _sifre);
        if (_girisYapanUser != null) {
          debugPrint(
              'Oturum Açan user id : ${_girisYapanUser.userID.toString()}');
        }
      } on FirebaseAuthException catch (e) {
        PlatformDuyarliAlertDialog(
          baslik: 'Oturum Açma Hata',
          icerik: Hatalar.goster(e.code),
          anaButonYazisi: 'Tamam',
        ).goster(context);
      }
    } else {
      try {
        User1? _olusturulanUser =
            await _userModel.createUserWithEmailandPassword(_email, _sifre);
        if (_olusturulanUser != null) {
          debugPrint(
              'Oturum Açan user id : ${_olusturulanUser.userID.toString()}');
        }
      } on FirebaseAuthException catch (e) {
        PlatformDuyarliAlertDialog(
          baslik: 'Kullanıcı Oluşturma Hata',
          icerik: Hatalar.goster(e.code),
          anaButonYazisi: 'Tamam',
        ).goster(context);
      }
    }
  }

  void _degistir() {
    setState(() {
      _formType =
          _formType == FormType.Login ? FormType.Register : FormType.Login;
    });
  }

  @override
  Widget build(BuildContext context) {
    _buttonText = _formType == FormType.Login ? 'Giriş Yap' : 'Kayıt Ol';
    _linkText = _formType == FormType.Login
        ? 'Hesabınız Yok Mu? Kayıt Olun'
        : 'Hesabınız Var Mı ? Giriş Yapın';

    final _userModel = Provider.of<UserModel>(context);

    if (_userModel.user != null) {
      Future.delayed(const Duration(milliseconds: 10), () {
        Navigator.of(context).pop();
      });
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Giriş / Kayıt'),
        ),
        body: _userModel.state == ViewState.Idle
            ? SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: 'ugur@ugur.com',
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            errorText: _userModel.emailHataMesaji != null
                                ? _userModel.emailHataMesaji
                                : null,
                            prefixIcon: Icon(Icons.mail),
                            hintText: 'Email',
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          onSaved: (String? girilenEmail) {
                            _email = girilenEmail!;
                          },
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          initialValue: 'password',
                          obscureText: true,
                          decoration: InputDecoration(
                            errorText: _userModel.sifreHataMesaji != null
                                ? _userModel.sifreHataMesaji
                                : null,
                            prefixIcon: const Icon(Icons.mail),
                            hintText: 'Şifre',
                            labelText: 'Şifre',
                            border: const OutlineInputBorder(),
                          ),
                          onSaved: (String? girilenSifre) {
                            _sifre = girilenSifre!;
                          },
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        SocialLoginButton(
                          buttonText: _buttonText,
                          buttonColor: Theme.of(context).primaryColor,
                          radius: 10,
                          onPressed: () => _formSubmit(),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        TextButton(
                          onPressed: () => _degistir(),
                          child: Text(_linkText),
                        )
                      ],
                    ),
                  ),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }
}
