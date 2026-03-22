import 'dart:ffi';
import 'dart:io';

import 'package:arti/arti.dart' as arti;

Future<void> main() async {
  try {
    await _run();
  } catch (e, st) {
    print('Error: $e');
    print(st);
  }
}

Future<void> _run() async {
  final cacheDir = _getCacheDirectory();
  final stateDir = _getStateDirectory();
  int socksPort = 9050;

  print('Testing FFI linkage...');
  final hello = arti.dartiHello();
  print('FFI says: $hello');

  print('\nStarting Tor on SOCKS port $socksPort...');
  final tor = arti.artiStart(socksPort, stateDir, cacheDir);

  print('Bootstrapping...');
  bool bootstrapped = arti.artiClientBootstrap(tor.client);
  print('Bootstrap: ${bootstrapped ? "ok" : "failed"}');

  while (true) {
    final status = arti.artiBootstrapStatus(tor.client);
    print(
        'Bootstrap: ${(status.progress * 100).round()}% - ${status.message}');
    if (status.progress >= 1.0) break;
    await Future.delayed(Duration(milliseconds: 500));
  }

  print('\nSetting dormant...');
  arti.artiClientSetDormant(tor.client, true);

  print('Reconfiguring...');
  final reconfigured = arti.artiReconfigure(tor.client, stateDir, cacheDir);
  print('Reconfigure: ${reconfigured ? "ok" : "failed"}');

  print('Creating isolated client...');
  final isolatedClient = arti.artiIsolatedClient(tor.client);
  print(
      'Isolated client: ${isolatedClient != nullptr ? "ok" : "failed"}');

  if (isolatedClient != nullptr) {
    final isoStatus = arti.artiBootstrapStatus(isolatedClient);
    print(
        'Isolated bootstrap: ${(isoStatus.progress * 100).round()}% - ${isoStatus.message}');
  }

  print('\nStopping proxy...');
  arti.artiProxyStop(tor.proxy);

  if (isolatedClient != nullptr) {
    arti.artiClientFree(isolatedClient);
  }
  arti.artiClientFree(tor.client);
  print('Done.');
}

String _getCacheDirectory() {
  if (Platform.isMacOS) {
    return "${Platform.environment['HOME']}/Library/Caches";
  } else if (Platform.isLinux) {
    return "${Platform.environment['HOME']}/.cache";
  } else if (Platform.isWindows) {
    return Platform.environment['LOCALAPPDATA'] ??
        "C:\\Users\\${Platform.environment['USERNAME']}\\AppData\\Local";
  } else {
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }
}

String _getStateDirectory() {
  if (Platform.isMacOS) {
    return "${Platform.environment['HOME']}/Library/Application Support";
  } else if (Platform.isLinux) {
    return "${Platform.environment['HOME']}/.local/share";
  } else if (Platform.isWindows) {
    return Platform.environment['APPDATA'] ??
        "C:\\Users\\${Platform.environment['USERNAME']}\\AppData\\Roaming";
  } else {
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }
}
