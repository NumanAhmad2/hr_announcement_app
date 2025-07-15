import 'package:flutter/material.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/data/models/announcement_model.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/data/repositories/announcement_repository.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/presentation/providers/announcement_provider.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/presentation/providers/location_provider.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:provider/provider.dart';

class TriggerGeofence {
  final AnnouncementRepository _repository;
  final GeofenceService _geofenceService = GeofenceService.instance;

  TriggerGeofence(this._repository);

  Future<void> call({required BuildContext context, required Function(String) onEnter}) async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final latitude = locationProvider.officeLatitude ?? 37.7749; // Fallback to default
    final longitude = locationProvider.officeLongitude ?? -122.4194;

    debugPrint('Setting geofence at latitude: $latitude, longitude: $longitude, radius: 2m');

    final geofenceList = [
      Geofence(
        id: 'office_area',
        latitude: latitude,
        longitude: longitude,
        radius: [GeofenceRadius(id: 'radius_2m', length: 2.0)],
      ),
    ];

    _geofenceService
      ..addGeofenceList(geofenceList)
      ..addGeofenceStatusChangeListener((geofence, geofenceRadius, status, location) async {
        debugPrint('Geofence event: id=${geofence.id}, status=$status, location=$location');
        if (status == GeofenceStatus.ENTER) {
          debugPrint('User entered geofence area');
          final announcement = AnnouncementModel(
            id: DateTime.now().millisecondsSinceEpoch,
            title: 'Welcome to the Office',
            message: 'You have entered the office area!',
            timestamp: DateTime.now(),
          );
          await _repository.saveAnnouncement(announcement);
          await Provider.of<AnnouncementProvider>(context, listen: false).addAnnouncement(announcement);
          onEnter(announcement.message);
        } else if (status == GeofenceStatus.EXIT) {
          debugPrint('User exited geofence area');
        }
      })
      ..start().then((_) => debugPrint('Geofence service started'))
      ..onError((error) => debugPrint('Geofence error: $error'));
  }

  Future<void> stop() async {
    await _geofenceService.stop();
    debugPrint('Geofence service stopped');
  }
}