import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:street_sync/models/services.dart';

// ignore: must_be_immutable
class ServiceDetailPage extends StatelessWidget {
  
  final Services service;

  const ServiceDetailPage({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('${service.imageLink}'),
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
                      '${service.title}',
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                    ),
                    const Spacer(),
                    const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey,
                      child: Icon(
                        Icons.favorite_outline_rounded,
                        color: Colors.white,
                      ),
                    ),
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
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: service.tags?.length ?? 0,
                  itemBuilder: (context, index) {
                    final tag = service.tags?[index];
                    return SizedBox(
                      width: tag != null ? (tag.name.length * 10).toDouble() : 0,
                      child: ElevatedButton(
                        onPressed: () {},
                        key: Key(tag?.name ?? ''),
                        child: Text(tag?.name ?? ''),
                      ),
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
}