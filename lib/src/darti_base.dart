import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'arti-ffi_bindings_generated.dart';

const String _libName = 'arti_ffi';

/// The dynamic library in which the symbols for [LibArtiBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open(
        'rust/target/release/$_libName.framework/lib$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('arti-ffi/target/release/lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('arti-ffi/target/release/lib$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final DartiBindings _bindings = DartiBindings(_dylib);

/// Starts the Tor client with specified SOCKS port, state directory, and cache directory.
Tor artiStart(int socksPort, String stateDir, String cacheDir) {
  final Pointer<Utf8> stateDirPtr = stateDir.toNativeUtf8();
  final Pointer<Utf8> cacheDirPtr = cacheDir.toNativeUtf8();
  final Tor tor =
      _bindings.arti_start(socksPort, stateDirPtr.cast(), cacheDirPtr.cast());

  calloc.free(stateDirPtr);
  calloc.free(cacheDirPtr);

  return tor;
}

/// Boots the Tor client.
bool artiClientBootstrap(Pointer<Void> client) {
  return _bindings.arti_client_bootstrap(client);
}

/// Sets the Tor client to dormant mode.
void artiClientSetDormant(Pointer<Void> client, bool softMode) {
  _bindings.arti_client_set_dormant(client, softMode ? true : false);
}

/// Stops the Tor proxy.
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

/// Prints a hello message to verify FFI linkage.
void artiHello() {
  _bindings.arti_hello();
}
