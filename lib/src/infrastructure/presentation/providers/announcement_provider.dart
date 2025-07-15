import 'package:flutter/material.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/data/models/announcement_model.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/data/repositories/announcement_repository.dart';

class AnnouncementProvider with ChangeNotifier {
  final AnnouncementRepository _repository;
  List<AnnouncementModel> _announcements = [];

  AnnouncementProvider(this._repository) {
    _loadAnnouncements();
  }

  List<AnnouncementModel> get announcements => _announcements;

  Future<void> _loadAnnouncements() async {
    _announcements = await _repository.getAnnouncements();
    notifyListeners();
  }

  Future<void> refreshAnnouncements() async {
    _announcements = await _repository.getAnnouncements();
    notifyListeners();
  }

  Future<void> addAnnouncement(AnnouncementModel announcement) async {
    await _repository.saveAnnouncement(announcement);
    await _loadAnnouncements();
  }
}
