import 'package:adhan/adhan.dart' as adhan;
import 'package:intl/intl.dart';
import '../models/prayer_data.dart';

class PrayerScheduleResult {
  final List<PrayerItem> prayers;
  final PrayerItem nextPrayer;
  final DateTime nextPrayerTime;
  final DateTime previousPrayerTime;
  final Duration remainingDuration;
  final String countdownString;
  final double progress;

  const PrayerScheduleResult({
    required this.prayers,
    required this.nextPrayer,
    required this.nextPrayerTime,
    required this.previousPrayerTime,
    required this.remainingDuration,
    required this.countdownString,
    required this.progress,
  });
}

class PrayerService {
  static adhan.CalculationParameters _getParameters(
    CalculationMethodType method,
    MadhabType madhab,
  ) {
    adhan.CalculationParameters params;
    switch (method) {
      case CalculationMethodType.egyptian:
        params = adhan.CalculationMethod.egyptian.getParameters();
        break;
      case CalculationMethodType.muslimWorldLeague:
        params = adhan.CalculationMethod.muslim_world_league.getParameters();
        break;
      case CalculationMethodType.ummAlQura:
        params = adhan.CalculationMethod.umm_al_qura.getParameters();
        break;
      case CalculationMethodType.northAmerica:
        params = adhan.CalculationMethod.north_america.getParameters();
        break;
      case CalculationMethodType.karachi:
        params = adhan.CalculationMethod.karachi.getParameters();
        break;
      case CalculationMethodType.dubai:
        params = adhan.CalculationMethod.dubai.getParameters();
        break;
      case CalculationMethodType.kuwait:
        params = adhan.CalculationMethod.kuwait.getParameters();
        break;
      case CalculationMethodType.qatar:
        params = adhan.CalculationMethod.qatar.getParameters();
        break;
    }

    params.madhab = madhab == MadhabType.hanafi ? adhan.Madhab.hanafi : adhan.Madhab.shafi;
    return params;
  }

  static PrayerScheduleResult calculateSchedule({
    required double latitude,
    required double longitude,
    required CalculationMethodType method,
    required MadhabType madhab,
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();
    final coords = adhan.Coordinates(latitude, longitude);
    final params = _getParameters(method, madhab);

    final todayDate = adhan.DateComponents.from(now);
    final todayTimes = adhan.PrayerTimes(coords, todayDate, params);

    final tomorrowDate = adhan.DateComponents.from(now.add(const Duration(days: 1)));
    final tomorrowTimes = adhan.PrayerTimes(coords, tomorrowDate, params);

    final yesterdayDate = adhan.DateComponents.from(now.subtract(const Duration(days: 1)));
    final yesterdayTimes = adhan.PrayerTimes(coords, yesterdayDate, params);

    // Identify next and previous prayer
    PrayerType nextType;
    DateTime nextTime;
    DateTime prevTime;

    if (now.isBefore(todayTimes.fajr)) {
      nextType = PrayerType.fajr;
      nextTime = todayTimes.fajr;
      prevTime = yesterdayTimes.isha;
    } else if (now.isBefore(todayTimes.sunrise)) {
      nextType = PrayerType.sunrise;
      nextTime = todayTimes.sunrise;
      prevTime = todayTimes.fajr;
    } else if (now.isBefore(todayTimes.dhuhr)) {
      nextType = PrayerType.dhuhr;
      nextTime = todayTimes.dhuhr;
      prevTime = todayTimes.sunrise;
    } else if (now.isBefore(todayTimes.asr)) {
      nextType = PrayerType.asr;
      nextTime = todayTimes.asr;
      prevTime = todayTimes.dhuhr;
    } else if (now.isBefore(todayTimes.maghrib)) {
      nextType = PrayerType.maghrib;
      nextTime = todayTimes.maghrib;
      prevTime = todayTimes.asr;
    } else if (now.isBefore(todayTimes.isha)) {
      nextType = PrayerType.isha;
      nextTime = todayTimes.isha;
      prevTime = todayTimes.maghrib;
    } else {
      nextType = PrayerType.fajr;
      nextTime = tomorrowTimes.fajr;
      prevTime = todayTimes.isha;
    }

    // Progress computation
    final totalSec = nextTime.difference(prevTime).inSeconds;
    final elapsedSec = now.difference(prevTime).inSeconds;
    final progress = totalSec > 0 ? (elapsedSec / totalSec).clamp(0.0, 1.0) : 0.0;

    final remaining = nextTime.isAfter(now) ? nextTime.difference(now) : Duration.zero;
    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    final countdownString = '$hours:$minutes:$seconds';

    final timeFormatter = DateFormat('hh:mm a');

    // Helper for relative text
    String formatRelative(DateTime target) {
      if (now.isBefore(target)) {
        final diff = target.difference(now);
        if (diff.inHours > 0) {
          final m = diff.inMinutes % 60;
          return m > 0 ? 'in ${diff.inHours}h ${m}m' : 'in ${diff.inHours}h';
        }
        return 'in ${diff.inMinutes}m';
      } else {
        final diff = now.difference(target);
        if (diff.inHours > 0) {
          final m = diff.inMinutes % 60;
          return m > 0 ? 'Passed ${diff.inHours}h ${m}m ago' : 'Passed ${diff.inHours}h ago';
        }
        if (diff.inMinutes > 0) {
          return 'Passed ${diff.inMinutes}m ago';
        }
        return 'Current';
      }
    }

    final rawList = [
      (PrayerType.fajr, todayTimes.fajr),
      (PrayerType.sunrise, todayTimes.sunrise),
      (PrayerType.dhuhr, todayTimes.dhuhr),
      (PrayerType.asr, todayTimes.asr),
      (PrayerType.maghrib, todayTimes.maghrib),
      (PrayerType.isha, todayTimes.isha),
    ];

    final prayers = rawList.map((entry) {
      final pType = entry.$1;
      final pTime = entry.$2;
      final isNext = pType == nextType && (nextTime.day == pTime.day);
      final isPast = now.isAfter(pTime);

      return PrayerItem(
        type: pType,
        englishName: pType.englishName,
        arabicName: pType.arabicName,
        time: pTime,
        isNext: isNext,
        isPast: isPast,
        formattedTime: timeFormatter.format(pTime),
        relativeTime: formatRelative(pTime),
      );
    }).toList();

    final nextPrayerItem = PrayerItem(
      type: nextType,
      englishName: nextType.englishName,
      arabicName: nextType.arabicName,
      time: nextTime,
      isNext: true,
      isPast: false,
      formattedTime: timeFormatter.format(nextTime),
      relativeTime: formatRelative(nextTime),
    );

    return PrayerScheduleResult(
      prayers: prayers,
      nextPrayer: nextPrayerItem,
      nextPrayerTime: nextTime,
      previousPrayerTime: prevTime,
      remainingDuration: remaining,
      countdownString: countdownString,
      progress: progress,
    );
  }
}
