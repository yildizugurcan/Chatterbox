import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lovers/app/landing_page.dart';
import 'package:flutter_lovers/locatior.dart';
import 'package:flutter_lovers/viewmodel/user_model.dart';
import 'package:provider/provider.dart';

void main() async {
  setupLocator();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserModel(),
      child: MaterialApp(
        title: 'Flutter Lovers',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple,
          ),
          appBarTheme: const AppBarTheme(
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 25,
            ),
            color: Colors.purple,
          ),
        ),
        home: const LandingPage(),
      ),
    );
  }
}
