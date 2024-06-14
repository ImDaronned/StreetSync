import 'package:flutter_test/flutter_test.dart';
import 'package:street_sync/models/comment.dart';

void main() {
  group('Comment', () {
    test('fromJson should return a valid Comment object', () {
      final json = {
        'user': 'John Doe',
        'score': 85,
        'description': 'Great service!'
      };

      final comment = Comment.fromJson(json);

      expect(comment.name, 'John Doe');
      expect(comment.score, 8.5);
      expect(comment.desc, 'Great service!');
    });

    test('toJson should return a valid JSON map', () {
      final comment = Comment(name: 'John Doe', score: 8.5, desc: 'Great service!');

      final json = comment.toJson();

      expect(json['user'], 'John Doe');
      expect(json['score'], 85);
      expect(json['description'], 'Great service!');
    });
  });
}
