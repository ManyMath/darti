import 'dart:ffi' as ffi;

typedef ArtiStartC = ffi.Struct Function(
    ffi.Uint16, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>);
typedef ArtiStartDart = ffi.Struct Function(
    int, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>);

typedef ArtiClientBootstrapC = ffi.Bool Function(ffi.Pointer<ffi.Void>);
typedef ArtiClientBootstrapDart = bool Function(ffi.Pointer<ffi.Void>);

typedef ArtiClientSetDormantC = ffi.Void Function(
    ffi.Pointer<ffi.Void>, ffi.Bool);
typedef ArtiClientSetDormantDart = void Function(ffi.Pointer<ffi.Void>, bool);

typedef ArtiProxyStopC = ffi.Void Function(ffi.Pointer<ffi.Void>);
typedef ArtiProxyStopDart = void Function(ffi.Pointer<ffi.Void>);

typedef ArtiProgressNextC = ffi.Pointer<ffi.Char> Function(ffi.Pointer<Tor>);
typedef ArtiProgressNextDart = ffi.Pointer<ffi.Char> Function(ffi.Pointer<Tor>);

typedef ArtiHelloC = ffi.Void Function();
typedef ArtiHelloDart = void Function();

/// Define a Dart class representing the Tor structure.
base class Tor extends ffi.Struct {
  external ffi.Pointer<ffi.Void> client;
  external ffi.Pointer<ffi.Void> proxy;
  external ffi.Pointer<ffi.Void> progress_sender;
  external ffi.Pointer<ffi.Void> progress_receiver;
}
