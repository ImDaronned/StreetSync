import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:street_sync/models/services.dart';
import 'package:street_sync/pages/profil/subpages/services/service_modifying.dart';

class MyServicePage extends StatelessWidget {
  const MyServicePage({super.key});

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
          'Your services',
          style: TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: _serviceList()
    );
  }

  Widget _serviceList() {
    return FutureBuilder<List<Services>>(
      future: Services.generateServices(true), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.only(top: 10, left: 10),
            child: const CircularProgressIndicator()
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<Services> serviceList = snapshot.data ?? [];
          
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: serviceList.length,
            itemBuilder: (context, index) => _buildEventCard(context, serviceList[index]),
          );
        }
      }
    );
  }

  Widget _buildEventCard(BuildContext context, Services service) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ModifyMySercice(service: service),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${service.price}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ModifyMySercice(service: service),
                          ),
                        );
                      },
                      child: const Text("Modify my service"),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}