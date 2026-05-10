import 'package:flutter/material.dart';
import 'cellfunc.dart';
import 'pizza_data.dart';
import 'pizza_page_popup.dart';

const backgroundcolor = Color(0xFFece6cc);
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Semopyo',
      theme: ThemeData(),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Semopyo',
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "세모표",
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(Icons.change_history, size: 50),
                              ],
                            ),
                            Icon(Icons.settings, size: 35),
                          ],
                        ),
                        Text(
                          "세상 모든 크기의 표준",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    "${dominoPizza['name']}",
                                    style: TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    "${dominoPizza['size']}사이즈",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
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
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    "${pizzaHutPizza['name']}",
                                    style: TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    "${pizzaHutPizza['size']}사이즈",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
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
                              "지름: 33cm",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 130),
                            Text(
                              "지름: 31cm",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
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
                                child: Center(child: Icon(Icons.add)),
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
                                child: Center(child: Icon(Icons.add)),
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
                                  "${dominoPizza['name']}가 더 큽니다!",
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "${dominoPizza['name']}은 ${pizzaHutPizza['name']}보다 약 ${((((dominoPizza['diameter'] as double) * (dominoPizza['diameter'] as double) * 3.14 - (pizzaHutPizza['diameter'] as double) * (pizzaHutPizza['diameter'] as double)) / (pizzaHutPizza['diameter'] as double) * (pizzaHutPizza['diameter'] as double)) * 100).toStringAsFixed(1)}% 더 넓습니다.",
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
                                      '${((dominoPizza['diameter'] as double) * (dominoPizza['diameter'] as double) * 3.14).toStringAsFixed(1)}cm²',
                                      '${((pizzaHutPizza['diameter'] as double) * (pizzaHutPizza['diameter'] as double) * 3.14).toStringAsFixed(1)}cm²',
                                    ),
                                    oneline(
                                      '가격',
                                      '${dominoPizza['price']}원',
                                      '${pizzaHutPizza['price']}원',
                                    ),
                                    oneline(
                                      '면적 당 가격',
                                      '${((dominoPizza['price'] as int) / (((dominoPizza['diameter'] as double) / 2) * ((dominoPizza['diameter'] as double) / 2) * 3.14)).toStringAsFixed(1)}원/cm²',
                                      '${((pizzaHutPizza['price'] as int) / (((pizzaHutPizza['diameter'] as double) / 2) * ((pizzaHutPizza['diameter'] as double) / 2) * 3.14)).toStringAsFixed(1)}원/cm²',
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
                              padding: const EdgeInsets.symmetric(
                                vertical: 20.0,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        fullscreenDialog: true,
                                        builder: (context) => PizzaPagePopup(),
                                      ),
                                    );
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
                                    "다른 피자 비교하러 가기",
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

                        // 추가 ......
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
