import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ticketing_dapp/model/seller_ticket.dart';
import 'package:ticketing_dapp/screen/seller/register/registration_concert.dart';

class SellerHome extends StatefulWidget {
  static const String id = 'seller_home';
  const SellerHome({Key? key}) : super(key: key);

  @override
  _SellerHomeState createState() => _SellerHomeState();
}

class _SellerHomeState extends State<SellerHome> {
  _loadMyTicket() {
    return getMyTicket();
  }

  _makeTicket(List<SellerTicket> data) {
    return ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              //
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      data[index].poster,
                      width: 100,
                      height: 100,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(data[index].title),
                        Text(data[index].time),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }, separatorBuilder: (BuildContext context, int index) {
      return Container(
        height: 1,
        color: Colors.grey.shade200,
      );
    }, itemCount: data.length);
  }

  Widget _bodyWidget(BuildContext context) {
    return FutureBuilder(
      future: _loadMyTicket(),
      builder: (BuildContext context, dynamic snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          print(snapshot.error);
          return Center(
            child: Text("Data Error"),
          );
        }

        if (snapshot.hasData) {
          print('snapshot data');
          print(snapshot.data);
          return _makeTicket(snapshot.data);
        }

        return Center(
          child: Text("소유중인 티켓이 없습니다."),
        );
      },
    );
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      backgroundColor: Color(0xffff6f61),
      elevation: 1,
      title: Text('공연 등록'),
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20,),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, RegistrationConcert.id);
            },
            child: Icon(
              Icons.add_circle,
              size: 30.0,
            ),
          ),
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbarWidget(),
      body: _bodyWidget(context),
    );
  }
}

Future<List<SellerTicket>> getMyTicket() async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User _user = _auth.currentUser!;

  List<SellerTicket> data = [];

  List<String> ticketNumbers = [];
  try {
    await FirebaseFirestore.instance
        .collection(_user.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            Map<String, dynamic> ticketDatas = doc.data() as Map<String, dynamic>;
            ticketNumbers.add(ticketDatas['id']);
          });
    });
    for(var i = 0; i < ticketNumbers.length; i++) {
      await FirebaseFirestore.instance.collection('concerts')
          .where('id', isEqualTo: i.toString())
          .get()
          .then((QuerySnapshot querySnapshot) {
        Map<String, dynamic> ticketDatas = querySnapshot.docs[0].data() as Map<String, dynamic>;
        SellerTicket tmp = SellerTicket.fromMap({
          'title': ticketDatas['title'],
          'time': ticketDatas['time'],
          'poster': ticketDatas['poster'],
        });
        data.add(tmp);
      });
    }
    print('data');
    print(data);
  } catch (e) {
    print(e);
  }
  return data;
}