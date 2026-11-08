import 'models.dart';
import 'router_repository.dart';

class MockRouterRepository implements RouterRepository {
  final List<ConnectedDevice> _devices = [
    const ConnectedDevice(
      name: 'MacBook Pro',
      address: '192.168.1.10',
      mac: 'A4:83:E7:10:2B:91',
      signal: -42,
      blocked: false,
    ),
    const ConnectedDevice(
      name: 'Pixel Phone',
      address: '192.168.1.11',
      mac: '68:5B:35:9C:12:07',
      signal: -58,
      blocked: false,
    ),
    const ConnectedDevice(
      name: 'Living Room TV',
      address: '192.168.1.20',
      mac: 'D8:31:34:AA:90:44',
      signal: -67,
      blocked: false,
    ),
  ];

  @override
  Future<RouterInfo> connect({
    required String address,
    required String username,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (address.trim().isEmpty || username.trim().isEmpty) {
      throw const FormatException('Router address and username are required.');
    }

    return RouterInfo(
      name: 'Home Router',
      model: 'OpenWrt One',
      address: address.trim(),
      openWrtVersion: '23.05.3',
      uptime: const Duration(days: 12, hours: 4, minutes: 32),
      sessionId: 'mock-session',
    );
  }

  @override
  Future<List<WifiNetwork>> getNetworks(RouterInfo router) async {
    return const [
      WifiNetwork(
        ssid: 'Home Wi-Fi',
        band: '5 GHz',
        channel: 36,
        enabled: true,
        guest: false,
      ),
      WifiNetwork(
        ssid: 'Home Wi-Fi',
        band: '2.4 GHz',
        channel: 6,
        enabled: true,
        guest: false,
      ),
      WifiNetwork(
        ssid: 'Home-Guest',
        band: '2.4 GHz',
        channel: 11,
        enabled: true,
        guest: true,
      ),
    ];
  }

  @override
  Future<List<ConnectedDevice>> getConnectedDevices(RouterInfo router) async {
    return List<ConnectedDevice>.of(_devices);
  }

  @override
  Future<void> setDeviceBlocked({
    required RouterInfo router,
    required ConnectedDevice device,
    required bool blocked,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final index = _devices.indexWhere((item) => item.mac == device.mac);
    if (index >= 0) {
      _devices[index] = ConnectedDevice(
        name: device.name,
        address: device.address,
        mac: device.mac,
        signal: device.signal,
        blocked: blocked,
      );
    }
  }

  @override
  Future<RouterCapabilities> getCapabilities(RouterInfo router) async {
    return const RouterCapabilities(
      supportsGuestNetwork: true,
      supportsClientBlocking: true,
      supportsFirmwareUpdates: true,
    );
  }

  @override
  Future<List<DiagnosticResult>> runDiagnostics(RouterInfo router) async {
    return const [
      DiagnosticResult(name: 'Gateway', detail: 'Reachable', success: true, latencyMs: 2),
      DiagnosticResult(name: 'DNS resolution', detail: 'Working normally', success: true, latencyMs: 18),
      DiagnosticResult(name: 'Internet access', detail: 'Connected', success: true, latencyMs: 24),
    ];
  }

  @override
  Future<SpeedTestResult> runSpeedTest(RouterInfo router) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return const SpeedTestResult(
      downloadMbps: 184.6,
      uploadMbps: 42.3,
      latencyMs: 18,
    );
  }

  @override
  Future<void> updateWifiNetwork({
    required RouterInfo router,
    required WifiNetwork network,
    required String password,
  }) async {}

  @override
  Future<void> setGuestNetworkEnabled({
    required RouterInfo router,
    required bool enabled,
  }) async {}

  @override
  Future<String> createBackup(RouterInfo router) async {
    return 'Mock backup created for ${router.name}.';
  }
}
