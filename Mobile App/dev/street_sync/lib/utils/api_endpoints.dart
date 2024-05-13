class ApiEndpoints {
  static const String baseUrl = 'https://streetsync.azurewebsites.net/';
  // ignore: library_private_types_in_public_api
  static _AuthEndPoints authEndPoints = _AuthEndPoints();
}

class _AuthEndPoints {
  final String register = 'users/signup';
  final String login = 'users/signin';
}