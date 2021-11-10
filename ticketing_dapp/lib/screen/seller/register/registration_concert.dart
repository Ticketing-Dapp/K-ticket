import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ticketing_dapp/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:ticketing_dapp/controller/contract_linking.dart';

class RegistrationConcert extends StatefulWidget {
  static const String id = 'registration_concert';

  @override
  _RegistrationConcertState createState() => _RegistrationConcertState();
}

class _RegistrationConcertState extends State<RegistrationConcert> {
  // User
  FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;

  // Calendar
  DateTime currentDate = DateTime.now();
  var concertTime;

  Future<void> _selectDate(BuildContext context) async {
    // DateTime currentDate = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(2021),
        lastDate: DateTime(2050));
    if (pickedDate != null && pickedDate != currentDate)
      setState(() {
        currentDate = pickedDate;
        concertTime = new DateFormat.yMd().format(currentDate);
      });
  }

  // Upload Image
  var imagePicker;
  late File _image;
  late String _imagePath;

  var _controller = TextEditingController();

  bool imageFlag = false;
  var concertName;
  late int nowPrice;
  late int seatsNumber;

  int hour = 0;
  int minute = 0;
  bool amOrPm = true;

  Map<String, int> priceList = {};

  final List<String> _seatList = ['VIP', 'R', 'A'];
  String _selectedValue = 'VIP';

  final oCcy = new NumberFormat("#,###", "ko_KR");

  String calcStringToWon(String priceString) {
    return "${oCcy.format(int.parse(priceString))}원";
  }

  @override
  void initState() {
    super.initState();
    imagePicker = new ImagePicker();
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      title: Text('공연 등록'),
      backgroundColor: Color(0xffff6f61),
      elevation: 1,
    );
  }

  Widget _concertName() {
    return Row(
      children: <Widget>[
        Container(child: Text('공연명'), width: 100,),
        Container(
          width: MediaQuery.of(context).size.width * 0.5,
          child: TextField(
            onChanged: (value) {
              concertName = value;
            },
            decoration: kTextFieldDecoration.copyWith(
              hintText: '공연명을 입력해주세요',
            ),
          ),
        ),
      ],
    );
  }

  Widget _concertDate() {
    return Row(
      children: <Widget>[
        Container(child: Text('공연일자'), width: 70,),
        GestureDetector(
          child: Text(concertTime == null ? 'Click me' : concertTime.toString()),
          onTap: () {
            _selectDate(context);
          },
        ),
        SizedBox(width: 10,),
        SizedBox(
          width: 50,
          height: 50,
          child: TextField(
              style: TextStyle(
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            onChanged: (value) {
                hour = int.parse(value);
            },
            decoration: InputDecoration(
              hintText: '00',
              hintStyle: TextStyle(color: Colors.grey),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xffff6f61), width: 2.0),
              ),
            )
          ),
        ),
        Text(':'),
        SizedBox(
          width: 50,
          height: 50,
          child: TextField(
            style: TextStyle(
              fontSize: 15,
            ),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                minute = int.parse(value);
              },
              decoration: InputDecoration(
                hintText: '00',
                hintStyle: TextStyle(color: Colors.grey),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xffff6f61), width: 2.0),
                ),
              )
          ),
        ),
        SizedBox(width: 10,),
        GestureDetector(
          onTap: () {
            setState(() {
              amOrPm = !amOrPm;
            });
          },
          child: Container(
            child: Text('AM', style: TextStyle(
              color: amOrPm == false ? Colors.black : Colors.black.withOpacity(0.3),
            ),),
          ),
        ),
        Text('/'),
        GestureDetector(
          onTap: () {
            setState(() {
              amOrPm = !amOrPm;
            });
          },
          child: Container(
            child: Text('PM', style: TextStyle(
              color: amOrPm == true ? Colors.black : Colors.black.withOpacity(0.3),
            ),),
          ),
        ),
        GestureDetector(
          onTap: () {
            _selectDate(context);
          },
          child: Container(
            width: 40,
            alignment: Alignment.centerRight,
            child: Text('수정'),
          ),
        ),
      ],
    );
  }

  Widget _concertSetPrice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('가격'),
        DropdownButton(
          value: _selectedValue,
          items: _seatList.map((value) {
            return DropdownMenuItem(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? value) {
            setState(() {
              _selectedValue = value!;
            });
          },
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: TextField(
            keyboardType: TextInputType.number,
            controller: _controller,
            onChanged: (value) {
              nowPrice = int.parse(value);
            },
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'Fill the price',
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Color(0xffff6f61),
          ),
          onPressed: () {
            // 이미 가격을 설정했다면 수정하고, 그게 아니라면 추가함
            _controller.clear();
            setState(() {
              priceList.update(_selectedValue, (value) => nowPrice,
                  ifAbsent: () => nowPrice);
            });
          },
          child: Text('추가'),
        ),
      ],
    );
  }

  Widget _concertGetPrice() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20,),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text("VIP"),
              SizedBox(width: 15,),
              Text(priceList['VIP'] == null ? '' : calcStringToWon(priceList['VIP'].toString())),
            ],
          ),
          Row(
            children: <Widget>[
              Text("R"),
              SizedBox(width: 15,),
              Text(priceList['R'] == null ? '' : calcStringToWon(priceList['R'].toString())),
            ],
          ),
          Row(
            children: <Widget>[
              Text("A"),
              SizedBox(width: 15,),
              Text(priceList['A'] == null ? '' : calcStringToWon(priceList['A'].toString())),
            ],
          ),
        ],
      ),
    );
  }

  Widget _concertPoster() {
    return GestureDetector(
      onTap: () async {
        XFile image = await imagePicker.pickImage(source: ImageSource.gallery);
        setState(() {
          _imagePath = image.path;
          print(_imagePath);
          _image = File(image.path);
          imageFlag = true;
        });
      },
      child: imageFlag == false ? Center(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Icon(
              Icons.photo,
              size: 25,
            ),
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ) : Image.file(_image),
    );
  }

  Widget _concertUpload() {
    return Consumer<ContractLinking>(
      builder: (context, ContractLinking, child) {
        return Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color(0xffff6f61),
            ),
            onPressed: () {
              String date;
              amOrPm == true ?
              date = concertTime + " " + hour.toString() + ":" + minute.toString() + ' PM'
                  :
              date = concertTime + " " + hour.toString() + ":" + minute.toString() + ' AM';
              print(date);
              uploadConcertInfo(concertName, concertTime, priceList, seatsNumber, _image, ContractLinking).then((value) {
                if (value == true) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: Text('공연 등록'),
                      content: Text('등록이 완료되었습니다.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: Text('Upload Error'),
                      content: Text('Sorry, Please reupload concert.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              }).catchError((e) {
                print('콘서트 등록 에러');
                print(e);
              });
            },
            child: Text('등록'),
          ),
        );
      },
    );
  }

  Widget _seatsWidget() {
    return Row(
      children: [
        Container(child: Text('좌석 수'), width: 100,),
        Container(
          width: MediaQuery.of(context).size.width * 0.5,
          child: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              seatsNumber = int.parse(value);
            },
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'set 15',
            ),
          ),
        ),
      ],
    );
  }

  Widget _bodyWidget() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20,),
            _concertPoster(),
            SizedBox(height: 20,),
            _concertName(),
            SizedBox(height: 20,),
            _concertDate(),
            SizedBox(height: 20,),
            _seatsWidget(),
            SizedBox(height: 20,),
            _concertSetPrice(),
            SizedBox(height: 20,),
            _concertGetPrice(),
            SizedBox(height: 20,),
            _concertUpload(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbarWidget(),
      body: _bodyWidget(),
    );
  }
}

Future<bool> uploadConcertInfo(
    String concertName, String time, Map<String, int> price, int seats, File _image, ContractLinking contractLink) async {
  try {
    FirebaseAuth _auth = FirebaseAuth.instance;
    User _user = _auth.currentUser!;

    var concertKey;
    await FirebaseFirestore.instance
        .collection('concerts')
        .get()
        .then((QuerySnapshot querySnapshot) {
          print(querySnapshot.size);
          concertKey = (querySnapshot.size).toString();
      });

    print('concertKey : ' + concertKey);

    contractLink.registerConcert(new BigInt.from(int.parse(concertKey)), new BigInt.from(seats), new BigInt.from(price['VIP']!.toInt()), new BigInt.from(price['R']!.toInt()), new BigInt.from(price['A']!.toInt()));

    Reference storageReference = FirebaseStorage.instance.ref().child('poster/${concertKey}/${concertName}');
    UploadTask uploadTask = storageReference.putFile(_image);

    var imageURL = await (await uploadTask).ref.getDownloadURL();
    print(imageURL);

    List isSell = [];
    for(var i = 0; i < seats; i++) {
      isSell.add(false);
    }

    // key == concertKey
    await FirebaseFirestore.instance.collection('concerts').doc(concertKey).set({
      'title': concertName,
      'time': time,
      'price': price,
      'seats' : seats,
      'id': concertKey,
      'isSell': isSell,
      'poster': imageURL,
    }, SetOptions(merge: true));

    // key == seller's ID
    await FirebaseFirestore.instance.collection(_user.uid).doc(concertKey).set({
      'id': concertKey,
    }, SetOptions(merge: true));

    return Future.value(true);
  } catch (e) {
    print(e);
    return Future.value(false);
  }
}