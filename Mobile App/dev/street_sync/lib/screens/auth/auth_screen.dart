import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:street_sync/controllers/login_controller.dart';
import 'package:street_sync/controllers/registration_controller.dart';
import 'package:street_sync/screens/auth/widget/input_fields.dart';
import 'package:street_sync/screens/auth/widget/submit_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  RegistrationController registrationController =
  Get.put(RegistrationController());

  LoginController loginController = 
  Get.put(LoginController());

  var isLogin = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
              Color(0xFFB81736),
              Color(0xFF281537),
            ])),
            child: const Padding(
              padding: EdgeInsets.only(top: 60.0, left: 22.0),
              child: Text(
                'Hello,\nSign in!',
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
              height: double.infinity,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isLogin.value ? loginWidget() : registerWidget(),
                      ]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget registerWidget() {
    return Column(
      children: [
        InputTextFieldWidget(registrationController.firstNameController, 'Fist Name'),
        const SizedBox(height: 10),
        InputTextFieldWidget(registrationController.nameController, 'Last Name'),
        const SizedBox(height: 10),
        InputTextFieldWidget(registrationController.emailController, 'E-Mail'),
        const SizedBox(height: 10),
        InputTextFieldWidget(registrationController.passwordController, 'Password'),
        SubmitButton(
          onPressed: () => registrationController.register(),
          title: 'Register'
        ),
        const SizedBox(height: 10,),
        Align(
          alignment: Alignment.bottomRight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text("Don't have an account ?"),
              MaterialButton(
                onPressed: () => isLogin.value = !isLogin.value,
                child: const Text('Sign Up / Login')
              )    
            ],
          ),
        )
      ],
    );
  }

  Widget loginWidget() {
    return Column(
      children: [
        InputTextFieldWidget(loginController.emailController, 'E-mail'),
        const SizedBox(height: 10),
        InputTextFieldWidget(loginController.passwordController, 'Password'),
        const SizedBox(height: 50),
        SubmitButton(
          onPressed: () => loginController.login(),
          title: 'Login'
        ),
        const SizedBox(height: 100),
        Align(
          alignment: Alignment.bottomRight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text("Don't have an account ?"),
              MaterialButton(
                onPressed: () => isLogin.value = !isLogin.value,
                child: const Text('Sign Up / Login')
              )    
            ],
          ),
        )
      ],
    );
  }
}

/*
  Padding(
          padding: EdgeInsets.all(36),
          child: Center(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox( height: 30),
                  Container(
                    child: const Text(
                      'WELCOME',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.w400
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MaterialButton(
                        color: !isLogin.value ? Colors.white : Colors.amber,
                        onPressed: () {
                          isLogin.value = !isLogin.value;
                        },
                        child: const Text('Login')
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


    Obx ( () => Scaffold(
      body: Stack(
        children:[ 
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFB81736),
                  Color(0xFF281537),
                ]
              )
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: 60.0, left: 22.0),
              child: Text('Hello,\nSign in!', style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.bold
              ),),
            )
          ),
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40)
                )
              ),
              height: double.infinity,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isLogin.value ? loginWidget() : registerWidget(), 
                  ]
                )
              ),
            )
          ),
        ]
      ),)
    );
  }
*/
