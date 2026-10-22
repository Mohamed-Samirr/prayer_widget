import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_widget/models/prayer_data.dart';
import 'package:prayer_widget/services/prayer_service.dart';

void main() {
  group('PrayerService Calculations', () {
    const double cairoLat = 30.0444;
    const double cairoLng = 31.2357;

    test('Computes 6 prayer events with valid non-null times', () {
      final schedule = PrayerService.calculateSchedule(
        latitude: cairoLat,
        longitude: cairoLng,
        method: CalculationMethodType.egyptian,
        madhab: MadhabType.shafi,
      );

      expect(schedule.prayers.length, 6);
      expect(schedule.nextPrayer, isNotNull);
      expect(schedule.countdownString, matches(RegExp(r'^\d{2}:\d{2}:\d{2}$')));
      expect(schedule.progress, inInclusiveRange(0.0, 1.0));
    });

    test('Handles night time after Isha smoothly transition to tomorrow Fajr', () {
      // Simulate 11:30 PM (well after Isha)
      final lateNight = DateTime(2026, 10, 22, 23, 30);
      final schedule = PrayerService.calculateSchedule(
        latitude: cairoLat,
        longitude: cairoLng,
        method: CalculationMethodType.egyptian,
        madhab: MadhabType.shafi,
        currentTime: lateNight,
      );

      expect(schedule.nextPrayer.type, PrayerType.fajr);
      expect(schedule.nextPrayerTime.isAfter(lateNight), isTrue);
      expect(schedule.remainingDuration.isNegative, isFalse);
    });

    test('Calculation methods switch without error', () {
      for (final method in CalculationMethodType.values) {
        final schedule = PrayerService.calculateSchedule(
          latitude: cairoLat,
          longitude: cairoLng,
          method: method,
          madhab: MadhabType.shafi,
        );
        expect(schedule.prayers.length, 6);
      }
    });
  });
}
