import 'package:flutter_test/flutter_test.dart';
import 'package:street_sync/models/services.dart';

void main() {
  group('Services', () {
    test('fromJson should return a valid Services object', () {
      final json = {
        'id': 1,
        'title': 'Service Title',
        'desc': 'Service Description',
        'tags': ['Tag1', 'Tag2'],
        'price': 100,
        'imageLink': 'http://example.com/image.jpg',
        'owner': 'John D.',
        'score': 4.5,
        'comments': [
          {
            'user': 'Jane Doe',
            'score': 90,
            'description': 'Excellent!'
          }
        ]
      };

      final service = Services.fromJson(json);

      expect(service.id, 1);
      expect(service.title, 'Service Title');
      expect(service.desc, 'Service Description');
      expect(service.tags?.length, 2);
      expect(service.price, 100);
      expect(service.imageLink, 'http://example.com/image.jpg');
      expect(service.owner, 'John D.');
      expect(service.score, 4.5);
      expect(service.comments.length, 1);
      expect(service.comments[0].name, 'Jane Doe');
    });
  });
}
