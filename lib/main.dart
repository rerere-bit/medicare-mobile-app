import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Auth
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
import 'screens/schedule/alarm_screen.dart';
//import 'screens/home/patient_caregiver_screen.dart'; // Import Caregiver Screen

// Services & Providers
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'providers/medication_provider.dart';
import 'providers/family_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id_ID', null);
  
  // Init Notifikasi
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
        navigatorKey: navigatorKey, // Global Key dari NotificationService
        debugShowCheckedModeBanner: false,
        title: 'Medicare',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF059669)), // Emerald Base
          useMaterial3: true,
          fontFamily: 'Roboto', // Opsional: Font default
        ),
        
        // --- AUTH GATE: Pintu Masuk dengan Logic Sync ---
        home: const AuthGate(), 
        
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/schedule': (context) => const ScheduleScreen(),
          '/history': (context) => const HistoryScreen(),
          '/family': (context) => const FamilyHomeScreen(),
          '/medication_list': (context) => const MedicationListScreen(),
        },
        
        // Handling Navigasi Alarm (Payload)
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

// --- WIDGET BARU: AUTH GATE (Menangani Sync & Auth State) ---
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isSyncing = false; // Flag agar tidak sync berulang-ulang saat rebuild

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // 1. Kondisi Loading Auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // 2. Kondisi Sudah Login
        if (snapshot.hasData && snapshot.data != null) {
          //final user = snapshot.data!;
          
          // --- LOGIC SYNC ALARM ---
          // Jalankan sync hanya sekali saat user terdeteksi login
          if (!_isSyncing) {
            _isSyncing = true;
            // Gunakan postFrameCallback agar aman dipanggil saat build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Provider.of<MedicationProvider>(context, listen: false).rescheduleAllAlarms();
            });
          }
          // ------------------------

          return const HomeScreen(); // Lanjut ke penentuan Role (Pasien/Keluarga)
        }

        // 3. Kondisi Belum Login
        _isSyncing = false; // Reset flag jika logout
        return const LoginScreen();
      },
    );
  }
}