import 'package:flutter_test/flutter_test.dart';
import 'package:street_sync/models/event.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('Event', () {
    test('fromJson should return a valid Event object', () {
      final json = {
        'id': 1,
        'title': 'Event Title',
        'desc': 'Event Description',
        'tags': ['Tag1', 'Tag2'],
        'dateString': '01/01/2022',
        'date': '2022-01-01T00:00:00.000Z',
        'imageLink': 'http://example.com/image.jpg',
        'owner': 'John D.'
      };

      final event = Event.fromJson(json);

      expect(event.id, 1);
      expect(event.title, 'Event Title');
      expect(event.desc, 'Event Description');
      expect(event.tags?.length, 2);
      expect(event.dateString, '01/01/2022');
      expect(event.date, DateTime.parse('2022-01-01T00:00:00.000Z'));
      expect(event.imageLink, 'http://example.com/image.jpg');
      expect(event.owner, 'John D.');
    });
  });
}
