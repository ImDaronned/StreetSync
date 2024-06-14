import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'package:street_sync/models/services.dart';
import 'package:street_sync/utils/api_endpoints.dart';

class Reservation {
  final String userId;
  final int servicesId;
  final String serviceName;
  final DateTime reservationDay;
  final bool accepted;
  final bool payed;
  final int id;
  final String servicePrice;

  Reservation({
    required this.userId,
    required this.servicesId,
    required this.serviceName,
    required this.reservationDay,
    required this.accepted,
    required this.id,
    required this.servicePrice,
    required this.payed
  });

  static Future<List<Reservation>> generateReservation(String string) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    var url = Uri.parse(ApiEndpoints.endPoints.serviceReserved + string);
    
    http.Response responseService = await http.get(
      url,
      headers: {
        'Authorization': 'martin $token',
        'Content-Type': 'application/json'
      }
    );

    if (responseService.statusCode == 200) {
      final json = jsonDecode(responseService.body);
      List<dynamic> res = json['result'];
      List<Reservation> resultReservation = [];
      List<Services> services = await Services.loadServicesFromPreferences();

      if (string.contains("owner")) {
        for (var r in res) {
          List<dynamic> reservations = r['reservations'];
          for (var reservation in reservations) {
            int servicesId = reservation['services_id'];
            String serviceName = services.firstWhere(
              (service) => service.id == servicesId,
              orElse: () => Services(
                id: 0,
                title: 'Unknown Service',
                desc: '',
                price: 0,
                imageLink: '',
                owner: '',
                score: 0.0,
                comments: [],
              ),
            ).title;
            String servicePrice = services.firstWhere(
            (service) => service.id == servicesId,
            orElse: () => Services(                
              id: 0,
              title: 'Unknown Service',
              desc: '',
              price: 0,
              imageLink: '',
              owner: '',
              score: 0.0,
              comments: [],
            ),
          ).price.toString();

            resultReservation.add(
              Reservation(
                userId: reservation['user_id'],
                servicesId: servicesId,
                serviceName: serviceName,
                reservationDay: DateTime.parse(reservation['reservation_day']),
                accepted: reservation['accepted'],
                id: reservation['id'],
                servicePrice: servicePrice,
                payed: reservation["paid"]
              ),
            );
          }
        }
      } else {
        for (var reservation in res) {
          int servicesId = reservation['services_id'];
          String serviceName = services.firstWhere(
            (service) => service.id == servicesId,
            orElse: () => Services(                
              id: 0,
              title: 'Unknown Service',
              desc: '',
              price: 0,
              imageLink: '',
              owner: '',
              score: 0.0,
              comments: [],
            ),
          ).title;
          String servicePrice = services.firstWhere(
            (service) => service.id == servicesId,
            orElse: () => Services(                
              id: 0,
              title: 'Unknown Service',
              desc: '',
              price: 0,
              imageLink: '',
              owner: '',
              score: 0.0,
              comments: [],
            ),
          ).price.toString();

          resultReservation.add(
            Reservation(
              userId: reservation['user_id'],
              servicesId: servicesId,
              serviceName: serviceName,
              reservationDay: DateTime.parse(reservation['reservation_day']),
              accepted: reservation['accepted'],
              id: reservation['id'],
              servicePrice: servicePrice,
              payed: reservation["paid"]
            ),
          );
        }
      }
      
      return resultReservation;
    } else {
      throw Exception();
    }
  }

  Future<void> acceptReservation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    var url = Uri.parse(ApiEndpoints.endPoints.serviceAccepted);
    
    final Map<String, dynamic> jsonData = {};
    jsonData["reservation_id"] = id;

    await http.post(
      url,
      headers: {
        'Authorization': 'martin $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(jsonData)
    );
  }

  Future<void> declineReservation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    var url = Uri.parse(ApiEndpoints.endPoints.serviceReject);
    
    final Map<String, dynamic> jsonData = {};
    jsonData["reservation_id"] = id;

    await http.post(
      url,
      headers: {
        'Authorization': 'martin $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(jsonData)
    );
  }

  Future<void> payedReservation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    var url = Uri.parse(ApiEndpoints.endPoints.payed);
    
    final Map<String, dynamic> jsonData = {};
    jsonData["reservation_id"] = id;

    await http.post(
      url,
      headers: {
        'Authorization': 'martin $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(jsonData)
    );
  }
}