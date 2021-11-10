import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:ticketing_dapp/model/concert_model.dart';

class CarouselImage extends StatefulWidget {
  CarouselImage({required this.concerts});
  final Set<Concert> concerts;

  @override
  _CarouselImageState createState() => _CarouselImageState();
}

class _CarouselImageState extends State<CarouselImage> {
  late Set<Concert> concerts;
  late List<Widget> images;
  // late List<String> keywords;
  late List<bool> likes;
  int _currentPage = 0;
  late String _currentKeyword;

  @override
  void initState() {
    super.initState();
    concerts = widget.concerts;
    images =
        concerts.map((m) => Image.network(m.poster)).toList();
    // keywords = concerts.map((m) => m.keyword).toList();
    likes = concerts.map((m) => m.like).toList();
    // _currentKeyword = keywords[0];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CarouselSlider(
        options: CarouselOptions(
          autoPlay: true,
        ),
        items: images,
      ),
    );
  }
}
