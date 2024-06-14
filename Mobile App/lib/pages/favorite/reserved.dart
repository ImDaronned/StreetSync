import 'package:flutter/material.dart';
import 'package:flutter_paypal_checkout/flutter_paypal_checkout.dart';
import 'package:street_sync/models/reservation.dart';
import 'package:street_sync/utils/paypal_data.dart';

class ReservedPage extends StatefulWidget {
  const ReservedPage({super.key});

  @override
  State<ReservedPage> createState() => _ReservedPage();
}

class _ReservedPage extends State<ReservedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _reservationList(),
    );
  }

  Widget _reservationList() {
    return FutureBuilder<List<Reservation>>(
      future: Reservation.generateReservation("?user=registered"),
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if(!reservation.payed)
                          IconButton(
                            icon: const Icon(Icons.monetization_on, color: Colors.blueAccent),
                            onPressed: () async {
                              try {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) =>  PaypalCheckout(
                                    sandboxMode: true,
                                    clientId: PaypalDatas.endPoints.clienId,
                                    secretKey: PaypalDatas.endPoints.clientSecret,
                                    returnURL: "success.snippetcoder.com",
                                    cancelURL: "cancel.snippetcoder.com",
                                    transactions: [
                                      {
                                        "amount": {
                                          "total": reservation.servicePrice,
                                          "currency": "USD",
                                          "details": {
                                            "subtotal":  reservation.servicePrice,
                                            "shipping": '0',
                                            "shipping_discount": 0
                                          }
                                        },
                                        "description": "Desc",
                                        "item_list": {
                                          "items": [
                                            {
                                              "name": reservation.serviceName,
                                              "quantity": "1",
                                              "price": reservation.servicePrice,
                                              "currency": "USD"
                                            }
                                          ]
                                        }
                                      }
                                    ],
                                    note: "Contact us for any questions on your order.",
                                    onSuccess: (Map params) async {
                                      await reservation.payedReservation();
                                    },
                                    onError: (err) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("An error occurred"),
                                            content: Text("Failed: $err"),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text("OK"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    onCancel: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Payment Cancelled"),
                                            content: const Text("You canceled the payment."),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text("OK"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },

                                  )) 
                                );
                                
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