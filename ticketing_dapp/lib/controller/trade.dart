import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ticketing_dapp/model/trading_concert.dart';

class ContentRepository {

  Map<String, Set<TradingConcert>> test_data = {
    'total': <TradingConcert>{},
    'concert': <TradingConcert>{},
    'musical': <TradingConcert>{},
  };


  Future<Set<TradingConcert>?> loadContentsByType(String type) async {
    await FirebaseFirestore.instance
        .collection('tradingConcert')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> concertData = doc.data()! as Map<String, dynamic>;
        TradingConcert tmp = TradingConcert.fromMap({
          'title': concertData['title'],
          'poster': concertData['poster'],
          'kinds': '콘서트',
          'id': concertData['id'],
          'seat': concertData['seat'],
          'price': concertData['price'],
          'time': concertData['time'],
          'host': concertData['host'],
        });

        test_data['total']!.add(tmp);
        test_data['concert']!.add(tmp);
      });
    });

    await Future.delayed(Duration(milliseconds: 1000));
    return test_data[type];
  }

}
