import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_data.dart';
import '../services/location_service.dart';
import '../services/prayer_service.dart';
import '../services/widget_service.dart';

class PrayerState extends ChangeNotifier {
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _statusMessage;

  double _latitude = LocationService.defaultLat;
  double _longitude = LocationService.defaultLng;
  String _locationName = LocationService.defaultName;
  bool _isGpsActive = false;

  CalculationMethodType _method = CalculationMethodType.egyptian;
  MadhabType _madhab = MadhabType.shafi;

  PrayerScheduleResult? _scheduleResult;
  Timer? _tickerTimer;
  int _lastWidgetUpdateMinute = -1;

  // Getters
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get statusMessage => _statusMessage;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String get locationName => _locationName;
  bool get isGpsActive => _isGpsActive;
  CalculationMethodType get method => _method;
  MadhabType get madhab => _madhab;
  PrayerScheduleResult? get scheduleResult => _scheduleResult;

  String get countdown => _scheduleResult?.countdownString ?? '00:00:00';
  double get progress => _scheduleResult?.progress ?? 0.0;
  List<PrayerItem> get prayers => _scheduleResult?.prayers ?? [];
  PrayerItem? get nextPrayer => _scheduleResult?.nextPrayer;

  String get gregorianDate => DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    // Load saved settings if any
    final savedMethodIndex = prefs.getInt('prayer_calc_method');
    if (savedMethodIndex != null && savedMethodIndex < CalculationMethodType.values.length) {
      _method = CalculationMethodType.values[savedMethodIndex];
    }

    final savedMadhabIndex = prefs.getInt('prayer_madhab');
    if (savedMadhabIndex != null && savedMadhabIndex < MadhabType.values.length) {
      _madhab = MadhabType.values[savedMadhabIndex];
    }

    // Acquire location
    final loc = await LocationService.getLocation();
    _latitude = loc.latitude;
    _longitude = loc.longitude;
    _locationName = loc.displayName;
    _isGpsActive = loc.isGpsActive;
    _statusMessage = loc.errorMessage;

    _recalculateSchedule();
    _syncWidget();

    _isLoading = false;
    notifyListeners();

    _startTicker();
  }

  Future<void> refreshLocation() async {
    _isRefreshing = true;
    notifyListeners();

    final loc = await LocationService.getLocation(forceRefresh: true);
    _latitude = loc.latitude;
    _longitude = loc.longitude;
    _locationName = loc.displayName;
    _isGpsActive = loc.isGpsActive;
    _statusMessage = loc.errorMessage;

    _recalculateSchedule();
    _syncWidget();

    _isRefreshing = false;
    notifyListeners();
  }

  Future<void> setCalculationMethod(CalculationMethodType newMethod) async {
    if (_method == newMethod) return;
    _method = newMethod;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('prayer_calc_method', newMethod.index);

    _recalculateSchedule();
    _syncWidget();
    notifyListeners();
  }

  Future<void> setMadhab(MadhabType newMadhab) async {
    if (_madhab == newMadhab) return;
    _madhab = newMadhab;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('prayer_madhab', newMadhab.index);

    _recalculateSchedule();
    _syncWidget();
    notifyListeners();
  }

  void _recalculateSchedule() {
    _scheduleResult = PrayerService.calculateSchedule(
      latitude: _latitude,
      longitude: _longitude,
      method: _method,
      madhab: _madhab,
    );
  }

  void _startTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();

      if (_scheduleResult != null) {
        // If current time passed next prayer target, trigger full transition
        if (now.isAfter(_scheduleResult!.nextPrayerTime)) {
          _recalculateSchedule();
          _syncWidget();
          notifyListeners();
          return;
        }

        // Real-time countdown computation
        final diff = _scheduleResult!.nextPrayerTime.difference(now);
        final hours = diff.inHours.toString().padLeft(2, '0');
        final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
        final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
        final countdownString = '$hours:$minutes:$seconds';

        final totalSec = _scheduleResult!.nextPrayerTime
            .difference(_scheduleResult!.previousPrayerTime)
            .inSeconds;
        final elapsedSec = now.difference(_scheduleResult!.previousPrayerTime).inSeconds;
        final progressRatio = totalSec > 0 ? (elapsedSec / totalSec).clamp(0.0, 1.0) : 0.0;

        _scheduleResult = PrayerScheduleResult(
          prayers: _scheduleResult!.prayers,
          nextPrayer: _scheduleResult!.nextPrayer,
          nextPrayerTime: _scheduleResult!.nextPrayerTime,
          previousPrayerTime: _scheduleResult!.previousPrayerTime,
          remainingDuration: diff,
          countdownString: countdownString,
          progress: progressRatio,
        );

        // Keep widget fresh periodically every minute
        if (now.minute != _lastWidgetUpdateMinute) {
          _lastWidgetUpdateMinute = now.minute;
          _syncWidget();
        }

        notifyListeners();
      }
    });
  }

  void _syncWidget() {
    if (_scheduleResult != null) {
      WidgetService.updateHomeWidget(
        locationName: _locationName,
        schedule: _scheduleResult!,
      );
    }
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }
}
