import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class DeviceUtils {
  static Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString("device_id");

    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString("device_id", deviceId);
    }
    return deviceId;
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    if (token == null) {
      debugPrint("⚠️ No access token found in storage");
    }
    return token;
  }

  static Future<String?> getPublicIP() async {
    try {
      final res = await http
          .get(Uri.parse("https://api.ipify.org?format=json"))
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body is Map && body.containsKey("ip")) {
          return body["ip"];
        }
      }
      return null;
    } catch (e) {
      debugPrint("❌ Failed to fetch IP: $e");
      return null;
    }
  }
}
