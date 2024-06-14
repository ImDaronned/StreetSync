import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:street_sync/models/reservation.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotificationPage createState() => _NotificationPage();
}

class _NotificationPage extends State<NotificationPage> {
  

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
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
          List<Reservation> waitingReservations =
              serviceList.where((reservation) => !reservation.accepted).toList();

          if (waitingReservations.isEmpty) {
            return const Center(child: Text('You have no reservations for the moment'));
          } else {
            return ListView.builder(
              itemCount: waitingReservations.length,
              itemBuilder: (context, index) {
                Reservation reservation = waitingReservations[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      reservation.serviceName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${'${reservation.reservationDay.toLocal()}'.split(' ')[0]} at ${'${reservation.reservationDay.toLocal()}'.split(' ')[1].substring(0, 5)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          onPressed: () async {
                            try {
                              await reservation.acceptReservation();

                              setState(() {});
                            } catch (e) {
                              throw Exception('Failed to accept reservation: $e');
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () async {
                            try {
                              await reservation.declineReservation();

                              setState(() {});
                            } catch (e) {
                              throw Exception('Failed to decline reservation: $e');
                            }
                          },
                        ),
                      ],
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