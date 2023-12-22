import 'package:flutter_lovers/models/user.dart';

abstract class AuthBase {
  Future<User1?> currentUser();
  Future<User1?> signInAnonymously();
  Future<bool> signOut();
  Future<User1?> signInWithGoogle();
  Future<User1?> signInWithFacebook();
  Future<User1?> signInWithEmailandPassword(String email, String sifre);
  Future<User1?> createUserWithEmailandPassword(String email, String sifre);
}
