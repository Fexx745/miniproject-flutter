import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const city = 'Nakhon Ratchasima';
  static const apikey = 'a0d63355b66540d793c104957242409';

  Future<String> fetchWeather() async {
    final response = await http.get(Uri.parse(
      'http://api.weatherapi.com/v1/current.json?key=$apikey&q=$city&aqi=no',
    ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return 'นครราชสีมา อุณหภูมิ: ${data['current']['temp_c']} °C';
    } else {
      return 'ไม่สามารถโหลดข้อมูลสภาพอากาศ';
    }
  }
}
