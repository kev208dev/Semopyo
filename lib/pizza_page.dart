import 'package:flutter/material.dart';
import 'cellfunc.dart';
import 'pizza_data.dart';
import 'pizza_page_popup.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic>? pizza1 = null;
Map<String, dynamic>? pizza2 = null;

const backgroundcolor = Colors.black;

class PizzaPage extends StatefulWidget {
  const PizzaPage({super.key});

  @override
  State<PizzaPage> createState() => _PizzaPageState();
}

class _PizzaPageState extends State<PizzaPage> {
  @override
  void initState() {
    super.initState();
    loadPizzaData();
  }

  Future<void> loadPizzaData() async {
    final prefs = await SharedPreferences.getInstance();

    final pizza1String = prefs.getString('pizza1');
    final pizza2String = prefs.getString('pizza2');

    setState(() {
      if (pizza1String != null) {
        pizza1 = Map<String, dynamic>.from(jsonDecode(pizza1String));
      }

      if (pizza2String != null) {
        pizza2 = Map<String, dynamic>.from(jsonDecode(pizza2String));
      }
    });
  }

  double pizzaArea(Map<String, dynamic>? pizza) {
    if (pizza == null) {
      return 0;
    }

    final diameter = pizza['diameter'] as double;
    final radius = diameter / 2;
    return radius * radius * 3.14;
  }

  double pricePerSlice(Map<String, dynamic>? pizza) {
    if (pizza == null) {
      return 0;
    }

    return (pizza['price'] as int) / 8;
  }

  String biggerPizzaText() {
    if (pizza1 == null || pizza2 == null) {
      return '피자 미선택';
    }

    final pizza1Area = pizzaArea(pizza1);
    final pizza2Area = pizzaArea(pizza2);

    if (pizza1Area > pizza2Area) {
      return '${pizza1!['name']}가 더 큽니다!';
    } else if (pizza2Area > pizza1Area) {
      return '${pizza2!['name']}가 더 큽니다!';
    } else {
      return '두 피자의 크기가 같습니다!';
    }
  }

  String areaCompareText() {
    if (pizza1 == null || pizza2 == null) {
      return '두 피자를 모두 선택해주세요.';
    }

    final pizza1Area = pizzaArea(pizza1);
    final pizza2Area = pizzaArea(pizza2);

    if (pizza1Area == pizza2Area) {
      return '${pizza1!['name']}와 ${pizza2!['name']}의 면적은 같습니다.';
    }

    final biggerPizza = pizza1Area > pizza2Area ? pizza1 : pizza2;
    final smallerPizza = pizza1Area > pizza2Area ? pizza2 : pizza1;
    final biggerArea = pizza1Area > pizza2Area ? pizza1Area : pizza2Area;
    final smallerArea = pizza1Area > pizza2Area ? pizza2Area : pizza1Area;
    final percent = ((biggerArea - smallerArea) / smallerArea) * 100;

    return '${biggerPizza!['name']}은 ${smallerPizza!['name']}보다 약 ${percent.toStringAsFixed(1)}% 더 넓습니다.';
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '🍕',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
      ),

      body: Container(
        decoration: BoxDecoration(
          color: backgroundcolor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            width: 150,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "첫번째 피자",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  "${pizza1 != null ? pizza1!['name'] : '피자 미선택'}",
                                  style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  "${pizza1 != null ? '${pizza1!['size']}사이즈' : ''}",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: const Text(
                                "VS",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            width: 150,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  blurRadius: 8,
                                  offset: Offset(4, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "두 번째 피자",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  "${pizza2 != null ? pizza2!['name'] : '피자 미선택'}",
                                  style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  "${pizza2 != null ? '${pizza2!['size']}사이즈' : ''}",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "지름: ${pizza1 != null ? '${pizza1!['diameter']}cm' : '피자 미선택'}",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 130),
                          Text(
                            "지름: ${pizza2 != null ? '${pizza2!['diameter']}cm' : '피자 미선택'}",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Hero(
                        tag: 'pizza-select',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.purple[400]!,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: pizza1 == null
                                    ? Icon(Icons.add)
                                    : Image.asset(
                                        pizza1!['thumbnail'] as String,
                                      ),
                              ),
                            ),
                            SizedBox(width: 80),
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.purple[400]!,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: pizza2 == null
                                    ? Icon(Icons.add)
                                    : Image.asset(
                                        pizza2!['thumbnail'] as String,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        height: 250,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 3,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                biggerPizzaText(),
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                areaCompareText(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 5),
                              Table(
                                columnWidths: {
                                  0: FlexColumnWidth(2.2),
                                  1: FlexColumnWidth(3),
                                  2: FlexColumnWidth(3),
                                },
                                border: TableBorder.all(
                                  color: Colors.black,
                                  width: 3,
                                ),
                                children: [
                                  oneline(
                                    '면적',
                                    '${pizzaArea(pizza1).toStringAsFixed(1)}cm²',
                                    '${pizzaArea(pizza2).toStringAsFixed(1)}cm²',
                                  ),
                                  oneline(
                                    '가격',
                                    '${pizza1 != null ? '${pizza1!['price']}원' : '0원'}',
                                    '${pizza2 != null ? '${pizza2!['price']}원' : '0원'}',
                                  ),
                                  oneline(
                                    '조각 당 가격',
                                    '${pricePerSlice(pizza1).toStringAsFixed(0)}원/조각',
                                    '${pricePerSlice(pizza2).toStringAsFixed(0)}원/조각',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      fullscreenDialog: true,
                                      builder: (context) => PizzaPagePopup(),
                                    ),
                                  );

                                  setState(() {});
                                },

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black87,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  "피자 선택하기",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
