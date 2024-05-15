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
                height: 235,
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



/*

return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30)
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 10
          )
        ]
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30)
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: Colors.black54,
          unselectedItemColor: Colors.grey.withOpacity(0.5),
          items: const [
            BottomNavigationBarItem(
              label: 'Home',
              icon: Icon(Icons.home_rounded,
              size: 30)),
            BottomNavigationBarItem(
              label: 'Liked',
              icon: Icon(Icons.favorite,
              size: 30)),
            BottomNavigationBarItem(
              label: "",
              icon: SizedBox.shrink()),
            BottomNavigationBarItem(
              label: 'Home',
              icon: Icon(Icons.credit_card,
              size: 30)),
            BottomNavigationBarItem(
              label: 'Profile',
              icon: Icon(Icons.person_rounded,
              size: 30))
          ],
          onTap: (int index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AuthPage())
              );
            }
          },
        )
      ),
    );

*/