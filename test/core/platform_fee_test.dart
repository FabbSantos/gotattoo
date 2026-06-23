import 'package:flutter_test/flutter_test.dart';
import 'package:gotattoo/core/constants/platform_fee.dart';

void main() {
  test('fee is the configured rate of the price', () {
    expect(PlatformFee.on(100), 100 * PlatformFee.rate);
  });

  test('artistPayout is the price minus the embedded fee', () {
    expect(PlatformFee.artistPayout(100), 100 - PlatformFee.on(100));
  });

  test('a R\$1000 tattoo at 3% nets R\$970 to the artist', () {
    expect(PlatformFee.on(1000), 30);
    expect(PlatformFee.artistPayout(1000), 970);
  });

  test('label renders the rate as a percentage', () {
    expect(PlatformFee.label, '${(PlatformFee.rate * 100).toStringAsFixed(0)}%');
  });
}
