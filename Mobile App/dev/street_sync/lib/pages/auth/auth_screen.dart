// ignore: file_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:street_sync/controllers/login_controller.dart';
import 'package:street_sync/controllers/registration_controller.dart';
import 'package:street_sync/pages/auth/widget/input_fields.dart';
import 'package:street_sync/pages/auth/widget/submit_button.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  RegistrationController registrationController =
  Get.put(RegistrationController());

  LoginController loginController =
  Get.put(LoginController());

  var isLogin = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Center(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox( height: 30),
                  const Icon(
                    Icons.lock,
                    size: 100,
                  ),
                  const SizedBox( height: 30),
                  Text(
                    'Welcome back, you\'ve missed',
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          color: !isLogin.value ? Colors.black : Colors.grey.shade200,
                          onPressed: () {
                            isLogin.value = false;
                          },
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                          ),
                          child: Text('Register', style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: !isLogin.value ? Colors.white : Colors.black,
                            ),
                          )
                        ),
                        MaterialButton(
                          color: !isLogin.value ? Colors.grey.shade200 : Colors.black,
                          onPressed: () {
                            isLogin.value = true;
                          },
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: Text('Log in', style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: !isLogin.value ? Colors.black : Colors.white,
                            ),
                          )
                        ),
                      ],
                    ),
                  const SizedBox(height: 80),
                  isLogin.value ? loginWidget() : registerWidget()
                ],
              )
            ),
          ),
        ),
      )
    );
  }

  Widget registerWidget() {
    return Column(
      children: [
        InputTextFieldWidget(registrationController.firstNameController, 'Fist Name', false),
        const SizedBox(height: 10),
        InputTextFieldWidget(registrationController.nameController, 'Last Name', false),
        const SizedBox(height: 10),
        InputTextFieldWidget(registrationController.emailController, 'E-Mail', false),
        const SizedBox(height: 10),
        InputTextFieldWidget(registrationController.passwordController, 'Password', true),
        const SizedBox(height: 50),
        SubmitButton(
            onPressed: () => registrationController.register(),
            title: 'Register'
        ),
      ],
    );
  }

  Widget loginWidget() {
    return Column(
      children: [
        InputTextFieldWidget(loginController.emailController, 'E-mail', false),
        const SizedBox(height: 10),
        InputTextFieldWidget(loginController.passwordController, 'Password', true),
        const SizedBox(height: 50),
        SubmitButton(
            onPressed: () => loginController.login(),
            title: 'Login'
        ),
      ],
    );
  }
}
