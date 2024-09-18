import 'dart:io';

import 'package:arti/darti.dart' as arti;
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  // Get platform-specific cache and state directories.
  final cacheDir = await _getCacheDirectory();
  final stateDir = await _getStateDirectory();

  // Example SOCKS port.
  int socksPort = 9050;

  // Test the hello function.
  print('Calling hello function...');
  arti.artiHello();

  // Start the Tor client.
  print('Starting Tor client...');
  final tor = arti.artiStart(socksPort, stateDir.path, cacheDir.path);
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

/// Get the appropriate cache directory based on the platform.
Future<Directory> _getCacheDirectory() async {
  if (Platform.isAndroid) {
    return await getTemporaryDirectory(); // Use temporary directory for Android.
  } else if (Platform.isIOS || Platform.isMacOS) {
    return await getLibraryDirectory(); // Use library directory for iOS/macOS.
  } else if (Platform.isLinux || Platform.isWindows) {
    return await getApplicationSupportDirectory(); // Use application support directory for Linux/Windows.
  } else {
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }
}

/// Get the appropriate state directory based on the platform.
Future<Directory> _getStateDirectory() async {
  if (Platform.isAndroid) {
    return await getApplicationDocumentsDirectory(); // Use documents directory for Android.
  } else if (Platform.isIOS || Platform.isMacOS) {
    return await getApplicationSupportDirectory(); // Use application support directory for iOS/macOS.
  } else if (Platform.isLinux || Platform.isWindows) {
    return await getApplicationSupportDirectory(); // Use application support directory for Linux/Windows.
  } else {
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }
}
