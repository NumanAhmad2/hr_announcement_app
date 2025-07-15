import 'package:flutter_developer_technical_test/src/infrastructure/data/repositories/announcement_repository.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/data/repositories/sqflite_repository.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/data/services/notification_service.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/data/sources/local_database.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/domain/usecases/get_all_broadcasts.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/domain/usecases/get_announcements.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/domain/usecases/trigger_geofence.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerSingleton<LocalDatabase>(LocalDatabase());
  getIt.registerSingleton<AnnouncementRepository>(
    SqfliteRepository(getIt<LocalDatabase>()),
  );
  getIt.registerSingleton<NotificationService>(NotificationService());
  getIt.registerSingleton<GetAnnouncements>(
    GetAnnouncements(getIt<AnnouncementRepository>()),
  );
  getIt.registerSingleton<GetAllBroadcasts>(
    GetAllBroadcasts(getIt<AnnouncementRepository>()),
  );
  getIt.registerSingleton<TriggerGeofence>(
    TriggerGeofence(getIt<AnnouncementRepository>()),
  );
}
