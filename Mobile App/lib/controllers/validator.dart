class Validator {
  static String emailValidator(final String value) {

    if(value.trim().isEmpty) return "Please enter an email";

    RegExp emailPattern = RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        caseSensitive: false,
        multiLine: false,
      );

    if(!emailPattern.hasMatch(value)) return "E-Mail is not valid";

    return '';
  }

  static String passwordValidator (final String value) {
    String message = "";

    if(value.trim().isEmpty) message = "Please enter a password";

    if(value.trim().isNotEmpty && value.length < 8) message = "Password must be more than 7 characters";

    return message;
  }
}