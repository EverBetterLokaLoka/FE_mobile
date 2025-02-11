import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://67ab0ce065ab088ea7e86b6f.mockapi.io/api';

  Future<dynamic> request({
    required String path,
    required String method,
    Map<String, dynamic>? data,
  }) async {
    final Uri url = Uri.parse('$baseUrl$path');
    http.Response response;

    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(url, headers: _defaultHeaders());
        break;
      case 'POST':
        response = await http.post(url, headers: _defaultHeaders(), body: jsonEncode(data));
        break;
      case 'PUT':
        response = await http.put(url, headers: _defaultHeaders(), body: jsonEncode(data));
        break;
      case 'PATCH':
        response = await http.patch(url, headers: _defaultHeaders(), body: jsonEncode(data));
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Map<String, String> _defaultHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // Authorization token
    };
  }
}