import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

const _verificationBaseUrl =
    'https://smartdine-backend-oq2x.onrender.com/api/verification-codes';

class VerificationCodeAPI {
  Future<bool> createCode({
    required String email,
    required String code,
    required DateTime expiresAt,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_verificationBaseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'code': code.trim(),
          'expiresAt': expiresAt.toIso8601String(),
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      debugPrint(
        'createCode failed: ${response.statusCode} - ${response.body}',
      );
      return false;
    } catch (err) {
      debugPrint('createCode error: $err');
      return false;
    }
  }

  Future<bool> verify({required String email, required String code}) async {
    try {
      final response = await http.post(
        Uri.parse('$_verificationBaseUrl/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim(), 'code': code.trim()}),
      );
      return response.statusCode == 200;
    } catch (err) {
      debugPrint('verifyCode error: $err');
      return false;
    }
  }
}

final verificationCodeApiProvider = Provider<VerificationCodeAPI>(
  (ref) => VerificationCodeAPI(),
);
