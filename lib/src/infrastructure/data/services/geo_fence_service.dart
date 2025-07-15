import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/presentation/providers/location_provider.dart';

class GeofenceService {
  static final GeofenceService _instance = GeofenceService._internal();
  factory GeofenceService.instance() => _instance;
  GeofenceService._internal();

  StreamSubscription<geolocator.Position>? _positionStreamSubscription;
  final StreamController<GeofenceEvent> _geofenceController =
      StreamController<GeofenceEvent>.broadcast();
  final ValueNotifier<bool> isInsideGeofence = ValueNotifier<bool>(false);
  GeofenceArea? _officeArea;

  Stream<GeofenceEvent> get geofenceStream => _geofenceController.stream;

  Future<bool> requestPermissions() async {
    final locationPermission = await Permission.locationWhenInUse.request();
    final notificationPermission = await Permission.notification.request();

    if (locationPermission.isGranted && notificationPermission.isGranted) {
      bool serviceEnabled =
          await geolocator.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services disabled');
        return false;
      }

      geolocator.LocationPermission permission =
          await geolocator.Geolocator.checkPermission();
      if (permission == geolocator.LocationPermission.denied) {
        permission = await geolocator.Geolocator.requestPermission();
        if (permission == geolocator.LocationPermission.denied) {
          debugPrint('Location permission denied');
          return false;
        }
      }

      if (permission == geolocator.LocationPermission.deniedForever) {
        debugPrint('Location permission permanently denied');
        return false;
      }

      return true;
    }
    debugPrint(
      'Permissions not granted: Location=${locationPermission.isGranted}, Notification=${notificationPermission.isGranted}',
    );
    return false;
  }

  void updateGeofenceArea(LocationProvider locationProvider) {
    _officeArea = GeofenceArea(
      id: 'office_area',
      name: 'Office',
      latitude:
          locationProvider.officeLatitude ?? 31.5497, // Default to Lahore, PK
      longitude: locationProvider.officeLongitude ?? 74.3436,
      radius: 2.0, // 2-meter radius
    );
    debugPrint(
      'Geofence updated: lat=${_officeArea!.latitude}, lon=${_officeArea!.longitude}, radius=${_officeArea!.radius}',
    );
  }

  Future<void> startGeofenceMonitoring() async {
    final hasPermissions = await requestPermissions();
    if (!hasPermissions || _officeArea == null) {
      debugPrint(
        'Geofence monitoring not started: Missing permissions or office location',
      );
      return;
    }

    const geolocator.LocationSettings locationSettings =
        geolocator.LocationSettings(
          accuracy: geolocator.LocationAccuracy.high,
          distanceFilter: 1, // Update on 1-meter movement
        );

    // Cancel existing subscription to avoid duplicates
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription =
        geolocator.Geolocator.getPositionStream(
          locationSettings: locationSettings,
        ).listen(
          (geolocator.Position position) {
            debugPrint(
              'Position update: lat=${position.latitude}, lon=${position.longitude}, accuracy=${position.accuracy}',
            );
            _checkGeofence(position);
          },
          onError: (e) {
            debugPrint('Position stream error: $e');
          },
        );
    debugPrint('Geofence monitoring started');
  }

  void _checkGeofence(geolocator.Position position) {
    if (_officeArea == null) {
      debugPrint('No office area defined');
      return;
    }

    double distance = _calculateDistance(
      position.latitude,
      position.longitude,
      _officeArea!.latitude,
      _officeArea!.longitude,
    );
    debugPrint('Distance to office: $distance meters');

    bool shouldBeInside = distance <= _officeArea!.radius;

    if (shouldBeInside && !isInsideGeofence.value) {
      _officeArea!.isInside = true;
      isInsideGeofence.value = true;
      _geofenceController.add(
        GeofenceEvent(
          area: _officeArea!,
          eventType: GeofenceEventType.enter,
          timestamp: DateTime.now(),
        ),
      );
      debugPrint('Geofence enter event triggered');
    } else if (!shouldBeInside && isInsideGeofence.value) {
      _officeArea!.isInside = false;
      isInsideGeofence.value = false;
      _geofenceController.add(
        GeofenceEvent(
          area: _officeArea!,
          eventType: GeofenceEventType.exit,
          timestamp: DateTime.now(),
        ),
      );
      debugPrint('Geofence exit event triggered');
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000;
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  void stopGeofenceMonitoring() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    isInsideGeofence.value = false;
    debugPrint('Geofence monitoring stopped');
  }

  void dispose() {
    stopGeofenceMonitoring();
    _geofenceController.close();
  }

  Future<geolocator.Position?> getCurrentPosition() async {
    try {
      return await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Failed to get current position: $e');
      return null;
    }
  }
}

class GeofenceArea {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radius;
  bool isInside;

  GeofenceArea({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.isInside = false,
  });
}

class GeofenceEvent {
  final GeofenceArea area;
  final GeofenceEventType eventType;
  final DateTime timestamp;

  GeofenceEvent({
    required this.area,
    required this.eventType,
    required this.timestamp,
  });
}

enum GeofenceEventType { enter, exit }
