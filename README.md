# Medicare - Aplikasi Pengingat Minum Obat & Monitoring Keluarga

Medicare adalah aplikasi mobile fullstack berbasis Flutter yang dirancang untuk membantu kepatuhan minum obat pasien dan memungkinkan keluarga memantau aktivitas kesehatan mereka secara *realtime*.

## 📱 Fitur Unggulan

### 1. Multi-Role Authentication
* **Mode Pasien:** Untuk pengguna yang membutuhkan pengingat obat.
* **Mode Keluarga:** Untuk pendamping yang memantau kepatuhan pasien.
* *Secure Login & Register dengan Firebase Auth.*

### 2. Manajemen Obat (CRUD)
* Tambah, Edit, dan Hapus jadwal obat.
* **Frekuensi Dinamis:** Mendukung jadwal 1x, 2x, 3x, hingga 4x sehari.
* Sinkronisasi data otomatis ke Cloud Firestore.

### 3. Smart Notification System 🔔
* Aplikasi menjadwalkan alarm lokal (Exact Alarm) secara otomatis berdasarkan frekuensi obat.
* Notifikasi tetap muncul meskipun aplikasi ditutup (Background Process).
* Izin otomatis untuk Android 12+ (Exact Alarm Permission).

### 4. Realtime Monitoring (Fitur Keluarga)
* Keluarga dapat menautkan akun pasien menggunakan email.
* Melihat daftar obat pasien secara *realtime*.
* Melihat **Riwayat Minum Obat** pasien (Log History) detik itu juga saat pasien mengonfirmasi minum obat.

## 🛠️ Tech Stack

* **Framework:** Flutter (Dart)
* **Backend:** Firebase (Authentication, Cloud Firestore)
* **State Management:** Provider (MVVM Architecture)
* **Local Features:** `flutter_local_notifications`, `timezone`, `intl`

## 📸 Screenshots
(Masukkan screenshot aplikasi di folder ini dan link ke sini)

## 🚀 Cara Instalasi

1.  Clone repository ini.
2.  Jalankan `flutter pub get`.
3.  Pastikan file `google-services.json` (Firebase Config) sudah ada di `android/app/`.
4.  Jalankan perintah:
    ```bash
    flutter run
    ```

---
*Dibuat untuk Tugas Proyek Mobile Programming.*