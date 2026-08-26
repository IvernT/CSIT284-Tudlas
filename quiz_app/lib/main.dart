import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 81, 6, 131),
                const Color.fromARGB(255, 81, 7, 131),
              ],
            ),
          ),
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 100),
                Image.asset(width: 300,"assets/logo.png"),
                SizedBox(height: 60),  
                Text(
                  style: TextStyle(fontSize: 22, color: Colors.white),
                  "Learn Flutter the fun way!",
                ),
                SizedBox(height: 30),
                TextButton(
                  onPressed: () {},
                  child: Text(style: TextStyle(fontSize: 18, color: Colors.white
                  ), "Start Quiz"),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
