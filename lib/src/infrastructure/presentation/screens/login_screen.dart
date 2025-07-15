import 'package:flutter/material.dart';
import 'package:flutter_developer_technical_test/core/widgets/custom_text_field.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/presentation/screens/home_screen.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/presentation/widgets/custom_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomTextField(label: 'Username'),
            const SizedBox(height: 16),
            const CustomTextField(label: 'Password', isPassword: true),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Login',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
