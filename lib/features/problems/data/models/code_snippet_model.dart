class CodeSnippet {
  final String lang;
  final String langSlug;
  final String code;

  const CodeSnippet({
    required this.lang,
    required this.langSlug,
    required this.code,
  });

  factory CodeSnippet.fromJson(Map<String, dynamic> json) {
    return CodeSnippet(
      lang: json['lang'] as String,
      langSlug: json['langSlug'] as String,
      code: json['code'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'lang': lang,
        'langSlug': langSlug,
        'code': code,
      };
}
