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
      brand: json['brand'],
      name: json['shoeName'],
      price: json['retailPrice'].toString(),
      image: json['thumbnail'],
    );
  }
}