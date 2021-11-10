class Concert {
  final String title;
  final String poster;
  final bool like;
  final String kinds;
  final int seats;
  final int id;
  final String time;
  final int vPrice;
  final int rPrice;
  final int aPrice;

  Concert.fromMap(Map<String, dynamic> map)
      : title = map['title'],
        poster = map['poster'],
        like = map['like'],
        seats = map['seats'],
        id = map['id'],
        time = map['time'],
        vPrice = map['vPrice'],
        rPrice = map['rPrice'],
        aPrice = map['aPrice'],
        kinds = map['kinds'];

  @override
  String toString() {
    return "Movie<$title>";
  }
}
