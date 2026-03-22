import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:arti/arti.dart' as arti;

void main() {
  runApp(const ArtiExampleApp());
}

class ArtiExampleApp extends StatelessWidget {
  const ArtiExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arti Example',
      home: const ArtiHomePage(),
    );
  }
}

class ArtiHomePage extends StatefulWidget {
  const ArtiHomePage({super.key});

  @override
  State<ArtiHomePage> createState() => _ArtiHomePageState();
}

class _ArtiHomePageState extends State<ArtiHomePage> {
  final List<String> _log = [];
  bool _running = false;

  void _addLog(String msg) {
    print(msg);
    setState(() => _log.add(msg));
  }

  Future<void> _runTest() async {
    setState(() {
      _log.clear();
      _running = true;
    });

    try {
      _addLog('Calling dartiHello()...');
      final hello = arti.dartiHello();
      _addLog('Hello result: $hello');

      final cacheDir = _getCacheDirectory();
      final stateDir = _getStateDirectory();
      const socksPort = 9050;

      _addLog('Starting Tor client on port $socksPort...');
      final tor = arti.artiStart(socksPort, stateDir, cacheDir);
      _addLog('Tor client started.');

      _addLog('Bootstrapping...');
      final ok = arti.artiClientBootstrap(tor.client);
      _addLog('Bootstrap result: ${ok ? "Success" : "Failure"}');

      _addLog('Checking bootstrap status...');
      final status = arti.artiBootstrapStatus(tor.client);
      _addLog('Bootstrap: ${(status.progress * 100).round()}% - ${status.message}');

      _addLog('Setting dormant mode...');
      arti.artiClientSetDormant(tor.client, true);
      _addLog('Dormant mode set.');

      _addLog('Reconfiguring...');
      final reconfigured = arti.artiReconfigure(tor.client, stateDir, cacheDir);
      _addLog('Reconfigure: ${reconfigured ? "Success" : "Failure"}');

      _addLog('Creating isolated client...');
      final isolated = arti.artiIsolatedClient(tor.client);
      _addLog('Isolated client: ${isolated != nullptr ? "Success" : "Failure"}');

      _addLog('Stopping proxy...');
      arti.artiProxyStop(tor.proxy);
      _addLog('Proxy stopped.');

      if (isolated != nullptr) {
        arti.artiClientFree(isolated);
        _addLog('Isolated client freed.');
      }
      arti.artiClientFree(tor.client);
      _addLog('Main client freed.');

      _addLog('--- Done ---');
    } catch (e, st) {
      _addLog('ERROR: $e');
      print(st);
    } finally {
      setState(() => _running = false);
    }
  }

  String _getCacheDirectory() {
    if (Platform.isAndroid) return '/data/user/0/com.manymath.arti_example/cache';
    if (Platform.isLinux) return '${Platform.environment['HOME']}/.cache';
    if (Platform.isMacOS) return '${Platform.environment['HOME']}/Library/Caches';
    if (Platform.isWindows) return Platform.environment['LOCALAPPDATA'] ?? '.';
    return '.';
  }

  String _getStateDirectory() {
    if (Platform.isAndroid) return '/data/user/0/com.manymath.arti_example/files';
    if (Platform.isLinux) return '${Platform.environment['HOME']}/.local/share';
    if (Platform.isMacOS) return '${Platform.environment['HOME']}/Library/Application Support';
    if (Platform.isWindows) return Platform.environment['APPDATA'] ?? '.';
    return '.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Arti FFI Test')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _running ? null : _runTest,
              child: Text(_running ? 'Running...' : 'Run Arti Test'),
            ),
          ),
          Expanded(
            child: SelectionArea(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _log.length,
                itemBuilder: (_, i) => SelectableText(
                  _log[i],
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
