import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // 1. Pastikan import ini ada

import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'providers/medication_provider.dart';
import 'providers/family_provider.dart'; // Import Family Provider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. Wajib ada agar format tanggal (Senin, Selasa, dll) tidak error
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider Obat
        ChangeNotifierProvider(create: (_) => MedicationProvider()),
        
        // 3. Provider Keluarga (TAMBAHKAN INI)
        ChangeNotifierProvider(create: (_) => FamilyProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Medicare',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}