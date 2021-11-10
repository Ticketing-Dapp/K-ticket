import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticketing_dapp/controller/auth.dart';
import 'package:ticketing_dapp/controller/contract_linking.dart';
import 'package:ticketing_dapp/model/my_ticket.dart';
import 'package:ticketing_dapp/screen/entrace.dart';
import 'package:ticketing_dapp/screen/login_screen.dart';

class More extends StatefulWidget {
  static const String id = 'more';
  const More({Key? key}) : super(key: key);

  @override
  _MoreState createState() => _MoreState();
}

class _MoreState extends State<More> {
  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      title: Text('마이 페이지'),
      backgroundColor: Color(0xffff6f61),
      elevation: 1,
      actions: [
        _logout(context),
      ],
    );
  }

  _loadMyTicket() {
    return getMyTicket();
  }

  _makeTicket(List<Ticket> data) {
    print(data);
    return Consumer<ContractLinking>(
      builder: (context, ContractLinking, child) {
        return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: GestureDetector(
                  onTap: () async {
                    // var flag = await ContractLinking.checkMyTicket(new BigInt.from(100), new BigInt.from(data[index].seat));
                    var flag = true;
                    if (flag == true) {
                      Navigator.pushNamed(context, Entrance.id, arguments: {
                        'title': data[index].title,
                        'time': data[index].time,
                        'seat': data[index].seat,
                        'id': data[index].id
                      });
                    } else if (flag == false) {
                      showDialog(context: context, builder: (BuildContext context) => AlertDialog(
                        title: Text('티켓'),
                        content: Text('입장이 불가합니다. \n관리자에게 문의해주세요.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                            child: const Text('OK'),
                          ),
                        ],
                      ),);
                    }
                  },
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
      },
    );
  }

  Widget _myTickets(BuildContext context) {
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

  Widget _bodyWidget(BuildContext context) {
    return Column(children: <Widget>[
      Text('My Ticket'),
      Flexible(child: _myTickets(context)),
      ],
    );
  }

  Widget _logout(BuildContext context) {
    return Container(
      child: Center(
        child: InkWell(
          onTap: () {
            signOutUser().whenComplete(() => {
              Navigator.pushNamedAndRemoveUntil(
                  context, LogInScreen.id, (route) => false)
            });
          },
          child: Text('Log Out'),
        ),
      ),
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
  await FirebaseFirestore.instance
      .collection(_user.uid)
      .get()
      .then((QuerySnapshot querySnapshot) {
    Map<String, dynamic> ticketDatas = querySnapshot.docs[0].data() as Map<String, dynamic>;
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

  return data;
}
