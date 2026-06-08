import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/supabase_provider.dart';
import '../models/database_models.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final supabaseClient = ref.watch(supabaseProvider);
  return AuthService(supabaseClient);
});

class AuthResult {
  final bool success;
  final String? error;
  final String? token;
  final String? refreshToken;
  final DateTime? expiresAt;
  final Employee? employee;

  AuthResult({
    required this.success,
    this.error,
    this.token,
    this.refreshToken,
    this.expiresAt,
    this.employee,
  });
}

class AuthService {
  final SupabaseClient _supabase;
  static const _storage = FlutterSecureStorage();

  // Secure storage keys
  static const _keyToken = 'session_token';
  static const _keyRefreshToken = 'session_refresh_token';
  static const _keyExpiresAt = 'session_expires_at';
  static const _keyEmployeeId = 'employeeId';
  static const _keyEmployeeName = 'EmployeeName';
  static const _keyRole = 'role';
  static const _keyDesignation = 'designation';

  AuthService(this._supabase);

  /// Hash a password with SHA-256 before sending to the server.
  /// The server will hash the stored plaintext password the same way and compare.
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Login with employee ID and password.
  /// Password is hashed client-side before being sent.
  Future<AuthResult> login(int employeeId, String password) async {
    final passwordHash = hashPassword(password);

    final response = await _supabase.rpc(
      'authenticate_user',
      params: {
        'p_employee_id': employeeId,
        'p_password_hash': passwordHash,
      },
    );

    final data = response as Map<String, dynamic>;

    if (data['success'] != true) {
      return AuthResult(
        success: false,
        error: data['error'] as String? ?? 'Authentication failed',
      );
    }

    final token = data['token'] as String;
    final refreshToken = data['refresh_token'] as String;
    final expiresAt = DateTime.parse(data['expires_at'] as String);
    final employeeData = data['employee'] as Map<String, dynamic>;
    final employee = Employee.fromJson(employeeData);

    // Persist session data securely
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
    await _storage.write(key: _keyExpiresAt, value: expiresAt.toIso8601String());
    await _storage.write(key: _keyEmployeeId, value: employee.id.toString());
    await _storage.write(key: _keyEmployeeName, value: employee.employeeName);
    await _storage.write(key: _keyRole, value: employee.role);
    await _storage.write(key: _keyDesignation, value: employee.designation);

    return AuthResult(
      success: true,
      token: token,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      employee: employee,
    );
  }

  /// Validate the current stored session against the server.
  /// Returns the employee if valid, null if invalid/expired.
  Future<Employee?> validateSession() async {
    final token = await _storage.read(key: _keyToken);
    if (token == null) return null;

    // Check local expiry first to avoid unnecessary network call
    final expiresAtStr = await _storage.read(key: _keyExpiresAt);
    if (expiresAtStr != null) {
      final expiresAt = DateTime.tryParse(expiresAtStr);
      if (expiresAt != null && expiresAt.isBefore(DateTime.now())) {
        // Try to refresh the session
        final refreshed = await refreshSession();
        if (!refreshed) {
          await clearSession();
          return null;
        }
      }
    }

    try {
      final currentToken = await _storage.read(key: _keyToken);
      final response = await _supabase.rpc(
        'validate_session',
        params: {'p_token': currentToken},
      );

      final data = response as Map<String, dynamic>;

      if (data['valid'] != true) {
        await clearSession();
        return null;
      }

      final employeeData = data['employee'] as Map<String, dynamic>;
      final employee = Employee.fromJson(employeeData);

      // Update local storage with fresh data from server (including designation)
      await _storage.write(key: _keyEmployeeId, value: employee.id.toString());
      await _storage.write(key: _keyEmployeeName, value: employee.employeeName);
      await _storage.write(key: _keyRole, value: employee.role);
      await _storage.write(key: _keyDesignation, value: employee.designation);

      return employee;
    } catch (e) {
      // Network error — fall back to stored data if session hasn't expired
      final id = await _storage.read(key: _keyEmployeeId);
      final name = await _storage.read(key: _keyEmployeeName);
      final role = await _storage.read(key: _keyRole);
      final designation = await _storage.read(key: _keyDesignation);
      
      if (id != null && name != null) {
        return Employee(
          id: int.parse(id),
          employeeName: name,
          employeePhone: 0,
          designation: designation ?? 'Employee',
          createdAt: DateTime.now(),
          role: role ?? 'User',
        );
      }
      return null;
    }
  }

  /// Refresh the session using the stored refresh token.
  Future<bool> refreshSession() async {
    final refreshToken = await _storage.read(key: _keyRefreshToken);
    if (refreshToken == null) return false;

    try {
      final response = await _supabase.rpc(
        'refresh_session',
        params: {'p_refresh_token': refreshToken},
      );

      final data = response as Map<String, dynamic>;

      if (data['success'] != true) return false;

      await _storage.write(key: _keyToken, value: data['token'] as String);
      await _storage.write(key: _keyRefreshToken, value: data['refresh_token'] as String);
      await _storage.write(
        key: _keyExpiresAt,
        value: (data['expires_at'] as String),
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Logout — invalidate server session and clear local data.
  Future<void> logout() async {
    final token = await _storage.read(key: _keyToken);

    if (token != null) {
      try {
        await _supabase.rpc(
          'invalidate_session',
          params: {'p_token': token},
        );
      } catch (_) {
        // Best-effort server invalidation — clear local data regardless
      }
    }

    await clearSession();
  }

  /// Clear all stored session data.
  Future<void> clearSession() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyExpiresAt);
    await _storage.delete(key: _keyEmployeeId);
    await _storage.delete(key: _keyEmployeeName);
    await _storage.delete(key: _keyRole);
    await _storage.delete(key: _keyDesignation);
  }

  /// Check if there is a stored session (quick check, no network).
  static Future<bool> hasStoredSession() async {
    return await _storage.containsKey(key: _keyToken);
  }
}
