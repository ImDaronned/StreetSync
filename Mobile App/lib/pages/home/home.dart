import 'package:flutter/material.dart';

import 'package:street_sync/pages/home/widgets/events/event_list.dart';
import 'package:street_sync/pages/home/widgets/landing.dart';
import 'package:street_sync/pages/home/widgets/services/services_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            const Landing(),
            const Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                'Events',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: SizedBox(
                height: 235,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: EventList()
                )
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                'Services',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: SizedBox(
                height: 260,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ServiceList()
                )
              ),
            ),
            const SizedBox(height: 150,)
          ],
        )
      ),
    );
  }
}