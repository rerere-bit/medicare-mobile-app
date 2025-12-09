import 'dart:convert';
import 'package:http/http.dart' as http;

class DrugModel {
  final String name;
  final String description;

  DrugModel({required this.name, required this.description});
}

class DrugService {
  // Base URL OpenFDA
  static const String _baseUrl = 'https://api.fda.gov/drug/label.json';

  Future<List<DrugModel>> searchDrugs(String query) async {
    if (query.length < 3) return []; // Minimal 3 huruf untuk hemat request

    try {
      // Query: mencari field 'openfda.brand_name' yang mengandung input user
      // Limit: batasi 5 hasil agar cepat
      final url = Uri.parse(
          '$_baseUrl?search=openfda.brand_name:"$query"*&limit=5');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Cek apakah ada hasil 'results'
        if (data['results'] == null) return [];

        List<dynamic> results = data['results'];

        return results.map((json) {
          // Ambil nama obat (brand_name)
          String name = "Unknown Drug";
          if (json['openfda'] != null && 
              json['openfda']['brand_name'] != null && 
              (json['openfda']['brand_name'] as List).isNotEmpty) {
            name = json['openfda']['brand_name'][0];
          }

          // Ambil deskripsi (indications_and_usage)
          String desc = "Deskripsi tidak tersedia.";
          if (json['indications_and_usage'] != null && 
              (json['indications_and_usage'] as List).isNotEmpty) {
            // Deskripsi API biasanya panjang, kita potong 100 karakter
            String rawDesc = json['indications_and_usage'][0];
            desc = rawDesc.length > 100 ? "${rawDesc.substring(0, 100)}..." : rawDesc;
          }

          return DrugModel(name: name, description: desc);
        }).toList();
      } else {
        // Jika error (misal 404 not found), kembalikan list kosong
        return [];
      }
    } catch (e) {
      print("Error fetching drugs: $e");
      return [];
    }
  }
}