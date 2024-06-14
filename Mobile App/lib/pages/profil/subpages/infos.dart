import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:street_sync/models/reservation.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text(
          'Informations',
          style: TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: _reservationList(),
    );
  }

  Widget _reservationList() {
    return FutureBuilder<List<Reservation>>(
      future: Reservation.generateReservation("?user=owner"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.only(top: 10, left: 10),
            child: const CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<Reservation> serviceList = snapshot.data ?? [];
          List<Reservation> acceptedReservations =
              serviceList.where((reservation) => reservation.accepted).toList();

          if (acceptedReservations.isEmpty) {
            return const Center(child: Text('You have no reservations for the moment'));
          } else {
            return ListView.builder(
              itemCount: acceptedReservations.length,
              itemBuilder: (context, index) {
                Reservation reservation = acceptedReservations[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      reservation.serviceName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${reservation.reservationDay.toLocal().toString().split(' ')[0]} at ${reservation.reservationDay.toLocal().toString().split(' ')[1].substring(0, 5)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () async {
                        try {
                          await reservation.declineReservation();
                          setState(() {});
                        } catch (e) {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to decline reservation: $e')),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            );
          }
        }
      },
    );
  }
}
