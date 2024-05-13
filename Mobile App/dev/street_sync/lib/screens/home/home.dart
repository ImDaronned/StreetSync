import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:street_sync/screens/auth/auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        TextButton(
          onPressed:  () async {
            final SharedPreferences prefs = await _prefs;
            prefs.clear();
            Get.offAll(const AuthScreen());
          },
          child: const Text(
            "Logout",
            style: TextStyle(color: Colors.white),
          ))
      ]),
      body: Center(
        child: Column(
          children: [
            const Text("Home"),
            TextButton(
              onPressed: () async {
                //final SharedPreferences prefs = await _prefs;
              }, 
              child: const Text('Print token'))
          ],
        ),
      ),
    );
  }
}