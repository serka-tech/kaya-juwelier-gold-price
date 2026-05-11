import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kaya_juwelier/core/constants/app_constants.dart';
import 'package:kaya_juwelier/utils/image_picker_helper.dart';

export 'package:kaya_juwelier/utils/image_picker_helper.dart'
    show PickedFile, pickImageFile;

// ── Upload manifest model ─────────────────────────────────────────────────────
class UploadManifest {
  final Map<String, String> timestamps; // imageKey → ISO timestamp

  const UploadManifest({this.timestamps = const {}});

  bool hasImage(String key) => timestamps.containsKey(key);

  String? fullLogoUrl()          => _urlFor('logo');
  String? fullAssetUrl(String key) => _urlFor(key);

  String? _urlFor(String key) {
    final ts = timestamps[key];
    if (ts == null) return null;
    final v = Uri.encodeComponent(ts);
    return '${AppConstants.apiBaseUrl}/api/upload/image/$key?v=$v';
  }

  factory UploadManifest.fromJson(Map<String, dynamic> json) =>
      UploadManifest(timestamps: json.map((k, v) => MapEntry(k, v as String)));
}

// ── Manifest provider ─────────────────────────────────────────────────────────
class UploadManifestNotifier extends AsyncNotifier<UploadManifest> {
  Timer? _timer;

  @override
  Future<UploadManifest> build() {
    // Poll every 30 seconds so uploaded images appear without app restart
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) async {
      final fresh = await _fetch();
      state = AsyncData(fresh);
    });
    ref.onDispose(() => _timer?.cancel());
    return _fetch();
  }

  Future<UploadManifest> _fetch() async {
    try {
      final res = await http
          .get(
            Uri.parse('${AppConstants.apiBaseUrl}/api/upload/manifest'),
            headers: {'ngrok-skip-browser-warning': 'true'},
          )
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json is Map<String, dynamic>) {
          return UploadManifest.fromJson(json);
        }
      }
    } catch (_) {}
    return const UploadManifest();
  }

  // ── Upload logo ─────────────────────────────────────────────────────────────
  Future<String?> uploadLogo(String token, PickedFile file) async =>
      _upload(token, 'logo', file,
          Uri.parse('${AppConstants.apiBaseUrl}/api/upload/logo'));

  // ── Upload asset image ──────────────────────────────────────────────────────
  Future<String?> uploadAsset(
          String token, String assetKey, PickedFile file) =>
      _upload(token, assetKey, file,
          Uri.parse('${AppConstants.apiBaseUrl}/api/upload/asset/$assetKey'));

  Future<String?> _upload(
      String token, String key, PickedFile file, Uri uri) async {
    try {
      final req = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['ngrok-skip-browser-warning'] = 'true'
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          file.bytes,
          filename: file.name,
        ));
      final streamed = await req.send().timeout(const Duration(seconds: 30));
      final res = await http.Response.fromStream(streamed);
      if (res.statusCode == 200) {
        state = AsyncData(await _fetch());
        return null;
      }
      return 'Yükleme başarısız. (${res.statusCode})';
    } catch (e) {
      return 'Bağlantı hatası: $e';
    }
  }
}

final uploadManifestProvider =
    AsyncNotifierProvider<UploadManifestNotifier, UploadManifest>(
        UploadManifestNotifier.new);

