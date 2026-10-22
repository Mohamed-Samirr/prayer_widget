import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String displayName;
  final bool isGpsActive;
  final String? errorMessage;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.displayName,
    required this.isGpsActive,
    this.errorMessage,
  });
}

class LocationService {
  static const String _prefLat = 'cached_lat';
  static const String _prefLng = 'cached_lng';
  static const String _prefName = 'cached_location_name';

  // Default Cairo coordinates (Egyptian Survey Authority default)
  static const double defaultLat = 30.0444;
  static const double defaultLng = 31.2357;
  static const String defaultName = 'Cairo, Egypt';

  static Future<LocationResult> getLocation({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _fallbackFromCache(
          prefs,
          errorMessage: 'Location services are disabled. Using cached location.',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return _fallbackFromCache(
            prefs,
            errorMessage: 'Location permission denied. Using cached location.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return _fallbackFromCache(
          prefs,
          errorMessage: 'Location permission permanently denied. Using cached location.',
        );
      }

      // Fetch fresh position with timeout
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      String formattedName = 'Unknown Location';
      try {
        final geocoding = Geocoding();
        final placemarks = await geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final locality = p.locality?.isNotEmpty == true
              ? p.locality
              : (p.subAdministrativeArea?.isNotEmpty == true
                  ? p.subAdministrativeArea
                  : p.administrativeArea);
          final country = p.country ?? '';

          if (locality != null && locality.isNotEmpty) {
            formattedName = country.isNotEmpty ? '$locality, $country' : locality;
          } else if (country.isNotEmpty) {
            formattedName = country;
          }
        }
      } catch (e) {
        debugPrint('Geocoding error: $e');
        formattedName = '${position.latitude.toStringAsFixed(2)}°, ${position.longitude.toStringAsFixed(2)}°';
      }

      // Cache successful location
      await prefs.setDouble(_prefLat, position.latitude);
      await prefs.setDouble(_prefLng, position.longitude);
      await prefs.setString(_prefName, formattedName);

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        displayName: formattedName,
        isGpsActive: true,
      );
    } catch (e) {
      debugPrint('Error getting GPS location: $e');
      return _fallbackFromCache(
        prefs,
        errorMessage: 'Unable to acquire GPS signal. Using cached location.',
      );
    }
  }

  static LocationResult _fallbackFromCache(
    SharedPreferences prefs, {
    String? errorMessage,
  }) {
    final cachedLat = prefs.getDouble(_prefLat) ?? defaultLat;
    final cachedLng = prefs.getDouble(_prefLng) ?? defaultLng;
    final cachedName = prefs.getString(_prefName) ?? defaultName;

    return LocationResult(
      latitude: cachedLat,
      longitude: cachedLng,
      displayName: cachedName,
      isGpsActive: false,
      errorMessage: errorMessage,
    );
  }
}
