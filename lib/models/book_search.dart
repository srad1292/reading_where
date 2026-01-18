class BookSearch {
  int page;
  int limit;
  String author;
  String title;
  String subject;

  BookSearch({
      required this.page,
      required this.limit,
      this.author = "",
      this.title = "",
      this.subject = ""
    });
}