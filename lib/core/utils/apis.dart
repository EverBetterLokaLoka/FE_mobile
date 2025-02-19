import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/url_constant.dart';

class ApiService {
  final String baseUrl = 'https://e044-14-176-232-65.ngrok-free.app/api';

  final String locationUrl = 'https://provinces.open-api.vn/api/p';

  Future<http.Response> request({
    required String path,
    required String method,
    required String typeUrl,
    Map<String, dynamic>? data,
  }) async {
    Uri url;
    if (typeUrl == UrlConstant().baseUrl) {
      url = Uri.parse('$baseUrl$path');
    } else if (typeUrl == UrlConstant().locationUrl) {
      print(locationUrl);
      url = Uri.parse('$locationUrl$path');
    } else {
      throw Exception('Invalid URL type: $typeUrl');
    }

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
      return response;
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