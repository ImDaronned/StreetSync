import 'package:flutter/material.dart';
import 'package:street_sync/pages/create/subpages/create_event.dart';
import 'package:street_sync/pages/create/subpages/create_service.dart';
import 'package:street_sync/pages/create/widget/button.dart';
import 'package:street_sync/pages/create/widget/create_landing.dart';

class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 10,),
          const CreateLanding(),
          const SizedBox(height: 50,),
          CreateButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateEventPage()),
              );
            },
            title: "Create Event",
            bgColor: Colors.blueAccent.withOpacity(0.3),
          ),
          const SizedBox(height:20,),
          CreateButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateServicePage()),
              );
            },
            title: "Create Service",
            bgColor: Colors.greenAccent.withOpacity(0.3),
          )
        ],
      )
    );
  }
}