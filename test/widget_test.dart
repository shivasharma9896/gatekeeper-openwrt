import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:gatekeeper_openwrt/app.dart';
import 'package:gatekeeper_openwrt/data/models.dart';
import 'package:gatekeeper_openwrt/data/mock_router_repository.dart';
import 'package:gatekeeper_openwrt/data/openwrt_rpc_client.dart';
import 'package:gatekeeper_openwrt/features/shell/app_shell.dart';

void main() {
  testWidgets('shows GateKeeper onboarding form', (tester) async {
    await tester.pumpWidget(
      GateKeeperApp(repository: MockRouterRepository()),
    );

    expect(find.text('Connect your OpenWrt router'), findsOneWidget);
    expect(find.text('Connect'), findsOneWidget);
    expect(find.text('Router address'), findsOneWidget);
  });

  test('parses an OpenWrt login response', () async {
    final client = OpenWrtRpcClient(
      client: MockClient((request) async => http.Response(
        '{"result":[0,{"ubus_rpc_session":"abc123"}]}',
        200,
      )),
    );

    final session = await client.login(
      address: '192.168.1.1',
      username: 'root',
      password: 'secret',
    );

    expect(session, 'abc123');
  });

  test('mock repository returns speed-test measurements', () async {
    final repository = MockRouterRepository();
    const router = RouterInfo(
      name: 'Home Router',
      model: 'OpenWrt One',
      address: '192.168.1.1',
      openWrtVersion: '23.05.3',
      uptime: Duration(days: 1),
      sessionId: 'mock-session',
    );

    final result = await repository.runSpeedTest(router);

    expect(result.downloadMbps, greaterThan(0));
    expect(result.uploadMbps, greaterThan(0));
    expect(result.latencyMs, greaterThan(0));
  });

  testWidgets('navigates through the GateKeeper feature shell', (tester) async {
    await tester.pumpWidget(
      OpenWrtManagerTestApp(repository: MockRouterRepository()),
    );
    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();
    expect(find.text('Good evening'), findsOneWidget);
    expect(find.text('Wi-Fi'), findsWidgets);
  });

  testWidgets('renders every primary feature screen', (tester) async {
    final repository = MockRouterRepository();
    const router = RouterInfo(
      name: 'Home Router',
      model: 'OpenWrt One',
      address: '192.168.1.1',
      openWrtVersion: '23.05.3',
      uptime: Duration(days: 1),
      sessionId: 'test-session',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: AppShell(repository: repository, router: router),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Good evening'), findsOneWidget);
    for (final label in ['Wi-Fi', 'Devices', 'Tools', 'Settings']) {
      await tester.tap(find.text(label).last);
      await tester.pump(const Duration(milliseconds: 600));
    }
    expect(find.text('Settings'), findsNWidgets(2));
  });
}

class OpenWrtManagerTestApp extends StatelessWidget {
  const OpenWrtManagerTestApp({required this.repository, super.key});

  final MockRouterRepository repository;

  @override
  Widget build(BuildContext context) {
    return GateKeeperApp(repository: repository);
  }
}
