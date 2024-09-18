import 'package:arti/arti.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    final hello = dartiHello();

    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () {
      expect(hello, "Hello there");
    });
  });
}
