import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ticketing_dapp/controller/trade.dart';
import 'package:ticketing_dapp/model/trading_concert.dart';
import 'package:ticketing_dapp/screen/trade/list_my_tickets.dart';
import 'package:ticketing_dapp/screen/trade/trade_detail.dart';
import 'package:ticketing_dapp/screen/trade/trade_search.dart';
import 'package:ticketing_dapp/screen/trade/trade_transaction.dart';

class TradeScreen extends StatefulWidget {
  static const String id = 'trade_screen';

  @override
  _TradeScreenState createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> {
  Map<String, Set<TradingConcert>> data = {
    'total': <TradingConcert>{},
    'concert': <TradingConcert>{},
    'musical': <TradingConcert>{},
  };

  bool _initialized = false;
  bool _error = false;

  void initializeConcert() async {
    try {
      await getTradingConcert(data);
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

  final Map<String, String> typeMap = {
    'total': '전체',
    'concert': '콘서트',
    'musical': '뮤지컬'
  };

  late ContentRepository contentRepository;
  String selectedType = 'total';
  late bool searchFlag;

  @override
  void initState() {
    initializeConcert();
    super.initState();
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      title: GestureDetector(
        onTap: () {},
        child: PopupMenuButton<String>(
          shape: ShapeBorder.lerp(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            1,
          ),
          offset: Offset(0, 20),
          onSelected: (String type) {
            print(type);
            setState(() {
              selectedType = type;
            });
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                child: Text("전체"),
                value: "total",
              ),
              PopupMenuItem(
                child: Text("콘서트"),
                value: "concert",
              ),
              PopupMenuItem(
                child: Text("뮤지컬"),
                value: "musical",
              ),
            ];
          },
          child: Row(
            children: <Widget>[
              Text(typeMap[selectedType].toString()),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
      elevation: 1,
      backgroundColor: Color(0xffff6f61),
      actions: [
        IconButton(
            onPressed: () {
              Navigator.pushNamed(context, TradeSearch.id);
            },
            icon: Icon(Icons.search),
        ),
        IconButton(onPressed: () {
          //
          },
          icon: Icon(Icons.list),
        ),
      ],
    );
  }

  Widget _floatingActionWidget() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          ListofMyTickets.id,
        );
      },
      child: Icon(Icons.mode_sharp),
      backgroundColor: Color(0xffff6f61),
    );
  }

  final oCcy = new NumberFormat("#,###", "ko_KR");

  String calcStringToWon(String priceString) {
    return "${oCcy.format(int.parse(priceString))}원";
  }

  _loadContents() {
    return data[selectedType];
  }

  _makeDataList(List<TradingConcert> data) {
    return ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              print(data[index].title);
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                    return TradeDetail(data: data[index]);
                  }));
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Hero(
                      tag: data[index].id,
                      child: Image.network(
                        data[index].poster,
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            data[index].title,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            data[index].time,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            calcStringToWon(data[index].price),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Container(
            height: 1,
            color: Colors.grey.shade200,
          );
        },
        itemCount: data.length);
  }

  Widget _bodyWidget() {
    var tmp = _loadContents();
    List<TradingConcert> listConcerts = [];
    tmp.forEach((element) {
      listConcerts.add(element);
    });
    return _makeDataList(listConcerts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _floatingActionWidget(),
      appBar: _appbarWidget(),
      body: _bodyWidget(),
    );
  }
}

Future<void> getTradingConcert(Map<String, Set<TradingConcert>> data) async {
  await FirebaseFirestore.instance
      .collection('tradingConcert')
      .get()
      .then((QuerySnapshot querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      Map<String, dynamic> concertData = doc.data()! as Map<String, dynamic>;
      concertData.keys.forEach((seat) {
        TradingConcert tmp = TradingConcert.fromMap({
          'title': concertData[seat]['title'],
          'poster': concertData[seat]['poster'],
          'kinds': '콘서트',
          'id': concertData[seat]['id'],
          'seat': concertData[seat]['seat'],
          'price': concertData[seat]['price'],
          'time': concertData[seat]['time'],
          'host': concertData[seat]['host'],
        });

        data['total']!.add(tmp);
        data['concert']!.add(tmp);
      });
    });
  });
}