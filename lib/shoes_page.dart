import 'package:flutter/material.dart';
import 'package:semopyo/color_set.dart';
import 'package:semopyo/shoe_select_page.dart';
import 'dart:ui';
import 'shoe_card_widgets.dart';
import 'shoes_data.dart';

class _ShoesPageState extends State<ShoesPage> {
  List<ShoeModel> shoes = [];

  @override
  void initState() {
    super.initState();

    SneakerApiService().fetchShoes().then((value) {
      setState(() {
        shoes = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 45),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(width: 150),
                Icon(Icons.shopping_bag_outlined),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "현재 신고있는 신발을 선택해주세요.",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  "선택한 신발을 기준으로 새로운 신발의 체감사이즈를 제시합니다.",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 150,
              height: 50,
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: ElevatedButton(
                  onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ShoeSelectPage(),
                        ),
                      );
                    
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF333333),
                    foregroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.search), Text('선택하러 가기')],
                  ),
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MainShoeCard(
                  brand: "Nike",
                  name: "Air Force 1` 07",
                  price: "129,000",
                  thumbnail: "assets/images/nike-airforce107.png",
                  color: "white",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ShoesPage extends StatefulWidget {
  const ShoesPage({super.key});
  @override
  State<ShoesPage> createState() => _ShoesPageState();
}
