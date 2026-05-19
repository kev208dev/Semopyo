import 'dart:ui';
import 'package:flutter/material.dart';
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
  final List<Color> color;
  @override
  
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 20,
      ),
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
            colors: color,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        width: 300,
        height: 350,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
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
                ],
              ),
              Positioned(
                right: -50,
                bottom: -30,
    
                child: Transform.rotate(
                  angle: -0.65,
                  child: ImageFiltered(
                   
                    imageFilter: ImageFilter.blur(
                      sigmaX: 18,
                      sigmaY: 18,
                    ),
                    child: Opacity(
                      opacity: 0.25,
                      child: Image.asset(
                        'assets/images/nike-airforce107.png',
                        width: 300,
                        color: Colors.pink.withAlpha(100),
                        colorBlendMode: BlendMode.srcATop,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -50,
                bottom: -7,
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
  final List<Color> color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 20,
      ),
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
            colors: color,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        width: 300,
        height: 150,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        brand,
                        style: TextStyle(
                          color: Colors.white,
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
    
                  SizedBox(height: 17),
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontSize: 15,
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
                ],
              ),
             
              Positioned(
                right: -10,
                bottom: -7,
                child: Image.asset(
                    thumbnail,
                    width: 160,
                    fit: BoxFit.contain,
                  ),
                ),
              
            ],
          ),
        ),
      ),
    );
  }
}