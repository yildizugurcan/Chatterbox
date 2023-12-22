import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lovers/app/sign_in/email_password_signin.dart';
import 'package:flutter_lovers/common_widget/social_login_button.dart';
import 'package:flutter_lovers/models/user.dart';
import 'package:flutter_lovers/viewmodel/user_model.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatelessWidget {
  void _misafirGirisi(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);

    await Firebase.initializeApp();
    User1 _user = (await _userModel.signInAnonymously())!;

    print('Oturum Açan user id : ${_user.userID.toString()}');
  }

  void _googleIleGiris(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);

    await Firebase.initializeApp();
    User1 _user = (await _userModel.signInWithGoogle())!;
    if (_user != null) {
      print('Oturum Açan user id : ${_user.userID.toString()}');
    }
  }

  void _emailVeSifreGiris(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const EmailveSifreLoginPage(),
      ),
    );
  }

  void _facebookIleGiris(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);

    await Firebase.initializeApp();
    User1? _user = await _userModel.signInWithFacebook();
    if (_user != null) {
      print('Oturum Açan user id : ${_user.userID.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/flutter_chat_logo.png', height: 200),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Oturum Açın',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(
              height: 20,
            ),
            SocialLoginButton(
              buttonText: 'Gmail ile Giriş Yap',
              textColor: Colors.black87,
              buttonIcon: Image.asset('images/google-logo.png'),
              buttonColor: Colors.white,
              onPressed: () => _googleIleGiris(context),
            ),
            SocialLoginButton(
              buttonText: 'Facebook ile Giriş Yap',
              buttonIcon: Image.asset('images/facebook-logo.png'),
              buttonColor: const Color(0xFF334D92),
              onPressed: () => _facebookIleGiris(context),
            ),
            SocialLoginButton(
              buttonText: 'Email ve Şifre ile Giriş Yap',
              buttonIcon: const Icon(
                Icons.email,
                size: 32,
                color: Colors.white,
              ),
              onPressed: () => _emailVeSifreGiris(context),
            ),
            SocialLoginButton(
              buttonText: 'Misafir Girişi',
              onPressed: () => _misafirGirisi(context),
              buttonIcon: const Icon(
                Icons.supervised_user_circle,
                size: 32,
                color: Colors.white,
              ),
              buttonColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
