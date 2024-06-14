import 'package:flutter/material.dart';

class Landing extends StatelessWidget {
  const Landing({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return Container(
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
                  Icons.thumb_up,
                  color: Colors.black,//Colors.blueAccent,
                  size: 20,
                  ),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Thanks for using Street Sync',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black//Colors.blueAccent
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Building neighborhoods where \nsolidarity is a two-way street.',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54//Color.fromARGB(110, 24, 104, 242))
                        ),
                    )
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