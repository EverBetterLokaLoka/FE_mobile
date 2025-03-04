import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/auth/services/auth_services.dart';
import '../constants/url_constant.dart';

class ApiService {
  final String baseUrl = 'https://1fa1-27-69-241-207.ngrok-free.app/api';

  final String locationUrl = 'https://provinces.open-api.vn/api/p';

  String? token = "";

  Future<http.Response> request({
    required String path,
    required String method,
    required String typeUrl,
    required String currentPath,
    Map<String, dynamic>? data,
  }) async {
    Uri url;
    if (typeUrl == UrlConstant().baseUrl) {
      if (currentPath != "/login" && currentPath != "/sign-up") {
        token = await AuthService().getToken();
      }
      url = Uri.parse('$baseUrl$path');
    } else if (typeUrl == UrlConstant().locationUrl) {
      token = "";
      url = Uri.parse('$locationUrl$path');
    } else {
      throw Exception('Invalid URL type: $typeUrl');
    }

    http.Response response;

    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(url, headers: _defaultHeaders(token!));
        break;
      case 'POST':
        response = await http.post(url,
            headers: _defaultHeaders(token!), body: jsonEncode(data));
        break;
      case 'PUT':
        response = await http.put(url,
            headers: _defaultHeaders(token!), body: jsonEncode(data));
        break;
      case 'PATCH':
        response = await http.patch(url,
            headers: _defaultHeaders(token!), body: jsonEncode(data));
        break;
      case 'DELETE':
        response = await http.delete(url,
            headers: _defaultHeaders(token!), body: jsonEncode(data));
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

  Map<String, String> _defaultHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      "Authorization": "Bearer $token",
    };
  }
}
