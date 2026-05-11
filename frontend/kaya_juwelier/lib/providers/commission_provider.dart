import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kaya_juwelier/core/constants/app_constants.dart';
import 'package:kaya_juwelier/models/commission_model.dart';

// ── Auth token provider ───────────────────────────────────────────────────────
class AuthNotifier extends AsyncNotifier<String?> {
  static const _key = 'admin_token';

  @override
  Future<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<String?> login(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final token = (jsonDecode(res.body) as Map)['token'] as String;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_key, token);
        state = AsyncData(token);
        return null; // no error
      }
      final msg = (jsonDecode(res.body) as Map)['message'] as String?;
      return msg ?? 'Giriş başarısız.';
    } catch (_) {
      return 'Sunucuya bağlanılamadı.';
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, String?>(AuthNotifier.new);

// ── Commission provider ───────────────────────────────────────────────────────
class CommissionNotifier extends AsyncNotifier<CommissionMap> {
  @override
  Future<CommissionMap> build() => _fetch();

  Future<CommissionMap> _fetch() async {
    try {
      final res = await http
          .get(Uri.parse('${AppConstants.apiBaseUrl}/api/commissions'),
              headers: {'ngrok-skip-browser-warning': 'true'})
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        return {
          for (final item in list)
            (item['assetKey'] as String):
                CommissionModel.fromJson(item as Map<String, dynamic>)
        };
      }
    } catch (_) {}
    return {}; // empty = no commission applied
  }

  Future<String?> updateSingle(String token, String assetKey, double percent) async {
    try {
      final res = await http.put(
        Uri.parse('${AppConstants.apiBaseUrl}/api/commissions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'assetKey': assetKey,
          'commissionPercent': percent,
        }),
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        state = AsyncData(await _fetch()); // refresh
        return null;
      }
      return (jsonDecode(res.body) as Map)['message'] as String? ?? 'Hata.';
    } catch (_) {
      return 'Sunucuya bağlanılamadı.';
    }
  }

  Future<String?> bulkUpdate(String token, Map<String, double> updates) async {
    try {
      final body = updates.entries
          .map((e) => {'assetKey': e.key, 'commissionPercent': e.value})
          .toList();

      final res = await http.put(
        Uri.parse('${AppConstants.apiBaseUrl}/api/commissions/bulk'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        state = AsyncData(await _fetch());
        return null;
      }
      return 'Güncelleme başarısız.';
    } catch (_) {
      return 'Sunucuya bağlanılamadı.';
    }
  }

  void refresh() { state = const AsyncLoading(); build().then((v) => state = AsyncData(v)); }
}

final commissionProvider =
    AsyncNotifierProvider<CommissionNotifier, CommissionMap>(CommissionNotifier.new);
