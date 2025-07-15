import 'package:flutter/material.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/data/models/announcement_model.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/data/repositories/announcement_repository.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/data/services/geo_fence_service.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/data/services/notification_service.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/presentation/providers/announcement_provider.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/presentation/providers/location_provider.dart';
import 'package:provider/provider.dart';

class TriggerGeofence {
  final AnnouncementRepository _repository;
  final GeofenceService _geofenceService;
  final NotificationService _notificationService;

  TriggerGeofence(
    this._repository,
    this._geofenceService,
    this._notificationService,
  );

  Future<void> call({
    required BuildContext context,
    required Function(String) onEnter,
  }) async {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );

    if (!locationProvider.isLocationSet) {
      throw Exception('Office location not set');
    }

    _geofenceService.updateGeofenceArea(locationProvider);

    try {
      await _geofenceService.startGeofenceMonitoring();

      _geofenceService.geofenceStream.listen((event) async {
        debugPrint(
          'Geofence event: id=${event.area.id}, eventType=${event.eventType}, timestamp=${event.timestamp}',
        );
        if (event.eventType == GeofenceEventType.enter) {
          debugPrint('User entered geofence area');
          final timestamp = DateTime.now();
          final announcement = AnnouncementModel(
            id: timestamp.millisecondsSinceEpoch,
            notificationId: (timestamp.millisecondsSinceEpoch % 2147483647)
                .toInt(),
            title: 'Welcome to the Office',
            message: 'You have entered the office area!',
            timestamp: timestamp,
            isGeofenceTriggered: true,
          );
          await _repository.saveAnnouncement(announcement);
          await Provider.of<AnnouncementProvider>(
            context,
            listen: false,
          ).addAnnouncement(announcement);
          await _notificationService.showNotification(
            announcement.message,
            notificationId: announcement.notificationId,
          );
          onEnter(announcement.message);
        } else if (event.eventType == GeofenceEventType.exit) {
          debugPrint('User exited geofence area');
        }
      });
    } catch (e) {
      debugPrint('Failed to start geofence monitoring: $e');
      rethrow;
    }
  }

  Future<void> stop() async {
    try {
      _geofenceService.stopGeofenceMonitoring();
      debugPrint('Geofence monitoring stopped');
    } catch (e) {
      debugPrint('Failed to stop geofence monitoring: $e');
    }
  }
}
