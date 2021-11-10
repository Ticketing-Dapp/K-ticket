class TradingConcert {
  final String title;
  final String poster;
  final String time;
  final String kinds;
  final int seat;
  final int id;
  final String price;
  final String host;

  TradingConcert.fromMap(Map<String, dynamic> map)
      : title = map['title'],
        poster = map['poster'],
        time = map['time'],
        seat = map['seat'],
        id = map['id'],
        price = map['price'],
        host = map['host'],
        kinds = map['kinds'];

  @override
  String toString() {
    return "Movie<$title>";
  }

}
