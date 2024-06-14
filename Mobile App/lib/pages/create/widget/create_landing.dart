import 'package:flutter/material.dart';

class CreateLanding extends StatelessWidget {
  const CreateLanding({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blueAccent.withOpacity(0.4),
                  Colors.greenAccent.withOpacity(0.4)
                ]
              ),
              borderRadius: BorderRadius.circular(20)
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.create,
                  color: Colors.black,
                  size: 20,
                  ),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create Section',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Please choose wich one you want\n to create',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54
                        ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      )
    );
  }
}