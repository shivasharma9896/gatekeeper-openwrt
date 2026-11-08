import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CredentialStore {
  CredentialStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<void> save({
    required String address,
    required String username,
    required String password,
  }) async {
    await Future.wait([
      _storage.write(key: 'router_address', value: address),
      _storage.write(key: 'router_username', value: username),
      _storage.write(key: 'router_password', value: password),
    ]);
  }

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> clear() => _storage.deleteAll();
}
