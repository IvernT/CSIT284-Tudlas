import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              const Color.fromARGB(255, 182, 28, 17),
              Colors.yellow
            ])
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  width: 200,'assets/dice-images/dice-2.png'),
                  SizedBox(height: 30),
                TextButton(onPressed: () {}, child: Text(
                  style: TextStyle(
                    fontSize: 28),"Roll Dice")),
              ],
            )
            )
        ),
      ),
    ),
  );
}
