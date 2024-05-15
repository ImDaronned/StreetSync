import 'package:flutter/material.dart';
import 'package:street_sync/models/services.dart';
import 'package:street_sync/pages/home/widgets/services/service_detail.dart';

// ignore: use_key_in_widget_constructors
class ServiceList extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Services>>(
      future: Services.generateServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<Services> servicesList = snapshot.data ?? [];
          
          double totalWidth = (servicesList.length * 250 + 10);

          return SizedBox(
            width: totalWidth,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: servicesList.length,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 250 / 221
              ), 
              itemCount: servicesList.length,
              itemBuilder: (context, index) => _buildServiceCard(context, servicesList[index]),
            )
          );
        }
      },
    );
  }

  Widget _buildServiceCard(BuildContext context, Services service) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailPage(service: service),
          )
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10,),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x230f1113),
              blurRadius: 9,
              offset: Offset(0, 4)
            )
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 250,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15)
                ),
                image: DecorationImage(
                  image: NetworkImage('${service.imageLink}'),
                  fit: BoxFit.fill
                )
              ),
            ),
            const SizedBox(height: 10,),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        "${service.title}",
                        style: const TextStyle(
                          fontSize: 19,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        "Matheo",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 170),
              child: Container(
                width: 72,
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.3),                    
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Text(
                      "${service.price} EUR",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                )
              ),
            )
          ]
        )
      ),
    );
  }
}