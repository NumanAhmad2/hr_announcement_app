import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/data/models/announcement_model.dart';

class AnnouncementRepository {
  final Database _database;

  AnnouncementRepository(this._database) {
    _seedSampleAnnouncements();
  }

  Future<void> _seedSampleAnnouncements() async {
    final announcements = await _database.query('announcements');
    if (announcements.isEmpty) {
      final sampleAnnouncements = [
        AnnouncementModel(
          id: DateTime.now().millisecondsSinceEpoch - 2 * 24 * 60 * 60 * 1000,
          notificationId: 1,
          title: 'Team Meeting Scheduled',
          message:
              'All employees are required to attend the quarterly team meeting on July 17, 2025, at 10 AM in Conference Room A.',
          timestamp: DateTime.now().subtract(Duration(days: 2)),
          isGeofenceTriggered: false,
        ),
        AnnouncementModel(
          id: DateTime.now().millisecondsSinceEpoch - 1 * 24 * 60 * 60 * 1000,
          notificationId: 2,
          title: 'New HR Policy Update',
          message:
              'Please review the updated HR policies on remote work effective August 1, 2025, available on the intranet.',
          timestamp: DateTime.now().subtract(Duration(days: 1)),
          isGeofenceTriggered: false,
        ),
        AnnouncementModel(
          id: DateTime.now().millisecondsSinceEpoch,
          notificationId: 3,
          title: 'Employee Wellness Program',
          message:
              'Join our new wellness program starting July 20, 2025. Sign up by July 18 on the HR portal!',
          timestamp: DateTime.now(),
          isGeofenceTriggered: false,
        ),
      ];

      for (var announcement in sampleAnnouncements) {
        await _database.insert(
          'announcements',
          announcement.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      debugPrint('Seeded ${sampleAnnouncements.length} HR announcements');
    }
  }

  Future<void> saveAnnouncement(AnnouncementModel announcement) async {
    await _database.insert(
      'announcements',
      announcement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AnnouncementModel>> getAnnouncements() async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'announcements',
    );
    return List.generate(
      maps.length,
      (i) => AnnouncementModel.fromMap(maps[i]),
    );
  }
}
