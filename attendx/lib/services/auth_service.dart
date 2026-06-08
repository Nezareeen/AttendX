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

  /// Login with employee ID and password using Supabase Auth
  Future<AuthResult> login(int employeeId, String password) async {
    final email = 'emp_$employeeId@attendx.local';

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return AuthResult(success: false, error: 'Authentication failed');
      }

      // Fetch employee data
      final empData = await _supabase
          .from('employees')
          .select()
          .eq('id', employeeId)
          .single();

      final employee = Employee.fromJson(empData);

      // Persist metadata
      await _storage.write(key: _keyEmployeeId, value: employee.id.toString());
      await _storage.write(key: _keyEmployeeName, value: employee.employeeName);
      await _storage.write(key: _keyRole, value: employee.role);
      await _storage.write(key: _keyDesignation, value: employee.designation);

      return AuthResult(success: true, employee: employee);
    } catch (e) {
      return AuthResult(success: false, error: 'Invalid credentials');
    }
  }

  /// Validate the current stored session against the server.
  /// Returns the employee if valid, null if invalid/expired.
  Future<Employee?> validateSession() async {
    final session = _supabase.auth.currentSession;
    if (session == null || session.isExpired) {
      await clearSession();
      return null;
    }

    try {
      final idStr = await _storage.read(key: _keyEmployeeId);
      if (idStr == null) return null;
      
      final employeeId = int.parse(idStr);
      final empData = await _supabase
          .from('employees')
          .select()
          .eq('id', employeeId)
          .single();

      final employee = Employee.fromJson(empData);

      // Update local storage with fresh data
      await _storage.write(key: _keyEmployeeName, value: employee.employeeName);
      await _storage.write(key: _keyRole, value: employee.role);
      await _storage.write(key: _keyDesignation, value: employee.designation);

      return employee;
    } catch (e) {
      // Network error — fall back to stored data
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

  /// Logout — invalidate server session and clear local data.
  Future<void> logout() async {
    await _supabase.auth.signOut();
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
    return await _storage.containsKey(key: _keyEmployeeId);
  }
}
