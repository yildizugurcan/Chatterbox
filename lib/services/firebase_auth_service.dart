import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_lovers/models/user.dart';
import 'package:flutter_lovers/services/auth_base.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService implements AuthBase {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<User1?> currentUser() async {
    try {
      User user = await _firebaseAuth.currentUser!;
      return _userFromFirebase(user);
    } catch (e) {}
    return null;
  }

  User1? _userFromFirebase(User user) {
    String? userEmail;
    if (user.providerData != null && user.providerData.isNotEmpty) {
      userEmail = user.providerData[0].email;
    }

    if (userEmail == null) return null;

    return User1(userID: user.uid, email: userEmail);
  }

  @override
  Future<User1?> signInAnonymously() async {
    try {
      UserCredential sonuc = await _firebaseAuth.signInAnonymously();
      User? user = sonuc.user;
      if (user != null) {
        return _userFromFirebase(user)!;
      }
    } catch (e) {}

    return null;
  }

  @override
  Future<bool> signOut() async {
    try {
      final _googleSignIn = GoogleSignIn();
      await _googleSignIn.signOut();

      final _facebookLogin = FacebookAuth.instance;
      await _facebookLogin.logOut();

      await _firebaseAuth.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<User1?> signInWithGoogle() async {
    GoogleSignIn _googleSignIn = GoogleSignIn();
    GoogleSignInAccount? _googleUser = await _googleSignIn.signIn();

    if (_googleUser != null) {
      GoogleSignInAuthentication _googleAuth = await _googleUser.authentication;
      if (_googleAuth.idToken != null && _googleAuth.accessToken != null) {
        UserCredential sonuc = await _firebaseAuth.signInWithCredential(
            GoogleAuthProvider.credential(
                idToken: _googleAuth.idToken,
                accessToken: _googleAuth.accessToken));
        User? _user = sonuc.user;
        return _userFromFirebase(_user!);
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  @override
  Future<User1?> signInWithFacebook() async {
    try {
      final _facebookLogin = FacebookAuth.instance;

      LoginResult _faceResult =
          await _facebookLogin.login(permissions: ['public_profile', 'email']);

      switch (_faceResult.status) {
        case LoginStatus.success:
          if (_faceResult.accessToken != null) {
            UserCredential _firebaseResult = await _firebaseAuth
                .signInWithCredential(FacebookAuthProvider.credential(
                    _faceResult.accessToken!.token));
            User _user = _firebaseResult.user!;
            return _userFromFirebase(_user);
          }
          break;

        case LoginStatus.cancelled:
          break;
        case LoginStatus.failed:
          break;
        case LoginStatus.operationInProgress:
        default:
          break;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User1?> createUserWithEmailandPassword(
      String email, String sifre) async {
    UserCredential sonuc = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: sifre);
    User user = sonuc.user!;
    if (user != null) {
      return _userFromFirebase(user)!;
    }
  }

  @override
  Future<User1?> signInWithEmailandPassword(String email, String sifre) async {
    UserCredential sonuc = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: sifre);
    User? user = sonuc.user;
    if (user != null) {
      return _userFromFirebase(user)!;
    }
  }
}
