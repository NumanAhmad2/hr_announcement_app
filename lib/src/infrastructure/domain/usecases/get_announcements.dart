import 'package:flutter_developer_technical_test/src/infrastructure/data/models/announcement_model.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/data/repositories/announcement_repository.dart';

class GetAnnouncements {
  final AnnouncementRepository _repository;

  GetAnnouncements(this._repository);

  Future<List<AnnouncementModel>> call() async {
    return await _repository.getAnnouncements();
  }
}
