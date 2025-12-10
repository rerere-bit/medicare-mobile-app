import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart'; // Import baru

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // --- 1. INISIALISASI ---
  Future<void> init() async {
    // A. Setup Zona Waktu Lokal (CRITICAL)
    await _configureLocalTimeZone();

    // B. Setup Android Settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // C. Setup iOS Settings
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // D. Initialize Plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          debugPrint('🔔 Notifikasi Diklik! Payload: ${response.payload}');
          navigatorKey.currentState?.pushNamed('/alarm', arguments: response.payload);
        }
      },
    );

    // E. Request Permission (WAJIB)
    await _requestPermissions();
  }

  // Helper: Ambil Zona Waktu HP
  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    debugPrint("🌍 Timezone set to: $timeZoneName");
  }

  // Helper: Minta Izin Notifikasi & Alarm
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // 1. Izin Notifikasi (Android 13+)
      final bool? grantedNotif = await androidImplementation?.requestNotificationsPermission();
      
      // 2. Izin Alarm Presisi (Android 12+)
      final bool? grantedAlarm = await androidImplementation?.requestExactAlarmsPermission();

      debugPrint("🔑 Izin Notifikasi: $grantedNotif | Izin Alarm: $grantedAlarm");
    }
  }

  // --- 2. FUNGSI SCHEDULE ALARM ---
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    
    // Konfigurasi Tampilan Notifikasi
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medicare_alarm_channel',   // ID Channel (Harus Unik & Tetap)
      'Alarm Obat Medicare',      // Nama Channel (Muncul di Settings HP)
      channelDescription: 'Alarm full screen untuk jadwal obat',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,     // PENTING: Muncul di Lock Screen
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.alarm,
      ticker: 'Waktunya minum obat',
      visibility: NotificationVisibility.public,
      // Suara custom (jika ada), kalau tidak pakai default
      // sound: RawResourceAndroidNotificationSound('alarm_sound'), 
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    // Konfigurasi Waktu (Timezone Aware)
    final now = tz.TZDateTime.now(tz.local);
    
    // Buat jadwal hari ini
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    // Jika jam sudah lewat, jadwalkan besok
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    debugPrint("⏰ Menjadwalkan Alarm ID:$id pada jam ${scheduledDate.toString()}");

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        platformDetails,
        // Mode Presisi Tinggi (Bekerja meski HP Doze/Sleep)
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, 
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Ulangi setiap hari
        payload: payload,
      );
      debugPrint("✅ Sukses Menjadwalkan ID:$id");
    } catch (e) {
      debugPrint("❌ GAGAL Menjadwalkan: $e");
    }
  }

  // --- 3. BATALKAN NOTIFIKASI ---
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    debugPrint("🗑️ Alarm ID:$id dibatalkan");
  }

  // --- 4. HAPUS SEMUA (Untuk Logout) ---
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}