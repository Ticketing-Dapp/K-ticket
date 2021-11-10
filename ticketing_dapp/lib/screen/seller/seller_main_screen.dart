import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ticketing_dapp/model/seller_ticket.dart';
import 'package:ticketing_dapp/screen/seller/register/registration_concert.dart';
import 'package:ticketing_dapp/screen/seller/seller_home.dart';
import 'seller_bottom.dart';
import 'package:ticketing_dapp/screen/seller/more/more.dart';

class SellerMainScreen extends StatefulWidget {
  static const String id = 'buyer_main_screen';

  @override
  _SellerMainScreen createState() => _SellerMainScreen();
}

class _SellerMainScreen extends State<SellerMainScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            SellerHome(),
            BottomTabMenu(menu: 'Save'),
            More(),
          ],
        ),
        bottomNavigationBar: SellerBottom(),
      ),
    );
  }
}

class BottomTabMenu extends StatelessWidget {
  BottomTabMenu({required this.menu});
  final String menu;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(menu),
      ),
    );
  }
}
