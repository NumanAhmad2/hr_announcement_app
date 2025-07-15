import 'package:flutter_developer_technical_test/src/infrastructure/data/models/announcement_model.dart';

abstract class AnnouncementRepository {
  Future<List<AnnouncementModel>> getAnnouncements();
  Future<List<AnnouncementModel>> getAllBroadcasts();
  Future<void> saveAnnouncement(AnnouncementModel announcement);
}
