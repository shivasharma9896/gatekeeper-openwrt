import 'package:flutter/material.dart';

import 'app.dart';
import 'data/mock_router_repository.dart';
import 'data/openwrt_repository.dart';
import 'data/router_repository.dart';

void main() {
  const useRealRouter = bool.fromEnvironment('REAL_OPENWRT');
  final RouterRepository repository =
      useRealRouter ? OpenWrtRepository() : MockRouterRepository();
  runApp(
    GateKeeperApp(repository: repository),
  );
}
