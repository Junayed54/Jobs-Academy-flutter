import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Get FCM token
  static Future<String?> getDeviceToken() async {
    return await _firebaseMessaging.getToken();
  }
}
