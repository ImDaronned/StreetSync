class ApiEndpoints {
  static const String baseUrl = 'https://streetsync.azurewebsites.net/';
  // ignore: library_private_types_in_public_api
  static _EndPoints endPoints = _EndPoints();
}

class _EndPoints {
  //Users
  final String register = '${ApiEndpoints.baseUrl}users/signup';
  final String login = '${ApiEndpoints.baseUrl}users/signin';

  //Events
  final String eventsTags = '${ApiEndpoints.baseUrl}events/tags';
  final String createEvent = '${ApiEndpoints.baseUrl}events/createone';
  final String allEvents = '${ApiEndpoints.baseUrl}events/getall';

  //Services
  final String serviceTags = '${ApiEndpoints.baseUrl}services/tags';
  final String allService = '${ApiEndpoints.baseUrl}services/getall';
  final String createService = '${ApiEndpoints.baseUrl}services/createone';
}