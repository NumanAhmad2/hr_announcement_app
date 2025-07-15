import 'package:flutter/material.dart';
import 'package:flutter_developer_technical_test/core/di/injection.dart';
import 'package:flutter_developer_technical_test/src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const HRBroadcastApp());
}
