import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../common/result.dart';
import '../../constants/constants.dart';

class ApiClient {
  final SharedPreferences sharedPreferences;
  final SupabaseClient supabaseClient;

  ApiClient({
    required this.sharedPreferences,
    required this.supabaseClient,
  });

  /// Tự động lấy Base URL động dựa trên subdomain đã lưu trong bộ nhớ
  String get baseUrl {
    final subdomain = sharedPreferences.getString(Constants.selectedSubdomainKey) ?? '';
    if (subdomain.isEmpty) {
      throw Exception('Chưa chọn doanh nghiệp (Subdomain). Vui lòng đăng nhập lại.');
    }

    // Nếu chạy local trong chế độ development
    const devHost = String.fromEnvironment('DEV_API_HOST');
    if (devHost.isNotEmpty) {
      return 'http://$subdomain.$devHost';
    }

    return 'https://$subdomain.oni.vn';
  }

  /// Gán Header mặc định đi kèm JWT của Supabase Session hiện tại
  Map<String, String> _getHeaders() {
    final session = supabaseClient.auth.currentSession;
    final token = session?.accessToken ?? '';

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// GET request
  Future<Result<T>> get<T>(String path, {T Function(dynamic)? fromJson}) async {
    try {
      final url = Uri.parse('$baseUrl$path');
      final response = await http.get(url, headers: _getHeaders());
      return _handleResponse(response, fromJson);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  /// POST request
  Future<Result<T>> post<T>(String path, {dynamic body, T Function(dynamic)? fromJson}) async {
    try {
      final url = Uri.parse('$baseUrl$path');
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response, fromJson);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  /// PUT request
  Future<Result<T>> put<T>(String path, {dynamic body, T Function(dynamic)? fromJson}) async {
    try {
      final url = Uri.parse('$baseUrl$path');
      final response = await http.put(
        url,
        headers: _getHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response, fromJson);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  /// DELETE request
  Future<Result<T>> delete<T>(String path, {T Function(dynamic)? fromJson}) async {
    try {
      final url = Uri.parse('$baseUrl$path');
      final response = await http.delete(url, headers: _getHeaders());
      return _handleResponse(response, fromJson);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  /// Xử lý dữ liệu trả về tập trung
  Result<T> _handleResponse<T>(http.Response response, T Function(dynamic)? fromJson) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (fromJson == null) {
        return Result.success(data: null as T);
      }
      final decoded = jsonDecode(response.body);
      return Result.success(data: fromJson(decoded));
    } else {
      String errorMessage = 'Lỗi kết nối máy chủ (${response.statusCode})';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('error')) {
          errorMessage = decoded['error'];
        }
      } catch (_) {}
      return Result.failure(error: errorMessage);
    }
  }
}
