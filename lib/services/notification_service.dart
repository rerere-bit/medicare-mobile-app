import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  // Singleton Pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Inisialisasi
  Future<void> init() async {
    tz.initializeTimeZones(); // Wajib untuk jadwal waktu

    // Setting Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Setting iOS (Standar)
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

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Fungsi Menjadwalkan Notifikasi Harian
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    
    // --- PERBAIKAN: Minta Izin Exact Alarm (Android 12+) ---
    // Ini mencegah error "Exact alarms are not permitted"
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestExactAlarmsPermission();
    }
    // --------------------------------------------------------

    // Konfigurasi Detail Notifikasi Android
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medication_channel', // Id Channel
      'Pengingat Obat',     // Nama Channel
      channelDescription: 'Notifikasi untuk jadwal minum obat',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true, // Agar muncul pop-up walau layar mati
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    // Hitung waktu jadwal hari ini/besok
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    // Jika jam sudah lewat hari ini, jadwalkan untuk besok
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Mode ini butuh izin di atas
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Ulangi setiap jam yang sama setiap hari
      );
    } catch (e) {
      // Tangkap error jika user menolak izin, agar aplikasi tidak crash
      print("Gagal menjadwalkan notifikasi: $e");
    }
  }

  // Batalkan Notifikasi (Misal obat dihapus)
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}