import 'package:flutter_lovers/models/user.dart';
import 'package:flutter_lovers/services/auth_base.dart';

class FakeAuthenticationService implements AuthBase {
  String userID = "123123123123123";

  @override
  Future<User1> currentUser() async {
    return await Future.value(
        User1(userID: userID, email: 'fakeuser@fake.com'));
  }

  @override
  Future<User1> signInAnonymously() async {
    return await Future.delayed(Duration(seconds: 2),
        () => User1(userID: userID, email: 'fakeuser@fake.com'));
  }

  @override
  Future<bool> signOut() {
    return Future.value(true);
  }

  @override
  Future<User1> signInWithGoogle() async {
    return await Future.delayed(
        Duration(seconds: 2),
        () =>
            User1(userID: 'google_user_id_12345', email: 'fakeuser@fake.com'));
  }

  @override
  Future<User1?> signInWithFacebook() async {
    return await Future.delayed(
        Duration(seconds: 2),
        () => User1(
            userID: 'facebook_user_id_12345', email: 'fakeuser@fake.com'));
  }

  @override
  Future<User1?> createUserWithEmailandPassword(
      String email, String sifre) async {
    return await Future.delayed(
        Duration(seconds: 2),
        () =>
            User1(userID: 'created_user_id_12345', email: 'fakeuser@fake.com'));
  }

  @override
  Future<User1?> signInWithEmailandPassword(String email, String sifre) async {
    return await Future.delayed(
        Duration(seconds: 2),
        () =>
            User1(userID: 'signin_user_id_12345', email: 'fakeuser@fake.com'));
  }
}
