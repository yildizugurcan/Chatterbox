import 'package:flutter_lovers/repository/user_repository.dart';
import 'package:flutter_lovers/services/bildirim_g%C3%B6nderme_servis.dart';
import 'package:flutter_lovers/services/fake_auth_service.dart';
import 'package:flutter_lovers/services/firebase_auth_service.dart';
import 'package:flutter_lovers/services/firebase_storage_service.dart';
import 'package:flutter_lovers/services/firestore_db_service.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => FirebaseAuthService());
  locator.registerLazySingleton(() => FakeAuthenticationService());
  locator.registerLazySingleton(() => FireStoreDBService());
  locator.registerLazySingleton(() => FirebaseStorageService());
  locator.registerLazySingleton(() => UserRepository());
  locator.registerLazySingleton(() => BildirimGondermeServis());
}
