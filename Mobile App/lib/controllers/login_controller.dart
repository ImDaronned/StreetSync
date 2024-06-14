import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:street_sync/models/event.dart';
import 'package:street_sync/models/services.dart';
import 'package:street_sync/pages/navbar.dart';
import 'package:street_sync/utils/api_endpoints.dart';
import 'package:http/http.dart' as http;

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> login() async {
    try {
      bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if(!serviceEnabled){
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if(permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');

        }
      }

      if(permission == LocationPermission.deniedForever) {
        return Future.error('Location permissions are permanently denied, we cannot request permissions.');
      }

      Position location = await Geolocator.getCurrentPosition();
      
      print(location);

      var headers = { 'Content-Type': 'application/json' };
      var url = Uri.parse( ApiEndpoints.endPoints.login );

      Map body = {
        "email": emailController.text.trim(),
        "password": passwordController.text,
        "coord": "45.8150108-15.981919"
      };

      http.Response response =
      await http.post(url, body: jsonEncode(body), headers: headers);
      print(response.body);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        var token = json['token'];
        var message = json['message'];

        var commaIndex = message.indexOf(',');

        var name = message.substring(0, commaIndex);

        final SharedPreferences  prefs = await _prefs;
        await prefs.setString('token', token);
        await prefs.setString('name', name);
        await prefs.setString('email', emailController.text);
        print("$token $name ${emailController.text}");

        //await Services.generateServices(false);
        print("services generate");
        await Event.generateEvent(false);
        print("events generate");

        emailController.clear();
        passwordController.clear();
        Get.off(const NavBarPage());

      } else {
        throw jsonDecode(response.body)["error"];
      }
    } catch (err) {
      Get.back();
      showDialog(
          context: Get.context!,
          builder: (context) {
            return SimpleDialog(
              title: const Text('Error'),
              contentPadding: const EdgeInsets.all(20),
              children: [Text(err.toString())],
            );
          });
    }
  }
}