import 'package:bangladesh_disaster_management/providers/weather_provider.dart';
import 'package:bangladesh_disaster_management/reports_screen/disaster_reports_screen.dart';
import 'package:bangladesh_disaster_management/satelliate_screen/satellite_screen.dart';
import 'package:bangladesh_disaster_management/screens/alert_screen.dart';
import 'package:bangladesh_disaster_management/screens/flood_monitor_screen.dart';
import 'package:bangladesh_disaster_management/screens/home_screen.dart';
import 'package:bangladesh_disaster_management/screens/settingscreen.dart';
import 'package:bangladesh_disaster_management/screens/splash_screen.dart';
import 'package:bangladesh_disaster_management/screens/weather_screen.dart';
// ADD THIS LINE
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'services/ffwc_api_service.dart';
import 'services/weather_service.dart';
import 'services/notification_service.dart';
import 'providers/flood_data_provider.dart';

// Initialize notification plugin globally
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://vbjntfdnzxhivvjlthbk.supabase.co', // Replace with your Supabase URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZiam50ZmRuenhoaXZ2amx0aGJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA0NDc3MjAsImV4cCI6MjA2NjAyMzcyMH0.7-uYBaruj1imxWJbyfIp3T_uTxbmJz0jvP6MeZ6C_Q0', // Replace with your Supabase anon key
  );

  // Initialize notifications
  await NotificationService.initialize();

  runApp(const DisasterManagementApp());
}

class DisasterManagementApp extends StatelessWidget {
  const DisasterManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FloodDataProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: MaterialApp(
        title: 'Bangladesh Disaster Management',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF1976D2),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1976D2),
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1976D2),
            foregroundColor: Colors.white,
            elevation: 4,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF1976D2),
          ),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/flood-monitor': (context) => const FloodMonitorScreen(),
          '/weather': (context) => const WeatherScreen(),
          '/alerts': (context) => const DisasterReportsScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/satellite': (context) => const SatelliteScreen(), // ADD THIS LINE
        },
      ),
    );
  }
}
