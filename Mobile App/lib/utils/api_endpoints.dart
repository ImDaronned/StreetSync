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
  final String events = '${ApiEndpoints.baseUrl}events';
  final String eventsTags = '${ApiEndpoints.baseUrl}events/tags';
  final String eventsReserved = '${ApiEndpoints.baseUrl}events/reservation';
  

  //Services
  final String services = '${ApiEndpoints.baseUrl}services';
  final String serviceTags = '${ApiEndpoints.baseUrl}services/tags';
  final String serviceReserved = '${ApiEndpoints.baseUrl}services/reservation';
  final String serviceAccepted = '${ApiEndpoints.baseUrl}services/accept';
  final String serviceReject = '${ApiEndpoints.baseUrl}services/reject';
  final String payed = '${ApiEndpoints.baseUrl}services/pay';

  //Users
  final String users = '${ApiEndpoints.baseUrl}users/profile';
}