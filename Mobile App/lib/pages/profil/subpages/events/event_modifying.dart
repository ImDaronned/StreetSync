import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:street_sync/models/event.dart';
import 'package:street_sync/pages/create/widget/button.dart';
import 'package:street_sync/pages/navbar.dart';
import 'package:street_sync/utils/api_endpoints.dart';
import 'package:street_sync/models/tags.dart';
import 'package:http/http.dart' as http;

class ModifyMyEvent extends StatefulWidget {
  final Event event;

  const ModifyMyEvent({super.key, required this.event});

  @override
  State<ModifyMyEvent> createState() => _ModifyMyEventState();
}

class _ModifyMyEventState extends State<ModifyMyEvent> {
  List<Tag> _tags = [];
  List<Widget> _tagButtons = [];
  final List<Widget> _selectedTagButtons = [];
  DateTime? _selectedDate;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageLinkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTags();
  }

  Future<void> _fetchTags() async {
    final response = await http
        .get(Uri.parse(ApiEndpoints.endPoints.eventsTags));

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

  Widget _buildDateInput() {
    return TextFormField(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (picked != null && picked != _selectedDate) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
      readOnly: true,
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
        label: const Text('Date'),
        prefixIcon: const Icon(Icons.calendar_month)
      ),
      controller: TextEditingController(
        text: _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : '',
      ),
    );
  }

  void _sendData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final name = _nameController.text;
    final description = _descriptionController.text;
    final date = _selectedDate != null ? _selectedDate!.toString().substring(0, 10) : '';
    final imageLink = _imageLinkController.text;
    final tags = [];
    for (var element in _selectedTagButtons) {
      tags.add(element.key
          .toString()
          .substring(3, element.key.toString().length - 3));
    }

    final Map<String, dynamic> jsonData = {};
  
    if (name.isNotEmpty) {
      jsonData["name"] = name;
    } if (description.isNotEmpty) {
      jsonData["description"] = description;
    } if (date.isNotEmpty) {
      jsonData["date"] = date;
    } if (tags.isNotEmpty) {
      jsonData["tags"] = tags;
    } if (imageLink.isNotEmpty) {
      jsonData["imageLink"] = imageLink;
    }

    final response = await http.patch(
      Uri.parse('${ApiEndpoints.endPoints.events}?id=${widget.event.id}'),

      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':
        'name $token',
      },
      body: jsonEncode(jsonData),
    );

    if (response.statusCode == 200) {
      await Event.generateEvent(false);
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

  void _deleteEvent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.delete(
      Uri.parse('${ApiEndpoints.endPoints.events}?id=${widget.event.id}'),

      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':
        'name $token',
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
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: 
          () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text(
          'Modify my event',
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
          child: Form( child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 150,
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.edit,
                            color: Colors.black,
                            size: 20,
                            ),
                          SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Instructions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black
                                ),
                              ),
                              SizedBox(height: 8),
                              Text('Please just fill the fields that\n you want to modify',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54
                                  ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                )
              ),
              const SizedBox(height: 30.0),
              _textInput(
                "Name",
                const Icon(Icons.people),
                _nameController
              ),
              const SizedBox(height: 16.0),
              _textInput(
                "Description",
                const Icon(Icons.description),
                _descriptionController
              ),
              const SizedBox(height: 16.0),
              _buildDateInput(),
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
                _imageLinkController
              ),
              const SizedBox(height: 50.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CreateButton(
                    onPressed: _sendData, 
                    title: 'Modify my event',
                    bgColor: Colors.blueAccent.withOpacity(0.3),
                  ),
                ],
              ),
              const SizedBox(height: 30.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _deleteEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.1), 
                      elevation: 0,
                      foregroundColor: Colors.red,
                      shape: const StadiumBorder(),
                      side: BorderSide.none
                    ),
                    child: const Text("Delete event"),
                  )
                ],
              )
            ],
          )),
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