import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_lovers/app/sohbet_page.dart';
import 'package:flutter_lovers/models/user.dart';
import 'package:flutter_lovers/viewmodel/chat_view_model.dart';
import 'package:flutter_lovers/viewmodel/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationHandler {
  FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static final NotificationHandler _singleton = NotificationHandler._internal();

  factory NotificationHandler() {
    return _singleton;
  }

  NotificationHandler._internal();
  late BuildContext myContext;

  initializeFCMNotification(BuildContext context) async {
    myContext = context;
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = DarwinInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onSelectNotification,
    );

    String? token = await _fcm.getToken().then((token) async {
      User _currentUser = await FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance
          .collection('tokens')
          .doc(_currentUser.uid)
          .set({'token': token});
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(message);
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    });

    FirebaseMessaging.onBackgroundMessage(myBackgroundMessage);
  }

  static Future<void> myBackgroundMessage(RemoteMessage message) async {
    NotificationHandler.showNotification(message);
  }

  static void showNotification(RemoteMessage message) async {
  
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails('12345', 'YENİ MESAJ',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        0,
        message.toMap()['data']['title'],
        message.toMap()['data']['body'],
        notificationDetails,
        payload: jsonEncode(message.toMap()));
  }

  onSelectNotification(NotificationResponse notificationResponse) async {
    final _userModel = Provider.of<UserModel>(myContext, listen: false);

    var payloadData = jsonDecode(notificationResponse.payload.toString());

    print("payload $payloadData");

    Navigator.of(myContext, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (context) => ChatViewModel(
              currentUser: _userModel.user,
              sohbetEdilenUser: User1.idveResim(
                  userID: payloadData['data']['gonderenUserID'],
                  profilURL: payloadData['data']['profilURL'])),
          child: SohbetPage(),
        ),
      ),
    );
  }
}
void onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) {}

