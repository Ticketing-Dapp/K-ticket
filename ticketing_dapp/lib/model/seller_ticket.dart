class SellerTicket {
  final String time;
  final String title;
  final String poster;

  SellerTicket.fromMap(Map<String, dynamic> map)
      : title = map['title'],
        poster = map['poster'],
        time = map['time'];

  @override
  String toString() {
    return "Movie<$title>";
  }
}