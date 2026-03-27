import 'dart:convert';
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

/// Fetch clearnet IP, bootstrap Tor, fetch IP via SOCKS, compare.
Future<void> _run() async {
  print('Fetching clearnet IP...');
  final clearnetIp = await _fetchIp();
  print('Clearnet IP: $clearnetIp');

  final cacheDir = _getCacheDirectory();
  final stateDir = _getStateDirectory();
  const socksPort = 9050;

  print('\nStarting Tor on SOCKS port $socksPort...');
  final tor = arti.artiStart(socksPort, stateDir, cacheDir);
  arti.artiClientBootstrap(tor.client);

  while (true) {
    final status = arti.artiBootstrapStatus(tor.client);
    print('Bootstrap: ${(status.progress * 100).round()}%');
    if (status.progress >= 1.0) break;
    await Future.delayed(Duration(milliseconds: 500));
  }

  print('\nFetching Tor IP...');
  final torIp = await _fetchIpViaSocks('127.0.0.1', socksPort);
  print('Tor IP:      $torIp');

  print('\n--- Result ---');
  print('Clearnet: $clearnetIp');
  print('Tor:      $torIp');
  if (clearnetIp != torIp) {
    print('IPs differ — Tor is working.');
  } else {
    print('WARNING: IPs match — traffic may not be routing through Tor.');
  }

  arti.artiProxyStop(tor.proxy);
  arti.artiClientFree(tor.client);
}

Future<String> _fetchIp() async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse('https://api.ipify.org'));
    final response = await request.close();
    return await response.transform(utf8.decoder).join();
  } finally {
    client.close();
  }
}

/// Fetch IP via SOCKS5 using curl (Dart HttpClient lacks SOCKS support).
Future<String> _fetchIpViaSocks(String proxyHost, int proxyPort) async {
  final result = await Process.run('curl', [
    '-s',
    '--socks5-hostname',
    '$proxyHost:$proxyPort',
    'https://api.ipify.org',
  ]);
  if (result.exitCode != 0) {
    throw Exception('curl failed: ${result.stderr}');
  }
  return (result.stdout as String).trim();
}

String _getCacheDirectory() {
  if (Platform.isMacOS) {
    return "${Platform.environment['HOME']}/Library/Caches";
  } else if (Platform.isLinux) {
    return "${Platform.environment['HOME']}/.cache";
  } else if (Platform.isWindows) {
    return Platform.environment['LOCALAPPDATA'] ??
        "C:\\Users\\${Platform.environment['USERNAME']}\\AppData\\Local";
  }
  throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
}

String _getStateDirectory() {
  if (Platform.isMacOS) {
    return "${Platform.environment['HOME']}/Library/Application Support";
  } else if (Platform.isLinux) {
    return "${Platform.environment['HOME']}/.local/share";
  } else if (Platform.isWindows) {
    return Platform.environment['APPDATA'] ??
        "C:\\Users\\${Platform.environment['USERNAME']}\\AppData\\Roaming";
  }
  throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
}
