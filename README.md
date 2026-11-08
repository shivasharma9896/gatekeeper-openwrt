# GateKeeper for OpenWrt

Flutter foundation for GateKeeper, a cross-platform OpenWrt router management app.

## Current milestone

The first vertical slice includes:

- Router onboarding form
- Repository boundary for OpenWrt integration
- Mock router connection
- Router status summary
- Wi-Fi network list
- Connected-device list
- Device block/unblock action

The app includes both `MockRouterRepository` for UI development and `OpenWrtRepository`/`OpenWrtRpcClient` for standard OpenWrt `rpcd`/`ubus` integration. The app entry point remains in mock mode until a router-specific environment is configured and tested.

Credentials can be stored through `CredentialStore`, backed by the platform secure-storage implementation. Never expose `rpcd` directly to the public internet; use a LAN connection or a secured VPN/tunnel.

## Branding

GateKeeper branding assets live in `assets/icon/`. The supplied monochrome asset is used in the in-app logo and as the adaptive launcher mark. The square and foreground paths are currently derived copies because only `gatekeeper_monochrome.png` was present in Downloads; replace them with the original full-color files when available and rerun `dart run flutter_launcher_icons`.

## Run

Install Flutter, then run:

```bash
flutter pub get
flutter run
flutter test
```

The app currently targets standard OpenWrt APIs and is not intended to manage arbitrary stock-router firmware.

To run the real OpenWrt integration instead of mock data:

```bash
flutter run --dart-define=REAL_OPENWRT=true
```

Use this only while connected to a trusted LAN or secured VPN. The real integration currently targets standard `rpcd`/`ubus` endpoints and should be tested against a disposable OpenWrt device before production use.
