import 'package:flutter/material.dart';
import 'package:street_sync/models/services.dart';
import 'package:street_sync/pages/home/widgets/services/service_detail.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchPage createState() => _SearchPage();
}

class _SearchPage extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<Services>> servicesFuture = Services.loadServicesFromPreferences();
  List<Services> servicesList = [];
  List<Services> filteredServices = [];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  void _loadServices() async {
    servicesList = await servicesFuture;
    setState(() {
      filteredServices = servicesList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(20),
            child: _textInput("Search", const Icon(Icons.search, color: Colors.black), _searchController)
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredServices.length,
              itemBuilder: (context, index) {
                final service = filteredServices[index];

                return ListTile(
                  leading: Image.network(
                    service.imageLink,
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                  ),
                  title: Text(service.title),
                  subtitle: Text(service.owner),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceDetailPage(service: service),
                      )
                    );
                  },
                );
              },
            )
          )
        ],
      )
    );
  }

  Widget _textInput(String label, Icon icon, TextEditingController controller) {
    return TextField(
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
      onChanged: search,
    );
  }

  void search(String query) {
    final suggestions = servicesList.where((service) {
      final serviceTitle = service.title.toLowerCase();
      final input = query.toLowerCase();

      return serviceTitle.contains(input);
    }).toList();

    setState(() {
      filteredServices = suggestions;
    });
  }
}