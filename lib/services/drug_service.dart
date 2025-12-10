import 'dart:convert';
import 'package:http/http.dart' as http;

class DrugModel {
  final String name;
  final String description;

  DrugModel({required this.name, required this.description});
}

class DrugService {
  // Base URL OpenFDA (Gratis & Publik)
  static const String _baseUrl = 'https://api.fda.gov/drug/label.json';

  // --- DATABASE OBAT LOKAL INDONESIA (FALLBACK) ---
  // Data ini akan muncul jika pencarian di API OpenFDA tidak ditemukan
  final List<DrugModel> _localDrugs = [
    DrugModel(name: "Paracetamol", description: "Pereda nyeri ringan dan penurun demam."),
    DrugModel(name: "Panadol", description: "Obat pusing dan demam (Paracetamol)."),
    DrugModel(name: "Sanmol", description: "Penurun panas dan pereda nyeri."),
    DrugModel(name: "Bodrex", description: "Meredakan sakit kepala dan sakit gigi."),
    DrugModel(name: "Promag", description: "Obat maag dan kembung (Antasida)."),
    DrugModel(name: "Mylanta", description: "Mengatasi asam lambung berlebih dan nyeri ulu hati."),
    DrugModel(name: "Tolak Angin", description: "Herbal untuk masuk angin dan menjaga daya tahan tubuh."),
    DrugModel(name: "Betadine", description: "Antiseptik untuk luka luar."),
    DrugModel(name: "Insto", description: "Obat tetes mata untuk mata merah/iritasi."),
    DrugModel(name: "Komix", description: "Obat batuk sirup."),
    DrugModel(name: "Procold", description: "Meringankan gejala flu, demam, sakit kepala."),
    DrugModel(name: "Amoxicillin", description: "Antibiotik untuk infeksi bakteri (Wajib Resep Dokter)."),
    DrugModel(name: "Cefadroxil", description: "Antibiotik spektrum luas (Wajib Resep Dokter)."),
    DrugModel(name: "Amlodipine", description: "Obat hipertensi/tekanan darah tinggi."),
    DrugModel(name: "Captopril", description: "Obat untuk hipertensi dan gagal jantung."),
    DrugModel(name: "Metformin", description: "Obat diabetes melitus tipe 2."),
    DrugModel(name: "Simvastatin", description: "Obat penurun kolesterol."),
    DrugModel(name: "Asam Mefenamat", description: "Pereda nyeri (sakit gigi, haid, sendi)."),
    DrugModel(name: "Ibuprofen", description: "Obat anti-inflamasi non-steroid (nyeri & radang)."),
    DrugModel(name: "Antangin", description: "Sirup herbal masuk angin."),
  ];

  Future<List<DrugModel>> searchDrugs(String query) async {
    // Minimal 3 huruf agar pencarian relevan
    if (query.length < 3) return [];

    List<DrugModel> apiResults = [];

    // 1. COBA TARIK DARI API OPENFDA
    try {
      // Query: mencari field 'openfda.brand_name' (Merk Dagang)
      final url = Uri.parse(
          '$_baseUrl?search=openfda.brand_name:"$query"&limit=5');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['results'] != null) {
          List<dynamic> results = data['results'];

          apiResults = results.map((json) {
            String name = "Unknown Drug";
            // Ambil Brand Name pertama
            if (json['openfda'] != null && 
                json['openfda']['brand_name'] != null && 
                (json['openfda']['brand_name'] as List).isNotEmpty) {
              name = json['openfda']['brand_name'][0];
            }

            // Ambil Deskripsi Singkat
            String desc = "Deskripsi dari FDA.";
            if (json['indications_and_usage'] != null && 
                (json['indications_and_usage'] as List).isNotEmpty) {
              String raw = json['indications_and_usage'][0];
              // Bersihkan teks agar rapi (hapus kode aneh jika ada)
              desc = raw.length > 80 ? "${raw.substring(0, 80)}..." : raw;
            } else if (json['purpose'] != null && (json['purpose'] as List).isNotEmpty) {
               desc = json['purpose'][0];
            }

            return DrugModel(name: name, description: desc);
          }).toList();
        }
      }
    } catch (e) {
      print("API Error (OpenFDA): $e");
      // Jangan return empty list dulu, kita lanjut cek data lokal
    }

    // 2. CARI DI DATA LOKAL (INDONESIA)
    // Filter list _localDrugs yang namanya mengandung query user
    final localResults = _localDrugs.where((drug) {
      return drug.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    // 3. GABUNGKAN HASIL (API + LOKAL)
    // Kita taruh hasil LOKAL duluan agar obat Indonesia muncul paling atas
    List<DrugModel> combinedResults = [...localResults, ...apiResults];

    // Hapus duplikasi nama (jika ada di API dan Lokal)
    final ids = <String>{};
    combinedResults.retainWhere((x) => ids.add(x.name.toLowerCase()));

    return combinedResults;
  }
}