import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:street_sync/models/services.dart';
import 'package:street_sync/pages/home/widgets/services/reservation.dart';

// ignore: must_be_immutable
class ServiceDetailPage extends StatelessWidget {
  
  final Services service;

  const ServiceDetailPage({super.key, required this.service});

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
                  image: NetworkImage(service.imageLink),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 30,
                left: 5
              ),
              child: buttonArrow(context), 
            ),
            scroll(),
          ],
        )
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
                      service.title,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => Reservation(service: service,))
                        );
                      },
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.greenAccent.withOpacity(0.2),
                        child: Icon(
                          Icons.favorite_outline_rounded,
                          color: Colors.green.withOpacity(0.7),
                        ),
                      ),
                    )
                  ],
                ),
                Text(
                  '${service.price} EUR',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                        "${service.score}",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.amber,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    const Icon(Icons.star, color: Colors.amber, size: 20,)
                  ],
                ),
                const SizedBox(height: 10,),
                Text(
                  '${service.desc}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey
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
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: service.tags?.length ?? 0,
                  itemBuilder: (context, index) {
                    final tag = service.tags?[index];
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent.withOpacity(0.1),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.greenAccent.withOpacity(0.5))
                          )
                        ),
                        onPressed: () {},
                        key: Key(tag!.name),
                        child: Text(tag.name, style: TextStyle(color: Colors.green.withOpacity(0.7)),),
                        );
                      },
                    );
                  }
                ),
                const SizedBox(height: 30,),
                const Text(
                  'Reviews',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
                const SizedBox(height: 10,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: service.comments.isEmpty ?
                  [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "No comments",
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    )
                  ] :
                  service.comments.map((comment) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey.shade200,
                            child: Text(
                              comment.name[0], 
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      comment.name,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          comment.score.toString(),
                                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  comment.desc,
                                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            )
          ),     
        );
      }
    );
  }
}