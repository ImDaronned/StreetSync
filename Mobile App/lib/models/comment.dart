class Comment {
  final String name;
  final double score;
  final String desc;

  Comment({required this.name, required this.score, required this.desc});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      name: json['user'],
      score: (json['score'] as num ).toDouble() /10,
      desc: json['description'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'user': name,
      'score': (score * 10).toInt(),
      'description': desc,
    };
  }
}