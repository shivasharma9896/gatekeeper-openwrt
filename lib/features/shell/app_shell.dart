import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../data/router_repository.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    required this.repository,
    required this.router,
    super.key,
  });

  final RouterRepository repository;
  final RouterInfo router;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      OverviewPage(repository: widget.repository, router: widget.router),
      WifiPage(repository: widget.repository, router: widget.router),
      DevicesPage(repository: widget.repository, router: widget.router),
      ToolsPage(repository: widget.repository, router: widget.router),
      const SettingsPage(),
    ];
    const destinations = [
      NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view), label: 'Overview'),
      NavigationDestination(icon: Icon(Icons.wifi_outlined), selectedIcon: Icon(Icons.wifi), label: 'Wi-Fi'),
      NavigationDestination(icon: Icon(Icons.devices_outlined), selectedIcon: Icon(Icons.devices), label: 'Devices'),
      NavigationDestination(icon: Icon(Icons.build_outlined), selectedIcon: Icon(Icons.build), label: 'Tools'),
      NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                if (wide)
                  NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                    labelType: NavigationRailLabelType.all,
                    leading: const _BrandMark(compact: true),
                    destinations: destinations
                        .map((destination) => NavigationRailDestination(
                              icon: destination.icon,
                              selectedIcon: destination.selectedIcon,
                              label: Text(destination.label),
                            ))
                        .toList(),
                  ),
                Expanded(
                  child: Column(
                    children: [
                      _TopBar(router: widget.router),
                      Expanded(child: pages[_selectedIndex]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                  destinations: destinations,
                ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.router});

  final RouterInfo router;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 10),
      child: Row(
        children: [
          const _BrandMark(),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: router.sessionId == 'mock-session'
                  ? Colors.orange.withValues(alpha: .12)
                  : Colors.green.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 9,
                  color: router.sessionId == 'mock-session'
                      ? Colors.orange
                      : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  router.sessionId == 'mock-session'
                      ? 'Demo data'
                      : 'Connected',
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(router.name.substring(0, 1)),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            child: Image.asset(
              'assets/icon/gatekeeper_monochrome.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: 10),
          Text('GateKeeper', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ],
    );
  }
}

class OverviewPage extends StatelessWidget {
  const OverviewPage({required this.repository, required this.router, super.key});

  final RouterRepository repository;
  final RouterInfo router;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([repository.getNetworks(router), repository.getConnectedDevices(router)]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final networks = snapshot.data![0] as List<WifiNetwork>;
        final devices = snapshot.data![1] as List<ConnectedDevice>;
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          children: [
            Text('Good evening', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Here is the latest from your network.', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            _HeroCard(router: router, devices: devices.length),
            const SizedBox(height: 18),
            GridView.count(
              crossAxisCount: MediaQuery.sizeOf(context).width > 1000 ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.65,
              children: [
                _MetricCard(label: 'Online devices', value: '${devices.length}', icon: Icons.devices, color: Colors.indigo),
                _MetricCard(label: 'Wi-Fi networks', value: '${networks.length}', icon: Icons.wifi, color: Colors.teal),
                const _MetricCard(label: 'Download', value: '184 Mbps', icon: Icons.download, color: Colors.orange),
                const _MetricCard(label: 'Upload', value: '42 Mbps', icon: Icons.upload, color: Colors.pink),
              ],
            ),
            const SizedBox(height: 18),
            _Panel(
              title: 'Network health',
              action: TextButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Open Tools to run a full connection test.')),
                ),
                child: const Text('Run test'),
              ),
              child: const Column(
                children: [
                  _HealthRow(label: 'Internet connection', detail: 'Excellent · 18 ms latency', value: 0.94, color: Colors.green),
                  _HealthRow(label: 'Wi-Fi coverage', detail: 'Good · 2 access points', value: 0.78, color: Colors.blue),
                  _HealthRow(label: 'Router security', detail: 'Protected · No alerts', value: 1, color: Colors.green),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class WifiPage extends StatefulWidget {
  const WifiPage({required this.repository, required this.router, super.key});

  final RouterRepository repository;
  final RouterInfo router;

  @override
  State<WifiPage> createState() => _WifiPageState();
}

class _WifiPageState extends State<WifiPage> {
  bool guestEnabled = true;
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WifiNetwork>>(
      future: widget.repository.getNetworks(widget.router),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final networks = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          children: [
            const _PageHeading(title: 'Wi-Fi networks', subtitle: 'Manage your wireless networks and coverage.'),
            const SizedBox(height: 18),
            ...networks.map((network) => _NetworkTile(network: network, onEdit: () => _showEdit(context, network))),
            const SizedBox(height: 12),
            _Panel(
              title: 'Guest network',
              action: Switch(value: guestEnabled, onChanged: (value) async {
                setState(() => guestEnabled = value);
                await widget.repository.setGuestNetworkEnabled(router: widget.router, enabled: value);
              }),
              child: const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Icon(Icons.people_outline)),
                title: Text('Home-Guest'),
                subtitle: Text('Isolated from your private network · 2 devices'),
                trailing: Icon(Icons.chevron_right),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEdit(BuildContext context, WifiNetwork network) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Edit ${network.band} network', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 18),
            TextField(decoration: const InputDecoration(labelText: 'Network name (SSID)'), controller: TextEditingController(text: network.ssid)),
            const SizedBox(height: 14),
            const TextField(decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: isSaving ? null : () async {
                setState(() => isSaving = true);
                await widget.repository.updateWifiNetwork(
                  router: widget.router,
                  network: network,
                  password: '',
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(isSaving ? 'Saving...' : 'Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class DevicesPage extends StatefulWidget {
  const DevicesPage({required this.repository, required this.router, super.key});

  final RouterRepository repository;
  final RouterInfo router;

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ConnectedDevice>>(
      future: widget.repository.getConnectedDevices(widget.router),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final devices = snapshot.data!.where((device) => device.name.toLowerCase().contains(query.toLowerCase()) || device.address.contains(query)).toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          children: [
            const _PageHeading(title: 'Connected devices', subtitle: 'See who is using your network and manage access.'),
            const SizedBox(height: 18),
            TextField(
              onChanged: (value) => setState(() => query = value),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search devices', suffixIcon: Icon(Icons.tune)),
            ),
            const SizedBox(height: 14),
            _Panel(
              title: 'Online now',
              action: Text('${devices.length} devices'),
              child: Column(
                children: devices.map((device) => _DeviceTile(device: device, onChanged: (allowed) async {
                  await widget.repository.setDeviceBlocked(router: widget.router, device: device, blocked: !allowed);
                  setState(() {});
                })).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ToolsPage extends StatefulWidget {
  const ToolsPage({required this.repository, required this.router, super.key});

  final RouterRepository repository;
  final RouterInfo router;

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  List<DiagnosticResult> diagnostics = const [];
  bool isRunning = false;
  bool isSpeedTesting = false;
  SpeedTestResult? speedTest;
  String? backupMessage;
  String? firmwareMessage;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      children: [
        const _PageHeading(title: 'Tools & diagnostics', subtitle: 'Keep your network fast, safe, and reliable.'),
        const SizedBox(height: 18),
        _ActionCard(
          icon: Icons.speed,
          title: 'Internet speed test',
          subtitle: speedTest == null
              ? 'Measure current download, upload, and latency.'
              : '${speedTest!.downloadMbps.toStringAsFixed(1)} Mbps down · ${speedTest!.uploadMbps.toStringAsFixed(1)} Mbps up · ${speedTest!.latencyMs} ms',
          action: isSpeedTesting ? 'Testing...' : 'Run test',
          onPressed: isSpeedTesting ? null : _runSpeedTest,
        ),
        _ActionCard(icon: Icons.network_check, title: 'Connection diagnostics', subtitle: 'Check DNS, gateway, and internet reachability.', action: isRunning ? 'Running...' : 'Start', onPressed: isRunning ? null : _runDiagnostics),
        _ActionCard(icon: Icons.backup_outlined, title: 'Configuration backup', subtitle: backupMessage ?? 'Save a recoverable copy of your router settings.', action: 'Back up', onPressed: _createBackup),
        _ActionCard(
          icon: Icons.system_update_alt,
          title: 'Firmware updates',
          subtitle: firmwareMessage ?? 'OpenWrt ${widget.router.openWrtVersion}',
          action: 'Check',
          onPressed: _checkFirmware,
        ),
        if (diagnostics.isNotEmpty) _Panel(
          title: 'Latest diagnostic results',
          child: Column(children: diagnostics.map((result) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(result.success ? Icons.check_circle : Icons.error, color: result.success ? Colors.green : Colors.red),
            title: Text(result.name),
            subtitle: Text(result.detail),
            trailing: result.latencyMs == null ? null : Text('${result.latencyMs} ms'),
          )).toList()),
        ),
      ],
    );
  }

  Future<void> _runDiagnostics() async {
    setState(() => isRunning = true);
    try {
      diagnostics = await widget.repository.runDiagnostics(widget.router);
    } finally {
      if (mounted) setState(() => isRunning = false);
    }
  }

  Future<void> _runSpeedTest() async {
    setState(() => isSpeedTesting = true);
    try {
      final result = await widget.repository.runSpeedTest(widget.router);
      if (mounted) setState(() => speedTest = result);
    } catch (error) {
      if (mounted) {
        setState(() => speedTest = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Speed test unavailable: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => isSpeedTesting = false);
    }
  }

  Future<void> _createBackup() async {
    try {
      final message = await widget.repository.createBackup(widget.router);
      if (mounted) setState(() => backupMessage = message);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup unavailable: $error')),
        );
      }
    }
  }

  Future<void> _checkFirmware() async {
    setState(() => firmwareMessage = 'Checking for updates...');
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => firmwareMessage =
          'OpenWrt ${widget.router.openWrtVersion} · No update found');
    }
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      children: [
        const _PageHeading(title: 'Settings', subtitle: 'Customize GateKeeper and your router experience.'),
        const SizedBox(height: 18),
        _Panel(title: 'Preferences', child: Column(children: [
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Notifications'), subtitle: const Text('Alerts for new devices and router health'), value: true, onChanged: (_) {}),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Biometric unlock'), subtitle: const Text('Use Face ID or fingerprint when available'), value: false, onChanged: (_) {}),
        ])),
        const SizedBox(height: 14),
        const _Panel(title: 'About', child: ListTile(contentPadding: EdgeInsets.zero, title: Text('GateKeeper for OpenWrt'), subtitle: Text('Prototype · Standard OpenWrt APIs'), trailing: Text('v0.1.0'))),
      ],
    );
  }
}

class _PageHeading extends StatelessWidget {
  const _PageHeading({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
      ]);
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.router, required this.devices});
  final RouterInfo router;
  final int devices;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1976D2)]),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              child: Image.asset(
                'assets/icon/gatekeeper_monochrome.png',
                width: 30,
                height: 30,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Your network is protected', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('${router.model} · $devices devices online', style: const TextStyle(color: Colors.white70)),
          ])),
          const Icon(Icons.chevron_right, color: Colors.white),
        ]),
      );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.icon, required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child, this.action});
  final String title;
  final Widget child;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.fromLTRB(18, 16, 18, 10), child: Column(children: [
        Row(children: [Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)), const Spacer(), if (action != null) action!]),
        const Divider(height: 22),
        child,
      ])));
}

class _HealthRow extends StatelessWidget {
  const _HealthRow({required this.label, required this.detail, required this.value, required this.color});
  final String label;
  final String detail;
  final double value;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w600)), const Spacer(), Text(detail, style: Theme.of(context).textTheme.bodySmall)]),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: value, minHeight: 7, borderRadius: BorderRadius.circular(8), color: color),
      ]));
}

class _NetworkTile extends StatelessWidget {
  const _NetworkTile({required this.network, required this.onEdit});
  final WifiNetwork network;
  final VoidCallback onEdit;
  @override
  Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(
        leading: CircleAvatar(child: Icon(network.band.contains('5') ? Icons.wifi : Icons.wifi_2_bar)),
        title: Text(network.ssid, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${network.band} · Channel ${network.channel} · ${network.guest ? 'Guest' : 'Private'}'),
        trailing: IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
      ));
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({required this.device, required this.onChanged});
  final ConnectedDevice device;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(child: Icon(device.name.toLowerCase().contains('tv') ? Icons.tv : Icons.devices_other)),
        title: Text(device.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${device.address} · ${device.signal} dBm'),
        trailing: Switch(value: !device.blocked, onChanged: onChanged),
      );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.action, required this.onPressed});
  final IconData icon;
  final String title;
  final String subtitle;
  final String action;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: FilledButton.tonal(onPressed: onPressed, child: Text(action)),
      ));
}
