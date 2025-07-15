import 'package:flutter_developer_technical_test/src/infrastructure/data/repositories/announcement_repository.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/data/services/geo_fence_service.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/data/services/notification_service.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/domain/usecases/get_all_broadcasts.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/domain/usecases/trigger_geofence.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final database = await openDatabase(
    join(await getDatabasesPath(), 'announcements.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE announcements(id INTEGER PRIMARY KEY, notificationId INTEGER, title TEXT, message TEXT, timestamp TEXT, isGeofenceTriggered INTEGER)',
      );
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute(
          'ALTER TABLE announcements ADD COLUMN notificationId INTEGER',
        );
      }
    },
    version: 2,
  );

  getIt.registerSingleton<Database>(database);
  getIt.registerSingleton<AnnouncementRepository>(
    AnnouncementRepository(database),
  );
  getIt.registerSingleton<NotificationService>(NotificationService());
  getIt.registerSingleton<GeofenceService>(GeofenceService.instance());
  getIt.registerSingleton<TriggerGeofence>(
    TriggerGeofence(
      getIt<AnnouncementRepository>(),
      getIt<GeofenceService>(),
      getIt<NotificationService>(),
    ),
  );
  getIt.registerSingleton<GetAllBroadcasts>(
    GetAllBroadcasts(getIt<AnnouncementRepository>()),
  );
}
