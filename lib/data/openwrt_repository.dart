import 'models.dart';
import 'openwrt_rpc_client.dart';
import 'router_repository.dart';

class OpenWrtRepository implements RouterRepository {
  OpenWrtRepository({OpenWrtRpcClient? client}) : _client = client ?? OpenWrtRpcClient();

  final OpenWrtRpcClient _client;

  @override
  Future<RouterInfo> connect({
    required String address,
    required String username,
    required String password,
  }) async {
    final session = await _client.login(
      address: address.trim(),
      username: username.trim(),
      password: password,
    );
    final system = await _client.call(
      address: address.trim(),
      sessionId: session,
      object: 'system',
      method: 'info',
    ) as Map<String, dynamic>;
    final release = (system['release'] as Map?)?.cast<String, dynamic>() ?? {};
    return RouterInfo(
      name: (release['hostname'] as String?) ?? 'OpenWrt Router',
      model: (system['board_name'] as String?) ?? 'OpenWrt',
      address: address.trim(),
      openWrtVersion: (release['version'] as String?) ?? 'Unknown',
      uptime: Duration(seconds: (system['uptime'] as num?)?.toInt() ?? 0),
      sessionId: session,
    );
  }

  @override
  Future<List<WifiNetwork>> getNetworks(RouterInfo router) async {
    final radios = await _client.call(
      address: router.address,
      sessionId: router.sessionId,
      object: 'iwinfo',
      method: 'devices',
    );
    if (radios is! List) return const [];
    final networks = <WifiNetwork>[];
    for (final radio in radios.whereType<String>()) {
      final info = await _client.call(
        address: router.address,
        sessionId: router.sessionId,
        object: 'iwinfo',
        method: 'info',
        params: [radio],
      );
      if (info is Map<String, dynamic>) {
        networks.add(WifiNetwork(
          ssid: (info['ssid'] as String?) ?? radio,
          band: (info['frequency'] as String?) ?? radio,
          channel: (info['channel'] as num?)?.toInt() ?? 0,
          enabled: true,
          guest: (info['ssid'] as String?)?.toLowerCase().contains('guest') ?? false,
        ));
      }
    }
    return networks;
  }

  @override
  Future<List<ConnectedDevice>> getConnectedDevices(RouterInfo router) async {
    final leases = await _client.call(
      address: router.address,
      sessionId: router.sessionId,
      object: 'dhcp',
      method: 'ipv4leases',
    );
    if (leases is! List) return const [];
    return leases.whereType<Map>().map((lease) => ConnectedDevice(
      name: (lease['hostname'] as String?)?.isNotEmpty == true ? lease['hostname'] as String : 'Unknown device',
      address: (lease['ipaddr'] as String?) ?? '',
      mac: (lease['macaddr'] as String?) ?? '',
      signal: 0,
      blocked: false,
    )).toList();
  }

  @override
  Future<void> setDeviceBlocked({
    required RouterInfo router,
    required ConnectedDevice device,
    required bool blocked,
  }) async {
    await _client.call(
      address: router.address,
      sessionId: router.sessionId,
      object: 'uci',
      method: 'set',
      params: ['firewall', '@rule[-1]', 'src_mac', device.mac],
    );
  }

  @override
  Future<RouterCapabilities> getCapabilities(RouterInfo router) async {
    return const RouterCapabilities(
      supportsGuestNetwork: true,
      supportsClientBlocking: true,
      supportsBackups: true,
      supportsFirmwareUpdates: true,
    );
  }

  @override
  Future<List<DiagnosticResult>> runDiagnostics(RouterInfo router) async {
    final result = await _client.call(
      address: router.address,
      sessionId: router.sessionId,
      object: 'system',
      method: 'info',
    );
    return [
      DiagnosticResult(
        name: 'Router API',
        detail: result is Map ? 'Reachable' : 'Unexpected response',
        success: result is Map,
      ),
    ];
  }

  @override
  Future<SpeedTestResult> runSpeedTest(RouterInfo router) async {
    throw const OpenWrtException(
      'Speed testing requires an internet test endpoint; it cannot be measured by rpcd alone.',
    );
  }

  @override
  Future<void> updateWifiNetwork({
    required RouterInfo router,
    required WifiNetwork network,
    required String password,
  }) async {
    await _client.call(
      address: router.address,
      sessionId: router.sessionId,
      object: 'uci',
      method: 'set',
      params: ['wireless', '@wifi-iface[0]', 'ssid', network.ssid],
    );
  }

  @override
  Future<void> setGuestNetworkEnabled({
    required RouterInfo router,
    required bool enabled,
  }) async {}

  @override
  Future<String> createBackup(RouterInfo router) async {
    throw const OpenWrtException('Backup export requires a privileged file endpoint.');
  }
}
