import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppStorage {
  static const _kToken = 'jwt_token';
  static final _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) => _storage.write(key: _kToken, value: token);
  static Future<String?> readToken() => _storage.read(key: _kToken);
  static Future<void> clear() => _storage.deleteAll();
}