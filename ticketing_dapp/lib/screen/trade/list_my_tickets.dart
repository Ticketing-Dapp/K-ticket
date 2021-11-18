import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ticketing_dapp/model/my_ticket.dart';
import 'package:ticketing_dapp/screen/trade/trade_transaction.dart';

class ListofMyTickets extends StatefulWidget {
  static const String id = 'select_ticket';
  const ListofMyTickets({Key? key}) : super(key: key);

  @override
  _ListofMyTicketsState createState() => _ListofMyTicketsState();
}

class _ListofMyTicketsState extends State<ListofMyTickets> {
  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      title: Text('보유중인 티켓'),
      backgroundColor: Color(0xffff6f61),
      elevation: 1,
    );
  }

  _loadMyTicket() {
    return getMyTicket();
  }

  _makeTicket(List<Ticket> data) {
    return ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, TradeTransaction.id, arguments: {
                'title': data[index].title,
                'time': data[index].time,
                'seat': data[index].seat,
                'poster': data[index].poster,
                'id': data[index].id,
              },);
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
                        Text('좌석번호 : ' + data[index].seat.toString()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbarWidget(),
      body: _bodyWidget(context),
    );
  }
}

Future<List<Ticket>> getMyTicket() async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User _user = _auth.currentUser!;

  List<Ticket> data = [];

  try {
    await FirebaseFirestore.instance
        .collection(_user.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            Map<String, dynamic> ticketDatas = doc.data() as Map<String, dynamic>;
            ticketDatas.keys.forEach((element) {
              Ticket tmp = Ticket.fromMap({
                'title': ticketDatas[element]['title'],
                'seat': ticketDatas[element]['seat'] + 1,
                'time': ticketDatas[element]['time'],
                'poster': ticketDatas[element]['poster'],
                'id': ticketDatas[element]['id'].toString(),
              });
              data.add(tmp);
          });
      });
    });
  } catch (e) {
    print(e);
  }

  return data;
}