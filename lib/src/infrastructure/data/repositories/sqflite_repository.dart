import 'package:flutter_developer_technical_test/src/infrastructure/data/models/announcement_model.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/data/repositories/announcement_repository.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/data/sources/local_database.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteRepository implements AnnouncementRepository {
  final LocalDatabase _database;

  SqfliteRepository(this._database) {
    _initializeDefaultData();
  }

  Future<void> _initializeDefaultData() async {
    final db = await _database.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM announcements'),
    );
    if (count == 0) {
      final defaultAnnouncements = [
        AnnouncementModel(
          id: 1,
          title: 'Welcome to the Team!',
          message:
              'We are excited to have you on board. Join us for the orientation session this Friday.',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
        ),
        AnnouncementModel(
          id: 2,
          title: 'Team Meeting',
          message:
              'Monthly team meeting scheduled for next Monday at 10 AM in Conference Room A.',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
        AnnouncementModel(
          id: 3,
          title: 'Holiday Schedule',
          message:
              'Reminder: Office will be closed on December 24th and 25th for the holidays.',
          timestamp: DateTime.now(),
        ),
      ];
      for (var announcement in defaultAnnouncements) {
        await db.insert(
          'announcements',
          announcement.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
  }

  @override
  Future<List<AnnouncementModel>> getAnnouncements() async {
    final db = await _database.database;
    final maps = await db.query(
      'announcements',
      orderBy: 'timestamp DESC',
      limit: 10,
    );
    return maps.map((map) => AnnouncementModel.fromMap(map)).toList();
  }

  @override
  Future<List<AnnouncementModel>> getAllBroadcasts() async {
    final db = await _database.database;
    final maps = await db.query('announcements', orderBy: 'timestamp DESC');
    return maps.map((map) => AnnouncementModel.fromMap(map)).toList();
  }

  @override
  Future<void> saveAnnouncement(AnnouncementModel announcement) async {
    final db = await _database.database;
    await db.insert(
      'announcements',
      announcement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
