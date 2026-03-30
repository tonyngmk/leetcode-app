class TopicTag {
  final String name;
  final String slug;

  const TopicTag({required this.name, required this.slug});

  factory TopicTag.fromJson(Map<String, dynamic> json) {
    return TopicTag(
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'slug': slug};
}
