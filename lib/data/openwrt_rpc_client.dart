import 'dart:convert';

import 'package:http/http.dart' as http;

class OpenWrtException implements Exception {
  const OpenWrtException(this.message);

  final String message;

  @override
  String toString() => message;
}

class OpenWrtRpcClient {
  OpenWrtRpcClient({
    http.Client? client,
    Duration timeout = const Duration(seconds: 8),
  })  : _client = client ?? http.Client(),
        _timeout = timeout;

  final http.Client _client;
  final Duration _timeout;
  int _requestId = 1;

  Future<dynamic> call({
    required String address,
    required String sessionId,
    required String object,
    required String method,
    List<dynamic> params = const [],
  }) async {
    final normalized = address.startsWith('http') ? address : 'http://$address';
    final response = await _client
        .post(
          Uri.parse('$normalized/ubus'),
          headers: const {'content-type': 'application/json'},
          body: jsonEncode({
            'jsonrpc': '2.0',
            'id': _requestId++,
            'method': 'call',
            'params': [sessionId, object, method, params],
          }),
        )
        .timeout(_timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw OpenWrtException('OpenWrt returned HTTP ${response.statusCode}.');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final result = decoded['result'];
    if (result is! List || result.length < 2 || result[0] != 0) {
      throw const OpenWrtException('OpenWrt rejected the request.');
    }
    return result[1];
  }

  Future<String> login({
    required String address,
    required String username,
    required String password,
  }) async {
    final normalized = address.startsWith('http') ? address : 'http://$address';
    final response = await _client
        .post(
          Uri.parse('$normalized/ubus'),
          headers: const {'content-type': 'application/json'},
          body: jsonEncode({
            'jsonrpc': '2.0',
            'id': _requestId++,
            'method': 'call',
            'params': [
              '0' * 32,
              'session',
              'login',
              [username, password, {'timeout': 3600, 'expires': 3600}],
            ],
          }),
        )
        .timeout(_timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const OpenWrtException('Unable to reach the OpenWrt router.');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final result = decoded['result'];
    if (result is! List || result.length < 2 || result[0] != 0) {
      throw const OpenWrtException('Invalid username or password.');
    }
    final data = result[1];
    if (data is! Map || data['ubus_rpc_session'] is! String) {
      throw const OpenWrtException('OpenWrt did not return a session.');
    }
    return data['ubus_rpc_session'] as String;
  }

  void close() => _client.close();
}
