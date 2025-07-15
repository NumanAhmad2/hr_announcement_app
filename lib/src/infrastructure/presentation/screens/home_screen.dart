import 'package:flutter/material.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/data/services/notification_service.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/domain/usecases/trigger_geofence.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/presentation/providers/announcement_provider.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/presentation/providers/location_provider.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/presentation/screens/announcement_details_screen.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/presentation/screens/history_screen.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/presentation/screens/login_screen.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/presentation/widgets/announcement_card.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<bool> _requestPermissions(BuildContext context) async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.activityRecognition,
    ].request();

    if (statuses[Permission.location]!.isPermanentlyDenied ||
        statuses[Permission.activityRecognition]!.isPermanentlyDenied) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Location or Activity Recognition permission is permanently denied. Please enable it in settings.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
      return false;
    }

    if (statuses[Permission.location]!.isDenied ||
        statuses[Permission.activityRecognition]!.isDenied) {
      return false;
    }

    return true;
  }

  Future<void> _setCurrentLocation(BuildContext context) async {
    bool hasPermission = await _requestPermissions(context);
    if (!hasPermission) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await Provider.of<LocationProvider>(context, listen: false)
          .setOfficeLocation(position.latitude, position.longitude);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error setting location: $e')),
        );
      }
    }
  }

  void _logout(BuildContext context) {
    Provider.of<LocationProvider>(context, listen: false).clearOfficeLocation();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationService = GetIt.I<NotificationService>();
    final triggerGeofence = GetIt.I<TriggerGeofence>();

    void initGeofence() async {
      bool hasPermission = await _requestPermissions(context);
      if (!hasPermission) return;

      triggerGeofence(
        onEnter: (message) async {
          await notificationService.showNotification(message);
          await Provider.of<AnnouncementProvider>(context, listen: false)
              .refreshAnnouncements();
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Welcome'),
                content: Text(message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('HR Announcements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF1976D2),
              ),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            Consumer<LocationProvider>(
              builder: (context, locationProvider, child) => ListTile(
                title: const Text('Set Current as Office Area'),
                enabled: !locationProvider.isLocationSet,
                onTap: () => _setCurrentLocation(context),
              ),
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: Consumer<AnnouncementProvider>(
        builder: (context, provider, child) {
          initGeofence();
          return RefreshIndicator(
            onRefresh: () => provider.refreshAnnouncements(),
            child: provider.announcements.isEmpty
                ? const Center(child: Text('No announcements available'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.announcements.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AnnouncementDetailsScreen(
                                announcement: provider.announcements[index],
                              ),
                            ),
                          );
                        },
                        child: AnnouncementCard(
                            announcement: provider.announcements[index]),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}