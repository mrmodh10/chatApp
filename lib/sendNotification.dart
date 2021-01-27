import 'dart:async';
import 'dart:convert';

import 'package:chatapp/getDataFromShared.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

final String serverToken = 'AAAAlK_2D7c:APA91bHmN9d1rHDVzSbD6qYQElrekXcovkLBT8CUQBH4pMfCdnn-MqwLPH153b7S4BkcdbkQDTa2BtZbxSeJK7PXxBGqY-sz0LMkK6zrVzDSJmjmDdYRGop1fj2Oq90WP48ITixebcKI';
final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

Future<Map<String, dynamic>> sendMessage(message,fcmToken) async {
  print(fcmToken);
  await firebaseMessaging.requestNotificationPermissions(
    const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false),
  );

  await http.post(
    'https://fcm.googleapis.com/fcm/send',
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverToken',
    },
    body: jsonEncode(
      <String, dynamic>{
        'notification': <String, dynamic>{
          'body': message,
          'title': await getCurrentUserName(),
          'sound':'default'
        },
        'priority': 'high',
        'data': <String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done'
        },
        'to':fcmToken.toString().trim(),
      },
    ),
  );
  final Completer<Map<String, dynamic>> completer =
  Completer<Map<String, dynamic>>();

  firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      completer.complete(message);
    },
  );
  return completer.future;
}