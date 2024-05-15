import 'dart:convert';

import 'package:street_sync/utils/api_endpoints.dart';
import 'package:street_sync/utils/tags.dart';
import 'package:http/http.dart' as http;

class Event {
  int? id;
  String? title;
  String? desc;
  List<Tag>? tags;
  String? dateString;
  DateTime date;
  String? imageLink;
  String? owner;


  Event({this.id, this.title, this.desc, required this.date, this.dateString, this.imageLink, this.tags, this.owner});

  static Future<List<Event>> generateEvent() async {
    var url = Uri.parse( ApiEndpoints.endPoints.allEvents );

    http.Response response = await http.get(url);
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      List<dynamic> events = json['send'];
      List<Event> result = [];

      for (var ev in events) { 
        DateTime dateAPI = DateTime.parse(ev['Date']);
        int day = dateAPI.day;
        int month = dateAPI.month;
        int year = dateAPI.year;

        String formattedDate = '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
        
        result.add(
          Event(
            id: ev['id'],
            title: ev['Name'],
            desc: ev['Description'],
            dateString: formattedDate,
            date: DateTime.parse(ev['Date']),
            imageLink: ev['Image'],
            tags: (ev['Tags'] as List<dynamic>).map(
              (tag) => Tag.fromJson(tag)
            ).toList(),
            owner: ev["Owner"]
          )
        );
      }

      return result;
    } else {
      throw Exception('Failed to load event');
    }
  }
}

//27:24