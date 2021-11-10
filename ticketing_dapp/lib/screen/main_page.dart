import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticketing_dapp/screen/home_screen.dart';
import 'package:ticketing_dapp/screen/trade/trade_screen.dart';
import 'package:ticketing_dapp/widget/bottom_bar.dart';
import 'more.dart';
import 'package:ticketing_dapp/controller/contract_linking.dart';


class MainPage extends StatefulWidget {
  static const String id = 'main_page';
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      backgroundColor: Colors.blue,
      elevation: 0,
    );
  }

  Widget _bottomWidget() {
    return TabBarView(
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        HomeScreen(),
        TradeScreen(),
        BottomTabMenu(menu: 'Search'),
        More(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        // appBar: _appbarWidget(),
        body: _bottomWidget(),
        bottomNavigationBar: Bottom(),
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
