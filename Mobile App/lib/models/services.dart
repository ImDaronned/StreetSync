import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:street_sync/utils/api_endpoints.dart';
import 'package:street_sync/models/comment.dart';
import 'package:street_sync/models/tags.dart';
import 'package:http/http.dart' as http;

class Services {
  int? id;
  String title;
  String? desc;
  List<Tag>? tags;
  int? price;
  String imageLink;
  String owner;
  double? score;
  List<Comment> comments;


  Services({
    required this.comments,
    this.id,
    required this.title,
    this.desc,
    required this.price,
    required this.imageLink,
    this.tags,
    required this.owner,
    this.score,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'desc': desc,
    'tags': tags?.map((tag) => tag.toJson()).toList(),
    'price': price,
    'imageLink': imageLink,
    'owner': owner,
    'score': score,
    'comments': comments.map((comment) => comment.toJson()).toList(),
  };

  factory Services.fromJson(Map<String, dynamic> json) => Services(
    id: json['id'],
    title: json['title'],
    desc: json['desc'],
    tags: (json['tags'] as List<dynamic>?)?.map((tag) => Tag.fromJson(tag)).toList(),
    price: json['price'],
    imageLink: json['imageLink'],
    owner: json['owner'],
    score: json['score'] == null ? 0.0 : (json['score'] as num).toDouble(),
    comments: (json['comments'] as List<dynamic>).map((review) => Comment.fromJson(review)).toList(),
  );
  
  static Future<List<Services>> generateServices(bool mine) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    await Future.delayed(const Duration(seconds: 2));

    if (token == null) {
      throw Exception('Token not found');
    }

    var isMine = mine ? "?owner=true" : '';
    var url = Uri.parse(ApiEndpoints.endPoints.services + isMine);

    http.Response responseService = await http.get(
      url,
      headers: {
        'Authorization': 'martin $token',
        'Content-Type': 'application/json'
      }
    );
    
    if (responseService.statusCode == 200) {
      final json = jsonDecode(responseService.body);

      List<dynamic> services = json['result'];
      List<Services> resultService = [];

      for (var s in services) {
        String ow = s["Owner"];
        List<String> names = ow.split(' ');
        String lastName = names[1];
        String firstName = names[0];

        String formattedFirstName = firstName[0].toUpperCase() + firstName.substring(1).toLowerCase();
        String formattedLastName = '${lastName[0].toUpperCase()}.';
        String formattedName = '$formattedFirstName $formattedLastName';
        resultService.add(
          Services(
            id: s['id'],
            title: s['Name'],
            desc: s['Description'],
            imageLink: s['ImageLink'],
            tags: (s['Tags'] as List<dynamic>).map(
              (tag) => Tag.fromJson(tag)
            ).toList(),
            owner: formattedName,
            price: s['Price'],
            score: s['Score'] == null ? 0.0 : (s['Score'] as num).toDouble(),
            comments: (s['Review'] as List<dynamic>).map(
              (review) => Comment.fromJson(review)
            ).toList()
          )
        );
      }

      if(!mine) {
        await prefs.setString('services', jsonEncode(resultService.map((s) => s.toJson()).toList()));
      }
      
      return resultService;
    } else {
      throw Exception('Failed to load service');
    }
  }

  static Future<List<Services>> loadServicesFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? servicesString = prefs.getString('services');

    if (servicesString == null) {
      return [];
    }

    List<dynamic> servicesJson = jsonDecode(servicesString);
    return servicesJson.map((json) => Services.fromJson(json)).toList();
  }
}