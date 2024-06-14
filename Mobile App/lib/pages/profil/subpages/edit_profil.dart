import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:street_sync/pages/navbar.dart';
import 'package:street_sync/utils/api_endpoints.dart';

class EditProfil extends StatefulWidget {
  const EditProfil({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EditProfil createState() => _EditProfil();
}

class _EditProfil extends State<EditProfil> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  //final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  

   void _sendData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    final Map<String, dynamic> jsonData = {};
    if (firstName.isNotEmpty) {
      jsonData["firstname"] = firstName;
    } if (lastName.isNotEmpty) {
      jsonData["name"] = lastName;
    } if (email.isNotEmpty) {
      jsonData["email"] = email;
    } if (password.isNotEmpty) {
      jsonData["password"] = password;
    }

    final response = await http.patch(
      Uri.parse(ApiEndpoints.endPoints.users),

      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'martin $token',
      },
      body: jsonEncode(jsonData),
    );

    if (response.statusCode == 200) {
     /*if (firstName.isNotEmpty) {
        final json = jsonDecode(response.body);

        var token = json['token'];
        var message = json['message'];

        var commaIndex = message.indexOf(',');
        var connectedIndex = message.indexOf('connected');

        var name = message.substring(commaIndex + 2, connectedIndex - 1);

        final SharedPreferences  prefs = await _prefs;
        await prefs.setString('token', token);
        await prefs.setString('name', name);
      }*/

      Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => const NavBarPage(),
          )
        );
    } else {
      throw Exception('Failed to send data');
    }
  }

  void _deleteUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.delete(
      Uri.parse(ApiEndpoints.endPoints.users),

      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'martin $token',
      }
    );

    if (response.statusCode == 200) {
      Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => const NavBarPage(),
          )
        );
    } else {
      throw Exception('Failed to send data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: 
          () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text(
          'Update your profil',
          style: TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Center(
                child: Icon(
                  Icons.people_rounded,
                  size: 100,
                ),
              ),
              const SizedBox( height: 30),
              Form(
                child: Column(
                  children: [
                    _textInput(
                      "First Name", 
                      const Icon(Icons.drive_file_rename_outline, color: Colors.black),
                      _firstNameController,
                      false
                    ),
                    const SizedBox(height: 20,),
                    _textInput(
                      "Last Name", 
                      const Icon(Icons.drive_file_rename_outline, color: Colors.black),
                      _lastNameController,
                      false
                    ),
                    const SizedBox(height: 20,),
                    _textInput(
                      "E-Mail", 
                      const Icon(Icons.email, color: Colors.black),
                      _emailController,
                      false
                    ),
                    const SizedBox(height: 20,),
                    _textInput(
                      "Password", 
                      const Icon(Icons.password, color: Colors.black),
                      _passwordController,
                      true
                    ),
                    const SizedBox(height: 40,),

                    SizedBox(
                      width: 250,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _sendData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, side: BorderSide.none, shape: const StadiumBorder()
                        ),
                        child: const Text(
                          "Edit Profile", 
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: _deleteUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.withOpacity(0.1), 
                            elevation: 0,
                            foregroundColor: Colors.red,
                            shape: const StadiumBorder(),
                            side: BorderSide.none
                          ),
                          child: const Text("Delete Account"),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      )
    );
  }

  Widget _textInput(String label, Icon icon, TextEditingController controller, bool isPassword) {
    
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100)
        ),
        prefixIconColor: Colors.black,
        floatingLabelStyle: const TextStyle(color: Colors.black),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: const BorderSide(width: 2, color: Colors.black54)
        ),
        label: Text(label),
        prefixIcon: icon
      ),
    );
  }
}