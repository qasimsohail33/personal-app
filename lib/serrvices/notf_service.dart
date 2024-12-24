import 'dart:io';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
 final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void requestNotificationPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert : true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    if (settings.authorizationStatus==AuthorizationStatus.authorized){
      print("user granted permisson");
    }else if (settings.authorizationStatus==AuthorizationStatus.provisional){
      print("user granted prov permisson");
    }else{
      AppSettings.openAppSettings();
      print("user denied permissoin");}
  }

  void initLocalNotifications (BuildContext context,RemoteMessage message) async {
    var androidInitialization = const AndroidInitializationSettings('@mipmap/ic_launcher');
var initializationSetting = InitializationSettings(
  android: androidInitialization,
);
await _flutterLocalNotificationsPlugin.initialize(
    initializationSetting,
  onDidReceiveNotificationResponse: (payload){


  }

);

  }
  Future<String?> getFcmToken() async {
    String? token = await _firebaseMessaging.getToken();
    return token!;
  }

  void firebaseInit(BuildContext context){
    FirebaseMessaging.onMessage.listen((message){
      if (Platform.isAndroid) {
        initLocalNotifications(context, message);
        showNotification(message);
      }
      print((message.notification!.title.toString()));
      print((message.notification!.body.toString()));
      showNotification(message);
    });
  }

  // Request permissions and initialize FCM

  // Handle incoming background messages

  // Optionally, display a notification dialog (foreground)
  void showNotification(RemoteMessage message ) async {

    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(10000).toString(),
        'High importance notification',
      importance: Importance.max,
    );

    AndroidNotificationDetails androidNot0ificationDetails = AndroidNotificationDetails(
    channel.id.toString(),
    channel.name.toString(),
     channelDescription:  'your channel description',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker'
    );
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNot0ificationDetails,
    );
    
    Future.delayed(Duration.zero,(){
      _flutterLocalNotificationsPlugin.show(
          1,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails);
    });
  }

  // Optionally, send a notification

}

