import 'dart:convert';

import 'package:street_sync/utils/api_endpoints.dart';
import 'package:street_sync/utils/tags.dart';
import 'package:http/http.dart' as http;

class Services {
  int? id;
  String? title;
  String? desc;
  List<Tag>? tags;
  int? price;
  String? imageLink;
  String? owner;


  Services({this.id, this.title, this.desc, required this.price, this.imageLink, this.tags, this.owner});

  static Future<List<Services>> generateServices() async {
    var url = Uri.parse( ApiEndpoints.endPoints.allService );

    http.Response response = await http.get(url);
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      List<dynamic> services = json['send'];
      List<Services> result = [];

      for (var s in services) { 
        
        result.add(
          Services(
            id: s['id'],
            title: s['Name'],
            desc: s['Description'],
            imageLink: s['Image'],
            tags: (s['Tags'] as List<dynamic>).map(
              (tag) => Tag.fromJson(tag)
            ).toList(),
            owner: s["Owner"],
            price: s['Price']
          )
        );
      }

      return result;
    } else {
      throw Exception('Failed to load event');
    }
  }
}