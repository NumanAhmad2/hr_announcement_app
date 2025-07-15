import 'package:flutter/material.dart';
import 'package:flutter_developer_technical_test/core/theme/app_theme.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/data/repositories/announcement_repository.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/presentation/providers/announcement_provider.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/presentation/providers/location_provider.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/presentation/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

class HRBroadcastApp extends StatelessWidget {
  const HRBroadcastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              AnnouncementProvider(GetIt.I<AnnouncementRepository>()),
        ),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: MaterialApp(
        title: 'HR Broadcast App',
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
      ),
    );
  }
}
