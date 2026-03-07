import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'arti-ffi_bindings_generated.dart';

const String _libName = 'arti_ffi';

final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('libarti_ffi.dylib');
  }
  if (Platform.isAndroid) {
    return DynamicLibrary.open('libarti_ffi.so');
  }
  if (Platform.isLinux) {
    // Bundled in Flutter; fall back to cargo output for standalone Dart.
    try {
      return DynamicLibrary.open('libarti_ffi.so');
    } catch (_) {
      return DynamicLibrary.open('../arti-ffi/target/release/libarti_ffi.so');
    }
  }
  if (Platform.isWindows) {
    try {
      return DynamicLibrary.open('arti_ffi.dll');
    } catch (_) {
      return DynamicLibrary.open('arti-ffi/target/release/arti_ffi.dll');
    }
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

final DartiBindings _bindings = DartiBindings(_dylib);

/// Start Tor with the given SOCKS port and directories.
Tor artiStart(int socksPort, String stateDir, String cacheDir) {
  final Pointer<Utf8> stateDirPtr = stateDir.toNativeUtf8();
  final Pointer<Utf8> cacheDirPtr = cacheDir.toNativeUtf8();
  final Tor tor =
      _bindings.arti_start(socksPort, stateDirPtr.cast(), cacheDirPtr.cast());

  calloc.free(stateDirPtr);
  calloc.free(cacheDirPtr);

  return tor;
}

bool artiClientBootstrap(Pointer<Void> client) {
  return _bindings.arti_client_bootstrap(client);
}

void artiClientSetDormant(Pointer<Void> client, bool softMode) {
  _bindings.arti_client_set_dormant(client, softMode ? true : false);
}

void artiProxyStop(Pointer<Void> proxy) {
  _bindings.arti_proxy_stop(proxy);
}

// /// Retrieves the next progress message.
// String artiProgressNext(Pointer<Tor> tor) {
//   final Pointer<Utf8> progressPtr = _bindings.arti_progress_next(tor);
//   final progress = progressPtr.toDartString();
//
//   calloc.free(progressPtr);
//
//   return progress;
// }

/// Verify FFI linkage.
String dartiHello() {
  final Pointer<Char> hello = _bindings.darti_hello();
  final there = hello.cast<Utf8>().toDartString();
  _bindings.darti_free_string(hello);
  return there;
}
