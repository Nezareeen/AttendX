import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecureLocalStorage extends LocalStorage {
  final _storage = const FlutterSecureStorage();

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> accessToken() async {
    _storage.read(key: 'supabase.session');
    return null;
  }

  @override
  Future<bool> hasAccessToken() async =>
      await _storage.containsKey(key: 'supabase.session');

  @override
  Future<void> persistSession(String value) async =>
      _storage.write(key: 'supabase.session', value: value);

  @override
  Future<void> removePersistedSession() async =>
      _storage.delete(key: 'supabase.session');
}
