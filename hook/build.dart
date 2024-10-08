import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_rust_mirror/native_toolchain_rust.dart';

void main(List<String> args) async {
  try {
    await build(args, (BuildConfig buildConfig, BuildOutput output) async {
      final builder = RustBuilder(
        // The ID of native assets consists of package name and crate name.
        package: 'arti',
        cratePath: 'arti-ffi',
        buildConfig: buildConfig,
      );

      // Run the Rust build process.
      await builder.run(output: output);
    });
  } catch (e) {
    // ignore: avoid_print
    print(e);
    exit(1);
  }
}
