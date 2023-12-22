import 'package:flutter/material.dart';
import 'package:flutter_lovers/app/konusmalarim_page.dart';
import 'package:flutter_lovers/app/kullanicilar.dart';
import 'package:flutter_lovers/app/my_custom_bottom_navi.dart';
import 'package:flutter_lovers/app/profil.dart';
import 'package:flutter_lovers/app/tab_items.dart';
import 'package:flutter_lovers/models/user.dart';

class HomePage extends StatefulWidget {
  final User1? user;

  const HomePage({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TabItem _currentTab = TabItem.Kullanicilar;

  Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.Kullanicilar: GlobalKey<NavigatorState>(),
    TabItem.Konusmalarim: GlobalKey<NavigatorState>(),
    TabItem.Profil: GlobalKey<NavigatorState>(),
  };

  Map<TabItem, Widget> tumSayfalar() {
    return {
      TabItem.Kullanicilar: const KullanicilarPage(),
      TabItem.Konusmalarim: const KonusmalarimPage(),
      TabItem.Profil: const ProfilPage(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: MyCustomBottomNavigation(
      navigatorKeys: navigatorKeys,
      sayfaOlusturucu: tumSayfalar(),
      currentTab: _currentTab,
      onSelectedTab: (secilenTab) {
        if (secilenTab == _currentTab) {
          navigatorKeys[secilenTab]!
              .currentState!
              .popUntil((route) => route.isFirst);
        } else {
          setState(
            () {
              _currentTab = secilenTab;
            },
          );
        }
      },
    ));
  }
}
