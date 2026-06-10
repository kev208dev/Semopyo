
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

/// API 실패(오프라인/레이트리밋) 시 쓰는 기본 목록.
/// 번들된 에셋이 1개라 이미지는 공유하지만, 브랜드/모델이 달라 체감사이즈 비교는 동작한다.
final List<ShoeModel> fallbackShoes = [
  ShoeModel(
    brand: 'Nike',
    name: 'Air Force 1 07',
    price: '129000',
    image: 'assets/images/nike-airforce107.png',
    color: 'White',
  ),
  ShoeModel(
    brand: 'Nike',
    name: 'Dunk Low',
    price: '139000',
    image: 'assets/images/nike-airforce107.png',
    color: 'Black',
  ),
  ShoeModel(
    brand: 'New Balance',
    name: '993',
    price: '259000',
    image: 'assets/images/nike-airforce107.png',
    color: 'Grey',
  ),
  ShoeModel(
    brand: 'Adidas',
    name: 'Samba',
    price: '139000',
    image: 'assets/images/nike-airforce107.png',
    color: 'White',
  ),
  ShoeModel(
    brand: 'Salomon',
    name: 'XT-6',
    price: '219000',
    image: 'assets/images/nike-airforce107.png',
    color: 'Black',
  ),
];

/// 앱 첫 진입 시 보여줄 기본 "현재 신는 신발".
ShoeModel defaultCurrentShoe() => ShoeModel(
  brand: 'Nike',
  name: 'Air Force 1 07',
  price: '129000',
  image: 'assets/images/nike-airforce107.png',
  color: 'White',
);
