import 'package:flutter/material.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/data/models/announcement_model.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/data/repositories/announcement_repository.dart';

class AnnouncementProvider with ChangeNotifier {
  final AnnouncementRepository _repository;
  List<AnnouncementModel> _announcements = [];
  bool _isLoading = false;
  String? _error;

  AnnouncementProvider(this._repository);

  List<AnnouncementModel> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAnnouncements() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _announcements = await _repository.getAnnouncements();
      _error = null;
    } catch (e) {
      _error = 'Failed to load announcements: $e';
      _announcements = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAnnouncements() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _announcements = await _repository.getAnnouncements();
      final hrAnnouncements = _announcements
          .where((a) => !a.isGeofenceTriggered)
          .toList();
      hrAnnouncements.shuffle();
      final geofenceAnnouncements = _announcements
          .where((a) => a.isGeofenceTriggered)
          .toList();
      _announcements = [...hrAnnouncements, ...geofenceAnnouncements];
      _error = null;
    } catch (e) {
      _error = 'Failed to refresh announcements: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAnnouncement(AnnouncementModel announcement) async {
    try {
      await _repository.saveAnnouncement(announcement);
      await loadAnnouncements();
    } catch (e) {
      _error = 'Failed to add announcement: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
