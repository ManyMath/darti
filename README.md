# `arti`
Arti (A Rust Tor Implementation) in a Dart package.  An original re-implementation of 
[Foundation-Devices/tor](https://github.com/Foundation-Devices/tor) 
([`tor` on pub.dev](https://pub.dev/packages/tor)) but for commandline applications, too.

## Setup
### Dart 3.6
This package requires Dart 3.6 for its new native assets feature.

### Native assets
Native assets is currently an experimental feature that is available in Flutter's `master` branch behind an optional Flutter config:
```
flutter config --enable-native-assets
```

See [this tracking issue](https://github.com/flutter/flutter/issues/129757) and [this milestone](https://github.com/dart-lang/native/milestone/15) for the eventual inclusion of native assets in a release.

### Quick setup
```
git clone git@github.com:ManyMath/darti
cd darti
git submodule update --init --recursive
dart pub get
dart --enable-experiment=native-assets run example/darti_example.dart
```
<!--- TODO: Remove the `git submodule update --init --recursive` step. --->
and wait a moment as the native assets are built.

## Development
- To generate `arti-ffi_bindings_generated.dart` Dart bindings for C:
  ```
  dart --enable-experiment=native-assets run ffigen --config ffigen.yaml
  ```
- If bindings are generated for a new (not previously supported/included in `lib/arti_base.dart`)
  function, a wrapper must be written for it by hand (see: `artiStart`, `artiClientBootstrap`).

# Acknowledgements
- Thank you Igor "icota" Cota and Foundation Devices for pub.dev/packages/tor,
  the Flutter cousin of this package.
- Thank you Diego "rehrar" Salazar and Cypher Stack for commissioning my work 
  on the above.
