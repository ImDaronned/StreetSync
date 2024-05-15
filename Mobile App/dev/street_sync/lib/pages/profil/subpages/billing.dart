import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BillingDetailPage extends StatelessWidget {
  const BillingDetailPage({super.key});

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: 
          () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text(
          'Your billing details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Billing',
          style: TextStyle(
            fontSize: 60,
            color: Colors.black
          ),
        ),
      ),
    );
  }
}