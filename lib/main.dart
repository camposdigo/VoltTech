import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const VoltTechApp());
}

class VoltTechApp extends StatelessWidget {
  const VoltTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VoltTech',
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
