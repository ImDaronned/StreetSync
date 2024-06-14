import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:street_sync/models/services.dart';
import 'package:street_sync/pages/create/widget/button.dart';
import 'package:street_sync/pages/navbar.dart';
import 'package:street_sync/utils/api_endpoints.dart';
import 'package:street_sync/models/tags.dart';

class CreateServicePage extends StatefulWidget {
  const CreateServicePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateServicePage createState() => _CreateServicePage();
}

class _CreateServicePage extends State<CreateServicePage> {

  List<Tag> _tags = [];
  List<Widget> _tagButtons = [];
  final List<Widget> _selectedTagButtons = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageLinkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTags();
  }

  Future<void> _fetchTags() async {
    final response = await http
        .get(Uri.parse(ApiEndpoints.endPoints.serviceTags));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      setState(() {
        _tags = responseData.map((tagData) => Tag.fromJson(tagData)).toList();
        _tagButtons = _tags.map((tag) => _buildTagButton(tag)).toList();
      });
    } else {
      throw Exception('Failed to load tags');
    }
  }

  Widget _buildTagButton(Tag tag) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.black)
        )
      ),
      onPressed: () {
        setState(() {
          _tagButtons.removeWhere((button) =>
          button.key.toString() == Key(tag.name).toString()); // Retirer le bouton de la liste des boutons de tag disponibles
          _selectedTagButtons.add(_buildSelectedTagButton(tag)); // Ajouter le bouton à la liste des boutons de tag sélectionnés
        });
      },
      key: Key(tag.name),
      child: Text(tag.name, style: const TextStyle(color: Colors.black),),
    );
  }

  Widget _buildSelectedTagButton(Tag tag) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      onPressed: () {
        setState(() {
          _selectedTagButtons.removeWhere((button) =>
          button.key.toString() == Key(tag.name).toString());
          _tagButtons.add(_buildTagButton(tag));
        });
      },
      key: Key(tag.name),
      child: Text(tag.name, style: const TextStyle(color: Colors.white),),
    );
  }

  void _sendData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final name = _nameController.text;
    final description = _descriptionController.text;
    final price = int.tryParse(_priceController.text);
    final imageLink = _imageLinkController.text;
    final tags = [];
    for (var element in _selectedTagButtons) {
      tags.add(element.key
          .toString()
          .substring(3, element.key.toString().length - 3));
    }

    final jsonData = {
      "name": name,
      "description": description,
      "price": price,
      "tags": tags,
      "imageLink": imageLink,
    };

    final response = await http.post(
      Uri.parse(ApiEndpoints.endPoints.services),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'name $token',
      },
      body: jsonEncode(jsonData),
    );

    if (response.statusCode == 201) {
      await Services.generateServices(false);
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
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: 
          () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text(
          'Create a service',
          style: TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 30.0),
              _textInput(
                "Name",
                const Icon(Icons.description),
                _nameController,
              ),
              const SizedBox(height: 16.0),
              _textInput(
                "Description",
                const Icon(Icons.description),
                _descriptionController,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  label: const Text("Price"),
                  prefixIcon: const Icon(Icons.price_change)
                ),
              ),
              const SizedBox(height: 16.0),
              const Text('Tags:'),
              const SizedBox(height: 16.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _tagButtons,
              ),
              const SizedBox(height: 16.0),
              Text(_selectedTagButtons.isEmpty ? '' : 'Selected Tags:'),
              const SizedBox(height: 8.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _selectedTagButtons,
              ),
              const SizedBox(height: 16.0),
              _textInput(
                "Image Link",
                const Icon(Icons.link),
                _imageLinkController,
              ),
              const SizedBox(height: 50.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CreateButton(
                    onPressed: _sendData, 
                    title: 'Create service',
                    bgColor: Colors.greenAccent.withOpacity(0.3),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textInput(String label, Icon icon, TextEditingController controller) {
    
    return TextFormField(
      controller: controller,
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