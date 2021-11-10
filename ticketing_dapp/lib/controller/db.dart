import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseAuth _auth = FirebaseAuth.instance;
User _user = _auth.currentUser!;

Future<bool> uploadConcertInfo(String concertName, DateTime time, Map<String, int> price, int theater) async {
  try {
    FirebaseAuth _auth = FirebaseAuth.instance;
    User _user = _auth.currentUser!;

    Map<String, dynamic> data = {
      'time': time,
      'price': price,
      'theater' : theater,
    };

    var concertKey;
    await FirebaseFirestore.instance
        .collection('concerts')
        .get()
        .then((QuerySnapshot querySnapshot) {
      print(querySnapshot.size);
      concertKey = (querySnapshot.size).toString();
    });

    print('concertKey : ' + concertKey);

    // key == concertKey
    FirebaseFirestore.instance.collection('concerts').doc(concertKey).set({
      concertName: data,
    }, SetOptions(merge: true));

    // key == seller's ID
    FirebaseFirestore.instance.collection(_user.uid).doc(concertKey).set({
      concertKey: concertKey,
    }, SetOptions(merge: true));

    return Future.value(true);
  } catch (e) {
    print(e);
    return Future.value(false);
  }
}
