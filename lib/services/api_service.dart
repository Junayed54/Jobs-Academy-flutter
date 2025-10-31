import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://jobs.academy/api";

  /// Register FCM Device Token
  static Future<void> registerDeviceToken({
    required String token,
    required String deviceId,
    required String deviceType,
    String? ipAddress,
    String? jwtToken,
  }) async {
    final url = Uri.parse("$baseUrl/device-token/");

    final headers = {
      "Content-Type": "application/json",
      if (jwtToken != null) "Authorization": "Bearer $jwtToken"
    };

    final body = jsonEncode({
      "token": token,
      "device_id": deviceId,
      "device_type": deviceType,
      "ip_address": ipAddress,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Device token registered: ${response.body}");
      } else {
        print("❌ Failed to register device token: ${response.statusCode} | ${response.body}");
      }
    } catch (e) {
      print("❌ Exception while registering device token: $e");
    }
  }

  /// Log user activity (can work for guest users too)
  static Future<void> logActivity({
    required String deviceId,
    required String path,
    required String method,
    String? token, // FCM token optional
    String? ipAddress,
    String? jwtToken,
  }) async {
    final url = Uri.parse("$baseUrl/log-activity/");

    final headers = {
      "Content-Type": "application/json",
      if (jwtToken != null) "Authorization": "Bearer $jwtToken"
    };

    final body = jsonEncode({
      "device_id": deviceId,
      "token": token,
      "path": path,
      "method": method,
      "ip_address": ipAddress,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Activity logged: ${response.body}");
      } else {
        print("❌ Failed to log activity: ${response.statusCode} | ${response.body}");
      }
    } catch (e) {
      print("❌ Exception while logging activity: $e");
    }
  }
}
