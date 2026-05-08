import 'package:flutter/material.dart';
import 'main.dart';

class PizzaPagePopup extends StatelessWidget {
  const PizzaPagePopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundcolor,
      appBar: AppBar(title: Text('피자 선택')),
      body: Column(
        children: [
          SizedBox(height: 20,),
          pizzaPlusCircle(),
          
        ]
      )
    );
  }
}
