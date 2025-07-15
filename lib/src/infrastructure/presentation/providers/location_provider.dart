import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider with ChangeNotifier {
  double? _officeLatitude;
  double? _officeLongitude;
  bool _isLocationSet = false;

  LocationProvider() {
    _loadLocation();
  }

  double? get officeLatitude => _officeLatitude;
  double? get officeLongitude => _officeLongitude;
  bool get isLocationSet => _isLocationSet;

  Future<void> setOfficeLocation(double latitude, double longitude) async {
    if (!_isLocationSet) {
      _officeLatitude = latitude;
      _officeLongitude = longitude;
      _isLocationSet = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('office_latitude', latitude);
      await prefs.setDouble('office_longitude', longitude);
      await prefs.setBool('is_location_set', true);
      notifyListeners();
    }
  }

  Future<void> clearOfficeLocation() async {
    _officeLatitude = null;
    _officeLongitude = null;
    _isLocationSet = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('office_latitude');
    await prefs.remove('office_longitude');
    await prefs.remove('is_location_set');
    notifyListeners();
  }

  Future<void> _loadLocation() async {
    final prefs = await SharedPreferences.getInstance();
    _officeLatitude = prefs.getDouble('office_latitude');
    _officeLongitude = prefs.getDouble('office_longitude');
    _isLocationSet = prefs.getBool('is_location_set') ?? false;
    notifyListeners();
  }
}
