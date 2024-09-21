import 'dart:io';

import 'package:arti/arti.dart' as arti;

Future<void> main() async {
  // Get platform-specific cache and state directories.
  final cacheDir = _getCacheDirectory();
  final stateDir = _getStateDirectory();

  // Example SOCKS port.
  int socksPort = 9050;

  // Test the hello function.
  print('Calling hello function...');
  arti.dartiHello();

  // Start the Tor client.
  print('Starting Tor client...');
  final tor = arti.artiStart(socksPort, stateDir, cacheDir);
  print('Tor client started.');

  // Bootstrap the Tor client.
  print('Bootstrapping Tor client...');
  bool bootstrapped = arti.artiClientBootstrap(tor.client);
  print('Bootstrap result: ${bootstrapped ? "Success" : "Failure"}');

  // Set Tor client to dormant mode.
  print('Setting Tor client to dormant mode...');
  arti.artiClientSetDormant(tor.client, true);
  print('Tor client set to dormant mode.');

  // // Fetch progress updates.
  // print('Fetching progress updates...');
  // String progress;
  // while ((progress = arti.artiProgressNext(tor)) != null) {
  //   print('Progress: $progress');
  // }

  // Stop the Tor proxy.
  print('Stopping Tor proxy...');
  arti.artiProxyStop(tor.proxy);
  print('Tor proxy stopped.');
}

//// Get the appropriate cache directory based on the platform.
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

/// Get the appropriate state directory based on the platform.
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
