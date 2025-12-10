import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
// HAPUS IMPORT INI: import 'package:flutter_timezone/flutter_timezone.dart'; 

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // A. Setup Zona Waktu Lokal (MANUAL FIX)
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

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          debugPrint('🔔 Notifikasi Diklik! Payload: ${response.payload}');
          navigatorKey.currentState?.pushNamed('/alarm', arguments: response.payload);
        }
      },
    );

    await _requestPermissions();
  }

  // --- UPDATE BAGIAN INI DI notification_service.dart ---
  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    
    try {
      // GANTI DARI 'Asia/Jakarta' KE 'Asia/Makassar'
      tz.setLocalLocation(tz.getLocation('Asia/Makassar')); 
      debugPrint("🌍 Timezone set manually to: Asia/Makassar (WITA)");
    } catch (e) {
      debugPrint("Error setting timezone: $e");
      // Fallback
      tz.setLocalLocation(tz.UTC); 
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotif = await androidImplementation?.requestNotificationsPermission();
      final bool? grantedAlarm = await androidImplementation?.requestExactAlarmsPermission();

      debugPrint("🔑 Izin Notifikasi: $grantedNotif | Izin Alarm: $grantedAlarm");
    }
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medicare_alarm_channel',
      'Alarm Obat Medicare',
      channelDescription: 'Alarm full screen untuk jadwal obat',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.alarm,
      ticker: 'Waktunya minum obat',
      visibility: NotificationVisibility.public,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    // Dapatkan waktu sekarang sesuai Zona Waktu yang sudah di-set (Jakarta)
    final now = tz.TZDateTime.now(tz.local);
    
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
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
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, 
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
      debugPrint("✅ Sukses Menjadwalkan ID:$id");
    } catch (e) {
      debugPrint("❌ GAGAL Menjadwalkan: $e");
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    debugPrint("🗑️ Alarm ID:$id dibatalkan");
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}