import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
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



  Future<String?> getFcmToken() async {
    String? token = await _firebaseMessaging.getToken();
    return token;
  }

  // Request permissions and initialize FCM
  Future<void> setup() async {
    // Request notification permission (for iOS)
    requestNotificationPermission();

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_onMessageHandler);
  }

  // Handle incoming background messages
  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    print('Handling a background message: ${message.messageId}');
  }

  // Handle incoming foreground messages
  void _onMessageHandler(RemoteMessage message) {
    if (message.notification != null) {
      print('Message received: ${message.notification!.title}');
      // Optionally, display an alert or a dialog
      // _showNotificationDialog(message.notification!);
    }
  }

  // Optionally, display a notification dialog (foreground)
  void _showNotificationDialog(RemoteNotification notification) {
    // This can be a dialog or any UI element you choose to show
    // when the app is in the foreground.
  }

  // Optionally, send a notification
  Future<void> sendNotification(String token, String title, String body) async {
    await _firebaseMessaging.sendMessage(
      to: token,
      data: {'title': title, 'body': body},
    );
  }
}

