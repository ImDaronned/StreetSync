import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;

  const SubmitButton({super.key, required this.onPressed, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(borderRadius:  BorderRadius.circular(20), boxShadow: [
        BoxShadow(
          color: Colors.white.withOpacity(0.25),
          offset: const Offset(0, 0),
          blurRadius: 2,
          spreadRadius: 1
        )
      ]),
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide.none
            )
          ),
          backgroundColor: MaterialStateProperty.all<Color>(
            Colors.black,
          )
        ),
        onPressed: onPressed,
        child: Text(title,
        style: const TextStyle(
          fontSize: 24,
          color: Colors.white,
        )),
      ),
    );
  }
}


/**
    Padding(
    padding: const EdgeInsets.only(top: 50.0),
    child: Container(
    height: 60,
    width: 300,
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(30),
    gradient: const LinearGradient(
    colors: [
    Color(0xFFB81736),
    Color(0xFF281537),
    ]
    )
    ),
    child: Center(child: Text(title, style: const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: Colors.white,
    ),)),
    )
    );
 */