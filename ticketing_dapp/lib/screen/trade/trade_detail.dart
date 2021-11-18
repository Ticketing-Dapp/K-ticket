import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ticketing_dapp/controller/contract_linking.dart';
import 'package:ticketing_dapp/model/trading_concert.dart';

class TradeDetail extends StatefulWidget {
  static const String id = 'trade_detail';
  final TradingConcert data;
  const TradeDetail({Key? key, required this.data}) : super(key: key);

  @override
  _TradeDetailState createState() => _TradeDetailState();
}

class _TradeDetailState extends State<TradeDetail> {
  final oCcy = new NumberFormat("#,###", "ko_KR");

  String calcStringToWon(String priceString) {
    return "${oCcy.format(int.parse(priceString))}원";
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        color: Colors.white,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  Widget _posterWidget() {
    return Hero(
      tag: widget.data.id.toString(),
      child: Image.network(
        widget.data.poster,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.fill,
      ),
    );
  }

  Widget _dividerLineWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Divider(
        height: 1,
        color: Colors.black.withOpacity(0.3),
      ),
    );
  }

  Widget _contentWidget() {
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
                child: Text(widget.data.title),
              ),
            ],
          ),
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
                child: Text(widget.data.time),
              ),
            ],
          ),
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
                child: Text(widget.data.seat.toString()),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                width: 60,
                child: Text('가격', textAlign: TextAlign.end, style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),),
              ),
              SizedBox(width: 15,),
              Container(
                child: Text(calcStringToWon(widget.data.price)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tradeButtonWidget() {
    return Consumer<ContractLinking>(
      builder: (context, ContractLinking, child) {
        return ElevatedButton(
          onPressed: () async {
            var flag = await tradeProcess(widget.data, ContractLinking);
            if(flag == true) {
              showDialog(context: context, builder: (BuildContext context) => AlertDialog(
                title: Text('양도거래'),
                content: Text('거래가 완료되었습니다.'),
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
                content: Text('관리자에게 문의하세요'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),);
            }
          },
          child: Text('신청'),
          style: ElevatedButton.styleFrom(
            primary: Color(0xffff6f61),
          ),
        );
      },
    );
  }

  Widget _bodyWidget() {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            _posterWidget(),
            _dividerLineWidget(),
            _contentWidget(),
            _tradeButtonWidget(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _appbarWidget(),
      body: _bodyWidget(),
    );
  }
}

Future<bool> tradeProcess(TradingConcert data, ContractLinking contractLinking) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User _user = _auth.currentUser!;

  CollectionReference collection = FirebaseFirestore.instance.collection('tradingConcert');

  try {
    await contractLinking.transferTicket(new BigInt.from(data.id), new BigInt.from(data.seat - 1));

    await FirebaseFirestore.instance.collection(_user.uid).doc(data.id.toString()).set({
      data.seat.toString() : {
        'id': data.id.toString(),
        'title': data.title,
        'time': data.time,
        'seat': data.seat,
        'poster': data.poster,
      },
    }, SetOptions(merge: true));

    // trading 목록 삭제
    await collection.doc(data.host).delete()
        .then((value) => print("user's trading list Deleted"))
        .catchError((error) => print("Failed to delete user: $error"));

    await FirebaseFirestore.instance.collection(data.host).doc(data.id.toString()).delete();

    return Future.value(true);
  } catch (e) {
    print(e);
    return Future.value(false);
  }
}