import 'dart:convert';
import 'package:http/http.dart' as http;
import 'shoes_data.dart';

class ShoeModel {
  final String brand;
  final String name;
  final String price;
  final String image;

  ShoeModel({
    required this.brand,
    required this.name,
    required this.price,
    required this.image,
  });

  factory ShoeModel.fromJson(Map<String, dynamic> json) {
    return ShoeModel(
      brand: json['brand'] ?? '',
      name: json['shoeName'] ?? '',
      price: json['retailPrice']?.toString() ?? '',
      image: json['thumbnail'] ?? '',
    );
  }
}

class SneakerApiService {
  Future<List<ShoeModel>> fetchShoes() async {
    final response = await http.get(
      Uri.parse('https://api.thesneakerdatabase.com/v1/sneakers?limit=10'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['results'];
      return data.map((json) => ShoeModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load shoes');
    }
  }
}
