import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:ticketing_dapp/controller/contract_linking.dart';
import 'package:ticketing_dapp/model/concert_model.dart';

class InfoConcert extends StatefulWidget {
  final Concert data;
  static const String id = 'info_concert';

  const InfoConcert({Key? key, required this.data}) : super(key: key);

  @override
  _InfoConcertState createState() => _InfoConcertState();
}

class _InfoConcertState extends State<InfoConcert> {
  String _selectedDate = '';

  List<dynamic> isSell = [];

  List<bool> seatSelected = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];
  int seat = -1;

  bool _initialized = false;
  bool _error = false;

  void initializeConcert() async {
    try {
      await getIsSell(isSell, widget.data.id.toString());
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

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      var date = new DateFormat.yMMMd().format(args.value);
      _selectedDate = date.toString();
    });
  }

  final oCcy = new NumberFormat("#,###", "ko_KR");

  String calcStringToWon(String priceString) {
    return "${oCcy.format(int.parse(priceString))}원";
  }

  Widget _priceInfo() {
    return Container(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Price', style: TextStyle(
          fontSize: 23,
        ),),
        Row(children: <Widget>[
          Container(
            width: 25,
            child: Center(child: Text('VIP')), color: Colors.black.withOpacity(0.3),),
          SizedBox(width: 5,),
          Text(calcStringToWon(widget.data.vPrice.toString())),
        ],
        ),
        Row(children: <Widget>[
          Container(
            width: 25,
            child: Center(child: Text('R')), color: Colors.black.withOpacity(0.3),),
          SizedBox(width: 5,),
          Text(calcStringToWon(widget.data.rPrice.toString())),
        ],
        ),
        Row(children: <Widget>[
          Container(
            width: 25,
            child: Center(child: Text('A')), color: Colors.black.withOpacity(0.3),),
          SizedBox(width: 5,),
          Text(calcStringToWon(widget.data.aPrice.toString())),
        ],
        ),
      ],
    ),);
  }

  Widget _seatsInfo(List isSell) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Text('Seats', style: TextStyle(
              fontSize: 23,
            ),
            ),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              width: MediaQuery.of(context).size.width * 0.2,
              color: Colors.black.withOpacity(0.5),
              child: Center(child: Text('무대', style: TextStyle(
                fontWeight: FontWeight.bold,
              ),)),
            ),
          ),
          Container(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return isSell[index] == false ? GestureDetector(
                        onTap: () {
                          setState(() {
                            seatSelected = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];
                            seatSelected[index] = !seatSelected[index];
                            if (seatSelected[index]) {
                              seat = index;
                            } else {
                              seat = -1;
                            }
                          });
                        },
                        child: Container(
                          width: 25,
                          height: 25,
                          color: seatSelected[index] == true ? Color(0xffff6f61) : Colors.transparent,
                          child: Center(child: Text((index + 1).toString()),),
                        ),
                      ) : Container(
                        width: 25,
                        height: 25,
                        color: Colors.black.withOpacity(0.3),
                        child: Center(child: Text((index + 1).toString()),),
                      );
                    }),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      index = index + 4;
                      return isSell[index] == false ? GestureDetector(
                        onTap: () {
                          setState(() {
                            seatSelected = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];
                            seatSelected[index] = !seatSelected[index];
                            if (seatSelected[index]) {
                              seat = index;
                            } else {
                              seat = -1;
                            }
                          });
                        },
                        child: Container(
                          width: 25,
                          height: 25,
                          color: seatSelected[index] == true ? Color(0xffff6f61) : Colors.transparent,
                          child: Center(child: Text((index + 1).toString()),),
                        ),
                      ) : Container(
                        width: 25,
                        height: 25,
                        color: Colors.black.withOpacity(0.3),
                        child: Center(child: Text((index + 1).toString()),),
                      );
                    }),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      index = index + 9;
                      return isSell[index] == false ? GestureDetector(
                        onTap: () {
                          setState(() {
                            seatSelected = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];
                            seatSelected[index] = !seatSelected[index];
                            if (seatSelected[index]) {
                              seat = index;
                            } else {
                              seat = -1;
                            }
                          });
                        },
                        child: Container(
                          width: 25,
                          height: 25,
                          color: seatSelected[index] == true ? Color(0xffff6f61) : Colors.transparent,
                          child: Center(child: Text((index + 1).toString()),),
                        ),
                      ) : Container(
                        width: 25,
                        height: 25,
                        color: Colors.black.withOpacity(0.3),
                        child: Center(child: Text((index + 1).toString()),),
                      );
                    }),
                  ),
                ],
              ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            width: MediaQuery.of(context).size.width,
            child: Text('VIP : 1 ~ 4, R : 5 ~ 9, A : 10 ~ 15',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.end,
            ),
          ),
          Row(
            children: <Widget>[
              Text('선택된 좌석 : ', style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500
              ),),
              SizedBox(width: 5,),
              seat == -1 ? Text('좌석을 선택해주세요.')
                  :
              seat < 4 ? Text('VIP ' + (seat + 1).toString())
                  :
              seat < 9 ? Text('R ' + (seat + 1).toString())
                  :
              Text('A ' + (seat + 1).toString()),
            ],
          )
        ],
      ),
    );
  }

  Widget _concertInfo(List isSell) {
    return Column(
      children: <Widget>[
        Container(
          child: Image.network(
            widget.data.poster,
            width: MediaQuery.of(context).size.width,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                  Text(widget.data.title, style: TextStyle(
                    fontSize: 23,
                  ),),
                  Text(widget.data.time),
                ],),
              ),
              _priceInfo(),
              _seatsInfo(isSell),
            ],
          ),
        ),
      ],
    );
  }

  Widget _calendar() {
    return Column(
      children: <Widget>[
        Container(
          child: SfDateRangePicker(
            onSelectionChanged: _onSelectionChanged,
            selectionMode: DateRangePickerSelectionMode.single,
            initialSelectedRange: PickerDateRange(
                DateTime.now().subtract(const Duration(days: 4)),
                DateTime.now().add(const Duration(days: 3))),
          ),
        ),
        Container(
          child: Text('선택된 날짜: ' + _selectedDate),
        ),
      ],
    );
  }

  Widget _book() {
    return Consumer<ContractLinking>(
      builder: (context, ContractLinking, child) {
        return ElevatedButton(
          onPressed: () async {
            var flag = await buyConcert(ContractLinking, widget.data, seat);

            if(flag == true) {
              showDialog(context: context, builder: (BuildContext context) => AlertDialog(
                title: Text('티켓 구매'),
                content: Text('구매가 완료되었습니다.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                    child: const Text('OK'),
                  ),
                ],
              ),);
            } else if (flag == false) {
              showDialog(context: context, builder: (BuildContext context) => AlertDialog(
                title: Text('티켓 구매'),
                content: Text('이미 선택된 좌석입니다.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),);
            }
          },
          child: Text('구매'),
          style: ElevatedButton.styleFrom(
            primary: Color(0xffff6f61),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      backgroundColor: Color(0xffff6f61),
      elevation: 1,
      title: Text(widget.data.title),
    );
  }

  Widget _bodyWidget(List isSell) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _concertInfo(isSell),
          _calendar(),
          _book(),
        ],
      ),
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
          child: CircularProgressIndicator(
            color: Colors.black.withOpacity(0.3),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _appbarWidget(),
      body: _bodyWidget(isSell),
    );
  }
}

Future<bool> buyConcert(ContractLinking contractLink, Concert data, int seat) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User _user = _auth.currentUser!;

  try {
    await contractLink.buyTicket(new BigInt.from(data.id), new BigInt.from(seat));

    await FirebaseFirestore.instance.collection(_user.uid).doc(data.id.toString()).set({
      seat.toString() : {
        'id': data.id.toString(),
        'title': data.title,
        'time': data.time,
        'seat': seat,
        'poster': data.poster,
      },
    }, SetOptions(merge: true));

    late List<dynamic> tmp;
    await FirebaseFirestore.instance.collection('concerts').where('id', isEqualTo: data.id.toString()).get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> concertData = doc.data()! as Map<String, dynamic>;
        tmp = concertData['isSell'];
      });
    });

    if (tmp[seat]) {
      return Future.value(false);
    } else {
      tmp[seat] = true;
    }

    await FirebaseFirestore.instance.collection('concerts')
        .doc(data.id.toString())
        .update(
      {
        'isSell': tmp,
      }
    );
    return Future.value(true);
  } catch (e) {
    print(e);
    return Future.value(false);
  }
}

Future<void> getIsSell(List<dynamic> isSell, String id) async {
  await FirebaseFirestore.instance.collection('concerts').where('id', isEqualTo: id).get().then((QuerySnapshot querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      Map<String, dynamic> concertData = doc.data()! as Map<String, dynamic>;
      concertData['isSell'].forEach((element) {
        isSell.add(element);
      });
    });
  });
}