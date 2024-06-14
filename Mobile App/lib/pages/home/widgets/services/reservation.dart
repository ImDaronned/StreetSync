import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:street_sync/models/services.dart';
import 'package:street_sync/pages/navbar.dart';
import 'package:street_sync/utils/api_endpoints.dart';

class Reservation extends StatefulWidget {
  final Services service;

  const Reservation({super.key, required this.service});

  @override
  // ignore: library_private_types_in_public_api
  _ReservationState createState() => _ReservationState();
}

class _ReservationState extends State<Reservation> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      int roundedMinute = (pickedTime.minute / 15).round() * 15;
      if (roundedMinute == 60) {
        roundedMinute = 0;
      }
      setState(() {
        selectedTime = TimeOfDay(hour: pickedTime.hour, minute: roundedMinute);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Reservation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Date:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _pickDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDate == null
                          ? 'Choose Date'
                          : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Time:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _pickTime(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedTime == null
                          ? 'Choose Time'
                          : selectedTime!.format(context),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.access_time),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () => reserved(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, side: BorderSide.none, shape: const StadiumBorder()
                ),
                child: const Text(
                  'Reserve',
                  style: TextStyle(
                    color: Colors.white,
                   fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void reserved() async {

    if (selectedDate != null && selectedTime != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      var url = Uri.parse(ApiEndpoints.endPoints.serviceReserved);

      var formattedDate = DateFormat('20yy-MM-dd').format(selectedDate!);
      var minutesFormatted = selectedTime!.minute.toString().padLeft(2, '0');
      var date = "$formattedDate ${selectedTime!.hour}:$minutesFormatted";

      final Map<String, dynamic> jsonData = {};
      jsonData["date"] = date;
      jsonData["service_id"] = widget.service.id;

      final response = await http.post(
        url,
        headers: {
          'Authorization' : 'name $token',
          'Content-Type' : 'application/json'
        },
        body: jsonEncode(jsonData),
      );

      if(response.statusCode == 200) {
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const NavBarPage()) 
        );
      }
      else {
        final Map<String, dynamic> responseJson = jsonDecode(response.body);
        // ignore: use_build_context_synchronously
        showFailureDialog(context, responseJson["error"]);
      }
    }
  }

  void showFailureDialog(BuildContext context, String err) {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text('Failed: $err'),
          actions: <Widget>[
            TextButton(child: const Text('Ok'), onPressed: () {Navigator.of(context).pop();})
          ],
        );
      }
    );
  }
}
