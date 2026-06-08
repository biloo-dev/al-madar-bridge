import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PrefManager {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Persistent Login
  static bool get rememberLogin => _prefs.getBool('rememberLogin') ?? false;
  static set rememberLogin(bool value) => _prefs.setBool('rememberLogin', value);

  static String get userEmail => _prefs.getString('userEmail') ?? "";
  static set userEmail(String value) => _prefs.setString('userEmail', value);

  static String get userFirstName => _prefs.getString('userFirstName') ?? "";
  static set userFirstName(String value) => _prefs.setString('userFirstName', value);

  static String get userPhone => _prefs.getString('userPhone') ?? "";
  static set userPhone(String value) => _prefs.setString('userPhone', value);

  static String get userLastName => _prefs.getString('userLastName') ?? "";
  static set userLastName(String value) => _prefs.setString('userLastName', value);

  static String get userType => _prefs.getString('userType') ?? "";
  static set userType(String value) => _prefs.setString('userType', value);

  static String get userStatus => _prefs.getString('userStatus') ?? "pending";
  static set userStatus(String value) => _prefs.setString('userStatus', value);

  // Profile completion status
  static bool get isProfileCompleted => _prefs.getBool('isProfileCompleted') ?? false;
  static set isProfileCompleted(bool value) => _prefs.setBool('isProfileCompleted', value);

  // Multi-step Registration Resume
  static String get registrationStep => _prefs.getString('registrationStep') ?? "basic";
  static set registrationStep(String value) => _prefs.setString('registrationStep', value);

  static Map<String, dynamic> get customProfileData {
    String? data = _prefs.getString('customProfileData');
    if (data == null) return {};
    return jsonDecode(data);
  }

  static set customProfileData(Map<String, dynamic> value) {
    _prefs.setString('customProfileData', jsonEncode(value));
  }

  static void clear() {
    _prefs.clear();
  }
}
