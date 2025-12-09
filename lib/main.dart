import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/home/family_home_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/medication/medication_list_screen.dart';
import 'screens/schedule/schedule_screen.dart';
import 'screens/schedule/alarm_screen.dart'; // Import Alarm Screen

// Services & Providers
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'providers/medication_provider.dart';
import 'providers/family_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id_ID', null);
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MedicationProvider()),
        ChangeNotifierProvider(create: (_) => FamilyProvider()),
      ],
      child: MaterialApp(
        // --- 1. SET NAVIGATOR KEY (PENTING UNTUK NOTIFIKASI) ---
        navigatorKey: navigatorKey,
        
        debugShowCheckedModeBanner: false,
        title: 'Medicare',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        
        // --- 2. LOGIKA AUTH PERSISTENCE (Langsung Home jika sudah login) ---
        home: StreamBuilder(
          stream: AuthService().authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                return const HomeScreen(); // Sudah Login
              } else {
                return const LoginScreen(); // Belum Login
              }
            }
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          },
        ),
        
        // --- 3. ROUTES ---
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/schedule': (context) => const ScheduleScreen(),
          '/history': (context) => const HistoryScreen(),
          '/family': (context) => const FamilyHomeScreen(),
          '/medication_list': (context) => const MedicationListScreen(),
        },
        
        // --- 4. ON GENERATE ROUTE (Untuk menangani arguments payload) ---
        onGenerateRoute: (settings) {
          if (settings.name == '/alarm') {
            final payload = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (context) => AlarmScreen(payload: payload),
            );
          }
          return null;
        },
      ),
    );
  }
}