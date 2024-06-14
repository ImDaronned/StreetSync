import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:street_sync/controllers/validator.dart';
import 'package:street_sync/pages/auth/auth_screen.dart';
import 'package:street_sync/utils/api_endpoints.dart';
import 'package:http/http.dart' as http;

class RegistrationController extends GetxController {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> register(BuildContext context) async {
    try {
      var headers = { 'Content-Type': 'application/json' };
      var url = Uri.parse(ApiEndpoints.endPoints.register);
      print("register");

      var msg = Validator.emailValidator(emailController.text);
      if(msg != '') {
        showDialog(
          context: context, 
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Email Error"),
              content: Text("$msg: should be example@gmail.com"),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ); 
          }
        );
      }

      var msgPassword = Validator.passwordValidator(passwordController.text);
      if(msgPassword != '') {
        showDialog(
          context: context, 
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Email Error"),
              content: Text(msgPassword),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ); 
          }
        );
      }

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

          Get.off(const AuthPage());
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