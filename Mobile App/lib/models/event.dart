import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:street_sync/utils/api_endpoints.dart';
import 'package:street_sync/models/tags.dart';
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

  Event({
    this.id, 
    this.title, 
    this.desc, 
    required this.date, 
    this.dateString, 
    this.imageLink, 
    this.tags, 
    this.owner
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'desc': desc,
    'tags': tags?.map((tag) => tag.toJson()).toList(),
    'dateString': dateString,
    'date': date.toIso8601String(),
    'imageLink': imageLink,
    'owner': owner,
  };

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    id: json['id'],
    title: json['title'],
    desc: json['desc'],
    tags: (json['tags'] as List<dynamic>?)?.map((tag) => Tag.fromJson(tag)).toList(),
    dateString: json['dateString'],
    date: DateTime.parse(json['date']),
    imageLink: json['imageLink'],
    owner: json['owner'],
  );

  static Future<List<Event>> generateEvent(bool mine) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }
    
    var isMine = mine ? "?owner=true" : '';
    var url = Uri.parse(ApiEndpoints.endPoints.events + isMine);

    http.Response response = await http.get(
      url,
      headers: {
        'Authorization': 'martin $token'
      }
    );
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      List<dynamic> events = json['result'];
      List<Event> result = [];

      for (var ev in events) { 
        DateTime dateAPI = DateTime.parse(ev['Date']);
        int day = dateAPI.day;
        int month = dateAPI.month;
        int year = dateAPI.year;

        String formattedDate = '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
        
        String ow = ev["Owner"];
        List<String> names = ow.split(' ');
        String lastName = names[1];
        String firstName = names[0];

        String formattedName = '$firstName ${lastName[0].toUpperCase()}.';

        result.add(
          Event(
            id: ev['id'],
            title: ev['Name'],
            desc: ev['Description'],
            dateString: formattedDate,
            date: DateTime.parse(ev['Date']),
            imageLink: ev['ImageLink'],
            tags: (ev['Tags'] as List<dynamic>).map(
              (tag) => Tag.fromJson(tag)
            ).toList(),
            owner: formattedName
          )
        );
      }

      if(!mine) {
        await prefs.setString('events', jsonEncode(result.map((e) => e.toJson()).toList()));
      }
      return result;
    } else {
      throw Exception('Failed to load event');
    }
  }

  static Future<List<Event>> loadEventsFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? eventsString = prefs.getString('events');

    if (eventsString == null) {
      return [];
    }

    List<dynamic> eventsJson = jsonDecode(eventsString);
    return eventsJson.map((json) => Event.fromJson(json)).toList();
  }
}