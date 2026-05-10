import 'package:flutter/material.dart';
import 'main.dart';
import 'pizza_data.dart';

class PizzaPagePopup extends StatelessWidget {
  const PizzaPagePopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundcolor,
      appBar: AppBar(
        title: Text(
          '피자 선택',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Hero(
            tag: 'pizza-select',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.purple[400]!, width: 2),
                  ),
                  child: Center(child: Icon(Icons.add)),
                ),
                SizedBox(width: 30),
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.purple[400]!, width: 2),
                  ),
                  child: Center(child: Icon(Icons.add)),
                ),
              ],
            ),
          ),
          Container(height: 20),
          SizedBox(
            height: 300,
            child: Stack(
              children: [
                Container(
                  color: backgroundcolor,
                  child: Hero(
                    tag: 'pizza-select',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 왼쪽 원
                        // 오른쪽 원
                      ],
                    ),
                  ),
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (int i = 0; i < pizzaList.length; i++)
                  pizzaLabel(
                    pizzaList[i]['thumbnail'] as String,
                    pizzaList[i]['name'] as String,
                    pizzaList[i]['size'] as String,
                    (3.14 *
                            ((pizzaList[i]['diameter'] as double) / 2) *
                            ((pizzaList[i]['diameter'] as double) / 2))
                        .toInt(),
                    pizzaList[i]['price'] as int,
                  ),
              ],
            ),
          ),
          /////////////
        ],
      ),
    );
  }

  Widget pizzaLabel(
    String thumbnail,
    String name,
    String size,
    int area,
    int price,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(204),
                  spreadRadius: 1,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),

            width: double.infinity,
            height: 100,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(thumbnail, width: 100, height: 100),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '사이즈: $size, 지름: 30cm, \n가격: $price원',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 2),
      ],
    );
  }
}
