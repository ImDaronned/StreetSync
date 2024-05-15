import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfil extends StatelessWidget {
  const EditProfil({super.key});

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
          'Update your profil',
          style: TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Center(
                child: Icon(
                  Icons.people_rounded,
                  size: 100,
                ),
              ),
              const SizedBox( height: 30),
              Form(
                child: Column(
                  children: [
                    _textInput(
                      "First Name", 
                      const Icon(Icons.drive_file_rename_outline, color: Colors.black)
                    ),
                    const SizedBox(height: 20,),
                    _textInput(
                      "Last Name", 
                      const Icon(Icons.drive_file_rename_outline, color: Colors.black)
                    ),
                    const SizedBox(height: 20,),
                    _textInput(
                      "E-Mail", 
                      const Icon(Icons.email, color: Colors.black)
                    ),
                    const SizedBox(height: 20,),
                    _textInput(
                      "Password", 
                      const Icon(Icons.password, color: Colors.black)
                    ),
                    const SizedBox(height: 40,),

                    SizedBox(
                      width: 250,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, side: BorderSide.none, shape: const StadiumBorder()
                        ),
                        child: const Text(
                          "Edit Profile", 
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.withOpacity(0.1), 
                            elevation: 0,
                            foregroundColor: Colors.red,
                            shape: const StadiumBorder(),
                            side: BorderSide.none
                          ),
                          child: const Text("Delete Account"),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      )
    );
  }

  Widget _textInput(String label, Icon icon) {
    
    return TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100)
        ),
        prefixIconColor: Colors.black,
        floatingLabelStyle: const TextStyle(color: Colors.black),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: const BorderSide(width: 2, color: Colors.black54)
        ),
        label: Text(label),
        prefixIcon: icon
      ),
    );
  }
}