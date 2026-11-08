import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../data/router_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    required this.repository,
    required this.router,
    super.key,
  });

  final RouterRepository repository;
  final RouterInfo router;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<_DashboardData> _dashboard;

  @override
  void initState() {
    super.initState();
    _dashboard = _loadDashboard();
  }

  Future<_DashboardData> _loadDashboard() async {
    final results = await Future.wait([
      widget.repository.getNetworks(widget.router),
      widget.repository.getConnectedDevices(widget.router),
    ]);
    return _DashboardData(
      networks: results[0] as List<WifiNetwork>,
      devices: results[1] as List<ConnectedDevice>,
    );
  }

  Future<void> _refresh() async {
    setState(() => _dashboard = _loadDashboard());
    await _dashboard;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.router.name),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<_DashboardData>(
        future: _dashboard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Unable to load router data: ${snapshot.error}'));
          }

          final data = snapshot.requireData;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _RouterSummary(router: widget.router),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Wi-Fi networks',
                  icon: Icons.wifi,
                  trailing: Text('${data.networks.length} configured'),
                  child: Column(
                    children: data.networks
                        .map((network) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                network.guest ? Icons.people_outline : Icons.wifi,
                              ),
                              title: Text(network.ssid),
                              subtitle: Text(
                                '${network.band}  •  Channel ${network.channel}',
                              ),
                              trailing: Icon(
                                network.enabled
                                    ? Icons.check_circle
                                    : Icons.pause_circle,
                                color: network.enabled
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Connected devices',
                  icon: Icons.devices,
                  trailing: Text('${data.devices.length} online'),
                  child: Column(
                    children: data.devices
                        .map(
                          (device) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              child: Icon(Icons.devices_other),
                            ),
                            title: Text(device.name),
                            subtitle: Text(
                              '${device.address}  •  ${device.signal} dBm',
                            ),
                            trailing: Switch(
                              value: !device.blocked,
                              onChanged: (online) => _toggleDevice(device, online),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _toggleDevice(ConnectedDevice device, bool online) async {
    await widget.repository.setDeviceBlocked(
      router: widget.router,
      device: device,
      blocked: !online,
    );
    if (mounted) {
      await _refresh();
    }
  }
}

class _DashboardData {
  const _DashboardData({
    required this.networks,
    required this.devices,
  });

  final List<WifiNetwork> networks;
  final List<ConnectedDevice> devices;
}

class _RouterSummary extends StatelessWidget {
  const _RouterSummary({required this.router});

  final RouterInfo router;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.router,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(router.model, style: Theme.of(context).textTheme.titleLarge),
                  Text('${router.address}  •  OpenWrt ${router.openWrtVersion}'),
                  Text(
                    'Uptime: ${router.uptime.inDays} days',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.trailing,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, size: 22),
                const SizedBox(width: 10),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                trailing,
              ],
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}
