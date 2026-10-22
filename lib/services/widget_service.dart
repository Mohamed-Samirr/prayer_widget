import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'prayer_service.dart';
import '../models/prayer_data.dart';

class WidgetService {
  static const String androidWidgetProvider = 'PrayerWidgetProvider';

  static Future<void> updateHomeWidget({
    required String locationName,
    required PrayerScheduleResult schedule,
  }) async {
    try {
      final next = schedule.nextPrayer;
      final prayersMap = {
        for (var p in schedule.prayers) p.type: p.formattedTime,
      };

      // Save widget dataset
      await HomeWidget.saveWidgetData<String>('widget_location', locationName);
      await HomeWidget.saveWidgetData<String>('widget_next_prayer_name', next.englishName);
      await HomeWidget.saveWidgetData<String>('widget_next_prayer_time', next.formattedTime);
      await HomeWidget.saveWidgetData<String>('widget_countdown', schedule.countdownString);
      await HomeWidget.saveWidgetData<String>('widget_active_prayer', next.type.name.toLowerCase());

      // Daily prayers times for the compact bottom row
      await HomeWidget.saveWidgetData<String>('widget_fajr_time', prayersMap[PrayerType.fajr] ?? '--:--');
      await HomeWidget.saveWidgetData<String>('widget_sunrise_time', prayersMap[PrayerType.sunrise] ?? '--:--');
      await HomeWidget.saveWidgetData<String>('widget_dhuhr_time', prayersMap[PrayerType.dhuhr] ?? '--:--');
      await HomeWidget.saveWidgetData<String>('widget_asr_time', prayersMap[PrayerType.asr] ?? '--:--');
      await HomeWidget.saveWidgetData<String>('widget_maghrib_time', prayersMap[PrayerType.maghrib] ?? '--:--');
      await HomeWidget.saveWidgetData<String>('widget_isha_time', prayersMap[PrayerType.isha] ?? '--:--');

      // Request native widget update
      await HomeWidget.updateWidget(
        name: androidWidgetProvider,
        androidName: androidWidgetProvider,
      );
    } catch (e) {
      debugPrint('Error syncing data to Home Screen Widget: $e');
    }
  }
}
