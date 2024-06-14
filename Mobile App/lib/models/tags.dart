class Tag {
  final String name;

  Tag({required this.name});

  factory Tag.fromJson(String json) {
    return Tag(
      name: json,
    );
  }

  String toJson() {
    return name;
  }
}