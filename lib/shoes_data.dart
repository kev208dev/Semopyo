
import 'dart:convert';
import 'package:http/http.dart' as http;


class SneakerApiService {
  Future<List<ShoeModel>> fetchShoes() async {
    final response = await http.get(
      Uri.parse(
        'https://the-sneaker-database.p.rapidapi.com/sneakers?limit=30&brand=Nike',
      ),

      headers: {
        'X-RapidAPI-Key': '082af82302mshb6feddc8bdb57d7p119cd5jsnc291f9bf91a0',

        'X-RapidAPI-Host': 'the-sneaker-database.p.rapidapi.com',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List shoesJson = data['results'];

      return shoesJson
          .where(
            (json) =>
                json['image'] != null &&
                json['image']['small'] != null &&
                json['image']['small'] != '',
          )
          .map((json) => ShoeModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load shoes');
    }
  }
}

class ShoeModel {
  final String brand;
  final String name;
  final String price;
  final String image;
  final String color;

  ShoeModel({
    required this.brand,
    required this.name,
    required this.price,
    required this.image,
    required this.color,
  });

  factory ShoeModel.fromJson(Map<String, dynamic> json) {
    return ShoeModel(
      brand: json['brand'] ?? '',
      name: (json['name'] ?? '')
          .split(' ')
          .skip(1)
          .join(' ')
          .split("'")[0]
          .trim(),
      price: json['estimatedMarketValue']?.toString() ?? '',
      image: json['image']['small'] ?? '',
      color: json['colorway'] ?? '',
    );
  }
}
