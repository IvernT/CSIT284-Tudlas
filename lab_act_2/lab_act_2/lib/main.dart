import 'package:flutter/material.dart';
import 'package:lab_act_2/dice_roller.dart';

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
            child: DiceRoller()
            )
        ),
      ),
    ),
  );
}
