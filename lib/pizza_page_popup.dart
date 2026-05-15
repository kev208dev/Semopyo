import 'package:flutter/material.dart';
import 'main.dart';
import 'pizza_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

int selectedSlot = 0;

class PizzaPagePopup extends StatefulWidget {
  const PizzaPagePopup({super.key});

  @override
  State<PizzaPagePopup> createState() => _PizzaPagePopupState();
}

class _PizzaPagePopupState extends State<PizzaPagePopup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundcolor,
      appBar: AppBar(
        title: const Text(
          '피자 선택',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () async{
                  if (pizza1 != null && pizza2 != null) {
                    Navigator.pop(
                      context,
                    );
                    setState(() {
                      selectedSlot = 0;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('두 피자를 모두 선택해주세요!'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "선택 완료",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 200,
            bottom: 90,
            child: ListView(
              padding: EdgeInsets.zero,
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
                    pizzaList[i]['diameter'] as double,
                  ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              height: 200,
              color: backgroundcolor,
              child: Hero(
                tag: 'pizza-select',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (selectedSlot == 1) {
                          setState(() {
                            selectedSlot = 0;
                          });
                        } else {
                          setState(() {
                            selectedSlot = 1;
                          });
                        }
                      },
                      child: Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: selectedSlot == 1
                              ? Border.all(color: Colors.purple, width: 5)
                              : Border.all(
                                  color: Colors.purple.withAlpha(100),
                                  width: 2,
                                ),
                        ),
                        child: pizza1 == null
                            ? const Center(child: Icon(Icons.add))
                            : Center(
                                child: Image.asset(
                                  pizza1!['thumbnail'] as String,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 30),
                    GestureDetector(
                      onTap: () {
                        if (selectedSlot == 2) {
                          setState(() {
                            selectedSlot = 0;
                          });
                        } else {
                          setState(() {
                            selectedSlot = 2;
                          });
                        }
                      },
                      child: Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: selectedSlot == 2
                              ? Border.all(color: Colors.purple, width: 5)
                              : Border.all(
                                  color: Colors.purple.withAlpha(100),
                                  width: 2,
                                ),
                        ),
                        child: pizza2 == null
                            ? const Center(child: Icon(Icons.add))
                            : Center(
                                child: Image.asset(
                                  pizza2!['thumbnail'] as String,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
    double diameter,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: GestureDetector(
            onTap: () {
              if (selectedSlot == 1) {
                setState(() {
                  pizza1 = {
                    'thumbnail': thumbnail,
                    'name': name,
                    'size': size,
                    'area': area,
                    'price': price,
                    'diameter': diameter,
                  };
                });
              } else if (selectedSlot == 2) {
                setState(() {
                  pizza2 = {
                    'thumbnail': thumbnail,
                    'name': name,
                    'size': size,
                    'area': area,
                    'price': price,
                    'diameter': diameter,
                  };
                });
              }
            },
            child: Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(90),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: Image.asset(
                          thumbnail,
                          width: 84,
                          height: 84,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '사이즈: $size, 지름: ${diameter.toStringAsFixed(1)}cm, 면적: ${area}cm²\n가격: $price원',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600]!,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
      ],),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
