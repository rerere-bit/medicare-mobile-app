import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    // Setup Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Setup iOS
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
          navigatorKey.currentState?.pushNamed('/alarm', arguments: response.payload);
        }
      },
    );

    // --- PENTING: REQUEST PERMISSION MANUAL ---
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // Minta izin Notifikasi (Android 13+)
      await androidImplementation?.requestNotificationsPermission();
      
      // Minta izin Alarm Presisi (Android 12+)
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  // --- FUNGSI SCHEDULE (SAMA, TAPI PASTIKAN ZONA WAKTU BENAR) ---
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    
    // Config Notifikasi Android
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medicare_channel_id', // ID Channel harus konsisten
      'Pengingat Obat Medicare',
      channelDescription: 'Alarm untuk jadwal minum obat',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true, // Agar muncul full screen
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.alarm, // Set kategori Alarm
      visibility: NotificationVisibility.public,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    // Logika Waktu
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    // Jika jam sudah lewat hari ini, jadwalkan besok
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    print("Scheduling Alarm ID: $id at $hour:$minute ($scheduledDate)"); // Debug Print

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Mode agresif agar bunyi saat doze
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Ulangi setiap hari di jam yang sama
        payload: payload,
      );
    } catch (e) {
      print("ERROR Scheduling Notification: $e");
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}