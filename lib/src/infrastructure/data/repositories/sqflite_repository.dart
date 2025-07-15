// import 'package:flutter/material.dart';
// import 'package:flutter_developer_technical_test/src/infrastructure/data/models/announcement_model.dart';
// import 'package:flutter_developer_technical_test/src/infrastructure/data/repositories/announcement_repository.dart';
// import 'package:flutter_developer_technical_test/src/infrastructure/data/sources/local_database.dart';
// import 'package:sqflite/sqflite.dart';

// class SqfliteRepository implements AnnouncementRepository {

//   SqfliteRepository(this._database) {
//     _initializeDefaultData();
//   }

//   Future<void> _initializeDefaultData() async {
//     final db = await _database.database;
//     final count = Sqflite.firstIntValue(
//       await db.rawQuery('SELECT COUNT(*) FROM announcements'),
//     );
//     if (count == 0) {
//       final defaultAnnouncements = [
//         AnnouncementModel(
//           id: 1,
//           notificationId: 1,
//           title: 'Welcome to the Team!',
//           message:
//               'We are excited to have you on board. Join us for the orientation session on July 18, 2025, at 9 AM in Conference Room B.',
//           timestamp: DateTime(2025, 7, 13, 9, 0),
//           isGeofenceTriggered: false,
//         ),
//         AnnouncementModel(
//           id: 2,
//           notificationId: 2,
//           title: 'Quarterly Team Meeting',
//           message:
//               'Mandatory team meeting scheduled for July 20, 2025, at 10 AM in Conference Room A. Please prepare your project updates.',
//           timestamp: DateTime(2025, 7, 14, 14, 30),
//           isGeofenceTriggered: false,
//         ),
//         AnnouncementModel(
//           id: 3,
//           notificationId: 3,
//           title: 'New HR Policy Update',
//           message:
//               'Updated remote work policies effective August 1, 2025. Review details on the HR portal by July 25.',
//           timestamp: DateTime(2025, 7, 15, 8, 0),
//           isGeofenceTriggered: false,
//         ),
//         AnnouncementModel(
//           id: 4,
//           notificationId: 4,
//           title: 'Employee Wellness Workshop',
//           message:
//               'Join our wellness workshop on July 22, 2025, at 2 PM. Register by July 18 on the intranet.',
//           timestamp: DateTime(2025, 7, 14, 10, 0),
//           isGeofenceTriggered: false,
//         ),
//         AnnouncementModel(
//           id: 5,
//           notificationId: 5,
//           title: 'Office Renovation Notice',
//           message:
//               'The office will undergo renovations from July 25-27, 2025. Remote work is encouraged during this period.',
//           timestamp: DateTime(2025, 7, 15, 12, 0),
//           isGeofenceTriggered: false,
//         ),
//       ];
//       for (var announcement in defaultAnnouncements) {
//         await db.insert(
//           'announcements',
//           announcement.toMap(),
//           conflictAlgorithm: ConflictAlgorithm.ignore,
//         );
//       }
//       debugPrint('Seeded ${defaultAnnouncements.length} HR announcements');
//     }
//   }

//   @override
//   Future<List<AnnouncementModel>> getAnnouncements() async {
//     final db = await _database.database;
//     final maps = await db.query(
//       'announcements',
//       orderBy: 'timestamp DESC',
//       limit: 10,
//     );
//     return maps.map((map) => AnnouncementModel.fromMap(map)).toList();
//   }

//   @override
//   Future<List<AnnouncementModel>> getAllBroadcasts() async {
//     final db = await _database.database;
//     final maps = await db.query('announcements', orderBy: 'timestamp DESC');
//     return maps.map((map) => AnnouncementModel.fromMap(map)).toList();
//   }

//   @override
//   Future<void> saveAnnouncement(AnnouncementModel announcement) async {
//     final db = await _database.database;
//     await db.insert(
//       'announcements',
//       announcement.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }
// }
