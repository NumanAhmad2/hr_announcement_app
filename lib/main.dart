import 'package:flutter/material.dart';
import 'package:flutter_developer_technical_test/core/di/injection.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/data/repositories/announcement_repository.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/presentation/providers/announcement_provider.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/presentation/providers/location_provider.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/presentation/screens/home_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AnnouncementProvider(getIt<AnnouncementRepository>()),
        ),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: MaterialApp(
        title: 'HR Broadcast App',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const HomeScreen(),
      ),
    );
  }
}
