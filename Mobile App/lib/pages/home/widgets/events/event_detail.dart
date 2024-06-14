import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:street_sync/models/event.dart';
import 'package:street_sync/pages/navbar.dart';
import 'package:street_sync/utils/api_endpoints.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class EventDetailPage extends StatelessWidget {
  
  final Event event;
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  final DateFormat formatter = DateFormat('dd/MM/yyyy');

  EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('${event.imageLink}'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: 5,
            child: buttonArrow(context),
          ),
          scroll(),
        ],
      ),
    );
  }

  buttonArrow(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        clipBehavior: Clip.hardEdge,
        height: 55,
        width: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.only(
              left: 10
            ),
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: Colors.white,
            ),
          )
        )
      ),
    );
  }

  scroll() {
    DateTime eventDate = event.date;
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 1.0,
      minChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          clipBehavior: Clip.hardEdge,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20
          ),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 25
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 5,
                        width: 35,
                        color: Colors.black12,
                      )
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${event.title}',
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => reserved(context),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.blueAccent.withOpacity(0.1),
                        child: Icon(
                          Icons.favorite_outline_rounded,
                          color: Colors.blueAccent.withOpacity(0.7),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Description',
                  style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                        ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${event.desc}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Date',
                  style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                        ),
                ),
                const SizedBox(height: 10),
                TableCalendar(
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: eventDate,
                  selectedDayPredicate: (day) => isSameDay(event.date, day),
                  calendarFormat: _calendarFormat,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Tags',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: event.tags?.length ?? 0,
                  itemBuilder: (context, index) {
                    final tag = event.tags?[index];
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent.withOpacity(0.1),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.blueAccent.withOpacity(0.5))
                          )
                        ),
                        onPressed: () {},
                        key: Key(tag!.name),
                        child: Text(tag.name, style: TextStyle(color: Colors.blueAccent.withOpacity(0.7)),),
                        );
                      },
                    );
                  }
                )
              ],
            )
          ),     
        );
      }
    );
  }

  void reserved(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    var url = Uri.parse(ApiEndpoints.endPoints.eventsReserved);

    final Map<String, dynamic> jsonData = {};
    jsonData["events_id"] = event.id;

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
      // ignore: use_build_context_synchronously
      showFailureDialog(context);
    }
  }

  void showFailureDialog(BuildContext context) {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed.'),
          actions: <Widget>[
            TextButton(child: const Text('Ok'), onPressed: () {Navigator.of(context).pop();})
          ],
        );
      }
    );
  }
}