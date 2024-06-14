import 'package:flutter_test/flutter_test.dart';
import 'package:street_sync/controllers/validator.dart';

void main() {
  group("Email Validator test", () {
    test("Empty email test", () {
      String result = Validator.emailValidator('');
      expect(result, "Please enter an email");
    });

    test("Valid email test", () {
      String result = Validator.emailValidator('example@example.com');
      expect(result, '');
    });

    test("Invalid email test", () {
      String result = Validator.emailValidator('invalid-email');
      expect(result, "E-Mail is not valid");
    });
  });

   group("Password Validator test", () {
    test("Empty password test", () {
      String result = Validator.passwordValidator('');
      expect(result, "Please enter a password");
    });

    test("Short password test", () {
      String result = Validator.passwordValidator('short');
      expect(result, "Password must be more than 7 characters");
    });

    test("Long password test", () {
      String result = Validator.passwordValidator('longpassword');
      expect(result, '');
    });

  });
  
}
