import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:street_sync/screens/auth/auth_screen.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:street_sync/utils/api_endpoints.dart';
import 'package:http/http.dart' as http;

class RegistrationController extends GetxController {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> register() async {
    try {
      var headers = { 'Content-Type': 'application/json' };
      var url = Uri.parse(
        ApiEndpoints.baseUrl + ApiEndpoints.authEndPoints.register
      );

      Map body = {
        "firstname": firstNameController.text,
        "name": nameController.text,
        "email": emailController.text.trim(),
        "password": passwordController.text
      };

      http.Response response =
          await http.post(url, body: jsonEncode(body), headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json['registered']) {
            firstNameController.clear();
            nameController.clear();
            emailController.clear();
            passwordController.clear();

            Get.off(const AuthScreen());
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