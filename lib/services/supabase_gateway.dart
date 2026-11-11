import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/supabase_config.dart';

/// Edge Function javobi. Xatoda [json] bo‘sh bo‘lishi mumkin.
class FunctionResult {
  const FunctionResult({required this.statusCode, this.json});

  final int statusCode;
  final Map<String, dynamic>? json;
}

/// Supabase Edge Function chaqiruvi.
abstract class EdgeInvoker {
  bool get isReady;

  Future<FunctionResult?> invoke(
    String name,
    Map<String, dynamic> body, {
    Duration? timeout,
  });
}

/// Haqiqiy chaqiruv: foydalanuvchi JWT si `Authorization` sarlavhasida.
class SupabaseGateway implements EdgeInvoker {
  SupabaseGateway({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  var _ready = false;
  var _started = false;

  @override
  bool get isReady => _ready;

  /// URL va anon kalit berilgan bo‘lsa, anonim sessiya oladi.
  /// Telefon OTP alohida ish. Xato bo‘lsa lokal rejimda qoladi.
  Future<void> ensureSession() async {
    if (_started) return;
    _started = true;
    if (!SupabaseConfig.isConfigured) return;

    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.anonKey,
      );
      final auth = Supabase.instance.client.auth;
      if (auth.currentSession == null) {
        final response = await auth.signInAnonymously();
        _ready = response.session?.accessToken.isNotEmpty ?? false;
      } else {
        _ready = auth.currentSession!.accessToken.isNotEmpty;
      }
    } catch (_) {
      _ready = false;
    }
  }

  @override
  Future<FunctionResult?> invoke(
    String name,
    Map<String, dynamic> body, {
    Duration? timeout,
  }) async {
    if (!_ready) return null;
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null || token.isEmpty) return null;

    final uri = Uri.parse('${SupabaseConfig.url}/functions/v1/$name');
    try {
      final res = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'apikey': SupabaseConfig.anonKey,
            },
            body: jsonEncode(body),
          )
          .timeout(timeout ?? const Duration(seconds: 12));

      Map<String, dynamic>? decoded;
      try {
        final raw = jsonDecode(res.body);
        if (raw is Map<String, dynamic>) decoded = raw;
      } catch (_) {
        decoded = null;
      }
      return FunctionResult(statusCode: res.statusCode, json: decoded);
    } catch (_) {
      return null;
    }
  }
}
