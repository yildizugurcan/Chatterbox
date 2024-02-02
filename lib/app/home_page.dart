import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lovers/app/konusmalarim_page.dart';
import 'package:flutter_lovers/app/kullanicilar.dart';
import 'package:flutter_lovers/app/my_custom_bottom_navi.dart';
import 'package:flutter_lovers/app/profil.dart';
import 'package:flutter_lovers/app/tab_items.dart';
import 'package:flutter_lovers/common_widget/platform_duyarli_alert.dart';
import 'package:flutter_lovers/models/user.dart';
import 'package:flutter_lovers/notification_handler.dart';
import 'package:flutter_lovers/viewmodel/all_users_view_model.dart';
import 'package:provider/provider.dart';



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
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  TabItem _currentTab = TabItem.Kullanicilar;

  Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.Kullanicilar: GlobalKey<NavigatorState>(),
    TabItem.Konusmalarim: GlobalKey<NavigatorState>(),
    TabItem.Profil: GlobalKey<NavigatorState>(),
  };

  Map<TabItem, Widget> tumSayfalar() {
    return {
      TabItem.Kullanicilar: ChangeNotifierProvider(
        create: (context) => AllUserViewModel(),
        child: const KullanicilarPage(),
      ),
      TabItem.Konusmalarim: const KonusmalarimPage(),
      TabItem.Profil: const ProfilPage(),
    };
  }

  @override
  void initState() {
    super.initState();

    NotificationHandler().initializeFCMNotification(context);
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
            setState(() {
              _currentTab = secilenTab;
            });
          }
        },
      ),
    );
  }
}
