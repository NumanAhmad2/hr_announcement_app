class AnnouncementModel {
  final int id;
  final int notificationId;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isGeofenceTriggered;

  AnnouncementModel({
    required this.id,
    required this.notificationId,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isGeofenceTriggered = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'notificationId': notificationId,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isGeofenceTriggered': isGeofenceTriggered ? 1 : 0,
    };
  }

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      id: map['id'],
      notificationId: map['notificationId'],
      title: map['title'],
      message: map['message'],
      timestamp: DateTime.parse(map['timestamp']),
      isGeofenceTriggered: map['isGeofenceTriggered'] == 1,
    );
  }
}
