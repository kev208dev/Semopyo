import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'color_set.dart';

class MainShoeCard extends StatelessWidget {
  const MainShoeCard({
    super.key,
    required this.brand,
    required this.name,
    required this.price,
    required this.thumbnail,
    required this.color,
  });

  final String brand;
  final String name;
  final String price;
  final String thumbnail;
  final String color;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withAlpha(77),
              blurRadius: 15,
              offset: Offset(5, 10),
            ),
          ],

          gradient: LinearGradient(
            begin: Alignment.topLeft,

            end: Alignment.bottomRight,
            colors: getColorSet(color),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        width: 300,
        height: 360,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        brand,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Icon(
                        size: 30,
                        Icons.favorite_border,
                        color: Colors.white,
                      ),
                    ],
                  ),

                  SizedBox(height: 17),
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${price}원',
                    style: TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: 280,
                      isExpanded: true,
                      items: [250, 255, 260, 265, 270, 275, 280, 285, 290].map(size) => DropdownMenuItem(
                        value: size,
                        child: Text(
                          'KR ${size}',
                          style: TextStyle(
                            fontSize:18,
                            fontWeight: Fontweight.w700),
                        )
                        ).toList(),

                    ),
                  ),
                ],
              ),
              
              Positioned( // 핑크 그림자
                right: -70,
                bottom: -11,

                child: Transform.rotate(
                  angle: -0.65,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Opacity(
                      opacity: 0.35,
                      child: Image.asset(
                        'assets/images/nike-airforce107.png',
                        width: 300,
                        color: Colors.pink.withAlpha(200),
                        colorBlendMode: BlendMode.srcATop,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -70,
                bottom: -11,
                child: Transform.rotate(
                  angle: -0.65,
                  child: Image.asset(
                    thumbnail,
                    width: 300,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////

class SubShoeCard extends StatelessWidget {
  const SubShoeCard({
    super.key,
    required this.brand,
    required this.name,
    required this.price,
    required this.thumbnail,
    required this.color,
  });

  final String brand;
  final String name;
  final String price;
  final String thumbnail;
  final String color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(77),
              blurRadius: 15,
              offset: Offset(5, 10),
            ),
          ],

          gradient: LinearGradient(
            begin: Alignment.topLeft,

            end: Alignment.bottomRight,
            colors: getColorSet(color),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        width: 100,
        height: 160,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        brand,
                        style: TextStyle(
                          color: thumbnail.contains("white")
                              ? Colors.black
                              : Colors.white,

                          fontSize: 30,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Icon(
                        size: 27,
                        Icons.favorite_border,
                        color: Colors.white,
                      ),
                    ],
                  ),

                  SizedBox(height: 8),
                  SizedBox(
                    width: 180,
                    child: Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: thumbnail.contains("white")
                            ? Colors.black
                            : Colors.white,
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '\$ ${price}',
                    style: TextStyle(
                      color: thumbnail.contains("white")
                          ? Colors.black
                          : Colors.white,
                      fontStyle: FontStyle.italic,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              Positioned(
                right: -20,
                bottom: -60,
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: thumbnail.isEmpty
                      ? SizedBox()
                      : Transform(
                          alignment: .center,
                          transform: Matrix4.rotationY(3.14159),
                          child: Image.network(thumbnail, fit: BoxFit.contain),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
