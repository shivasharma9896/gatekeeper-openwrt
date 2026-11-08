import 'models.dart';

abstract interface class RouterRepository {
  Future<RouterInfo> connect({
    required String address,
    required String username,
    required String password,
  });

  Future<List<WifiNetwork>> getNetworks(RouterInfo router);

  Future<List<ConnectedDevice>> getConnectedDevices(RouterInfo router);

  Future<void> setDeviceBlocked({
    required RouterInfo router,
    required ConnectedDevice device,
    required bool blocked,
  });

  Future<RouterCapabilities> getCapabilities(RouterInfo router) async {
    return const RouterCapabilities();
  }

  Future<List<DiagnosticResult>> runDiagnostics(RouterInfo router) async {
    return const [];
  }

  Future<SpeedTestResult> runSpeedTest(RouterInfo router) async {
    return const SpeedTestResult(downloadMbps: 0, uploadMbps: 0, latencyMs: 0);
  }

  Future<void> updateWifiNetwork({
    required RouterInfo router,
    required WifiNetwork network,
    required String password,
  }) async {}

  Future<void> setGuestNetworkEnabled({
    required RouterInfo router,
    required bool enabled,
  }) async {}

  Future<String> createBackup(RouterInfo router) async {
    return 'Backup is not available for this router.';
  }
}
