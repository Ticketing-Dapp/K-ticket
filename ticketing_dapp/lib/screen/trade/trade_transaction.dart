import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticketing_dapp/constants.dart';
import 'package:ticketing_dapp/controller/contract_linking.dart';

class TradeTransaction extends StatefulWidget {
  static const String id = 'trade_transaction';

  @override
  _TradeTransactionState createState() => _TradeTransactionState();
}

class _TradeTransactionState extends State<TradeTransaction> {
  late String price;

  static const IconData ticket = IconData(0xf916,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      backgroundColor: Color(0xffff6f61),
      elevation: 1,
      title: Text('양도거래 등록'),
    );
  }

  Widget _ticketInfo(Map arg) {
    return Container(
      padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.15, 20, MediaQuery.of(context).size.width * 0.15, 30),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                  width: 60,
                  child: Text('콘서트 명', textAlign: TextAlign.end, style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),),
              ),
              SizedBox(width: 15,),
              Container(
                child: Text(arg['title']),
              ),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            children: <Widget>[
              Container(
                width: 60,
                child: Text('날짜', textAlign: TextAlign.end, style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),),
              ),
              SizedBox(width: 15,),
              Container(
                child: Text(arg['time']),
              ),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            children: <Widget>[
              Container(
                width: 60,
                child: Text('좌석', textAlign: TextAlign.end, style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),),
              ),
              SizedBox(width: 15,),
              Container(
                child: Text(arg['seat'].toString()),
              ),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            children: <Widget>[
              Container(
                width: 60,
                height: 30,
                child: Text('가격', textAlign: TextAlign.end, style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),),
              ),
              SizedBox(width: 15,),
              Container(
                width: 180,
                height: 30,
                child: TextField(
                  keyboardType: TextInputType.number,
                onChanged: (value) {
                  price = value;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                  hintText: '가격을 작성해주세요',
                  ),
              ),
              ),
            ],
          ),
        ],
      )
    );
  }

  Widget _tradeButtonWidget(Map arg) {
    return Consumer<ContractLinking>(
      builder: (context, ContractLinking, child) {
        return ElevatedButton(
          onPressed: () async {
            var flag = await uploadTrading(
                  arg['title'],
                  arg['time'],
                  arg['seat'],
                  price,
                  arg['poster'],
                  int.parse(arg['id']),
                  ContractLinking);

            if (flag == true) {
              showDialog(context: context, builder: (BuildContext context) => AlertDialog(
                title: Text('양도거래'),
                content: Text('등록이 완료되었습니다.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                    child: const Text('OK'),
                  ),
                ],
              ),);
            } else if (flag == false) {
              showDialog(context: context, builder: (BuildContext context) => AlertDialog(
                title: Text('양도거래'),
                content: Text('가격이 원가보다 높습니다.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),);
            }
          },
          child: Text('등록'),
          style: ElevatedButton.styleFrom(
            primary: Color(0xffff6f61),
          ),
        );
      }
    );
  }

  Widget _posterWidget(Map arg) {
    return Container(
      child: Image.network(arg['poster']),
    );
  }

  Widget _bodyWidget(Map arg) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _posterWidget(arg),
          _ticketInfo(arg),
          _tradeButtonWidget(arg),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)!.settings.arguments as Map;
    return Scaffold(
      appBar: _appbarWidget(),
      body: _bodyWidget(arg),
    );
  }
}

Future<bool> uploadTrading(String title, String time, int seat, String price, String poster, int id, ContractLinking contractLink) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User _user = _auth.currentUser!;

  print('seat');
  print(seat);
  try {
    await contractLink.setPrice(new BigInt.from(id), new BigInt.from(seat - 1), new BigInt.from(int.parse(price)));

    await FirebaseFirestore.instance.collection('tradingConcert').doc(_user.uid).set({
      id.toString() + " " + seat.toString(): {
        'title': title,
        'time': time,
        'price': price,
        'seat' : seat,
        'poster': poster,
        'id': id,
        'host': _user.uid,
      },
    }, SetOptions(merge: true));
    return Future.value(true);
  } catch (e) {
    print(e);
    return Future.value(false);
  }
}