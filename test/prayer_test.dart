import 'package:adhan/adhan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adhan prayer calculation test', () {
    final coords = Coordinates(30.0444, 31.2357);
    final params = CalculationMethod.egyptian.getParameters();
    params.madhab = Madhab.shafi;
    final dateComponents = DateComponents.from(DateTime.now());
    final prayerTimes = PrayerTimes(coords, dateComponents, params);
    
    expect(prayerTimes.fajr, isNotNull);
    expect(prayerTimes.sunrise, isNotNull);
    expect(prayerTimes.dhuhr, isNotNull);
    expect(prayerTimes.asr, isNotNull);
    expect(prayerTimes.maghrib, isNotNull);
    expect(prayerTimes.isha, isNotNull);
  });
}
