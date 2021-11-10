import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ticketing_dapp/model/concert_model.dart';
import 'package:ticketing_dapp/widget/box_slider.dart';
import 'package:ticketing_dapp/widget/carousel_slider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Set<Concert> concerts = <Concert>{};

  bool _initialized = false;
  bool _error = false;

  void initializeConcert() async {
    try {
      await getConcerts(concerts);
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      print(e);
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    initializeConcert();
    super.initState();
  }

  Widget _category() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Column(
          children: <Widget>[
            Icon(Icons.music_note_rounded),
            Text('콘서트'),
          ],
        ),
        Column(
          children: <Widget>[
            Icon(Icons.sports_baseball),
            Text('스포츠'),
          ],
        ),
        Column(
          children: <Widget>[
            Icon(Icons.movie_sharp),
            Text('영화'),
          ],
        ),
        Column(
          children: <Widget>[
            Icon(Icons.photo),
            Text('전시/행사'),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if(_error) {
      return Center(
        child: Container(
          child: Text('Something went wrong'),
        ),
      );
    }

    if (!_initialized) {
      return Center(
        child: Container(
          child: Text('Loading'),
        ),
      );
    }

    return ListView(
      children: <Widget>[
        CarouselImage(concerts: concerts),
        SizedBox(height: 30,),
        _category(),
        SizedBox(height: 30,),
        BoxSlider(concerts: concerts, title: '지금 뜨는 콘서트',),
        SizedBox(height: 15,),
        BoxSlider(concerts: concerts, title: '오픈 예정 콘서트'),
      ],
    );
  }
}

Future<bool> getConcerts(Set<Concert> concerts) async {
  await FirebaseFirestore.instance
      .collection('concerts')
      .get()
      .then((QuerySnapshot querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      print(doc.id);
      Map<String, dynamic> concertData = doc.data()! as Map<String, dynamic>;
      Concert tmp = Concert.fromMap({
        'title': concertData['title'],
        'poster': concertData['poster'],
        'like' : false,
        'kinds': '콘서트',
        'seats': concertData['seats'],
        'time': concertData['time'],
        'id': int.parse(doc.id),
        'vPrice': concertData['price']['VIP'],
        'rPrice': concertData['price']['R'],
        'aPrice': concertData['price']['A'],
      });
      concerts.add(tmp);
    });
  });

  return Future.value(true);
}