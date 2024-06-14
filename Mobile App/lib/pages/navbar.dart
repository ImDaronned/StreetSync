import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:street_sync/pages/auth/auth_screen.dart';
import 'package:street_sync/pages/favorite/reserved.dart';

import 'package:street_sync/pages/search/search.dart';
import 'package:street_sync/pages/create/create.dart';
import 'package:street_sync/pages/home/home.dart';
import 'package:street_sync/pages/profil/profil.dart';

class NavBarPage extends StatefulWidget {
  const NavBarPage({super.key});

  @override
  State<NavBarPage> createState() => _NavBarPageState();
}

class _NavBarPageState extends State<NavBarPage> {
  late Future<SharedPreferences> _prefs;
  int index = 0;

  @override
  void initState() {
    super.initState();
    _prefs = SharedPreferences.getInstance();
  }

  final items = <Widget>[
    const Icon(Icons.home, size: 30,),
    const Icon(Icons.calendar_today_outlined, size: 30,),
    const Icon(Icons.search, size: 30,),
    const Icon(Icons.add, size: 30,),
    const Icon(Icons.people, size: 30,)
  ];

  final screens = [
    const HomePage(),
    const ReservedPage(),
    const SearchPage(),
    const CreatePage(),
    const ProfilPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.red,
      appBar: _buildAppBar(),
      body: screens[index],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          iconTheme: IconThemeData(color: Colors.grey.shade500)
        ),
        child: CurvedNavigationBar(
          items: items,
          height: 60,
          backgroundColor: Colors.transparent,
          color: Colors.grey.shade200,
          onTap: (index) => setState(() => this.index = index),
        ),
      )
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: FutureBuilder(
        future: _prefs,
        builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            final SharedPreferences prefs = snapshot.data!;
            final String? name = prefs.getString('name');
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                'Hi, ${name ?? "Mathéo"}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: InkWell(
            onTap: () async {
              final SharedPreferences prefs = await _prefs;
              prefs.clear();
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthPage()),
                (Route<dynamic> route) => false,
              );
            },
            child: const SizedBox(
              width: 50,
              height: 50,
              child: Icon(
                Icons.logout,
                color: Colors.black,
              )
            )
          )
        )
      ],
    );
  }
}