import 'package:flutter/material.dart';

class CreateButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final Color bgColor;

  const CreateButton({super.key, required this.onPressed, required this.title, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(327, 50),
        backgroundColor: bgColor,
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(title, style: const TextStyle(color: Colors.black54),),
    );
  }
}