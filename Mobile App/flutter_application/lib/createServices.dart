import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class Tag {
  final String name;

  Tag({required this.name});

  factory Tag.fromJson(String json) {
    return Tag(
      name: json,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Tag> _tags = [];
  List<Widget> _tagButtons = [];
  List<Widget> _selectedTagButtons = [];

  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _imageLinkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTags();
  }

  Future<void> _fetchTags() async {
    final response = await http
        .get(Uri.parse('https://streetsync.azurewebsites.net/services/tags'));

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
      onPressed: () {
        setState(() {
          _tagButtons.removeWhere((button) =>
              button.key.toString() ==
              Key(tag.name)
                  .toString()); // Retirer le bouton de la liste des boutons de tag disponibles
          _selectedTagButtons.add(_buildSelectedTagButton(
              tag)); // Ajouter le bouton à la liste des boutons de tag sélectionnés
        });
      },
      key: Key(tag.name), // Clé unique pour identifier le bouton
      child: Text(tag.name),
    );
  }

  Widget _buildSelectedTagButton(Tag tag) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedTagButtons.removeWhere((button) =>
              button.key.toString() ==
              Key(tag.name)
                  .toString()); // Retirer le bouton de la liste des boutons de tag sélectionnés
          _tagButtons.add(_buildTagButton(
              tag)); // Ajouter le bouton à la liste des boutons de tag disponibles
        });
      },
      key: Key(tag.name), // Clé unique pour identifier le bouton
      child: Text(tag.name),
    );
  }

  void _sendData() async {
    final name = _nameController.text;
    final description = _descriptionController.text;
    final price = double.tryParse(_priceController.text) ?? 0;
    final imageLink = _imageLinkController.text;
    final tags = [];
    _selectedTagButtons.forEach((element) {
      tags.add(element.key
          .toString()
          .substring(3, element.key.toString().length - 3));
    }); // Obtenez les noms des tags à partir des clés des boutons

    final jsonData = {
      "name": name,
      "description": description,
      "tags": tags,
      "price": price,
      "imageLink": imageLink,
    };

    final String tokenName = 'martin'; // Le nom de la variable pour le token
    //fait en sorte de mettre le token que tu as récuperer du login
    final String token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiMTcxNTM3NTU0NzUxNSIsImlhdCI6MTcxNTM3NTU5NSwiZXhwIjoxNzE1NDYxOTk1fQ.anLaA_LAg4mGcIO-pJzg6VWy4hd4kYJMO99H8UQ7kZs'; // Le token lui-même

    final response = await http.post(
      Uri.parse('https://streetsync.azurewebsites.net/services/createone'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':
            '$tokenName $token', // Utilisation du nom de la variable et du token
      },
      body: jsonEncode(jsonData),
    );

    if (response.statusCode == 200) {
      // La requête a réussi
      print('Data sent successfully');
    } else {
      // La requête a échoué
      throw Exception('Failed to send data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Tag'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _tagButtons,
              ),
              const SizedBox(height: 16.0),
              Text('Selected Tags:'),
              const SizedBox(height: 8.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _selectedTagButtons,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9]')), // Accepter uniquement les chiffres
                ],
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _imageLinkController,
                decoration: InputDecoration(
                  labelText: 'Image Link',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _sendData,
                child: Text('Create a new service'),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
