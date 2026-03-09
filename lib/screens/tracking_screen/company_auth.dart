import 'package:shared_preferences/shared_preferences.dart';

class CompanyAuth {
  static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();

    final apiKey = prefs.getString("api_key") ?? "";
    final apiSecret = prefs.getString("api_secret") ?? "";

    return {
      "Authorization": "token $apiKey:$apiSecret",
      "Content-Type": "application/json",
    };
  }
}
