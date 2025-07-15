import 'package:flutter/material.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/data/services/geo_fence_service.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/data/sources/local_database.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/domain/usecases/trigger_geofence.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:flutter_developer_technical_test/src/infrastructure/data/services/notification_service.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/presentation/providers/announcement_provider.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/presentation/providers/location_provider.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/presentation/screens/announcement_details_screen.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/presentation/screens/history_screen.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/presentation/screens/login_screen.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/presentation/widgets/announcement_card.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final triggerGeofence = GetIt.I<TriggerGeofence>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Delay to ensure database is initialized
      Future.delayed(Duration(milliseconds: 100), () {
        _initGeofence();
        context.read<AnnouncementProvider>().loadAnnouncements();
      });
    });
  }

  @override
  void dispose() {
    triggerGeofence.stop();
    _tabController.dispose();
    super.dispose();
  }

  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.locationWhenInUse,
      Permission.notification,
    ].request();

    if (statuses[Permission.locationWhenInUse]!.isPermanentlyDenied ||
        statuses[Permission.notification]!.isPermanentlyDenied) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Location or Notification permission is permanently denied. Please enable it in settings.',
            ),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
      return false;
    }

    if (statuses[Permission.locationWhenInUse]!.isDenied ||
        statuses[Permission.notification]!.isDenied) {
      return false;
    }

    return true;
  }

  Future<void> _setCurrentLocation() async {
    bool hasPermission = await _requestPermissions();
    if (!hasPermission) return;

    try {
      geolocator.Position position =
          await geolocator.Geolocator.getCurrentPosition(
            desiredAccuracy: geolocator.LocationAccuracy.high,
          );
      await Provider.of<LocationProvider>(
        context,
        listen: false,
      ).setOfficeLocation(position.latitude, position.longitude);
      await triggerGeofence.stop();
      await _initGeofence();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Office location set to current location'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error setting office location: $e')),
        );
      }
    }
  }

  void _logout() {
    Provider.of<LocationProvider>(context, listen: false).clearOfficeLocation();
    triggerGeofence.stop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _initGeofence() async {
    bool hasPermission = await _requestPermissions();
    if (!hasPermission) return;

    try {
      final locationProvider = Provider.of<LocationProvider>(
        context,
        listen: false,
      );
      if (!locationProvider.isLocationSet) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please set office location first')),
          );
        }
        return;
      }
      await triggerGeofence(
        context: context,
        // officeLatitude: locationProvider.officeLatitude!,
        // officeLongitude: locationProvider.officeLongitude!,
        onEnter: (message) async {
          debugPrint('Showing notification and popup for: $message');
          final notificationId =
              DateTime.now().millisecondsSinceEpoch % 2147483647;
          await GetIt.I<NotificationService>().showNotification(
            message,
            notificationId: notificationId,
          );
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Welcome to the Office'),
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
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize geofence: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final geofenceService = GetIt.I<GeofenceService>();
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'HR Announcements'),
            Tab(text: 'Geofence Announcements'),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1976D2)),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            Consumer<LocationProvider>(
              builder: (context, locationProvider, child) => ListTile(
                title: const Text('Set Current as Office Area'),
                enabled: !locationProvider.isLocationSet,
                onTap: _setCurrentLocation,
              ),
            ),
            ListTile(title: const Text('Logout'), onTap: _logout),
          ],
        ),
      ),
      body: Column(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: geofenceService.isInsideGeofence,
            builder: (context, isInside, child) {
              debugPrint('Button state: isInside=$isInside');
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: null, // Disabled, used as status indicator
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isInside ? Colors.green : Colors.red,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    isInside ? 'Inside Office Area' : 'Outside Office Area',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: Consumer<AnnouncementProvider>(
              builder: (context, provider, child) {
                final hrAnnouncements = provider.announcements
                    .where((a) => !a.isGeofenceTriggered)
                    .toList();
                final geofenceAnnouncements = provider.announcements
                    .where((a) => a.isGeofenceTriggered)
                    .toList();
                debugPrint(
                  'HR Announcements: ${hrAnnouncements.length}, Titles: ${hrAnnouncements.map((a) => a.title).toList()}',
                );
                debugPrint(
                  'Geofence Announcements: ${geofenceAnnouncements.length}',
                );
                return TabBarView(
                  controller: _tabController,
                  children: [
                    // HR Announcements Tab
                    RefreshIndicator(
                      onRefresh: () => provider.refreshAnnouncements(),
                      child: provider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : hrAnnouncements.isEmpty
                          ? const Center(
                              child: Text('No HR announcements available'),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: hrAnnouncements.length,
                              itemBuilder: (context, index) {
                                final announcement = hrAnnouncements[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            AnnouncementDetailsScreen(
                                              announcement: announcement,
                                            ),
                                      ),
                                    );
                                  },
                                  child: AnnouncementCard(
                                    announcement: announcement,
                                  ),
                                );
                              },
                            ),
                    ),
                    // Geofence Announcements Tab
                    RefreshIndicator(
                      onRefresh: () => provider.refreshAnnouncements(),
                      child: provider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : geofenceAnnouncements.isEmpty
                          ? const Center(
                              child: Text(
                                'No geofence announcements available',
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: geofenceAnnouncements.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            AnnouncementDetailsScreen(
                                              announcement:
                                                  geofenceAnnouncements[index],
                                            ),
                                      ),
                                    );
                                  },
                                  child: AnnouncementCard(
                                    announcement: geofenceAnnouncements[index],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
