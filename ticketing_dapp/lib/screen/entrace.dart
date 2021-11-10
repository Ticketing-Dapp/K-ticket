import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Entrance extends StatelessWidget {
  static const String id = 'entrance';

  const Entrance({Key? key}) : super(key: key);

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      elevation: 0,
      iconTheme: IconThemeData(
        color: Colors.black, //change your color here
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _bodyWidget(Map arg, BuildContext context) {
    FirebaseAuth _auth = FirebaseAuth.instance;
    User _user = _auth.currentUser!;

    String qr = 'title_' + arg['title'] + 'time_' + arg['time'] + 'seat_' + arg['seat'].toString() + 'id_' + arg['id'] + 'user_id_' + _user.uid;
    return Container(
      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.2),
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('입장을 위한 QR', style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),),
              SizedBox(width: 3,),
              Text('X', style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),),
              SizedBox(width: 3,),
              Text('K-ticket', style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xffff6f61),
              ),),
          ],
          ),
          SizedBox(height: 10,),
          Container(
            child: QrImage(
            data: qr,
            version: QrVersions.auto,
            size: 250.0,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)!.settings.arguments as Map;
    return Scaffold(
      appBar: _appbarWidget(),
      body: _bodyWidget(arg, context),
    );
  }
}

