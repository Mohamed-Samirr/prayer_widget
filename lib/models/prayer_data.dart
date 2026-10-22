enum PrayerType {
  fajr,
  sunrise,
  dhuhr,
  asr,
  maghrib,
  isha;

  String get englishName {
    switch (this) {
      case PrayerType.fajr:
        return 'Fajr';
      case PrayerType.sunrise:
        return 'Sunrise';
      case PrayerType.dhuhr:
        return 'Dhuhr';
      case PrayerType.asr:
        return 'Asr';
      case PrayerType.maghrib:
        return 'Maghrib';
      case PrayerType.isha:
        return 'Isha';
    }
  }

  String get arabicName {
    switch (this) {
      case PrayerType.fajr:
        return 'الفجر';
      case PrayerType.sunrise:
        return 'الشروق';
      case PrayerType.dhuhr:
        return 'الظهر';
      case PrayerType.asr:
        return 'العصر';
      case PrayerType.maghrib:
        return 'المغرب';
      case PrayerType.isha:
        return 'العشاء';
    }
  }

  bool get isMandatoryPrayer => this != PrayerType.sunrise;
}

class PrayerItem {
  final PrayerType type;
  final String englishName;
  final String arabicName;
  final DateTime time;
  final bool isNext;
  final bool isPast;
  final String formattedTime;
  final String relativeTime;

  const PrayerItem({
    required this.type,
    required this.englishName,
    required this.arabicName,
    required this.time,
    required this.isNext,
    required this.isPast,
    required this.formattedTime,
    required this.relativeTime,
  });

  PrayerItem copyWith({
    PrayerType? type,
    String? englishName,
    String? arabicName,
    DateTime? time,
    bool? isNext,
    bool? isPast,
    String? formattedTime,
    String? relativeTime,
  }) {
    return PrayerItem(
      type: type ?? this.type,
      englishName: englishName ?? this.englishName,
      arabicName: arabicName ?? this.arabicName,
      time: time ?? this.time,
      isNext: isNext ?? this.isNext,
      isPast: isPast ?? this.isPast,
      formattedTime: formattedTime ?? this.formattedTime,
      relativeTime: relativeTime ?? this.relativeTime,
    );
  }
}

enum CalculationMethodType {
  egyptian,
  muslimWorldLeague,
  ummAlQura,
  northAmerica,
  karachi,
  dubai,
  kuwait,
  qatar;

  String get title {
    switch (this) {
      case CalculationMethodType.egyptian:
        return 'Egyptian General Authority of Survey';
      case CalculationMethodType.muslimWorldLeague:
        return 'Muslim World League';
      case CalculationMethodType.ummAlQura:
        return 'Umm Al-Qura University, Makkah';
      case CalculationMethodType.northAmerica:
        return 'Islamic Society of North America (ISNA)';
      case CalculationMethodType.karachi:
        return 'Univ. of Islamic Sciences, Karachi';
      case CalculationMethodType.dubai:
        return 'Dubai';
      case CalculationMethodType.kuwait:
        return 'Kuwait';
      case CalculationMethodType.qatar:
        return 'Qatar';
    }
  }

  String get shortName {
    switch (this) {
      case CalculationMethodType.egyptian:
        return 'Egyptian Survey';
      case CalculationMethodType.muslimWorldLeague:
        return 'MWL';
      case CalculationMethodType.ummAlQura:
        return 'Umm Al-Qura';
      case CalculationMethodType.northAmerica:
        return 'ISNA';
      case CalculationMethodType.karachi:
        return 'Karachi';
      case CalculationMethodType.dubai:
        return 'Dubai';
      case CalculationMethodType.kuwait:
        return 'Kuwait';
      case CalculationMethodType.qatar:
        return 'Qatar';
    }
  }
}

enum MadhabType {
  shafi,
  hanafi;

  String get title {
    switch (this) {
      case MadhabType.shafi:
        return 'Standard (Shafi\'i, Maliki, Hanbali)';
      case MadhabType.hanafi:
        return 'Hanafi';
    }
  }
}
