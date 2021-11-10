class Ticket {
  final int seat;
  final String time;
  final String title;
  final String poster;
  final String id;

  Ticket.fromMap(Map<String, dynamic> map)
      : title = map['title'],
        seat = map['seat'],
        poster = map['poster'],
        id = map['id'],
        time = map['time'];

  @override
  String toString() {
    return "Movie<$title>";
  }
}