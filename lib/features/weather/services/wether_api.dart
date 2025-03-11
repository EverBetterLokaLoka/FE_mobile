import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiKey = '46c642bcc3f999e910d7dcfdd7e5e182';

class WeatherApi {
  Future<Map<String, dynamic>?> fetchWeather(String cityName) async {
    var url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$apiKey&units=metric');

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        print(json.decode(response.body));
        return json.decode(response.body);
      } else {
        print('❌ Lỗi: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Exception: $e');
      return null;
    }
  }
}
