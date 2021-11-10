import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:ticketing_dapp/constants.dart';
import 'package:ticketing_dapp/model/concert_model.dart';
import 'package:ticketing_dapp/screen/info_concert.dart';

class BoxSlider extends StatelessWidget {
   BoxSlider({required this.concerts, required this.title});
  final Set<Concert> concerts;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title),
          SizedBox(height: 10,),
          Material(
            child: CarouselSlider(
              items: makeBoxImages(context, concerts),
              options: CarouselOptions(
                viewportFraction: 0.3,
                enableInfiniteScroll: false,
                initialPage: 1,
                height: 160 // static -> fix later
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<Widget> makeBoxImages(BuildContext context, Set<Concert> concerts) {
  List<Widget> results = [];

  concerts.forEach((concert) {
    results.add(
      Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                    return InfoConcert(data: concert);
                  }));
              // Navigator.pushNamed(context, InfoConcert.id, arguments: {
              //   'title': concert.title,
              //   'poster': concert.poster,
              //   'like' : concert.like,
              //   'kinds': concert.kinds,
              //   'seats': concert.seats,
              //   'time': concert.time,
              //   'id': concert.id,
              //   'vPrice': concert.vPrice,
              //   'rPrice': concert.rPrice,
              //   'aPrice': concert.aPrice,
              // },);
            },
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.network(
                    concert.poster,
                    width: MediaQuery.of(context).size.width * 0.25,
                    fit: BoxFit.fitWidth,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        kIconMap[concert.kinds],
                        size: 15,
                      ),
                      Text(concert.kinds),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  });
  return results;
}
