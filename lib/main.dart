import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.instance.initialize();
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
