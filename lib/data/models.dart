class RouterInfo {
  const RouterInfo({
    required this.name,
    required this.model,
    required this.address,
    required this.openWrtVersion,
    required this.uptime,
    required this.sessionId,
  });

  final String name;
  final String model;
  final String address;
  final String openWrtVersion;
  final Duration uptime;
  final String sessionId;
}

class WifiNetwork {
  const WifiNetwork({
    required this.ssid,
    required this.band,
    required this.channel,
    required this.enabled,
    required this.guest,
  });

  final String ssid;
  final String band;
  final int channel;
  final bool enabled;
  final bool guest;
}

class ConnectedDevice {
  const ConnectedDevice({
    required this.name,
    required this.address,
    required this.mac,
    required this.signal,
    required this.blocked,
  });

  final String name;
  final String address;
  final String mac;
  final int signal;
  final bool blocked;
}

class RouterCapabilities {
  const RouterCapabilities({
    this.supportsGuestNetwork = false,
    this.supportsClientBlocking = false,
    this.supportsBackups = true,
    this.supportsFirmwareUpdates = false,
  });

  final bool supportsGuestNetwork;
  final bool supportsClientBlocking;
  final bool supportsBackups;
  final bool supportsFirmwareUpdates;
}

class DiagnosticResult {
  const DiagnosticResult({
    required this.name,
    required this.detail,
    required this.success,
    this.latencyMs,
  });

  final String name;
  final String detail;
  final bool success;
  final int? latencyMs;
}

class SpeedTestResult {
  const SpeedTestResult({
    required this.downloadMbps,
    required this.uploadMbps,
    required this.latencyMs,
  });

  final double downloadMbps;
  final double uploadMbps;
  final int latencyMs;
}
