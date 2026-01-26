class OpenAuthor {

  String authorName;

  OpenAuthor({required this.authorName});

  factory OpenAuthor.fromJson(Map<String, dynamic> json) {
    return OpenAuthor(
      authorName: json['personal_name'] ?? '',
    );
  }


}