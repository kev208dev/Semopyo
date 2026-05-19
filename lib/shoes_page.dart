import 'package:flutter/material.dart';
import 'package:semopyo/color_set.dart';
import 'dart:ui';
import 'shoe_card_widgets.dart';
import 'sneaker_api.dart';

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
      appBar: AppBar(
        title: Text("👟"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              height: 50,
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF333333),
                    foregroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.search), Text('Search')],
                  ),
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.black,
                  size: 40,
                ),
                MainShoeCard(
                  brand: "Nike",
                  name: "Air Force 1` 07",
                  price: "129,000",
                  thumbnail: "assets/images/nike-airforce107.png",
                  color: white,
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.black,
                  size: 40,
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(width: 10),
                Icon(Icons.compare_arrows, color: Colors.black, size: 30),

                Expanded(
                  child: SizedBox(
                    height: 200,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        SubShoeCard(
                          brand: "Nike",
                          name: "Air Force 1` 07",
                          price: "129,000",
                          thumbnail: "assets/images/nike-airforce107.png",
                          color: white,
                        ),
                      ],
                    ),
                  ),
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
