import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:street_sync/screens/home/home.dart';
import 'package:street_sync/utils/api_endpoints.dart';
import 'package:http/http.dart' as http;

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> login() async {
    try {
      var headers = { 'Content-Type': 'application/json' };
      var url = Uri.parse(
        ApiEndpoints.baseUrl + ApiEndpoints.authEndPoints.login
      );

      Map body = {
        "email": emailController.text.trim(),
        "password": passwordController.text
      };

      http.Response response =
          await http.post(url, body: jsonEncode(body), headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json['token']) {
            var token = json['token'];


            final SharedPreferences  prefs = await _prefs;
            await prefs.setString('token', token);
            
            emailController.clear();
            passwordController.clear();
            Get.off(const HomeScreen());
        } else {
          throw jsonDecode(response.body)["error"];
        }
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